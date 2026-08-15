# SSH keys are fetched by hand from the Proton Pass web vault

The `ssh` module ships `~/.ssh/config` only — host entries and `IdentityFile` paths, never key material, since this repository is public. After installing on a new machine, the two keys are downloaded manually from the Proton Pass web vault. The installer checks whether the key files exist and, if not, ends with instructions rather than reporting success.

## The agent is not started by this repository

`~/.ssh/config` sets `AddKeysToAgent yes`, so keys are added to whatever agent the session already provides, on first use. Nothing in this repository starts an agent.

`IdentitiesOnly yes` is set alongside it so that ssh offers only the key named for a host rather than every key it can find, which otherwise trips server-side authentication attempt limits once more than one key is present.

## Considered Options

**Proton Pass CLI as an SSH agent** was the automated alternative and would have made keys appear the moment you sign in. It was rejected on availability: `proton-pass-cli` is AUR-only on Arch and absent from Debian and Ubuntu entirely, making it the one tool in the stack that fits nowhere on the ladder in ADR-0001. Dropping it removes that exception, and keys as plain files work with the stock `ssh-agent` on every distribution.

**Starting `ssh-agent` from `.zshrc`** was the previous approach, commented out rather than removed. It is rejected: it spawns an agent per interactive shell unless its `pgrep` guard is exactly right, and it fails silently when the key files are absent — the precise failure mode this ADR exists to make loud.

**A systemd user service** for the agent is better engineering and was still declined. It would add unit files to a repository that has deliberately stayed at "configuration files in `$HOME`", and `AddKeysToAgent` covers the actual need with a line in a file the module already ships — which also means a stranger cherry-picking the `ssh` module gets the same behaviour.

## Consequences

Bringing up a new machine has a manual step. This is consistent with syncing being manual everywhere else in this design.

`commit.gpgsign = true` means **every git commit fails until the signing key is present**. This is the first thing you would do on a new machine, so the installer must say so loudly rather than exiting quietly. Missing keys are one of only two conditions that make the installer exit non-zero.

Git configuration splits into a tracked shared part and an untracked `config.local`, pulled in via `[include]`, holding identity and the signing key path. No template or example file is shipped for it — a half-filled template looks configured and is not. `docs/setup/git.md` lists the required keys verbatim instead, and the installer's closing report points there when the file is absent.
