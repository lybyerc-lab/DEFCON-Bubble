# Active handoff

## Current milestone
Foundation 0

## Current branch + exact SHA
`agent/foundation-0`

Current head: `d8d376f333818203e9576c3e46ec88eef25cef2c`

## Current acceptance target
Merge Foundation 0 only after the exact current head passes the pinned Godot 4.7.1 CI smoke workflow.

## What is true now
- Godot baseline is 4.7.1 stable with GDScript.
- Repository is public, not open source, with an explicit rights notice.
- `GameRoot -> BeachArena` boots without production gameplay.
- Named input/collision conventions, semantic code anchors, repo memory, system map, decisions, and CI exist.
- Previous PR head `50ec4846e669e7e036cf78e07acb119fef6d00cb` passed CI run `32083253342`: checksum, engine pin, import, foundation contract, and headless boot all succeeded.
- CI checkout was then upgraded to a SHA-pinned current action to remove the Node 20 deprecation warning, so the new head requires fresh proof.

## What is blocked
Nothing known. Waiting only on CI evidence for the exact current head.

## Must not change
- No production bubbles, weapons, castle damage, waves, upgrades, saves, or progression in Foundation 0.
- No secrets in Git.
- No new dependency without explicit justification/provenance.
- Keep `main` buildable.

## Next actions
1. Verify CI for current head `d8d376f333818203e9576c3e46ec88eef25cef2c`.
2. If green, merge PR #1 and verify `main`.
3. Start the next bounded milestone: `[DB:COMBAT:DAMAGE]` common damage request contract plus test target before Bubble #1.
