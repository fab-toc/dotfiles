# SSH keys are fetched by hand from the Proton Pass web vault

The `ssh` module ships `~/.ssh/config` only — host entries and `IdentityFile` paths, never key material, since this repository is public. After installing on a new machine, the two keys are downloaded manually from the Proton Pass web vault. The installer checks whether the key files exist and, if not, ends with instructions rather than reporting success.

## Considered Options

**Proton Pass CLI as an SSH agent** was the automated alternative and would have made keys appear the moment you sign in. It was rejected on availability: `proton-pass-cli` is AUR-only on Arch and absent from Debian and Ubuntu entirely, making it the one tool in the stack that fits nowhere on the ladder in ADR-0001. Dropping it removes that exception, and keys as plain files work with the stock `ssh-agent` on every distribution.

## Consequences

Bringing up a new machine has a manual step. This is consistent with syncing being manual everywhere else in this design.

`commit.gpgsign = true` means **every git commit fails until the signing key is present**. This is the first thing you would do on a new machine, so the installer must say so loudly rather than exiting quietly.

Git configuration splits into a tracked shared part and an untracked `config.local`, pulled in via `[include]`, holding identity and the signing key path.
