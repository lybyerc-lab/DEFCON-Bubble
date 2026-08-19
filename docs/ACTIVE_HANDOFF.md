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

The shared damage boundary remains `DamageRequest` -> `DamageReceiver` -> target-owned outcome. Native mobile is the product target, desktop is development/automation, and Web Compatibility is the rapid phone review surface.

The phone-accepted mixed encounter establishes Basic/Brute, Fast/Runner, Heavy/Big Blub, one persistent two-health CastleChunk, roof-fired toothpicks, three authored escalating waves, readable intermissions/terminal states, pristine RETRY, and a presentation-only `BeachEnvironment`.

The phone-accepted first upgrade choice establishes one run-scoped between-wave decision. `UpgradeDefinition` is data with stable IDs; `FirstUpgradeChoice` owns the single decision and applies its narrow effect; `MixedEncounter` exposes only a hold/release seam and still owns wave progression; the HUD forwards stable IDs and owns no effect. SKEWER takes toothpicks from 1 to 2 damage with a longer silhouette; SHELL REINFORCEMENT takes the castle from 2/2 to 3/3 without erasing damage history.

Two engineering laws were promoted with it. Essential calls stay outside `assert()`, enforced in Godot Verify by `scripts/check_release_safe_asserts.py`, because Godot strips asserts from release builds and CI runs a debug binary. Only `main` deploys to the Pages review booth on push; feature branches are previewed through a deliberate `workflow_dispatch` run.

## Current bounded milestone

No new gameplay milestone is selected yet.

Do not infer the next task from the remaining monster roster, from the upgrade seam that now exists, or from previously discussed systems. The next slice must be chosen deliberately from current design intent and must state one bounded player-facing question plus its phone acceptance target before implementation begins.

`FirstUpgradeChoice` proves one authored decision. It is not permission to build a catalog, an economy, a second upgrade tier, or a progression system without a new bounded question.

The approved but not-yet-implemented roster still includes Stiltwalker, Weaver, Mutant, and Bubble King. Their concept roles are not permission to invent mechanics early.

## Must not drift into

- generalized upgrade catalogs, currencies, shops, rarity, rerolls, or meta progression because one choice now exists
- generalized wave DSLs, registries, procedural spawning, or universal navigation without a concrete need
- multiple lanes/chunks, repair, or economy merely because they are future possibilities
- new weapons or enemy mechanics without a bounded gameplay question
- reopening accepted POP, castle, encounter, or upgrade behavior without new player evidence or a measured defect
- pooling or speculative optimization without measurements
- native-store packaging before platform/store priority is deliberately selected

## Immediate sequence

1. Keep accepted `main` green and recoverable.
2. Resolve current Game Director intent and live repo state before selecting the next milestone.
3. Define the next bounded player-facing question, ownership boundaries, non-goals, and phone acceptance gate.
4. Create a fresh feature branch only after that scope is explicit.
5. Promote only after automation is green and the relevant player-facing behavior is accepted on a phone.

## Standing laws

- Targets own resistance, health, death, and destruction decisions.
- Presentation reacts to gameplay truth; it never becomes damage or upgrade authority.
- Touch UI requests player intent; it never becomes combat authority.
- Keep `main` buildable.
- Automation proves; promotion is deliberate.
- Automation must exercise what the exported build actually runs; keep essential calls outside `assert()`.
- The Pages review booth serves `main` on push; branch previews are deliberate.
- Player-facing mobile behavior needs representative phone/touch evidence.
- No secrets in Git and no new dependency without explicit justification/provenance.
