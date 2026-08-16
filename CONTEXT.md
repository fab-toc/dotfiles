# Dotfiles

A public, distribution-agnostic dotfiles repository. Its purpose is that the _configuration_ is identical and correct on every machine — Arch, Ubuntu, or Debian, desktop or headless server. Installation is only the means to that end.

## Language

### Configuration

**Module**:
A directory under `modules/` holding one tool's configuration, laid out as it should appear relative to `$HOME`, and named for that tool. The unit a person chooses to install or skip — by linking or by copying.
_Avoid_: package (means a distro package here), stow package, dotfile

**Link Mode**:
Installing modules by symlinking them from the repository with stow. Edits to an installed file are edits to the repository, and the repository must stay where it is.
_Avoid_: stow mode, symlink install

**Copy Mode**:
Installing modules by copying them. The repository can be deleted afterwards; nothing writes back, and updating means installing again. Everything else — packages, machine state, the report — is identical to link mode.
_Avoid_: export, vendor, snapshot

**Guard**:
A runtime check that lets one byte-identical configuration file behave correctly whether or not a given tool is present. A guard tests for what is present — a binary, a file — never for which distribution it is running on.
_Avoid_: fallback, conditional, feature detection

**Local Config**:
An untracked, machine-specific file that a tracked config pulls in, holding what genuinely cannot be shared — identity, keys, secrets.
_Avoid_: override, private config, zshrc.local

### Installation

**Tool**:
A piece of software the repository knows about. A tool may have a module, or may be used with its defaults. Having no module does not make a tool invisible here — every tool has a row in the manifest.
_Avoid_: program, app, dependency

**Manifest**:
`tools.json`, the registry of every tool in the environment. One entry per tool, with a source for each distribution, whether it is graphical, whether it is selected by default, optionally why it is what it is, and optionally which SSH keys its configuration expects. Whether a tool has a module is not recorded — the presence of `modules/<tool>/` is the fact.
_Avoid_: package list, config file, install list

**Source**:
What a manifest cell holds: where a tool comes from on that distribution. One of a package name, `mise`, `manual`, `excluded`, or `unsupported`.
_Avoid_: rung, provider, backend

**Ladder**:
The ordered sources tried for a tool on a given distribution. The order differs per distribution and is not symmetric: on Arch it is the official repositories, then the AUR; on Debian and Ubuntu it is apt, then mise. Every ladder ends in one of the three terminal sources.
_Avoid_: strategy, fallback chain

**Manual**:
A source meaning the tool cannot be installed automatically here, but can be installed by hand. `docs/setup/<tool>.md` says how, and the installer reports it as outstanding work.
_Avoid_: skipped, todo, deferred

**Excluded**:
A source meaning the tool is deliberately not installed here because another source already covers the need. Working as intended, and never reported.
_Avoid_: disabled, ignored, off

**Unsupported**:
A source meaning a tool cannot be had on a distribution at all. An honest, reported outcome — not a failure.
_Avoid_: missing, broken, unavailable

**Selection**:
The tools this run installs, and therefore the modules it links. Either the tools named as arguments — each bringing along the tools its configuration integrates with — or, when none are named, the manifest's defaults, remembered per machine. Naming tools decides one run; it never changes what the machine remembers.
_Avoid_: profile, preset, subset

**Machine State**:
The record, kept at `$XDG_STATE_HOME/dotfiles/state` as tab-separated `key<TAB>value` lines, of which tools a given machine selected, whether it is headless, and which directory its modules are linked from. What makes re-runs silent and repeatable.
_Avoid_: state file, cache, local manifest

**Headless**:
A machine that is declared, never detected, to have no graphical session. Graphical tools are skipped there.
_Avoid_: server, CLI-only, no-GUI

**Backup**:
An existing file that installing would have replaced, moved aside to `.bak` and reported before either mode touches it. Never silently discarded, never absorbed into this repository.
_Avoid_: conflict, adopted file
