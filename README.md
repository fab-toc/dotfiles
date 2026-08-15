# dotfiles

Configuration for Arch, Debian and Ubuntu — desktop or headless server — from a
single branch, with no generated files and no per-machine forks.

## Two invariants

1. **The repository contains only what is identical on every machine.** No
   generated files, no per-machine files, no per-distribution branches. Anything
   that legitimately differs — identity, keys, host inventories, machine state —
   lives outside the repository.
2. **Configuration files are byte-identical everywhere; only their runtime
   behaviour differs.** A config adapts by guarding on what is *present*, never
   by being rewritten, regenerated, or branched. Nothing here parses
   `/etc/os-release`.

The practical consequence: **every module is independently cherry-pickable.**
Any reference to a tool tolerates that tool being absent, so you can copy one
directory out of this repository without inheriting the rest of it, and without
an unguarded `eval` breaking your login shell.

## Install

Requires `git` and `curl`. Install them first — the bootstrap deliberately
installs nothing.

```sh
sudo pacman -S git curl      # Arch
sudo apt install git curl    # Debian / Ubuntu
```

Then:

```sh
curl -fsSL https://raw.githubusercontent.com/fab-toc/dotfiles/main/bootstrap.sh | sh
```

The bootstrap is a few readable lines: it checks git, clones to `~/.dotfiles`,
and hands off to `install.sh`. Read it before you pipe it.

The repository path is a permanent contract — GNU Stow encodes it into every
symlink — so `~/.dotfiles` is not configurable and the installer refuses to run
from anywhere else.

## What the installer does

Reads [`tools.tsv`](./tools.tsv), installs each selected tool from the source
named for your distribution, links the modules with `stow --no-folding`, and
ends with a report of everything still outstanding.

It never uses `stow --adopt`: a conflicting file is moved to `<name>.bak` and
reported, never pulled into the repository over tracked configuration.

The report is the whole safety net — there is no test suite, knowingly
([ADR-0007](./docs/adr/0007-testing-deferred.md)) — so it lists tools to install
by hand, tools unavailable on your distribution, tools that installed but need
setup steps, files moved aside, and missing SSH keys. It exits non-zero only if
a module failed to link or the SSH keys are absent: outstanding manual work is
reported, not treated as failure.

Re-runs are silent. Which tools a machine selected, and whether it is headless,
are remembered in `$XDG_STATE_HOME/dotfiles/state` — outside the repository,
where `git clean -xdf` cannot reach them.

## Where tools come from

Each tool has a row in [`tools.tsv`](./tools.tsv) with a source per
distribution. GitHub renders it as a table. A source is a package name or one of:

| Source        | Meaning                                                            |
| ------------- | ------------------------------------------------------------------ |
| `mise`        | installed via [mise](https://mise.jdx.dev/) — Debian and Ubuntu only |
| `manual`      | install by hand; `docs/setup/<tool>.md` says how                    |
| `excluded`    | deliberately not installed here; another source covers the need     |
| `unsupported` | not available on this distribution at all                           |

The ladder is not symmetric. On Arch it is the official repositories, then the
AUR via `yay`. On Debian and Ubuntu it is apt, then mise — which is installed
from its own apt repository, never curl-piped.

Every tool has a row whether or not it has configuration here. Whether a tool
has a module is not recorded: the presence of `modules/<tool>/` is the fact.

## Layout

- `modules/` — one directory per tool, laid out relative to `$HOME`. The only
  thing stow ever sees; nothing outside it is ever symlinked.
- `tools.tsv` — the manifest.
- `docs/adr/` — the decisions, and the alternatives already rejected.
- `docs/setup/` — the manual and post-install steps.
- [`CONTEXT.md`](./CONTEXT.md) — the vocabulary. Read it first.

Several choices here look wrong until you know why they were made. The ADRs say
why; check them before "fixing" one.

## Removing

```sh
stow --dir ~/.dotfiles/modules --target ~ --delete <module>
```

This reverses the symlinks only. It never removes packages — uninstalling system
software is destructive and is not what "remove your dotfiles" means. Any `.bak`
files are left alone, so restoring them stays a deliberate act.
