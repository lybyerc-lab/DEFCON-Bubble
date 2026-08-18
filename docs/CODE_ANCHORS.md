# Code anchor vocabulary

Format: `[DB:<DOMAIN>:<RESPONSIBILITY>]`

Initial domains:

- `FOUNDATION`
- `CORE`
- `COMBAT`
- `PLAYER`
- `INPUT`
- `WEAPON`
- `ENEMY`
- `CASTLE`
- `WAVE`
- `UPGRADE`
- `DATA`
- `UI`
- `PRESENTATION`
- `AUDIO`
- `VFX`
- `PLATFORM`
- `PERF`
- `DEBUG`
- `TEST`
- `SAVE`
- `AGENT`

Examples in the current codebase:

- `[DB:INPUT:PLAYER_INTENT]`
- `[DB:PLATFORM:MOBILE]`
- `[DB:PLATFORM:WEB_PREVIEW]`
- `[DB:PLATFORM:RENDERER_POLICY]`
- `[DB:PERF:QUALITY]`
- `[DB:PRESENTATION:POP_FX]`
- `[DB:CASTLE:CHUNK]`
- `[DB:WAVE:FIRST_DEFENSE]`
- `[DB:PRESENTATION:FIRST_DEFENSE_HUD]`
- `[DB:TEST:FIRST_DEFENSE]`

Rules:

1. Tag responsibilities, not individual obvious lines.
2. Preserve a stable anchor when the responsibility moves unchanged.
3. Rename the anchor when responsibility changes.
4. Prefer code symbols, types, stable IDs, groups, signals, and tests over redundant comments.
5. Structured logs and test names may reuse anchor vocabulary.
6. Platform anchors identify adapters and policies, not gameplay ownership. Mobile or Web UI must still route through gameplay contracts.
