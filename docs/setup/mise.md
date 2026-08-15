# mise

## Debian and Ubuntu — installed for you

mise is the second rung of the ladder here, and the installer sets it up from
mise's own apt repository before reading the manifest. Nothing to do by hand.

```sh
sudo apt install -y extrepo && sudo extrepo enable mise && sudo apt install -y mise
# Ubuntu 26.04+ may use the PPA instead:
sudo add-apt-repository -y ppa:jdxcode/mise
```

Never `curl … | sh` it. That was an earlier mistake in this repository, made on
the false belief that mise was unpackaged for Debian — see ADR-0001.

## Arch — deliberately not installed

Arch's ladder has no mise rung: pacman and the AUR cover everything, and Arch
already solves version-juggling natively (`archlinux-java`, `extra/nvm`). The
manifest's `arch` cell is `manual` to say exactly that — installable, chosen
against.

You may still want it for one reason: working in a repository whose
contributors pin its toolchain in a `mise.toml`. That is legitimate.

```sh
sudo pacman -S mise
```

### The one rule

**Never create `~/.config/mise/config.toml`.**

mise merges every config file from the current directory up to the root. A
project's `mise.toml` therefore only affects that directory tree, which is what
makes it safe — outside it, mise contributes nothing to `PATH` and your pacman
binaries are untouched. A *global* config is merged into every resolution, so
one line in it would shadow a pacman binary everywhere, and mise would have
quietly become the package manager for that tool.

Practically: `mise use` inside a project, never `mise use -g`.

Leave `.nvmrc` support off (it is off by default, behind
`idiomatic_version_file_enable_tools`). On Arch, `.nvmrc` belongs to nvm; enabling
it in mise would give two managers a claim on the same file.

See ADR-0008 for the full reasoning.
