# SSH

## Keys are fetched by hand

This repository is public and contains no key material. After installing on a
new machine, download both keys from the Proton Pass web vault into `~/.ssh`:

- `~/.ssh/github_key` — GitHub, and git commit signing
- `~/.ssh/its_servers` — ITS infrastructure

```sh
chmod 600 ~/.ssh/github_key ~/.ssh/its_servers
```

The installer checks for both and exits non-zero if either is missing.
`commit.gpgsign = true` means every git commit fails until the signing key is
there, so this is reported loudly rather than passed over.

## The host inventory is local, not tracked

`~/.ssh/config` is the tracked module and holds **defaults only**. Real
hostnames, internal addresses and ports describe live infrastructure and do not
belong in a public repository, so they live in an untracked
`~/.ssh/config.local`, included from the top of the tracked file.

```
# ~/.ssh/config.local
Host its-*
  IdentityFile ~/.ssh/its_servers
  User root
  AddressFamily inet

Host its-example
  Hostname 192.168.0.1
```

The include comes first because in `ssh_config` the **first** obtained value for
a parameter wins, so host-specific settings must be read before the `Host *`
defaults.

## No agent is started

`AddKeysToAgent yes` in the tracked config loads a key into whatever agent the
session provides, on first use. Nothing in this repository starts an agent, and
nothing should: an agent started from `.zshrc` spawns one per interactive shell
and fails silently when keys are absent. See ADR-0004.

`IdentitiesOnly yes` is set so ssh offers only the key named for a host. Without
it, more than one key on disk means servers reject you for too many failed
attempts before the right key is tried.

Verify what ssh will actually do for a host without connecting:

```sh
ssh -G its-example
```
