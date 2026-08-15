# No zsh plugin manager: plugins come from distribution packages

Zsh plugins are installed as ordinary distribution packages and sourced by a small helper that tries each packaging convention's path, because those paths differ between Arch and Debian. There is no plugin manager.

The previous setup git-cloned [zinit](https://github.com/zdharma-continuum/zinit) from inside `.zshrc` and let it fetch each plugin at shell startup. Zinit is packaged nowhere — not in Arch's repositories, not in Debian's, not in the AUR — so the clone was unavoidable, which put a network fetch on the critical path of every login shell. A network hiccup broke the shell.

## What is actually sourced

Only two plugins are sourced, and **the order matters**: `zsh-syntax-highlighting` must come last, after everything that defines widgets. The helper is therefore called once per plugin in a deliberate order rather than looping over an unordered set, so that a future reader sees two named lines instead of an array they might sort alphabetically.

`zsh-completions` is **not** sourced. It installs completion functions into `/usr/share/zsh/site-functions`, which is already in `$fpath` before `.zshrc` runs, so it needs no configuration at all — only a manifest row. It is absent from both Debian and the AUR, so its Debian source is `unsupported`.

## Considered Options

**Sheldon** was the strongest alternative: it is in Arch's official repositories, installable via mise elsewhere, and it is declarative — a tracked `plugins.toml` and a lockfile would pin plugin versions identically across machines, which fits this repository's goals well. It was rejected to avoid adding a tool whose only job is to fetch two files that the distributions already package.

## Consequences

**`fzf-tab` is dropped**, by choice rather than by constraint. An earlier version of this ADR recorded it as lost because it was "packaged nowhere", and named it as the one thing that would justify revisiting Sheldon. That was wrong on the fact — it is in the AUR, which is a legitimate rung on Arch — and moot on the decision, because it is no longer used. Nothing now argues for a plugin manager.

**`diff-so-fancy` is dropped.** It was git's pager and `interactive.diffFilter`, and it could not be guarded: git configuration has no mechanism to test whether a binary exists (`includeIf` supports only `gitdir:`, `onbranch:` and `hasconfig:`), so on any machine without it both `git diff` and `git add -p` broke outright. Since it is packaged on Arch but nowhere on Debian, that was guaranteed to happen. Git's own output — `diff.algorithm = histogram`, `colorMoved`, `mnemonicPrefix`, `interHunkContext` — is used instead. This is the durable fix: the `git` module now names no external binary, so there is nothing left to guard in the one file that cannot express a guard. If a pager is ever wanted again, the correct route is a tracked shim in `$XDG_BIN_HOME` that execs the tool if present and falls through to `$PAGER` otherwise, never a bare command in `git/config`.
