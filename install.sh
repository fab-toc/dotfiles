#!/bin/sh
# Installer, and its own entry point.
#
# POSIX sh, not bash: this file is meant to be run as `curl … | sh`, and
# Debian's /bin/sh is dash. Piped, it has no repository to work from, so it
# clones one and re-execs itself from the clone. Run from a checkout, it uses
# whatever directory it is sitting in — the location is yours to choose, but it
# is fixed once chosen, because stow encodes it into every symlink.
#
# Reads tools.json, installs each selected tool from the source named for this
# distribution, stows the modules that have one, and ends with a report of
# everything still outstanding. The report is the only thing standing in for a
# test suite — see docs/adr/0007-testing-deferred.md

set -eu

REPO_URL="https://github.com/fab-toc/dotfiles.git"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
STATE="$STATE_DIR/state"

# Accumulators for the closing report. POSIX sh has no arrays; newline-
# separated strings are the honest substitute.
REPORT_MANUAL=""
REPORT_UNSUPPORTED=""
REPORT_DOCS=""
REPORT_BACKUPS=""
REPORT_FAILED=""
EXIT_CODE=0

# Tools whose row asks for SSH keys contribute to this list only when they are
# actually selected, so installing one module never asks about another's keys.
REQUIRED_KEYS=""
SELECTED_GIT="no"
SELECTED_MODULES=""

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

if [ -t 1 ]; then
	B="$(printf '\033[1m')"
	R="$(printf '\033[0m')"
	RED="$(printf '\033[1;31m')"
	YEL="$(printf '\033[1;33m')"
	GRN="$(printf '\033[1;32m')"
	DIM="$(printf '\033[2m')"
else
	B=""
	R=""
	RED=""
	YEL=""
	GRN=""
	DIM=""
fi

info() { printf '%s==>%s %s\n' "$B" "$R" "$1"; }
warn() { printf '%swarning:%s %s\n' "$YEL" "$R" "$1" >&2; }
die() {
	printf '%serror:%s %s\n' "$RED" "$R" "$1" >&2
	exit 1
}

append() {
	# append VAR_CONTENTS LINE -> prints the new contents
	if [ -z "$1" ]; then printf '%s' "$2"; else printf '%s\n%s' "$1" "$2"; fi
}

# ---------------------------------------------------------------------------
# Selection
# ---------------------------------------------------------------------------
# Named tools are installed and their modules linked; nothing else is touched.
# With no arguments, the manifest's defaults decide. $DOTFILES_MODULES exists
# because `curl … | sh` cannot take arguments without `sh -s --`, which is
# obscure enough that people get it wrong.

SELECTION="${DOTFILES_MODULES:-}"
for arg in "$@"; do
	case "$arg" in
	-*) die "Unknown option: $arg" ;;
	*) SELECTION="$SELECTION $arg" ;;
	esac
done
SELECTION="${SELECTION# }"

# ---------------------------------------------------------------------------
# Finding the repository
# ---------------------------------------------------------------------------
# Piped, $0 is `sh` or `-` and there is nothing to install from; from a
# checkout, $0 resolves to a directory holding the manifest. That difference is
# the whole test. See docs/adr/0002-stow-contract.md

HERE=""
if [ -n "${0:-}" ] && [ -f "$0" ]; then
	HERE="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
	[ -f "$HERE/tools.json" ] && [ -d "$HERE/modules" ] || HERE=""
fi

if [ -n "$HERE" ]; then
	DOTFILES="$HERE"
else
	# No checkout: clone one and hand over to the copy on disk. Everything
	# after this point assumes a repository it can read.
	DOTFILES="${DOTFILES_DIR:-$HOME/.dotfiles}"
	command -v git >/dev/null 2>&1 ||
		die "git is required to clone the repository. Install git, then run this again."

	if [ -e "$DOTFILES" ]; then
		[ -d "$DOTFILES/.git" ] ||
			die "$DOTFILES exists but is not a git repository. Move it aside, or set \$DOTFILES_DIR."
		info "Updating existing clone at $DOTFILES"
		git -C "$DOTFILES" pull --ff-only
	else
		info "Cloning into $DOTFILES"
		git clone "$REPO_URL" "$DOTFILES"
	fi

	[ -f "$DOTFILES/install.sh" ] ||
		die "$DOTFILES/install.sh is missing; the clone looks incomplete."

	DOTFILES_MODULES="$SELECTION" exec sh "$DOTFILES/install.sh"
