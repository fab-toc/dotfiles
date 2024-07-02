# dotfiles

This directory contains the dotfiles of my system. As for now, I actually use fish for my shell and fisher for my plugin manager.

## Requirements

To install those dotfiles, make sure you have the following packages installed (the commands used are available on Debian-based distros) :

### Git

```
sudo apt install git
```

### Stow

```
sudo apt install stow
```

### Fish shell

```
echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg > /dev/null
sudo apt update
sudo apt install fish
```

## Installation

### Auto-install script

To install this configuration, you can use the install.sh script provided. Just use the following (with root permissions !) :

```
sudo ./install.sh
```

### Manual Installation

#### Begin by cloning this repo into your home folder (important !)

```
cd ~
git clone https://github.com/fab-toc/dotfiles.git
```

#### Plugins for fish : fisher plugin manager

```
fisher install jorgebucaran/fisher
fisher install ilancosman/tide@v6
fisher install edc/bass
fisher install jorgebucaran/nvm.fish
```

#### Configure the Tide prompt

Execute this command to follow the auto-install script :

```
tide configure
```

#### Finally, you can stow your files to auto-apply all of the configurations.

```
cd ~/dotfiles
stow .
```

BUT, if you already have a configuration stored on your machine, this will throw an error telling you stow encountered conflicts.

If you want to preserve your actual configuration, you have to execute this command that will keep (for the conflicts you encountered) your actual configuration :

```
cd ~/dotfiles
stow --adopt .
```

Else, if you want to adopt a complete (or partial) new configuration, you have to backup in another folder (or simply delete) all the configuration files that you do not want to keep.
