# Virtualization QEMU/KVM setup

The packages install from the manifest on both distributions — this is not a
`manual` tool. What it needs is **post-install steps only a human can run**:
group membership, socket enablement and ACLs. That is why this page exists, and
why the installer lists any tool with a `docs/setup/` page in its closing report
even when the package installed cleanly.

Sections 1–3 below are Arch. See [Debian and Ubuntu](#debian-and-ubuntu) at the
end for the differences.


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

## Debian and Ubuntu

The whole stack is packaged, so installation is ordinary:

```bash
sudo apt install qemu-system-x86 libvirt-daemon-system libvirt-clients \
  virt-manager virtinst ovmf swtpm dnsmasq bridge-utils
```

Three differences from Arch:

**The daemon is monolithic.** Debian still ships and enables `libvirtd.service`
rather than the modular `virtqemud`/`virtnetworkd` sockets. Do not disable it and
do not copy the modular `systemctl enable` block above — on Debian that is the
supported arrangement.

```bash
sudo systemctl enable --now libvirtd.service
```

**The group is `libvirt` on both, but Debian also uses `kvm`:**

```bash
sudo usermod -aG libvirt,kvm $USER
```

Log out and back in for group membership to take effect — `newgrp` only affects
the current shell.

**The default network is not started automatically** on some releases:

```bash
sudo virsh net-start default
sudo virsh net-autostart default
```

The `setfacl` steps for `/var/lib/libvirt/images` apply unchanged if you want to
write images as your own user.

Verify the same way on both distributions:

```bash
virsh -c qemu:///system version
virt-host-validate
```
