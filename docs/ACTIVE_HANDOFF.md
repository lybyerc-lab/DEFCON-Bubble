# Active handoff

## Recovery rule

Resolve live GitHub state first. Then read `AGENT_CONTEXT.md`, this handoff, `docs/DIRECTORS_NOTES.md`, and `docs/MOBILE_FIRST.md` before acting on player-facing or platform work.

Do not assume this file's PR numbers or branch state are current. Verify them live.

## Canonical baseline

Accepted on `main`:
- `[DB:COMBAT:POP]` at `98ce22ed5f119bbb9d4adfc3f72e8468b1aafe58`
- `[DB:CASTLE:IMPACT]` at `10cb2f20446c759dfa62a1303483552634fddda4`
- `[DB:WAVE:FIRST_DEFENSE]` at `306f7a8c94fe55e17b7dd29850f9f327211ccb9c`
- `[DB:ENCOUNTER:MIXED_THREE_WAVE]` at `942083789e8d7dc4c61e9aad78757d95eb083451`
- `[DB:UPGRADE:FIRST_CHOICE]` at `56f62eac8370c6b065aab5926d3716a81ce3418f`
- `[DB:PRESENTATION:LIT_BEACH]` at `27f0e660f1bcf6341ca0b672b20c5e4de840df16`

The shared damage boundary remains `DamageRequest` -> `DamageReceiver` -> target-owned outcome. Native mobile is the product target, desktop is development/automation, and Web Compatibility is the rapid phone review surface.

The phone-accepted mixed encounter establishes Basic/Brute, Fast/Runner, Heavy/Big Blub, one persistent two-health CastleChunk, roof-fired toothpicks, three authored escalating waves, readable intermissions/terminal states, pristine RETRY, and a presentation-only `BeachEnvironment`.

The phone-accepted first upgrade choice establishes one run-scoped between-wave decision. `UpgradeDefinition` is data with stable IDs; `FirstUpgradeChoice` owns the single decision and applies its narrow effect; `MixedEncounter` exposes only a hold/release seam and still owns wave progression; the HUD forwards stable IDs and owns no effect. SKEWER takes toothpicks from 1 to 2 damage with a longer silhouette; SHELL REINFORCEMENT takes the castle from 2/2 to 3/3 without erasing damage history.

The phone-accepted lit beach establishes scene lighting and one soap-film substance. `BeachEnvironment` owns a `WorldEnvironment` with a procedural sky, sky-sourced ambient, ACES tonemapping, and restrained screen-blend glow. `shaders/soap_film.gdshader` is the single source of truth for the family's surface, used by the body through `BubblePopFx` and by every limb through `BubbleCreatureFx`. Limbs hold their own fixed alpha so a translucent variant tint cannot dissolve the bipedal silhouette.

Two engineering laws were promoted with it. Essential calls stay outside `assert()`, enforced in Godot Verify by `scripts/check_release_safe_asserts.py`, because Godot strips asserts from release builds and CI runs a debug binary. Only `main` deploys to the Pages review booth on push; feature branches are previewed through a deliberate `workflow_dispatch` run.

## Current bounded milestone

`[DB:PLAYER:WALL_DEFENDER]`

### Player-facing question

Does giving the defender a body that patrols the wall make deciding **where to stand** the heart of a wave, without cluttering the phone controls?

### Why now

The game has never had a player. Firing came from a marker bolted to the castle roof, so the only decision in a run was when to press FIRE, plus one upgrade choice. That is why every candidate for "the next milestone" kept sounding like another monster: there was no loop to deepen.

A throwaway prototype on `agent/iso-wall-prototype` was built and phone-tested before this scope was written. It established three things:

- Positioning is a real decision. Toothpicks travel down the defender's current depth lane, so roughly 27 percent of shots connected across 210 shots and 63 pops. Missing is the cost of standing in the wrong place.
- One degree of freedom is enough. A drag along the wall plus hold-to-fire needs no virtual stick and no control clutter.
- Rotating the layout so combat still runs left to right keeps the bipedal silhouettes in profile and gives the approach axis the long edge of the screen.

That last point is what makes this a bounded milestone rather than a re-founding. Combat stays left to right, so the locked law in `AGENT_CONTEXT.md` needs no superseding. This is additive.

### Exact proof

The accepted mixed three-wave encounter, played with a defender:

