# Tool sources follow a ladder: distribution repository, then mise, then unsupported

Every tool is installed from the distribution's own package manager where possible, from [mise](https://mise.jdx.dev/) where the distribution's version is too old or the tool is absent, and is otherwise declared unsupported on that distribution. The goal is that installed software stays tracked by the system — visible to `pacman`/`apt`, removable, upgradable — rather than arriving as untracked blobs cloned or curl-piped into `$HOME`.

## Considered Options

**Nix / home-manager** was the obvious alternative and would give byte-identical tooling on every distribution — genuinely stronger reproducibility than this design achieves. It was rejected because it replaces the host's package management rather than using it, which is precisely the property we wanted, and because it is a large commitment for a configuration repository.

**Flatpak as a rung for graphical tools** was considered and rejected. It would have made Ghostty and Zed installable on Debian and Ubuntu, but sandboxing degrades a terminal emulator's integration with the host shell, and it adds a third mechanism to maintain for machines that are mostly headless anyway.

## Consequences

Tool _versions_ differ between machines even though configuration does not. Debian and Ubuntu will run older builds of anything mise does not cover.

mise itself is not packaged for Debian or Ubuntu, so bootstrapping it there is a `curl | sh` — a knowing exception to the rule above. It earns its place: one untracked binary makes every tool beneath it declarative, and it eliminates Debian's renamed binaries (`batcat`, `fdfind`) that previously forced per-distribution aliases and a generated config file.

Because mise does not install graphical applications and Flatpak was rejected, **Ghostty and Zed are Arch-only**. On a Debian or Ubuntu desktop their modules are skipped and neither tool's configuration applies.

`yay` is bootstrapped on Arch via `base-devel` and `makepkg -si`. This is a clone and a local build, but it is the only mechanism the AUR has and it ends in a pacman-registered package, so it counts as native. The installer never _depends_ on `yay` for its own work.
