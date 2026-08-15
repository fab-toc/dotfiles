# One branch for all distributions, not a branch per distribution

`main` is the single supported branch. Configuration files are byte-identical on every machine and adapt at _runtime_ through guards; they are never forked per distribution.

This reverses an earlier strategy of a branch per distribution, of which `arch` is the surviving artefact. That approach guaranteed permanent divergence: a fix made on one branch would have to be merged into every other, and the branches would drift apart exactly where they were most similar. It is also incompatible with the core goal — if the branches differ, the configuration is not the same everywhere.

## Consequences

Anything distribution-specific must be expressed as a guard inside a shared file, not as a separate file or branch. Where a shared file cannot express the difference — identity, secrets — it belongs in an untracked local config instead.

Alias _names_ are part of the configuration contract and are identical everywhere; their implementations may differ. `i`, `u`, and `s` mean the same thing on every machine even though one resolves to `yay` and another to `apt`.

Generated configuration is rejected for the same reason: a file written at install time is invisible, drifts from the repository, and differs per machine by construction.
