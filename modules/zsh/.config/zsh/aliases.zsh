#!/usr/bin/zsh

# Aliases guard on what is present, never on which distribution this is.
# Alias *names* are the contract and are identical everywhere; what they
# resolve to may differ. See docs/adr/0005-single-branch-not-per-distribution.md

# ===========================
# Classic Shell Commands
# ===========================

# Debian ships bat as `batcat` (the name `bat` is taken by bacula). Ask which
# binary exists rather than which distribution this is — on a machine with
# neither, `cat` must stay the real cat.
if command -v bat >/dev/null; then
  alias cat="bat"
elif command -v batcat >/dev/null; then
  alias cat="batcat"
fi

# Same rename, same treatment.
if command -v fdfind >/dev/null && ! command -v fd >/dev/null; then
  alias fd="fdfind"
fi

command -v zoxide >/dev/null && alias cd="z"
alias c="clear"

# Not aliased over grep: rg takes different flags and recurses by default,
# so anything expecting real grep would misbehave.
command -v rg >/dev/null && alias rg="rg --color=auto"
alias grep="grep --color=auto"
alias diff="diff --color=auto"
alias df="df -h"


# ===========================
# Package Manager
# ===========================

# yay first so it wins on Arch once bootstrapped, pacman next so these aliases
# still work on a fresh Arch machine before it is, apt last.
if command -v yay >/dev/null; then
  alias s="yay -Ss"
  alias i="yay -S --needed"
  alias u="yay -Syu"
elif command -v pacman >/dev/null; then
  alias s="pacman -Ss"
  alias i="sudo pacman -S --needed"
  alias u="sudo pacman -Syu"
elif command -v apt >/dev/null; then
  alias s="apt search"
  alias i="sudo apt install"
  alias u="sudo apt update"
fi


# ===========================
# File Listing
# ===========================
if command -v eza >/dev/null; then
  alias ls="eza --icons"
  alias ll="eza -lh --icons --git"
  alias la="eza -lah --icons --git"
  alias tree="eza --tree --icons"
else
  alias ll="ls -lh"
  alias la="ls -lah"
fi


# ===========================
# neovim
# ===========================
command -v nvim >/dev/null && alias v="nvim"


# ===========================
# docker
# ===========================
alias sd="systemctl start containerd.service docker.service"


# ===========================
# git
# ===========================
alias g="git"

alias gcl="git clone"
alias gi="git init"

alias gco="git checkout"
alias gb="git branch"
alias gs="git status"
alias gd="git diff"

alias ga="git add"
alias gaa="git add --all"
alias gap="git add --patch"

alias gl="git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n'"
alias gc="git commit"

alias gf="git fetch"
alias gp="git push"
alias gu="git pull"


# ===========================
# GitHub
# ===========================
alias gh-create="gh repo create --private --source=. --remote=origin && git push -u --all && gh browse"


# ===========================
# pnpm
# ===========================
alias pn="pnpm"
alias px="pnpx"
