# Copy mode: the same install without stow, for people who want the repository gone

The installer installs modules in one of two modes, chosen by an explicit prompt on first run and remembered per machine (`--link` / `--copy` skip the question).

**Link mode** is stow, and it is what this repository was built around: edits to `~/.config/git/config` are edits to the repository, which is the property ADR-0002 chose stow for.

**Copy mode** writes the same files as plain copies. Nothing is linked, the repository can be deleted afterwards, and the configuration is simply files the machine owns now.

Copy mode exists because someone reading this repository on GitHub and wanting the zsh configuration does not necessarily want a git checkout living in their home directory forever. Telling them to clone, stow, and then keep the clone is asking them to adopt a maintenance relationship they did not ask for.

## What copy mode gives up, and says so

Every property stow was chosen for is gone: edits do not write back, pulling the repository updates nothing, and there is no uninstall — `stow -D` knows what it linked, `cp` does not. These are not defects to be fixed later; they are what "copy" means.

The installer therefore **says this at the end of every copy-mode run** rather than leaving it to be discovered, and the mode prompt states the consequence of each answer before it is chosen. Silent success is this project's known failure mode (ADR-0007), and copies that no update will ever reach are exactly that: everything looks installed and stays frozen.

## Copy mode is a full install, not an export

It installs packages, writes machine state, and reports the same way. Only the last step differs. An earlier draft called it "export mode" and scoped it to files only; that name undersold what it does and the scope would have made "install someone else's configuration" a two-command job for no gain.

## Two things a copy must do that a link never had to

**Permissions.** A symlink points at the repository's own file and inherits its mode. A copy does not, and `~/.ssh` is where that becomes silently fatal: ssh ignores a config or key it considers world-readable and gives no useful reason. Copy mode uses `cp -p`, then forces `700` on `~/.ssh` and `600` on its files whenever the `openssh` module was installed.

**Backups.** Stow refuses to overwrite a real file, which is what made the backup pass safe. `cp` has no such scruple, so the pass that moves a conflicting file to `<name>.bak` runs before either mode touches anything — it protects link mode from an abort and copy mode from a silent overwrite.

## Consequences

Machine state records the mode, and the recorded repository path is written **only in link mode** — copy mode makes no symlinks, so it is bound to no directory and the "you moved the repository" check does not apply to it.

A machine that copied and then deleted the repository keeps a state file describing something that no longer exists. It is reported, not cleaned up: deleting a record of what a machine has is not something an installer should do quietly.

## Considered Options

**Tracking every copied file in machine state**, so that update and uninstall could still work. Rejected: that is reimplementing stow, badly, in a script with no tests, to recover properties the user gave up on purpose by choosing copy.

**Not offering it.** Defensible — "clone it and copy the files yourself" is a complete answer. Rejected because the copy that people would then do by hand is the one that skips the backup pass and the `~/.ssh` modes, which are the two things that actually go wrong.
