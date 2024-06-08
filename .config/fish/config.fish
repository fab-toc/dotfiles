# Remove the greeting of fish when the shell opens
set fish_greeting ""

# Customize Tide prompt colors
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
set -g tide_character_color_failure 'red'

# Aliases
alias ls "eza --icons"
alias la "ls -a"
alias ll "ls -l"
alias lla "ll -la"

alias g git
alias vim nvim

set -Ux EDITOR nvim

# Permit Firefox to support Wayland
set -Ux MOZ_ENABLE_WAYLAND 1
