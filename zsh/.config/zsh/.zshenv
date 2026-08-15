#!/usr/bin/zsh

# Used to set the user's environment variables. Will always be read.
# Should not contain commands that produce output or assume that the shell is connected to a TTY. Setting interactive shell options or outputting text here can break non-interactive scripts and tools.
# Must only contain environment variables that define the system environment, not variables that dictate the behavior of interactive sessions. Never include variables related to terminal colors, prompts, or history.

# XDG
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"

# A terminal editor is the only choice that works identically on every
# machine, including headless servers where no GUI editor exists.
export EDITOR="nvim"
export VISUAL="$EDITOR"
export PAGER="less"

export BROWSER="zen-browser"

# Bun
export BUN_INSTALL="$XDG_CACHE_HOME/bun"

# Android
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_USER_HOME="$HOME/.android"

# PATH
typeset -U path PATH
path=(
    $path

    # Binaries
    $XDG_BIN_HOME
    $BUN_INSTALL/bin

    # Android
    $ANDROID_HOME/emulator
    # $ANDROID_HOME/tools/bin
    $ANDROID_HOME/platform-tools
    # $ANDROID_HOME/cmdline-tools/latest/bin
)
path=($^path(N-/))
export PATH
