#!/usr/bin/zsh

# Used to set the user's interactive shell configuration and execute commands. Will be read when zsh starts as an interactive shell.
# Configures the human-facing terminal interface. Usually uses internal shell variables rather than exported environment variables.

# ===========================
# ZSH
# ===========================

# --- ZSH Plugins ---

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit ice lucid as"program" pick"bin/git-dsf"
zinit load so-fancy/diff-so-fancy


# --- ZSH Configuration ---

# Source ZSH Files
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/functions.zsh"

# Load completions
autoload -Uz compinit && compinit
autoload -U bashcompinit && bashcompinit

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# History
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=100000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


# ===========================
# SSH
# ===========================

# # SSH-agent setup
# if [ -z "$SSH_AUTH_SOCK" ] || ! pgrep -u "$USER" ssh-agent > /dev/null; then
#   eval "$(ssh-agent -s)" > /dev/null
#   ssh-add ~/.ssh/github_key > /dev/null 2>&1
#   ssh-add ~/.ssh/its_servers > /dev/null 2>&1
# fi


# ===========================
# Shell Integrations
# ===========================

# Load NVM (Node Version Manager)
source "/usr/share/nvm/init-nvm.sh"

# 3. Hook d'auto-switch (Détection des fichiers .nvmrc)
autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Restitution de la version Node par défaut"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc

load-nvmrc # initial load

source <(fzf --zsh)
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
