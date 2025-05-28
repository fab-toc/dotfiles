#!/bin/sh

# Install all the packages needed
sudo pacman -S zsh stow curl git neovim bat fzf uv pnpm eza starship zoxide ghostty

# Change default shell to zsh
chsh -s $(which zsh)

# Apply my configuration
cd ~/dotfiles
stow .

echo "Installation complete."