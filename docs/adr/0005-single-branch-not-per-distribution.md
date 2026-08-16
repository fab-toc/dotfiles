# One branch for all distributions, not a branch per distribution

`main` is the single supported branch. Configuration files are byte-identical on every machine and adapt at _runtime_ through guards; they are never forked per distribution.

This reverses an earlier strategy of a branch per distribution, of which `arch` is the surviving artefact. That approach guaranteed permanent divergence: a fix made on one branch would have to be merged into every other, and the branches would drift apart exactly where they were most similar. It is also incompatible with the core goal — if the branches differ, the configuration is not the same everywhere.

## Guards test for presence, not for distribution

Anything distribution-specific is expressed as a guard on **what is present** — a binary on `$PATH`, a file on disk — never on what `/etc/os-release` says. The two look interchangeable and are not: presence is the thing the configuration actually depends on, and distribution is a proxy for it that is wrong at the edges.

The proxy was wrong here in three places, all of them live bugs:

- `alias cat=bat` on Arch, `batcat` elsewhere. On any machine where bat is not installed at all, `cat` was aliased to a missing binary. Guarding on `command -v bat` / `command -v batcat` is correct everywhere and needs no distribution check.
- `alias i="yay -S"` on Arch. On a fresh Arch machine, before `yay` is bootstrapped, this aliases to a binary that does not exist. Trying `yay`, then `pacman`, then `apt` — first hit wins — is correct at every point in the machine's life.
- A `distro()` function carrying arms for redhat, suse, gentoo and slackware, none of which any consumer handled. Distributions this repository has never supported appeared to be supported.

`distro()` was deleted as a consequence. Nothing in this repository parses `/etc/os-release`.

## Consequences

Alias _names_ are part of the configuration contract and are identical everywhere; their implementations may differ. `i`, `u`, and `s` mean the same thing on every machine even though one resolves to `yay` and another to `apt` — but which one is chosen by asking the machine what it has, not what it is.

Where a shared file cannot express the difference — identity, secrets — it belongs in an untracked local config instead.

Generated configuration is rejected for the same reason: a file written at install time is invisible, drifts from the repository, and differs per machine by construction. This extends to documentation that duplicates data: a README table generated from `tools.json` and committed would drift the same way, so the README links to the manifest instead.
