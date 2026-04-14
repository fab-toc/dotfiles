# My dotfiles

This directory contains the dotfiles of my system.

# How to install

Just use the auto-install script :

```
cd ~
git clone https://github.com/fab-toc/dotfiles.git
sudo chmod +x dotfiles/install.sh
./dotfiles/install.sh
```

```bash
stow --no-folding
```

L'option `--no-folding` permet de forcer force Stow à toujours descendre au niveau le plus profond possible pour créer des liens symboliques vers les fichiers et non vers les dossiers (pour être sûr que seuls les fichiers présents dans vos dotfiles soient liés)
