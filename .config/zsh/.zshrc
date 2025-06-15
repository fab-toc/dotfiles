#!/bin/sh 

##### ZSH

### ZSH Plugins

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


### ZSH Configuration

# Source ZSH Files
source "$ZDOTDIR/aliases.sh"

# Load completions
autoload -Uz compinit && compinit

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# History
HISTSIZE=5000
HISTFILE=$ZDOTDIR/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


##### SSH

# SSH-agent setup
if [ -z "$SSH_AUTH_SOCK" ] || ! pgrep -u "$USER" ssh-agent > /dev/null; then
  eval "$(ssh-agent -s)" > /dev/null
  ssh-add ~/.ssh/github_key > /dev/null 2>&1
  ssh-add ~/.ssh/its_servers > /dev/null 2>&1
fi


##### Shell integrations

# Load NVM (Node Version Manager)
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Setup pnpm
export PNPM_HOME="${HOME}/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Setup bun
export PATH=$PATH:$HOME/.cache/.bun/bin # executables for global packages

# Enable UV for Python and shell completions
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Enable Starship
eval "$(starship init zsh)"

# Enable Zoxide
eval "$(zoxide init zsh)"
