# Active handoff

## Current milestone
`[DB:COMBAT:DAMAGE]` common damage contract

## Current branch / PR
`agent/combat-damage-contract`

Resolve the live head SHA and PR from GitHub/Git at session start. Do not hardcode this file's own HEAD.

Last verified canonical baseline: `main` commit `42aa750307ad5d8bf1d0a1149ff755602aca0c7c`.
Foundation 0 code tree matches green PR-head tree `5df5d8d05bbc36be94f4997870276d31dffa7db4`; PR verification run `32083666776` passed before promotion.

## Current acceptance target
Prove the typed damage request and receiver contract in Godot 4.7.1 CI before implementing Bubble #1.

## What is true now
- Foundation 0 is canonical on `main`.
- `DamageRequest` is the common construct-once hit message.
- `DamageReceiver` validates/routs requests but owns no gameplay outcome.
- `PIERCE` and `IMPACT` are the initial typed damage categories.
- A dedicated headless damage-contract test is part of automatic Godot verification.

## What is blocked
Nothing known. This branch requires CI evidence before promotion.

## Must not change
- No production bubble, toothpick projectile, health system, castle damage, wave logic, upgrades, saves, or progression in this milestone.
- Targets own resistance, health, death, and destruction decisions.
- Presentation never becomes damage authority.
- No secrets in Git and no new dependency without explicit justification/provenance.

## Next actions
1. Open a draft PR for this bounded contract.
2. Verify Godot CI on the exact PR head.
3. If green and contract review is clean, promote deliberately.
4. Only then begin Bubble #1 and toothpick hit integration.
