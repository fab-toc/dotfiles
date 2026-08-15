#!/bin/sh
# Entry point for `curl -fsSL <raw url>/bootstrap.sh | sh`.
#
# This is the one curl-pipe in the design that cannot be avoided: it runs
# before the repository exists, so there is nothing else to run it from. It is
# kept short enough to read in a browser before you trust it, and it installs
# nothing — git and curl are prerequisites stated in the README.
#
# See docs/adr/0001-tool-source-ladder.md

set -eu

REPO_URL="https://github.com/fab-toc/dotfiles.git"
# The path is a permanent contract: stow's symlinks encode it.
# See docs/adr/0002-stow-contract.md
DOTFILES="$HOME/.dotfiles"

die() {
	printf '\033[1;31merror:\033[0m %s\n' "$1" >&2
	exit 1
}

command -v git >/dev/null 2>&1 ||
	die "git is required and was not found. Install git and curl, then run this again."

if [ -e "$DOTFILES" ]; then
	[ -d "$DOTFILES/.git" ] ||
		die "$DOTFILES exists but is not a git repository. Move it aside and run this again."
	printf 'Updating existing clone at %s\n' "$DOTFILES"
	git -C "$DOTFILES" pull --ff-only
else
	printf 'Cloning into %s\n' "$DOTFILES"
	git clone "$REPO_URL" "$DOTFILES"
fi

[ -f "$DOTFILES/install.sh" ] ||
	die "$DOTFILES/install.sh is missing; the clone looks incomplete."

exec sh "$DOTFILES/install.sh" "$@"
