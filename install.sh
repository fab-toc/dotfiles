#!/bin/sh

# Install all the packages needed
sudo apt install -y zsh stow curl git neovim bat gpg
chsh -s $(which zsh)

# Install eza cli
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

# Install Starship
curl -sS https://starship.rs/install.sh | sh # follow the installation script but do NOT append to configuration
starship preset no-runtime-versions -o ~/.config/starship.toml # apply starship preset

# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install # follow the installation script but do NOT append to configuration

# Apply my configuration
cd ~/dotfiles
stow .
