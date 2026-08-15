# Arch Linux Setup

## Pre-install

- Download the installer (https://archlinux.org/download/#download-mirrors)
- Verify :

  ```bash
  b2sum -c b2sums.txt --ignore-missing
  ```

  ```bash
  sha256sum -c sha256sums.txt --ignore-missing
  ```

  ```bash
  gpg --auto-key-locate clear,wkd -v --locate-external-key pierre@archlinux.org

  gpg --verify archlinux-2026.02.01-x86_64.iso.sig
  ```

```bash
sudo grub-mkfont -o /boot/grub/fonts/jetbrainsmono.pf2 /usr/share/fonts/TTF/JetBrainsMonoNLNerdFont-Regular.ttf
sudo echo 'GRUB_FONT="/boot/grub/fonts/jetbrainsmono.pf2"' >> /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
