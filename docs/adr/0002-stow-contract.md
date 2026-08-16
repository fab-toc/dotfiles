# GNU Stow from wherever the repository lives, with backups on conflict and no `--adopt`

Configuration is symlinked into `$HOME` by GNU Stow, using `--dir modules --no-folding`.

**The location is yours to choose, and fixed once chosen.** Symlinks encode the repository's absolute path, so what stow actually requires is stability, not a particular directory — an earlier version of this ADR conflated the two and hardcoded `~/.dotfiles`. The installer now takes its own directory as the repository (`$DOTFILES_DIR` decides only where a piped run clones to, defaulting to `~/.dotfiles`) and records that path in machine state. Run later from a different directory, it **refuses** while the recorded one still exists — unstow there first, or the old links are orphaned with nothing to remove them — and **adopts the new path with a warning** when the recorded one is gone, because by then the links are already broken and there is nothing left to clean up.

Only selected modules are linked. A module directory whose tool was not selected is configuration for something the machine does not have, and linking it anyway was a bug this rule removes.

Stow is what makes editing a config _in place_ on any machine write through to the repository, which is the whole reason it was chosen over a copy-based installer.

## Considered Options

**`--adopt`** is the usual answer to stow's habit of aborting when a real file sits where a symlink should go. It is rejected outright: `--adopt` pulls the machine's existing file _into the repository_, silently overwriting tracked configuration with whatever was on that machine. It can corrupt the source of truth, and it does so quietly.

Instead, a conflicting file is moved to `<name>.bak` and every backup is reported at the end of the run. This matters most on exactly the machines stow handles worst — ones already carrying a hand-edited `~/.bashrc` or `~/.profile`.

**Folding** (stow's default of linking whole directories) is disabled with `--no-folding`, so only files this repository actually tracks are linked. A folded directory link would silently capture unrelated files created later.

## The installer is its own entry point

There is no `bootstrap.sh`. `install.sh` is fetched and piped to `sh`; finding no checkout around it — `$0` is `sh` or `-` under a pipe, and resolves to a directory holding `tools.json` otherwise — it clones the repository and re-execs itself from the clone. A separate bootstrap existed only because `$0` is unreliable in a pipe, which is a fact one `if` can handle rather than a second file that must be kept in step with the first.

Because a pipe cannot take arguments without `sh -s --`, a piped run passes its selection through `$DOTFILES_MODULES` to the re-exec.

## Consequences

`--unstow` reverses the symlinks and _reports_ any `.bak` files it finds without touching them, leaving restoration deliberate. It never uninstalls packages — removing system packages is destructive and is not what "remove your dotfiles" means.
