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

Requires `git` and `curl`. Install them first — the installer deliberately
arranges nothing on your behalf before you have read it.

```sh
sudo pacman -S git curl      # Arch
sudo apt install git curl    # Debian / Ubuntu
```

Everything:

```sh
curl -fsSL https://raw.githubusercontent.com/fab-toc/dotfiles/main/install.sh | sh
```

Or only the parts you want — naming a tool brings along the ones its
configuration integrates with, so `zsh` arrives with its prompt, completions and
the tools its aliases call:

```sh
curl -fsSL .../install.sh | DOTFILES_MODULES="zsh git" sh
curl -fsSL .../install.sh | sh -s -- zsh git          # same thing
```

Piped, the installer finds no repository around it, so it clones one and
re-execs itself from the clone. Read it before you pipe it — it is the only file
you have to trust.

### Where it lives

`~/.dotfiles` by default; set `DOTFILES_DIR` to clone somewhere else, or clone
by hand and run `./install.sh` from wherever you put it.

The location is yours, but it is fixed once chosen: GNU Stow encodes the
repository's absolute path into every symlink it makes. The installer remembers
where it ran from and refuses to run from a second location while the first one
still exists — unstow there first, or you leave broken links behind that nothing
owns. If the old directory is already gone, it adopts the new path and says so.

Selecting tools by argument decides that run only. It does not change what the
machine remembers, so a later bare `./install.sh` still installs the defaults.

## What the installer does

Reads [`tools.json`](./tools.json), installs each selected tool from the source
named for your distribution, installs the modules of the tools it selected, and
ends with a report of everything still outstanding.

A conflicting file already in your home directory is moved to `<name>.bak` and
reported — never overwritten, never absorbed into the repository. Link mode never
uses `stow --adopt`, which would do exactly that. A symlink left over from a
repository that has moved or been deleted is removed and reported, as is one that
copy mode is about to replace.

### Link or copy

The installer asks once per machine, and remembers ([ADR-0009](./docs/adr/0009-copy-mode.md)):

| Mode           | What it does                    | What it costs                                                     |
| -------------- | ------------------------------- | ----------------------------------------------------------------- |
| `--link`       | `stow --no-folding` from the repo | The repository has to stay put                                     |
| `--copy`       | plain copies of the same files  | No write-back, no `git pull` updates, no uninstall — run it again  |

Copy mode is a full install — packages, state, report — differing only in that
last step. It exists so you can take the parts you want and delete the
repository afterwards. The installer says so at the end of every copy run,
because a configuration that quietly stops receiving updates is worse than one
that never arrived.

The report is the whole safety net — there is no test suite, knowingly
([ADR-0007](./docs/adr/0007-testing-deferred.md)) — so it lists tools to install
by hand, tools unavailable on your distribution, tools that installed but need
setup steps, files moved aside, and missing SSH keys.

Outstanding manual work is reported, not treated as failure — it exits zero with
`manual` items pending. Anything the installer *tried and failed* to do fails the
run: a package that would not install, a module that would not link or copy, or
missing SSH keys you asked it to treat as fatal.

Which SSH keys a tool expects is declared in its manifest entry, and only the
tools you selected are ever checked. The installer asks once per machine whether
a missing key should fail the run — say yes on a machine where `commit.gpgsign`
must never silently start failing, no if you are installing someone else's
configuration.

Re-runs are silent. Which tools a machine selected, whether it is headless, which
mode it uses and where it installed from are remembered in
`$XDG_STATE_HOME/dotfiles/state` — outside the repository, where `git clean -xdf`
cannot reach them.

## Where tools come from

Each tool has an entry in [`tools.json`](./tools.json) with a source per
distribution, and an optional `note` saying why. A source is a package name or one of:

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

- `modules/` — one directory per tool, named for it and laid out relative to
  `$HOME`. The only thing ever installed into your home directory.
- `tools.json` — the manifest.
- `docs/adr/` — the decisions, and the alternatives already rejected.
- `docs/setup/` — the manual and post-install steps.
- [`CONTEXT.md`](./CONTEXT.md) — the vocabulary. Read it first.

Several choices here look wrong until you know why they were made. The ADRs say
why; check them before "fixing" one.

## Removing

Link mode:

```sh
stow --dir <repo>/modules --target ~ --delete <module>
```

This reverses the symlinks only. It never removes packages — uninstalling system
software is destructive and is not what "remove your dotfiles" means. Any `.bak`
files are left alone, so restoring them stays a deliberate act.

Copy mode has no undo: the files are yours, and deleting them is your business.
That is the trade you made when you chose it.

Moving the repository is an unstow here, a move, then a fresh install — the
symlinks encode the old path and nothing repairs them in place.
