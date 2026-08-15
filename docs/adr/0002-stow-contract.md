# GNU Stow at a fixed path, with backups on conflict and no `--adopt`

Configuration is symlinked into `$HOME` by GNU Stow from `~/.dotfiles`, using `--dir modules --no-folding`. Symlinks encode the repository's absolute path, so the location is a permanent contract: moving the repository dangles every link, and the installer refuses to run from anywhere else.

Stow is what makes editing a config _in place_ on any machine write through to the repository, which is the whole reason it was chosen over a copy-based installer.

## Considered Options

**`--adopt`** is the usual answer to stow's habit of aborting when a real file sits where a symlink should go. It is rejected outright: `--adopt` pulls the machine's existing file _into the repository_, silently overwriting tracked configuration with whatever was on that machine. It can corrupt the source of truth, and it does so quietly.

Instead, a conflicting file is moved to `<name>.bak` and every backup is reported at the end of the run. This matters most on exactly the machines stow handles worst — ones already carrying a hand-edited `~/.bashrc` or `~/.profile`.

**Folding** (stow's default of linking whole directories) is disabled with `--no-folding`, so only files this repository actually tracks are linked. A folded directory link would silently capture unrelated files created later.

## Consequences

`--unstow` reverses the symlinks and _reports_ any `.bak` files it finds without touching them, leaving restoration deliberate. It never uninstalls packages — removing system packages is destructive and is not what "remove your dotfiles" means.
