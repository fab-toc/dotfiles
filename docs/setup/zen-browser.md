# Zen Browser

`$BROWSER` in `.zshenv` names `zen-browser`, so the variable is only meaningful
on machines where it is installed. Nothing breaks where it is not: no
configuration in this repository invokes `$BROWSER` directly.

## Arch — AUR

```sh
yay -S zen-browser-bin
```

## Debian and Ubuntu — manual

Not packaged. Download the official tarball or the AppImage from
<https://zen-browser.app/download>, or install the Flatpak. Unpack under `/opt`
and put a launcher on `$PATH` if you want `$BROWSER` to resolve.
