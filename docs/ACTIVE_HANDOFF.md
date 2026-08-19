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

`[DB:CAMERA:ORIENTATION_FRAMING]`

### Player-facing question

Does the battlefield frame correctly on a real phone in both orientations, so the playable surface reads as a beach the player is defending rather than a shallow strip with dead space beside it?

### Why now

The Game Director found this on a phone while accepting `[DB:PRESENTATION:LIT_BEACH]`. It is a pre-existing defect that lighting made visible: previously the void background hid where the beach ended.

`Camera3D` in `scenes/arena/beach_arena.tscn` sets no `keep_aspect`, so it takes Godot's default `KEEP_HEIGHT`. Vertical FOV is locked at 75 degrees and horizontal expands with the display aspect. Authored against the 1280x720 window and viewed on a roughly 20:9 phone in landscape, that yields about 25 percent more width and no additional depth. The sand is 24 by 12, so the playable surface reads as a shallow strip with dead space either side.

This is a mobile-first framing defect on the primary product target, so it outranks surface fidelity. Sand and water are the slice after this one and will be judged inside whatever framing this milestone establishes.

### Exact proof

The battlefield frames deliberately rather than by engine default:

- an explicit framing decision for the arena camera rather than an inherited `keep_aspect` default
- the playable surface fills a defined, intentional share of the screen in both portrait and landscape on phone aspect ratios
- the castle, the spawn edge, and the full left-to-right combat lane are all visible at once in both orientations
- no gameplay-relevant space sits outside the frame, and no large dead margin sits inside it
- framing derives from named values rather than magic coordinates, so it can be retuned without hunting through the scene

Whether this is solved by `keep_aspect`, FOV, camera placement, arena proportions, or an orientation-aware combination is an implementation decision for the milestone, made from what actually reads on a phone.

### Ownership

- The arena scene owns battlefield framing. Framing is presentation and never changes spawn positions, castle placement, travel distances, or wave timing.
- `MixedEncounter` keeps wave progression. `CastleChunk` keeps castle truth. Enemies keep movement and collision.
- If arena proportions change, gameplay distances that depend on them must be preserved deliberately and proven, not adjusted to suit the camera.
- Touch controls keep requesting intent only. Reframing must not move combat authority into the camera or the HUD.

### Phone acceptance target

- portrait and landscape both frame the battlefield deliberately, with no shallow-strip read and no large dead margin
- castle, spawn edge, and the full combat lane are visible together in both orientations
- enemy approach still reads as pressure, and Fast still reads as urgent at the new framing
- Big Blub still reads as large relative to the frame
- HUD, wave and castle messaging, terminal states, and the upgrade overlay stay readable and stay clear of the action
- touch targets remain comfortable and do not overlap the battlefield read
- rotating the device mid-run recovers to a correct frame without breaking the encounter
- the accepted three-wave encounter, POP, castle consequence, upgrade choice, win/loss, and RETRY are all unchanged
- no gameplay value, distance, or timing changed

### Non-goals

- no sand shader, wet-sand shoreline, or animated water; that is the next slice and is judged inside this framing
- no camera shake, push-in, dynamic tracking, or cinematic moves; this slice is static framing correctness
- no new geometry, meshes, textures, or roster art
- no lighting, glow, or material changes; `[DB:PRESENTATION:LIT_BEACH]` is accepted
- no HUD redesign beyond what framing correctness requires
- no wave, enemy, castle, or upgrade rebalance
- no new input scheme or control layout

## Must not drift into

- generalized upgrade catalogs, currencies, shops, rarity, rerolls, or meta progression because one choice now exists
- generalized wave DSLs, registries, procedural spawning, or universal navigation without a concrete need
- multiple lanes/chunks, repair, or economy merely because they are future possibilities
- new weapons or enemy mechanics without a bounded gameplay question
- reopening accepted POP, castle, encounter, or upgrade behavior without new player evidence or a measured defect
- pooling or speculative optimization without measurements
- native-store packaging before platform/store priority is deliberately selected

## Immediate sequence

1. Establish deliberate arena framing on `agent/camera-framing`.
2. Keep every accepted gameplay fixture green; framing must not move a gameplay assertion.
3. Add a deterministic proof that framing is explicit rather than inherited from an engine default, and that gameplay distances are unchanged.
4. Deploy the exact feature head to the phone review booth with a deliberate `workflow_dispatch` run.
5. Judge both orientations, mid-run rotation, enemy pressure, HUD clearance, and touch comfort on a phone.
6. Tune only evidenced defects inside this milestone.
7. Promote only after explicit Game Director acceptance.

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
