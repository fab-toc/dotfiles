#!/bin/sh

. "$ZDOTDIR/functions.sh"

DISTRIBUTION=$(distro)

# ===========================
# Classic Shell Commands
# ===========================
if [ "$DISTRIBUTION" = "redhat" ] || [ "$DISTRIBUTION" = "arch" ]; then
  alias cat="bat"
else
  alias cat="batcat"
fi

alias cd="z"
alias c="clear"

# ===========================
# Package Manager
# ===========================
if [ "$DISTRIBUTION" = "arch" ]; then
  alias s="yay -Ss"
  alias i="yay -S"
  alias u="yay -Syu"
elif [ "$DISTRIBUTION" = "debian" ]; then
  alias s="apt search"
  alias i="apt install"
  alias u="apt update"
fi

# ===========================
# File Listing
# ===========================
alias ls="eza --icons"
alias ll="ls -l"
alias la="ls -a"
alias lla="ls -la"

# ===========================
# neovim
# ===========================
alias v="nvim"

# ===========================
# fastfetch
# ===========================
alias ff="fastfetch"

# ===========================
# systemd
# ===========================
alias ctl="systemctl"

# ===========================
# docker
# ===========================
alias docker-clean=' \
  docker container prune -f ; \
  docker image prune -f ; \
  docker network prune -f ; \
  docker volume prune -f '

alias sd="systemctl start containerd.service docker.service"

# ===========================
# git
# ===========================
alias g="git"

alias gi="git init"
alias gcl="git clone"

alias gs="git status --short"
alias ga="git add"
alias gaa="git add ."
alias gap="git add --patch"
alias gc="git commit"

alias gl="git log --graph --all --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n'"
alias gb="git branch"
alias gco="git checkout"
alias gd="git diff --output-indicator-new=' ' --output-indicator-old=' '"

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
