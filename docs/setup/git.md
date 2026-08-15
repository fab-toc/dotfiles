# Git identity

`~/.config/git/config` is tracked and shared. Everything machine-specific lives
in `~/.config/git/config.local`, which is untracked, pulled in by an `[include]`
at the top of the shared file, and **never committed** — this repository is
public. See ADR-0004.

No template or example file is shipped: a half-filled template looks configured
and is not. Create the file by hand with these four keys.

```ini
[user]
  name = Your Name
  email = you@example.com
  # SSH key used for signing. commit.gpgsign = true is set in the shared
  # config, so every commit fails until this resolves to a real key.
  signingkey = ~/.ssh/github_key.pub

[gpg "ssh"]
  # Optional: lets `git log --show-signature` verify your own commits.
  allowedSignersFile = ~/.config/git/allowed_signers
```

If you set `allowedSignersFile`, that file holds one line per signer:

```
you@example.com ssh-ed25519 AAAAC3Nza...
```

The key itself is downloaded from the Proton Pass web vault — see
[openssh.md](./openssh.md). Until it exists, every commit fails, which is why
the installer exits non-zero rather than reporting success.
