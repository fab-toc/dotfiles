# Remove the greeting of fish when the shell opens
set fish_greeting ""

# Environment Variables
set -Ux nvm_default_version lts # Default NODE.js version to use
set -Ux MOZ_ENABLE_WAYLAND 1 # Permit Firefox to support Wayland
set -Ux EDITOR nvim # Sets the default editor for the system to nvim
set -Ux ANDROID_HOME /home/ftocco/Android/Sdk # For Android Studio


#### XDG NINJA
set -Ux XDG_DATA_HOME "$HOME/.local/share"
set -Ux XDG_CONFIG_HOME "$HOME/.config"
set -Ux XDG_STATE_HOME "$HOME/.local/state"
set -Ux XDG_CACHE_HOME "$HOME/.cache"

set -Ux HISTFILE "$XDG_STATE_HOME/bash/history"
set -Ux DOTNET_CLI_HOME "$XDG_DATA_HOME/dotnet"
set -Ux GNUPGHOME "$XDG_DATA_HOME/gnupg"
set -Ux NVM_DIR "$XDG_DATA_HOME/nvm"


#### Customize Tide prompt colors
set -Ux tide_git_bg_color 268bd2
set -Ux tide_git_bg_color_unstable C4A000
set -Ux tide_git_bg_color_urgent CC0000
set -Ux tide_git_branch_color 000000
set -Ux tide_git_color_branch 000000
set -Ux tide_git_color_conflicted 000000
set -Ux tide_git_color_dirty 000000
set -Ux tide_git_color_operation 000000
set -Ux tide_git_color_staged 000000
set -Ux tide_git_color_stash 000000
set -Ux tide_git_color_untracked 000000
set -Ux tide_git_color_upstream 000000
set -Ux tide_git_conflicted_color 000000
set -Ux tide_git_dirty_color 000000
set -Ux tide_git_icon 
set -Ux tide_git_operation_color 000000
set -Ux tide_git_staged_color 000000
set -Ux tide_git_stash_color 000000
set -Ux tide_git_untracked_color 000000
set -Ux tide_git_upstream_color 000000

set -Ux tide_pwd_bg_color 444444
set -Ux tide_character_color 268bd2
set -Ux tide_character_color_failure 'red'




# Aliases
alias ls "eza --icons"
alias la "ls -a"
alias ll "ls -l"
alias lla "ll -la"

alias g git
alias vim nvim
alias maj "sudo apt full-upgrade; flatpak update; fisher update"



# Abbreviations
abbr -a gck git checkout
abbr -a gpo git push origin
abbr -a ga git add .
abbr -a gco git commit -m



# Dev
alias p pnpm

# pnpm
set -gx PNPM_HOME "/home/ftocco/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end