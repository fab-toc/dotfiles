# Virtualization QEMU/KVM setup

https://wiki.archlinux.org/title/KVM
https://wiki.archlinux.org/title/QEMU
https://wiki.archlinux.org/title/Libvirt
https://wiki.archlinux.org/title/Virt-manager

https://sysguides.com/install-kvm-on-linux

## 1. Checking support for KVM

### 1.1 Hardware support

```bash
LC_ALL=C.UTF-8 lscpu | grep -i Virtualization
```

### 1.2 Kernel support

```bash
zgrep CONFIG_KVM /proc/config.gz
```

```bash
lsmod | grep kvm
```

## 1. Install the needed packages

```bash
sudo pacman -S --needed qemu-full libvirt virt-install virt-manager virt-viewer edk2-ovmf swtpm qemu-img guestfs-tools libosinfo tuned dnsmasq iptables-nft
```

## 2. Setup the permissions

```bash
sudo usermod -aG libvirt $USER
```

## 3. Setup services

### Deactivate the monolithic daemon...

In case you already activated the monolithic libvirt daemon, stop it and disable it to use the modular daemons.

```bash
sudo systemctl stop libvirtd.service libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket
sudo systemctl disable libvirtd.service libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket
```

_You can also mask the services so you cannot activate them by mistake later on_

```bash
sudo systemctl mask libvirtd.service libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket
```

### ...in favor of the modular ones

```bash
sudo systemctl enable --now \
virtqemud.socket \
virtnetworkd.socket \
virtnodedevd.socket \
virtnwfilterd.socket \
virtsecretd.socket \
virtstoraged.socket \
virtproxyd.socket \
virtlogd.socket \
virtlockd.socket
```

```bash
sudo setfacl -R -b /var/lib/libvirt/images
sudo setfacl -R -m u:$USER:rwX /var/lib/libvirt/images
sudo setfacl -m d:u:$USER:rwx /var/lib/libvirt/images
```
