# Working in this repository

Read [CONTEXT.md](./CONTEXT.md) first for the vocabulary, then [docs/adr/](./docs/adr/) for the decisions and the alternatives already rejected. Several choices here look wrong until you know why they were made — check the ADRs before "fixing" one.

## The two invariants

Everything else follows from these:

1. **The repository contains only what is identical on every machine.** No generated files, no per-machine files, no per-distribution branches or forks of a config. Anything that legitimately differs — identity, keys, host inventories, machine state — lives outside the repository.
2. **Configuration files are byte-identical everywhere; only their runtime behaviour differs.** A config adapts by guarding on what is present, never by being rewritten, regenerated, or branched.

## Rules that follow

- **Guard every integration.** Any reference to a tool from a config must tolerate that tool being absent. An unguarded `eval "$(foo init zsh)"` breaks the login shell on every machine that lacks `foo` — and a stranger cherry-picking a single module from this public repository will hit exactly that.
- **Guard on presence, never on distribution.** `command -v bat`, not `$ID = arch`. The two look interchangeable and are not: presence is what the config actually depends on, and distribution is a proxy that is wrong at the edges. Nothing outside `install.sh` may parse `/etc/os-release`; the installer alone may ask, and only to pick which manifest column to read.
- **State goes in `$XDG_STATE_HOME`, not the repository.** Machine state, shell history, caches. A file inside `~/.dotfiles` is at risk from `git clean -xdf` and breaks invariant 1.
- **Respect the XDG Base Directory specification** wherever a tool supports it. Where a tool does not — `~/.ssh` — leave it alone.
- **Never add key material or secrets.** This repository is public. This extends past keys to anything that describes real infrastructure: hostnames, internal addresses, ports. Those go in a local config — see `modules/ssh/.ssh/config` for the pattern.
- **The installer is POSIX `sh`**, not bash: the entry point is `curl … | sh` and Debian's `/bin/sh` is dash. Assume only `sh`, `git`, `curl`, and a package manager. Lint with `shellcheck -s sh`, format with `shfmt -s`.
- **Fail loudly.** Silent success is this project's known failure mode — see ADR-0007. An unsupported tool is reported, not skipped quietly.
- **Commits follow Conventional Commits.**

## Layout

- `modules/` — one directory per tool's configuration, laid out relative to `$HOME`. Everything stow ever sees.
- `tools.json` — the manifest. An object keyed by tool name; read with `jq`, which the installer installs first. See ADR-0006.
- `docs/adr/` — decisions.
- `docs/setup/` — manual installs and post-install steps. **Filenames must match the tool name in `tools.json` exactly**: the installer flags a tool as needing setup by testing for `docs/setup/<tool>.md`, so a mismatched name silently disables the report.
- `bootstrap.sh` — the piped entry point. `install.sh` — the installer.

Nothing outside `modules/` is ever symlinked into `$HOME`.

## Testing changes

There is no CI. Before changing `install.sh`, run it against a sandbox rather than trusting that it parses — stub the package managers on `$PATH`, point `HOME` at a temporary directory, and check the closing report and exit code. Verifying that a shell config still loads is `zsh -i -c exit` with no output on stderr; that single assertion catches most of the class of bug this repository actually suffers from.
