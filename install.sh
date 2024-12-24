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
sudo apt install -y zsh stow curl git neovim bat gpg

# Change default shell to zsh
chsh -s $(which zsh)

# Install eza cli
if ask "Do you want to install eza to replace ls ?"; then
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt update
  sudo apt install -y eza
fi

# Install Starship
if ask "Do you want to install Starship ?"; then
  curl -sS https://starship.rs/install.sh | sh # follow the installation script but do NOT append to configuration
  starship preset no-runtime-versions -o ~/.config/starship.toml # apply starship preset
fi

# Install fzf
if ask "Do you want to install fzf ?"; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install # follow the installation script but do NOT append to configuration
fi

# Install uv
if ask "Do you want to install uv for Python ?"; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Install pnpm
if ask "Do you want to install pnpm ?"; then
  curl -fsSL https://get.pnpm.io/install.sh | sh -
fi


# Apply my configuration
cd ~/dotfiles
stow .

echo "Installation complete."