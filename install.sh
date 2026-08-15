#!/bin/sh
# Installer. POSIX sh, not bash: Debian's /bin/sh is dash.
#
# Reads tools.tsv, installs each selected tool from the source named for this
# distribution, stows the modules that have one, and ends with a report of
# everything still outstanding. The report is the only thing standing in for a
# test suite — see docs/adr/0007-testing-deferred.md

set -eu

DOTFILES="$HOME/.dotfiles"
MANIFEST="$DOTFILES/tools.tsv"
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
# Preconditions
# ---------------------------------------------------------------------------

# Stow encodes this repository's absolute path into every symlink, so running
# from anywhere else would silently produce links that dangle the moment the
# directory moves. See docs/adr/0002-stow-contract.md
HERE="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
[ "$HERE" = "$DOTFILES" ] ||
	die "This repository must live at $DOTFILES (found it at $HERE)."

[ -f "$MANIFEST" ] || die "Manifest not found at $MANIFEST"

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

info "Reading $MANIFEST"

# The header line is skipped by name rather than by counting lines, so
# reordering the file cannot silently install a tool called "tool".
while IFS="$(printf '\t')" read -r tool arch debian kind default; do
	[ "$tool" = "tool" ] && continue
	[ -z "$tool" ] && continue

	case "$COLUMN" in
	arch) source="$arch" ;;
	debian) source="$debian" ;;
	esac

	# Graphical tools are skipped on a machine declared headless.
	if [ "$kind" = "gui" ] && [ "$HEADLESS" = "yes" ]; then
		continue
	fi

	# Selection is remembered, so a re-run asks nothing.
	selected="$(state_get "tool.$tool")"
	if [ -z "$selected" ]; then
		selected="$default"
		state_set "tool.$tool" "$selected"
	fi
	[ "$selected" = "yes" ] || continue

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
done <"$MANIFEST"

# ---------------------------------------------------------------------------
# Stow
# ---------------------------------------------------------------------------
# --no-folding so only files this repository tracks are linked; a folded
# directory link would silently capture unrelated files created later.
# Never --adopt: it pulls the machine's file into the repository, overwriting
# tracked configuration. See docs/adr/0002-stow-contract.md

command -v stow >/dev/null 2>&1 || die "stow is required and was not installed."

info "Linking modules"
for dir in "$DOTFILES"/modules/*/; do
	[ -d "$dir" ] || continue
	module="$(basename "$dir")"

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
# commit.gpgsign = true means every git commit fails until the signing key is
# present, so this is loud and it fails the run.
# See docs/adr/0004-manual-ssh-key-retrieval.md

MISSING_KEYS=""
for key in "$HOME/.ssh/github_key" "$HOME/.ssh/its_servers"; do
	[ -f "$key" ] || MISSING_KEYS="$(append "$MISSING_KEYS" "$key")"
done

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
	section "Missing SSH keys — download from the Proton Pass web vault" "$MISSING_KEYS"
	printf '\n%sUntil these exist, every git commit will fail (commit.gpgsign = true).%s\n' "$RED" "$R"
	EXIT_CODE=1
fi

if [ -f "$HOME/.config/git/config" ] && [ ! -f "$HOME/.config/git/config.local" ]; then
	printf '\n%sgit identity is not configured%s — see docs/setup/git.md\n' "$YEL" "$R"
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
