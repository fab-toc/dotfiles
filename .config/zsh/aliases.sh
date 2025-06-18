#!/bin/sh

alias v="nvim"
alias vim="nvim"

alias c="clear"

alias cat="bat"
alias cd="z"

# systemd aliases
alias start="sudo systemctl start"

# LS aliases
alias ls="eza --icons"
alias ll="eza --icons -l"
alias la="eza --icons -a"
alias lla="eza --icons -la"

# Git aliases
alias g="git"
alias ga="git add"
alias gaa="git add ."
alias gco="git commit -m"
alias gst="git status"
alias gps="git push origin"
alias gpl="git pull origin"
alias gf="git fetch origin"
alias gck="git checkout"
alias gr="git reset --hard"

# GitHub
alias gh-create="gh repo create --private --source=. --remote=origin && git push -u --all && gh browse"

# PNPM
alias pn="pnpm"
alias px="pnpx"

# fastfetch
alias ff="fastfetch"
