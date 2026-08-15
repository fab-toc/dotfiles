# The manifest is a whitespace-aligned table, not TOML or JSON

`tools.tsv` is a plain aligned table — one line per tool, columns for the package name on each distribution, the mise fallback, the graphical/CLI tag, and whether it is selected by default. It is read with shell builtins:

```sh
while read -r tool arch debian mise kind default; do ...
```

The installer is POSIX `sh`, because the entry point is `curl … | sh` and Debian's `/bin/sh` is dash. That constraint decides the format.

## Considered Options

**TOML** would need a parser — `tomllib` via Python, or `yq` — for what is a flat lookup table with no nesting and no types. **JSON with `jq`** is worse: `jq` is absent from minimal Debian images, so reading the file that lists what to install would itself require installing something first. **A sourceable shell data file** needs no parsing at all, but it is code wearing data's clothes, and it invites cleverness that breaks.

The data is rectangular — every tool has exactly the same fields — so a table is its honest shape, and it renders into the README's tool table trivially.
