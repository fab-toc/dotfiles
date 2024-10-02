#!/bin/sh

# Install all the packages needed
sudo apt install zsh stow curl git neovim
chsh -s $(which zsh)


# Install Starship
curl -sS https://starship.rs/install.sh | sh # follow the installation script but do NOT append to configuration
starship preset no-runtime-versions -o ~/.config/starship.toml # apply starship preset

# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install # follow the installation script but do NOT append to configuration

# Apply my configuration
cd ~/dotfiles
stow .
