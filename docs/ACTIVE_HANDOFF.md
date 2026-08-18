# Active handoff

## Current milestone
Foundation 0

## Current branch / PR
`agent/foundation-0` / PR #1

Live head SHA is always resolved from GitHub/Git at session start. Do not hardcode the branch's own current HEAD in this file because editing this file creates a new HEAD.

Last verified implementation SHA: `50ec4846e669e7e036cf78e07acb119fef6d00cb`
Verified by Foundation Smoke run `32083253342`.

## Current acceptance target
Merge Foundation 0 only after the exact live PR head passes the pinned Godot 4.7.1 CI smoke workflow.

## What is true now
- Godot baseline is 4.7.1 stable with GDScript.
- Repository is public, not open source, with an explicit rights notice.
- `GameRoot -> BeachArena` boots without production gameplay.
- Named input/collision conventions, semantic code anchors, repo memory, system map, decisions, and CI exist.
- Last verified implementation SHA passed checksum verification, engine pin, import, foundation contract, and headless boot.
- CI checkout was upgraded to a SHA-pinned current action to remove the Node 20 deprecation warning; the live PR head requires fresh proof after that change.

## What is blocked
Nothing known. Acceptance depends only on green CI for the exact live PR head.

## Must not change
- No production bubbles, weapons, castle damage, waves, upgrades, saves, or progression in Foundation 0.
- No secrets in Git.
- No new dependency without explicit justification/provenance.
- Keep `main` buildable.

## Next actions
1. Resolve the live PR #1 head SHA from GitHub.
2. Verify Foundation Smoke for that exact SHA.
3. If green, merge PR #1 and verify `main`.
4. Start `[DB:COMBAT:DAMAGE]`: common damage request contract plus test target before Bubble #1.
