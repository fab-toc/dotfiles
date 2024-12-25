#!/bin/sh

# Ask function to ask a yes/no question
ask() {
  while true; do
    read -p "$1 [y/n]: " choice
    case "$choice" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Please answer 'y' or 'n'." ;;
    esac
  done
}


# Install all the packages needed
brew install curl stow neovim bat eza starship fzf


starship preset no-runtime-versions -o ~/.config/starship.toml # apply starship preset


# Install uv
if ask "Do you want to install uv for Python ?"; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi


# Install pnpm
if ask "Do you want to install pnpm (package manager for js projects) ?"; then
  brew install pnpm
fi


# Apply my configuration
cd ~/dotfiles
stow .

echo "Installation complete."