# No zsh plugin manager: plugins come from distribution packages

Zsh plugins are installed as ordinary distribution packages and sourced from a small loop over candidate paths, because those paths differ between Arch and Debian. There is no plugin manager.

The previous setup git-cloned [zinit](https://github.com/zdharma-continuum/zinit) from inside `.zshrc` and let it fetch each plugin at shell startup. Zinit is packaged nowhere — not in Arch's repositories, not in Debian's, not in the AUR — so the clone was unavoidable, which put a network fetch on the critical path of every login shell. A network hiccup broke the shell.

## Considered Options

**Sheldon** was the strongest alternative: it is in Arch's official repositories, installable via mise elsewhere, and it is declarative — a tracked `plugins.toml` and a lockfile would pin plugin versions identically across machines, which fits this repository's goals well. It was rejected to avoid adding a tool whose only job is to fetch three files that the distributions already package.

## Consequences

**`fzf-tab` is lost.** It is packaged nowhere and there is no plugin manager to fetch it, so its completion menu and the `zstyle ':fzf-tab:complete:cd:*'` preview are gone. This is the accepted price of the decision, and it is the one thing that would justify revisiting it in favour of Sheldon.

`diff-so-fancy` is in Arch's official repositories but not reliably elsewhere, so git's pager and `interactive.diffFilter` must degrade to a plain diff rather than error where it is missing.
