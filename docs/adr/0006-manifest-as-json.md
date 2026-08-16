# The manifest is JSON read with jq — reversing this ADR's own earlier decision

`tools.json` is an object keyed by tool name, read with `jq`. The installer installs `jq` before it reads the manifest.

**This ADR previously decided the opposite**, and the reasoning it used then has not stopped being true. It said: the installer is POSIX `sh`, because the entry point is `curl … | sh` and Debian's `/bin/sh` is dash; `jq` is absent from a minimal Debian image, so reading the file that lists what to install would itself require installing something first. Every clause of that is still correct. The file that says what to install now needs a program installed before it can be read, and the package name for that program is hardcoded in `install.sh` because it is the one thing that cannot come from the manifest.

That cost was accepted deliberately, in exchange for a standard format that a reader already knows how to parse, that fails loudly on a syntax error instead of silently shifting a column, and that can hold structure the table could not — `requires_keys` is a list, and a table cell cannot be a list.

`jq` is a cheap dependency as these things go: on Arch it is `extra`, 480 KiB, depending only on glibc and oniguruma; on Debian it is in `main`. It is not a runtime — nothing but the installer ever calls it — and it has a row in the manifest so that it is visible as a tool this environment carries.

## Shape

```json
"neovim": {
  "arch": "neovim",
  "debian": "mise",
  "kind": "cli",
  "default": true,
  "note": "apt's neovim trails the releases the configuration expects."
}
```

| Field           | Values                                                                   |
| --------------- | ------------------------------------------------------------------------ |
| _key_           | the tool's name, and the module directory name if it has one              |
| `arch`          | a package name, or `manual` / `excluded` / `unsupported`                  |
| `debian`        | a package name, or `mise` / `manual` / `excluded` / `unsupported`         |
| `kind`          | `cli` or `gui`                                                           |
| `default`       | `true` or `false` — selected when no modules are named                    |
| `note`          | optional; why this row is what it is. Never read by the installer         |
| `requires_keys` | optional; SSH keys this tool's configuration expects, checked when selected |

An object keyed by tool name rather than an array of objects: it reads as the lookup table it is, `jq` preserves insertion order so `yay` still precedes the AUR rows that need it, and a duplicate key is a thing `jq` will not silently accept twice.

The source is the field's value, not a separate axis: there is no `mise` field, because the `debian` value either names an apt package or says `mise`.

Nothing records whether a tool has a module. The presence of `modules/<tool>/` is the fact, and a field would only be able to lie about it.

## Where the "why" lives

JSON has no comments. That is a real loss over the tab-separated table, which could have carried them, and it is paid back with the `note` field: one sentence about *this row*, sitting next to the value it explains, rendered on GitHub where the manifest is actually read.

The division is deliberate. A `note` holds facts about one row — why `nvm` is `excluded` on Debian, why `neovim` takes the mise rung. Anything cross-cutting — the ladder's ordering, why the terminal sources are a closed set of three — belongs in an ADR, because a note that wants to be a paragraph is an ADR that has not been written yet. Documentation that duplicates data drifts (ADR-0005), so the explanation lives against the data and nowhere else.

## Considered Options

**Keeping the tab-separated table.** Free, and it rendered as a sortable table on GitHub. Rejected because tabs are invisible, a table cell cannot hold a list, and the format could express nothing the installer did not already hardcode.

**TOML** needs `python3` and `tomllib`: 73 MiB on an Arch base that ships no python, to read 37 flat records. Rejected on cost.

**YAML** needs `yq` — and there are two incompatible programs by that name. Arch's `extra/yq` and Debian's `yq` are the Python jq wrapper; mikefarah's `yq`, which most documentation means, has different syntax and is packaged on Arch as `go-yq`. A script calling `yq` cannot know which one it got. Rejected as unfixable from a script.

**A bespoke block format** — `key=value` lines, blank-line separated — would have needed no dependency at all and could hold comments. Rejected because it is a format nobody else knows, invented to avoid a 480 KiB package.
