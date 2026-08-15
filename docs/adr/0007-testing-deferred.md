# Testing is deferred, knowingly

There is no test suite and no CI. This is a deliberate choice for a small personal repository, recorded here so it reads as a decision rather than an oversight.

## Considered Options

A **container matrix** — running the real install inside `archlinux`, `debian:stable`, and `ubuntu:lts` images — was proposed both as GitHub Actions and as a local script invoked by hand. Both were declined as disproportionate to the project's size.

## Consequences

This is the largest known risk in the design, for a specific reason: the repository claims to work on three distributions, but only Arch is ever exercised. The Debian and Ubuntu paths are unverified on every change.

That risk is not hypothetical. The `install.sh` that preceded this design referenced an undefined `$DISTRO_FAMILY` and therefore _installed nothing at all_ while exiting successfully, sourced a filename that did not exist, and generated a `zshrc.local` that nothing ever read. Silent, plausible-looking success is this project's characteristic failure mode, and it is exactly what a test would catch.

If testing is ever revisited, the single highest-value assertion is that `zsh -i -c exit` completes with no output on stderr. It catches the whole class of bugs where a config references a tool that is not installed.
