# Java

Both distributions install multiple JDKs side by side and switch between them
natively, so this repository ships no Java configuration at all — only a
manifest row. Only the *switching command* differs, which is why this page
exists.

## Arch

OpenJDK 8, 11, 17, 21, 25 and 26 are in the official repositories and can all be
installed without conflict.

```sh
sudo pacman -S jdk-openjdk        # latest
sudo pacman -S jdk21-openjdk      # a specific LTS
```

Switch the default with the helper from `java-runtime-common`:

```sh
archlinux-java status
sudo archlinux-java set jdk21-openjdk
```

**Arch does not use `JAVA_HOME`,** and this repository deliberately does not set
it. `/usr/lib/jvm/default` is the switchable symlink and `/usr/bin` already
carries the binaries. If a single program insists on the variable, set it for
that program — `JAVA_HOME=/usr/lib/jvm/default` — rather than exporting it from
the shell configuration, where it would contradict the distribution's design.

Always edit `/usr/lib/jvm/default` through `archlinux-java`, never by hand.

## Debian and Ubuntu

Trixie carries `openjdk-21` and `openjdk-25`; bookworm has `openjdk-17`.

```sh
sudo apt install default-jdk      # the release's default
sudo apt install openjdk-21-jdk   # a specific version
```

Switch with alternatives:

```sh
sudo update-alternatives --config java
sudo update-alternatives --config javac
```

Debian tooling is more likely to want `JAVA_HOME`. Set it per project, e.g. in
Gradle's `gradle.properties`, rather than globally.

## Why there is no `jdk` alias

Switching your default JDK is a once-a-year action. An alias used that rarely is
one you will not remember, so this page is the carrier instead — see the Q9
reasoning recorded in ADR-0005's spirit: alias names are a contract, and a
contract nobody invokes is not worth having.