fi

MANIFEST="$DOTFILES/tools.json"
[ -f "$MANIFEST" ] || die "Manifest not found at $MANIFEST"
info "Repository: ${B}${DOTFILES}${R}"

# ---------------------------------------------------------------------------
# Distribution
# ---------------------------------------------------------------------------
# The installer is the one place that may ask what distribution this is: it
# picks which *manifest column* to read. Configuration files never do this.

if command -v pacman >/dev/null 2>&1; then
	COLUMN="arch"
elif command -v apt-get >/dev/null 2>&1; then
	COLUMN="debian"
else
	die "Unsupported distribution: neither pacman nor apt-get was found."
fi
info "Distribution column: ${B}${COLUMN}${R}"

# ---------------------------------------------------------------------------
# Machine state
# ---------------------------------------------------------------------------
# Which tools this machine selected, and whether it is headless. Kept in
# $XDG_STATE_HOME so `git clean -xdf` in the repository cannot destroy it.

mkdir -p "$STATE_DIR"
[ -f "$STATE" ] || : >"$STATE"

state_get() {
	# state_get KEY -> value, empty if unset
	awk -F'\t' -v k="$1" '$1 == k { print $2; exit }' "$STATE"
}

state_set() {
	# state_set KEY VALUE
	tmp="$STATE.tmp"
	awk -F'\t' -v k="$1" '$1 != k' "$STATE" >"$tmp"
	printf '%s\t%s\n' "$1" "$2" >>"$tmp"
	mv "$tmp" "$STATE"
}

# The location is free but not movable: every symlink stow made encodes the
# absolute path it was made from. Running from a second location would leave the
# first one's links behind, dangling and unowned, so it is refused while the old
# directory is still there to unstow from. If it is gone, the links are already
# broken and there is nothing left to clean up, so the new path is adopted with
# a warning. See docs/adr/0002-stow-contract.md
RECORDED_PATH="$(state_get dotfiles.path)"
if [ -n "$RECORDED_PATH" ] && [ "$RECORDED_PATH" != "$DOTFILES" ]; then
	if [ -d "$RECORDED_PATH" ]; then
		die "This machine's modules are linked from $RECORDED_PATH.
  Unstow there first (see the README), or delete the dotfiles.path line in $STATE."
	fi
	warn "$RECORDED_PATH is gone; any links it made are already broken. Adopting $DOTFILES."
fi
state_set dotfiles.path "$DOTFILES"

HEADLESS="$(state_get headless)"
if [ -z "$HEADLESS" ]; then
	# Declared, never detected. A machine with a display today may be
	# administered over ssh tomorrow; guessing would flip-flop.
	printf 'Is this machine headless (no graphical session)? [y/N] '
	read -r answer </dev/tty || answer="n"
	case "$answer" in
	[Yy]*) HEADLESS="yes" ;;
	*) HEADLESS="no" ;;
	esac
	state_set headless "$HEADLESS"
fi
info "Headless: ${B}${HEADLESS}${R}"

# ---------------------------------------------------------------------------
# Package manager front ends
# ---------------------------------------------------------------------------

pkg_installed() {
	case "$COLUMN" in
	arch) pacman -Qq "$1" >/dev/null 2>&1 ;;
	debian) dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q '^install ok installed$' ;;
	esac
}

pkg_install() {
	case "$COLUMN" in
	arch)
		if command -v yay >/dev/null 2>&1; then
			yay -S --needed --noconfirm "$1"
		else
			sudo pacman -S --needed --noconfirm "$1"
		fi
		;;
	debian) sudo apt-get install -y "$1" ;;
	esac
}