- one `[DB:PLAYER:WALL_DEFENDER]` who exists only on a patrol path along the depth axis, owns its position and its own firing origin, and owns no damage or encounter outcome
- one degree of freedom: a drag picks a point on the wall and the defender runs to it, clamped to the patrol path
- **firing stays manual.** Hold to fire, at the accepted toothpick cadence. FIRE is the game's established verb and removing it is a separate question, not a side effect of adding a body
- toothpicks originate from the defender at enemy height rather than from the castle roof marker
- authored spawns gain a depth position, so a wave arrives spread across the patrol path instead of in a single file
- `ArenaCamera` frames the patrol depth as well as the approach lane, and pitches to suit
- the castle keeps its accepted ownership exactly: one `CastleChunk`, two health, typed `IMPACT`, destruction and persistence unchanged. Anything that crosses the wall line damages it as it does today

### Ownership

- The defender owns its position along the patrol path and the origin of the toothpicks it fires. It owns no damage outcome, no enemy state, no wave progression, and no castle truth.
- `ToothpickProjectile` keeps `PIERCE` and its damage request. Being fired from a body rather than a marker changes where it starts, nothing else.
- `BasicBubble` and its variants keep health, speed, movement, POP, and despawn.
- `CastleChunk` keeps health, `IMPACT`, destruction, and persistence. The wall is presentation and a patrol path; it is not a second damageable thing.
- `MixedEncounter` keeps the authored three-wave schedule, intermissions, and outcome. It gains a depth coordinate on spawns and nothing else.
- `FirstUpgradeChoice` keeps its run-scoped decision. Skewer configures the defender's projectiles exactly as it configures the marker's today.
- Touch input requests intent. It never becomes combat, movement authority, or encounter truth.

### Phone acceptance target

- choosing where to stand feels like a decision with weight, not chore-work beside the fire button
- the drag is comfortable one-thumbed and the defender goes where the thumb asks
- the defender is readable against sand, water, and bubbles at phone size
- enemies arriving spread across the depth of the wall create genuine "which one do I take" pressure
- Fast still reads as the urgent threat and Big Blub still reads as the slow siege problem
- POP, castle consequence, wave timing, intermissions, the upgrade choice, win/loss, and RETRY all still behave as accepted
- a leak still damages the castle, and two still lose the run
- frame rate and thermals hold through a full three-wave run
- controls stay clear of the battlefield read, and the HUD stays legible

### Non-goals

- no multi-chunk castle, per-lane castle health, wall damage, or repair
- no defender health, death, stamina, dodging, or melee
- no second weapon, weapon switching, aiming, or manual targeting
- no auto-fire; if hold-to-fire proves to be dead weight that becomes its own question
- no new enemy archetype and no enemy pathing toward the defender
- no wave rebalance beyond giving existing authored spawns a depth position
- no upgrade catalog growth, economy, or progression
- no sand or water shader work; that slice is still queued behind this one
- no camera shake, push-in, or cinematic moves

## Must not drift into

- a second damageable structure, multi-chunk castle, or repair because a wall now exists
- defender health, death, or dodging because the defender now has a body
- aiming, weapon switching, or a second weapon family
- generalized upgrade catalogs, currencies, shops, or meta progression
- generalized wave DSLs, registries, procedural spawning, or universal navigation
- reopening accepted POP, castle, encounter, upgrade, lighting, or framing behavior without new player evidence or a measured defect
- pooling or speculative optimization without measurements
- native-store packaging before platform/store priority is deliberately selected

## Immediate sequence

1. Build the defender, patrol path, and firing origin on `agent/wall-defender`.
2. Give authored spawns a depth position and reframe the camera for the patrol band.
3. Keep every accepted gameplay fixture green. Encounter timing, POP, castle consequence, and the upgrade choice are regression surfaces, not things to adjust.
4. Add a deterministic proof that the defender owns position and firing origin only, that the castle keeps its accepted ownership, and that no accepted gameplay value moved.
5. Deploy the exact feature head to the phone review booth with a deliberate `workflow_dispatch` run.
6. Judge positioning weight, thumb comfort, readability, and wave pressure on a phone.
7. Tune only evidenced defects inside this milestone.
8. Promote only after explicit Game Director acceptance, then retire `agent/iso-wall-prototype`.

## Standing laws

- Targets own resistance, health, death, and destruction decisions.
- Presentation reacts to gameplay truth; it never becomes damage or upgrade authority.
- Touch UI requests player intent; it never becomes combat authority.
- Keep `main` buildable.
- Automation proves; promotion is deliberate.
- Automation must exercise what the exported build actually runs; keep essential calls outside `assert()`.
- The Pages review booth serves `main` on push; branch previews are deliberate.
- The game is played in landscape; the approach axis owns the long edge of the screen.
- Player-facing mobile behavior needs representative phone/touch evidence.
- No secrets in Git and no new dependency without explicit justification/provenance.
