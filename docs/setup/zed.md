# Zed

## Arch

```sh
sudo pacman -S zed
```

## Debian and Ubuntu — manual

There is no official apt repository and no `.deb`. The official route is the
install script:

```sh
curl -f https://zed.dev/install.sh | sh
```

A `manual` document may prescribe a curl-pipe when that is genuinely what
upstream prescribes. The difference from ADR-0001's original mistake is that
*you* run this knowingly after reading the page, rather than the installer
running it on your behalf without telling you.

Note that Debian's `zed` package is an unrelated program, not this editor.
Installing it will not give you Zed.