# yay is bootstrapped from base-devel and makepkg. It is a clone and a local
# build, but it ends in a pacman-registered package, so it counts as native.
# The installer never depends on yay for its own work — only for AUR rows.
bootstrap_yay() {
	command -v yay >/dev/null 2>&1 && return 0
	info "Bootstrapping yay from the AUR"
	sudo pacman -S --needed --noconfirm base-devel git
	tmp="$(mktemp -d)"
	git clone https://aur.archlinux.org/yay.git "$tmp/yay"
	(cd "$tmp/yay" && makepkg -si --noconfirm)
	rm -rf "$tmp"
}

# jq reads the manifest, so it is installed before the manifest can be read.
# Its package name is the one thing that cannot come from the manifest without
# a chicken-and-egg problem, so it is hardcoded here — and nowhere else.
# See docs/adr/0006-manifest-as-json.md
bootstrap_jq() {
	command -v jq >/dev/null 2>&1 && return 0
	info "Installing jq, which is needed to read the manifest"
	pkg_install jq || die "jq could not be installed, so $MANIFEST cannot be read."
}

# mise is the second rung on Debian and Ubuntu, installed from its own apt
# repository — never by curl-piping its installer.
# See docs/adr/0001-tool-source-ladder.md
bootstrap_mise() {
	command -v mise >/dev/null 2>&1 && return 0
	info "Bootstrapping mise from its apt repository"
	sudo apt-get install -y extrepo
	sudo extrepo enable mise
	sudo apt-get update
	sudo apt-get install -y mise
}

# ---------------------------------------------------------------------------
# The manifest loop
# ---------------------------------------------------------------------------

install_tool() {
	tool="$1"
	source="$2"

	case "$source" in
	excluded)
		# Working as intended. Deliberately not reported.
		return 0
		;;
	unsupported)
		REPORT_UNSUPPORTED="$(append "$REPORT_UNSUPPORTED" "$tool")"
		return 0
		;;
	manual)
		REPORT_MANUAL="$(append "$REPORT_MANUAL" "$tool")"
		return 0
		;;
	mise)
		bootstrap_mise
		if mise use -g "$tool" >/dev/null 2>&1; then
			return 0
		fi
		warn "mise could not install $tool"
		REPORT_FAILED="$(append "$REPORT_FAILED" "$tool (mise)")"
		return 1
		;;
	*)
		if pkg_installed "$source"; then
			printf '%s  %s already installed%s\n' "$DIM" "$tool" "$R"
			return 0
		fi
		if pkg_install "$source"; then
			return 0
		fi
		warn "failed to install $tool ($source)"
		REPORT_FAILED="$(append "$REPORT_FAILED" "$tool ($source)")"
		return 1
		;;
	esac
}

bootstrap_jq

# A named tool brings along the tools its configuration integrates with: asking
# for the zsh module and getting a prompt-less, completion-less zsh would be a
# surprise. The list is the manifest's `with` field, one level deep only.
EXPANDED=""
for want in $SELECTION; do
	jq -e --arg t "$want" 'has($t)' "$MANIFEST" >/dev/null ||
		die "No tool called '$want' in the manifest."
	EXPANDED="$EXPANDED $want $(jq -r --arg t "$want" '.[$t].with // [] | join(" ")' "$MANIFEST")"
done

selected_by_argument() {
	# selected_by_argument TOOL -> true when TOOL was named or brought along
	case " $EXPANDED " in
	*" $1 "*) return 0 ;;
	*) return 1 ;;
	esac
}

info "Reading $MANIFEST"

