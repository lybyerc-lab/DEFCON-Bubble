# Code anchor vocabulary

Format: `[DB:<DOMAIN>:<RESPONSIBILITY>]`

Initial domains:

- `FOUNDATION`
- `CORE`
- `COMBAT`
- `PLAYER`
- `WEAPON`
- `ENEMY`
- `CASTLE`
- `WAVE`
- `UPGRADE`
- `DATA`
- `UI`
- `AUDIO`
- `VFX`
- `DEBUG`
- `TEST`
- `SAVE`
- `AGENT`

Rules:

1. Tag responsibilities, not individual obvious lines.
2. Preserve a stable anchor when the responsibility moves unchanged.
3. Rename the anchor when responsibility changes.
4. Prefer code symbols, types, stable IDs, groups, signals, and tests over redundant comments.
5. Structured logs and test names may reuse anchor vocabulary.
