# mise may be installed on Arch, but never given a global config

ADR-0001 makes mise a rung on Debian and Ubuntu only; on Arch its manifest source is `manual`. That records what this repository installs. It does not forbid you from installing mise on an Arch machine yourself, and there is a good reason to: a project whose contributors use mise may pin its toolchain in a `mise.toml`, and working in that repository means honouring it.

The condition is absolute: **never create `~/.config/mise/config.toml`.**

## Why that one rule carries the whole decision

`mise activate zsh` installs a hook that recomputes `PATH` at every prompt. It walks up from the current directory collecting config files and merges them, nearest-wins, and prepends `~/.local/share/mise/installs/<tool>/<version>/bin` only for the tools the resolved config actually activates. Outside any directory tree containing a mise config, mise contributes nothing and pacman's binaries are untouched. Inside a project pinning Node 20, mise's Node 20 shadows `extra/nodejs` — and only within that tree.

A global config is merged into *every* resolution. A single `tools.node = "20"` in `~/.config/mise/config.toml` would shadow pacman's node in your home directory, in `/tmp`, everywhere — and mise would have quietly become the package manager for that tool on a system where ADR-0001 says it manages nothing. Nothing in mise prevents this, and no guard in this repository can detect it. It is a discipline, which is why it is written down.

The corollary: every mise-managed tool on an Arch machine belongs to a project. `mise use` inside a repository, never `mise use -g`.

## Considered Options

**Forbidding mise on Arch outright** was the literal reading of "I do not want to use mise at all on Arch". It was rejected because it makes the machine unable to work in repositories that require it, for a rule that only ever needed to constrain *scope*.

**A fifth manifest value, `excluded`, for mise's Arch cell** was considered and is wrong here. `excluded` means the need is covered by another source and the tool should not be installed; mise on Arch is genuinely installable by hand for a real purpose, which is exactly what `manual` means. (`excluded` was still added, for cases like nvm on Debian — see ADR-0001.)

**Shims mode** (`~/.local/share/mise/shims` permanently on `PATH`) instead of `mise activate` was not adopted. It resolves per-directory too, but it places a directory of interceptors ahead of the system's binaries at all times, which is a larger standing commitment than a hook that recomputes `PATH`.

## Consequences

The `mise activate` line in `.zshrc` stays guarded on `command -v mise` and is byte-identical everywhere. On Debian it activates the rung; on Arch it activates nothing unless you have chosen to install mise, and then only inside projects. Invariant 2 holds without a special case.

mise's `.nvmrc` support is **disabled by default**, behind `idiomatic_version_file_enable_tools`. That is what keeps it from colliding with nvm, which is the Node manager on Arch (ADR-0001). Leave it disabled: `.nvmrc` belongs to nvm, `mise.toml` belongs to mise, and enabling it would give two managers a claim on the same file.