# jq flattens the manifest to one tab-separated line per tool, so the loop below
# stays the plain `read` it always was. Only the column for this distribution is
# emitted; `note` is never read — it exists for humans reading the file on
# GitHub. jq preserves the manifest's key order, so yay still comes before the
# AUR rows that need it.
ROWS="$(mktemp)"
trap 'rm -f "$ROWS"' EXIT INT TERM
jq -r --arg col "$COLUMN" '
	to_entries[]
	| [ .key,
	    .value[$col],
	    .value.kind,
	    (if .value.default then "yes" else "no" end),
	    (.value.requires_keys // [] | join(" "))
	  ]
	| @tsv
' "$MANIFEST" >"$ROWS" || die "$MANIFEST is not valid JSON, or is missing a field."

# The manifest is data read once; the loop below is where every decision about
# it is made.
while IFS="$(printf '\t')" read -r tool source kind default keys; do
	[ -z "$tool" ] && continue

	# Graphical tools are skipped on a machine declared headless.
	if [ "$kind" = "gui" ] && [ "$HEADLESS" = "yes" ]; then
		continue
	fi

	if [ -n "$SELECTION" ]; then
		# An argument is a one-off answer, not a new default: it decides this
		# run only, and leaves what the machine remembers alone.
		selected_by_argument "$tool" || continue
	else
		# Selection is remembered, so a re-run asks nothing.
		selected="$(state_get "tool.$tool")"
		if [ -z "$selected" ]; then
			selected="$default"
			state_set "tool.$tool" "$selected"
		fi
		[ "$selected" = "yes" ] || continue
	fi

	# Only selected modules are linked. A module whose tool was not selected is
	# configuration for something this machine does not have.
	[ -d "$DOTFILES/modules/$tool" ] &&
		SELECTED_MODULES="$(append "$SELECTED_MODULES" "$tool")"

	# Only a selected tool's keys are ever asked about.
	for key in $keys; do
		REQUIRED_KEYS="$(append "$REQUIRED_KEYS" "$key")"
	done
	[ "$tool" = "git" ] && SELECTED_GIT="yes"

	# jq is already installed above; its row is documentary.
	[ "$tool" = "jq" ] && continue

	# yay is itself a row, and it is what installs AUR rows, so it comes first.
	if [ "$tool" = "yay" ] && [ "$COLUMN" = "arch" ]; then
		bootstrap_yay || REPORT_FAILED="$(append "$REPORT_FAILED" "yay")"
		continue
	fi
	# mise's row is documentary: on Debian the bootstrap above installs it, on
	# Arch it is `manual` by policy. See docs/adr/0008-*.md
	if [ "$tool" = "mise" ]; then
		[ "$COLUMN" = "debian" ] && bootstrap_mise
		[ "$source" = "manual" ] && REPORT_MANUAL="$(append "$REPORT_MANUAL" "$tool")"
		continue
	fi

	install_tool "$tool" "$source" || true

	# Any tool with a setup document needs a human step even when its package
	# installed cleanly — group membership, sockets, ACLs. The file's existence
	# is the flag, so the manifest needs no column for it.
	if [ -f "$DOTFILES/docs/setup/$tool.md" ]; then
		REPORT_DOCS="$(append "$REPORT_DOCS" "$tool")"
	fi
done <"$ROWS"

# ---------------------------------------------------------------------------
# Stow
# ---------------------------------------------------------------------------
# --no-folding so only files this repository tracks are linked; a folded
# directory link would silently capture unrelated files created later.
# Never --adopt: it pulls the machine's file into the repository, overwriting
# tracked configuration. See docs/adr/0002-stow-contract.md

if [ -z "$SELECTED_MODULES" ]; then
	info "No modules to link."
else
	command -v stow >/dev/null 2>&1 || die "stow is required and was not installed."
	info "Linking modules"
fi

for module in $SELECTED_MODULES; do
	dir="$DOTFILES/modules/$module"

	# A conflicting real file is moved aside, never absorbed and never
	# discarded. Every backup is reported at the end.
	while read -r conflict; do
		[ -n "$conflict" ] || continue
		target="$HOME/$conflict"
		if [ -e "$target" ] && [ ! -L "$target" ]; then
			mv "$target" "$target.bak"
			REPORT_BACKUPS="$(append "$REPORT_BACKUPS" "$target.bak")"
		fi
	done <<EOF
$(cd "$dir" && find . -type f | sed 's|^\./||')
EOF

	if stow --dir "$DOTFILES/modules" --target "$HOME" --no-folding "$module"; then
		printf '%s  linked %s%s\n' "$DIM" "$module" "$R"
	else
		warn "stow failed for module $module"
		REPORT_FAILED="$(append "$REPORT_FAILED" "stow: $module")"
		EXIT_CODE=1
	fi
done

# ---------------------------------------------------------------------------
# SSH keys
# ---------------------------------------------------------------------------
# Which keys are expected is the manifest's business, not this script's: a row's
# requires_keys names them, and only selected rows contribute. Whether a missing
# key is fatal is asked once and remembered — the question names its own effect
# rather than asking who you are, because the answer to "are you the owner?"
# tells nobody what it changes.
# See docs/adr/0004-manual-ssh-key-retrieval.md

MISSING_KEYS=""
if [ -n "$REQUIRED_KEYS" ]; then
	# The same key can be named by more than one row.
	REQUIRED_KEYS="$(printf '%s\n' "$REQUIRED_KEYS" | sort -u)"

	KEYS_FATAL="$(state_get keys_fatal)"
	if [ -z "$KEYS_FATAL" ]; then
		printf '\n%sThe tools you selected expect these SSH keys:%s\n' "$B" "$R"
		printf '%s\n' "$REQUIRED_KEYS" | while read -r key; do
			[ -n "$key" ] && printf '  - %s\n' "$key"
		done
		printf 'Fail this install when they are missing, rather than only reporting it? [y/N] '
		read -r answer </dev/tty || answer="n"
		case "$answer" in
		[Yy]*) KEYS_FATAL="yes" ;;
		*) KEYS_FATAL="no" ;;
		esac
		state_set keys_fatal "$KEYS_FATAL"
	fi

	while read -r key; do
		[ -n "$key" ] || continue
		# The manifest writes ~ because it is data, not a shell.
		expanded="$(printf '%s' "$key" | sed "s|^~|$HOME|")"
		[ -f "$expanded" ] || MISSING_KEYS="$(append "$MISSING_KEYS" "$expanded")"
	done <<EOF
