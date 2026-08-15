# Testing is deferred, knowingly; the closing report stands in for it

There is no test suite and no CI. This is a deliberate choice for a small personal repository, recorded here so it reads as a decision rather than an oversight.

## Considered Options

A **container matrix** — running the real install inside `archlinux`, `debian:stable`, and `ubuntu:lts` images — was proposed both as GitHub Actions and as a local script invoked by hand. Both were declined as disproportionate to the project's size.

## The closing report

Because nothing tests the install, the report the installer prints at the end is the only defence against the failure mode below, which makes its contents a design decision rather than formatting. It lists:

- every `manual` tool, with the path to its `docs/setup/<tool>.md`
- every `unsupported` tool, with the distribution that lacks it
- every `.bak` file stow moved aside (ADR-0002)
- missing SSH keys, with the Proton Pass instruction (ADR-0004)
- every tool that has a `docs/setup/<tool>.md` file, whatever its source

That last category catches the tools which install cleanly but still need a human — group membership, socket enablement, ACLs, as libvirt does. The file's existence is the flag, so the manifest needs no column for it and the two cannot fall out of sync.

`excluded` tools are never listed. They are working as intended, and a report that mentions them trains you to skim it.

The run **exits zero with outstanding `manual` items** and non-zero only if a module failed to stow or the SSH keys are absent. The distinction is "did the installer do its job" versus "is the machine finished": a `manual` item is correctly-reported work, and failing the run on it would teach you to ignore the exit code. Missing keys are different because ADR-0004 makes every commit fail until they are present, so the machine is not usable. A one-line summary count comes last, since a report you must scroll up for is a report you will not read.

## Consequences

This is the largest known risk in the design, for a specific reason: the repository claims to work on three distributions, but only Arch is ever exercised. The Debian and Ubuntu paths are unverified on every change.

That risk is not hypothetical. The `install.sh` that preceded this design referenced an undefined `$DISTRO_FAMILY` and therefore _installed nothing at all_ while exiting successfully, sourced a filename that did not exist, and generated a `zshrc.local` that nothing ever read. Silent, plausible-looking success is this project's characteristic failure mode, and it is exactly what a test would catch.

If testing is ever revisited, the single highest-value assertion is that an interactive zsh starts with no output on stderr. It catches the whole class of bugs where a config references a tool that is not installed.

It must be run **under a pseudo-terminal**:

```sh
script -qec 'zsh -i -c exit' /dev/null
```

A bare `zsh -i -c exit` is not a usable assertion. Without a terminal, zle cannot be enabled, so `fzf`, `zoxide`, `starship` and `mise` each emit `can't change option: zle` — failures that say nothing about the configuration and that would train you to ignore the check.
