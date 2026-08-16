# Tool sources form a per-distribution ladder ending in manual, excluded, or unsupported

Every tool is installed from the distribution's own package manager where possible. The goal is that installed software stays tracked by the system — visible to `pacman`/`apt`, removable, upgradable — rather than arriving as untracked blobs cloned or curl-piped into `$HOME`.

The ladder is **not the same on every distribution**:

- **Arch**: official repositories, then the AUR via `yay`.
- **Debian and Ubuntu**: apt, then [mise](https://mise.jdx.dev/).

Every ladder ends in one of three terminal sources: `manual` (installable by hand, see `docs/setup/<tool>.md`), `excluded` (deliberately not installed here because the other ladder covers the need), or `unsupported` (cannot be had here at all). Each tool's source per distribution is a field in `tools.json`; see ADR-0006.

## Why mise is a rung on Debian and not on Arch

mise exists here to compensate for old or absent apt packages. Arch does not have that problem, and it already solves version-juggling natively where it matters — `archlinux-java` for JDKs, `extra/nvm` for Node. Adding mise there would mean two managers competing over the same binaries for no gain, so mise's Arch cell is `manual`: installable, deliberately not installed by this repository. ADR-0008 records the conditions under which you may install it yourself.

mise is installed on Debian and Ubuntu **from its own apt repository**, never by curl-piping its installer:

```sh
# Debian 11+ / Ubuntu 22.04+
sudo apt install -y extrepo && sudo extrepo enable mise
# Ubuntu 26.04+
sudo add-apt-repository -y ppa:jdxcode/mise
```

An earlier version of this ADR claimed mise was "not packaged for Debian or Ubuntu" and granted itself a `curl | sh` exception on that basis. The claim was false and the exception was never earned.

## When a tool takes the mise rung

The rule is "absent from apt, or too old for features actually in use". Whether a version is too old is a judgement no script can make, so it is decided once, by hand, and written into the field — `tools.json` holds either a package name or the literal `mise`. The installer does no version comparison. The cost is that a Debian release which catches up keeps using mise until the row is edited; that is preferred over version arithmetic that is wrong silently.

## Considered Options

**Nix / home-manager** was the obvious alternative and would give byte-identical tooling on every distribution — genuinely stronger reproducibility than this design achieves. It was rejected because it replaces the host's package management rather than using it, which is precisely the property we wanted, and because it is a large commitment for a configuration repository.

**Flatpak as a rung for graphical tools** was considered and rejected. It would have made Ghostty and Zed installable on Debian and Ubuntu, but sandboxing degrades a terminal emulator's integration with the host shell, and it adds a third mechanism to maintain for machines that are mostly headless anyway.

**Automatic version comparison** — a minimum-version column and `dpkg --compare-versions` — was rejected for the reason above: it encodes a judgement about features as a number, and it would need maintaining across three distribution releases.

**A single terminal source** (only `unsupported`) was the original design. It could not distinguish "you cannot have this here" from "install this by hand, here is how", which collapsed a to-do list into a list of regrets. `manual` and `excluded` exist to keep those three states apart, and the closing report treats each differently.

## Consequences

Tool _versions_ differ between machines even though configuration does not. Debian and Ubuntu will run older builds of anything mise does not cover.

**Ghostty and Zed are `manual` on Debian, not unsupported.** Zed's official Linux route is `curl -f https://zed.dev/install.sh | sh`; Ghostty prebuilds binaries for macOS only, leaving a source build or a community `.deb`. A `manual` document may prescribe whatever upstream prescribes, curl-pipes included — the meaningful difference from an installer doing it on your behalf is that you read the document and run the command knowingly.

**The installer itself is the one curl-pipe this design cannot avoid.** It is fetched before the repository exists, so there is nothing else to run it from. It clones and re-execs rather than installing anything of its own, and it fails loudly if git is absent — git and curl are stated prerequisites in the README rather than something a script silently arranges.

`yay` is bootstrapped on Arch via `base-devel` and `makepkg -si`. This is a clone and a local build, but it is the only mechanism the AUR has and it ends in a pacman-registered package, so it counts as native. The installer never _depends_ on `yay` for its own work.

Debian's renamed binaries (`batcat`, `fdfind`) are **not** a reason to take the mise rung. They are handled by guarding on which binary exists — see ADR-0005 — which keeps the packages system-tracked and removes the distribution conditional at the same time.