$REQUIRED_KEYS
EOF
fi

# ---------------------------------------------------------------------------
# Closing report
# ---------------------------------------------------------------------------

section() {
	# section TITLE CONTENT [SUFFIX]
	[ -n "$2" ] || return 0
	printf '\n%s%s%s\n' "$B" "$1" "$R"
	printf '%s\n' "$2" | while read -r line; do
		[ -n "$line" ] || continue
		printf '  - %s%s\n' "$line" "${3:-}"
	done
}

printf '\n%s────────────────────────────────────────%s\n' "$B" "$R"
printf '%sInstall report%s\n' "$B" "$R"

section "Install by hand (see docs/setup/)" "$REPORT_MANUAL"
section "Not available on this distribution" "$REPORT_UNSUPPORTED"
section "Installed, but needs setup steps" "$REPORT_DOCS"
section "Existing files moved aside" "$REPORT_BACKUPS"
section "Failed" "$REPORT_FAILED"

if [ -n "$MISSING_KEYS" ]; then
	section "Missing SSH keys — see docs/setup/openssh.md" "$MISSING_KEYS"
	if [ "$KEYS_FATAL" = "yes" ]; then
		printf '\n%sUntil these exist, every git commit will fail (commit.gpgsign = true).%s\n' "$RED" "$R"
		EXIT_CODE=1
	fi
fi

# Driven by what was selected, never by which files happen to be lying around:
# behaviour that changes because a file was spotted is behaviour nobody can
# predict from the arguments they typed.
if [ "$SELECTED_GIT" = "yes" ]; then
	printf '\n%sgit identity and signing key are not in this repository%s — see docs/setup/git.md\n' "$YEL" "$R"
fi

count() { printf '%s\n' "$1" | awk 'NF { n++ } END { print n + 0 }'; }

printf '\n%s%s manual, %s unsupported, %s need setup, %s backed up, %s failed%s\n' \
	"$B" \
	"$(count "$REPORT_MANUAL")" \
	"$(count "$REPORT_UNSUPPORTED")" \
	"$(count "$REPORT_DOCS")" \
	"$(count "$REPORT_BACKUPS")" \
	"$(count "$REPORT_FAILED")" \
	"$R"

if [ "$EXIT_CODE" -eq 0 ]; then
	printf '%sDone.%s\n' "$GRN" "$R"
else
	printf '%sFinished with problems above.%s\n' "$RED" "$R"
fi

exit "$EXIT_CODE"
