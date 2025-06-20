#!/bin/sh

# classic shell commands
alias cd="z"
alias cat="bat"
alias c="clear"

alias ls="eza --icons"
alias ll="ls -l"
alias la="ls -a"
alias lla="ls -la"


# neovim
alias v="nvim"


# fastfetch
alias ff="fastfetch"


# systemd
alias start="sudo systemctl start"


# git
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


# GitHub
alias gh-create="gh repo create --private --source=. --remote=origin && git push -u --all && gh browse"


# pnpm
alias pn="pnpm"
alias px="pnpx"
