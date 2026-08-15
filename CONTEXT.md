# Dotfiles

A public, distribution-agnostic dotfiles repository. Its purpose is that the _configuration_ is identical and correct on every machine — Arch, Ubuntu, or Debian, desktop or headless server. Installation is only the means to that end.

## Language

### Configuration

**Module**:
A directory under `modules/` holding one tool's configuration, laid out as it should appear relative to `$HOME`. The unit a person chooses to install or skip.
_Avoid_: package (means a distro package here), stow package, dotfile

**Guard**:
A runtime check that lets one byte-identical configuration file behave correctly whether or not a given tool is present.
_Avoid_: fallback, conditional, feature detection

**Local Config**:
An untracked, machine-specific file that a tracked config pulls in, holding what genuinely cannot be shared — identity, keys, secrets.
_Avoid_: override, private config, zshrc.local

### Installation

**Tool**:
A piece of software the repository installs. A tool may have a module, or may be used with its defaults.
_Avoid_: program, app, dependency

**Manifest**:
`tools.tsv`, the table mapping each tool to its package name per distribution, its fallback, whether it is graphical, and whether it is selected by default.
_Avoid_: package list, config file, registry

**Ladder**:
The ordered set of sources tried when installing a tool: the distribution's own repository first, then mise, then declaring the tool unsupported there.
_Avoid_: strategy, fallback chain

**Unsupported**:
A deliberate declaration that a tool cannot be installed on a given distribution. An honest, reported outcome — not a failure.
_Avoid_: missing, broken, unavailable

**Bootstrap**:
The piped entry script. It ensures git is present, clones this repository to `~/.dotfiles`, and hands off to the installer.
_Avoid_: setup, init

**Machine State**:
The record, kept outside this repository, of which tools a given machine selected and whether it is headless. What makes re-runs silent and repeatable.
_Avoid_: state file, cache, local manifest

**Headless**:
A machine that is declared, never detected, to have no graphical session. Graphical tools are skipped there.
_Avoid_: server, CLI-only, no-GUI

**Backup**:
An existing file that stow would have overwritten, moved aside to `.bak` and reported. Never silently discarded, never absorbed into this repository.
_Avoid_: conflict, adopted file
