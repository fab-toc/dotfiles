#!/usr/bin/zsh

# Used to set the user's interactive shell configuration and execute commands. Will be read when zsh starts as an interactive shell.
# Configures the human-facing terminal interface. Usually uses internal shell variables rather than exported environment variables.

# ===========================
# ZSH Plugins
# ===========================

# Plugins are distribution packages, not fetched at startup: nothing here
# touches the network. See docs/adr/0003-no-zsh-plugin-manager.md
#
# Arch packages them under /usr/share/zsh/plugins/<name>/, Debian directly
# under /usr/share/<name>/. Try both; a plugin that is installed nowhere is
# simply not loaded.
_src_plugin() {
  local name="$1" candidate
  for candidate in \
    "/usr/share/zsh/plugins/$name/$name.zsh" \
    "/usr/share/$name/$name.zsh"; do
    if [ -r "$candidate" ]; then
      source "$candidate"
      return 0
    fi
  done
  return 1
}

# Order is significant: zsh-syntax-highlighting must be sourced last, after
# everything that defines widgets. Do not sort these lines.
_src_plugin zsh-autosuggestions
_src_plugin zsh-syntax-highlighting

# zsh-completions is deliberately absent from the list above. It installs its
# functions into /usr/share/zsh/site-functions, which is already in $fpath
# before this file runs, so it needs no sourcing at all.

# ===========================
# ZSH Configuration
# ===========================

# Source ZSH Files
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/functions.zsh"

# Load completions
# The completion dump is a cache, so it belongs outside the repository.
autoload -Uz compinit && compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
autoload -U bashcompinit && bashcompinit

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# History
# State, not configuration: kept out of the dotfiles repository entirely.
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}"
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
# Shell Integrations
# ===========================

# Every integration below is guarded on the tool being present. An unguarded
# eval breaks the login shell on any machine lacking the tool — including a
# machine of yours mid-install, and anyone who cherry-picks this module.

command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v fzf >/dev/null && source <(fzf --zsh)
command -v uv >/dev/null && eval "$(uv generate-shell-completion zsh)"
command -v uvx >/dev/null && eval "$(uvx --generate-shell-completion zsh)"

# mise is the tool source on Debian and Ubuntu only. On Arch it is normally
# absent and this is a no-op; if you have installed it for project work, it
# activates per-directory and must never be given a global config.
# See docs/adr/0008-mise-permitted-on-arch-without-a-global-config.md
command -v mise >/dev/null && eval "$(mise activate zsh)"

# nvm is the Node version manager on Arch. Two packaging conventions exist:
# Arch's `nvm` package ships an init script under /usr/share, while upstream's
# installer puts nvm.sh in $NVM_DIR (default ~/.nvm). Try both.
for _nvm_init in \
  /usr/share/nvm/init-nvm.sh \
  "${NVM_DIR:-$HOME/.nvm}/nvm.sh"; do
  if [ -r "$_nvm_init" ]; then
    source "$_nvm_init"
    break
  fi
done
unset _nvm_init
