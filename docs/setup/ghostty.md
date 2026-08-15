# Ghostty

## Arch

```sh
sudo pacman -S ghostty
```

## Debian and Ubuntu — manual

The Ghostty project distributes prebuilt binaries **for macOS only**. On Linux it
relies on distribution and community packagers, and neither Debian nor Ubuntu
has an official package. Two routes:

1. **Build from source** — the officially supported path. Needs a Zig toolchain
   and the GTK development headers. See <https://ghostty.org/docs/install/build>.
2. **A community `.deb`** — the `ghostty-ubuntu` project publishes builds. Faster,
   but you are trusting a third party's binary.

Prefer the source build. The community package is noted because it is the route
you will actually reach for on a machine you use once a month.

Flatpak was considered as a general answer for graphical tools and rejected:
sandboxing degrades a terminal emulator's integration with the host shell,
which is the one thing a terminal must get right. See ADR-0001.
