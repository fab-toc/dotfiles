# The manifest is a tab-separated table, not TOML or JSON

`tools.tsv` is a genuinely tab-separated table — one line per tool, read with shell builtins:

```sh
while read -r tool arch debian kind default; do ...
```

The installer is POSIX `sh`, because the entry point is `curl … | sh` and Debian's `/bin/sh` is dash. That constraint decides the format.

## Columns

| Column    | Values                                                        |
| --------- | ------------------------------------------------------------- |
| `tool`    | the tool's name, and the module directory name if it has one   |
| `arch`    | a package name, or `manual` / `excluded` / `unsupported`       |
| `debian`  | a package name, or `mise` / `manual` / `excluded` / `unsupported` |
| `kind`    | `cli` or `gui`                                                 |
| `default` | `yes` or `no` — selected by default                            |

The source is the cell's value, not a separate axis: there is no `mise` column, because the `debian` cell either names an apt package or says `mise`. An earlier version of this ADR specified `tool arch debian mise kind default`; the `mise` column was redundant once cells could hold a source directly, and it could not express `manual` or `excluded` at all.

Nothing records whether a tool has a module. The presence of `modules/<tool>/` is the fact, and a column would only be able to lie about it.

The `arch` cell does not distinguish official repositories from the AUR, because `yay -S` does not care. That means the manifest cannot tell you `android-studio` is an AUR build — that belongs in `docs/setup/android.md` rather than in a column that would be meaningful on one distribution only.

## Tabs, not alignment

The file is tab-separated rather than whitespace-aligned. `while read -r` accepts either, so nothing in the installer forces the choice; the reader does. **GitHub renders a true `.tsv` as a sortable table**, so the manifest is readable as a table where it is actually read, and the README links to it rather than carrying a duplicate that would drift. The cost is that the raw file is ragged in an editor without tab-stop rendering.

## Considered Options

**TOML** would need a parser — `tomllib` via Python, or `yq` — for what is a flat lookup table with no nesting and no types. **JSON with `jq`** is worse: `jq` is absent from minimal Debian images, so reading the file that lists what to install would itself require installing something first. **A sourceable shell data file** needs no parsing at all, but it is code wearing data's clothes, and it invites cleverness that breaks.

The data is rectangular — every tool has exactly the same fields — so a table is its honest shape.
