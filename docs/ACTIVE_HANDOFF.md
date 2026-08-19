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

`[DB:PRESENTATION:LIT_BEACH]`

### Player-facing question

Does a lit beach with genuine soap-film bubbles make the already-accepted encounter read as a real beach war on a phone, without changing any gameplay truth?

### Why now

The whole game currently renders as 26 spheres, 9 planes, 6 boxes, and 4 materials. Three specific gaps cost more than the absence of art assets:

- There is no `WorldEnvironment` anywhere and no `default_environment` in `project.godot`. The background renders as void and, with a single `DirectionalLight3D` and no ambient term, every surface the sun misses falls to near-black.
- The bubble material uses `shading_mode = 0`. The enemies are unshaded, so they cannot catch the sun, show a rim, or read as soap film at all.
- `docs/concepts/bubble_monster_roster_v1.png` is approved art direction that the primitives only loosely approximate.

This slice closes the first two. It is presentation-only, so it carries no gameplay risk, and it is the cheapest work with a visible payoff.

### Exact proof

One lit scene and one soap-film material, nothing else:

- **`WorldEnvironment` owned by `BeachEnvironment`**
  - procedural sky whose sun direction and warmth agree with the existing `Sun` `DirectionalLight3D`
  - ambient light sourced from that sky, so shadowed surfaces read as shadow rather than black
  - filmic/ACES tonemapping
  - restrained glow, tuned so bubbles read as luminous without blooming the HUD

- **Soap-film bubble material**
  - a project-authored `ShaderMaterial` replacing the unshaded `StandardMaterial3D`
  - fresnel rim brightening toward grazing angles
  - thin-film iridescence that shifts hue across the surface
  - shaded, so the bubble responds to the sun and the sky ambient
  - alpha and silhouette stay close enough that Basic, Fast, and Heavy remain instantly distinguishable

Accepted colour identity is preserved: Fast stays acid-lime and urgent, Big Blub stays large and slow, and the POP droplet choreography is untouched.

### Ownership

- `BeachEnvironment` owns the `WorldEnvironment`, sky, ambient, tonemap, glow, and sun. It owns no gameplay, no schedule, no collision, and no castle state.
- The soap-film shader and its material are presentation only. They read gameplay state; they never set it.
- `BasicBubble` and its inherited scenes keep every gameplay value unchanged: health, speed, scale, collision, damage, POP, and despawn.
- `BubblePopFx` keeps the accepted rupture and droplet behaviour. This slice re-lights it; it does not re-choreograph it.
- Any quality tier introduced here affects presentation cost only and never an authoritative gameplay outcome.

### Renderer risk

The Web booth runs the Compatibility renderer, which supports less than the Mobile renderer. Glow and shader features can differ or silently degrade there. The booth is an exported release build, so it is the authority for what a reviewer actually sees, and the recent release-build defect is the standing reminder that editor behaviour is not evidence.

Verify the shader and glow in the booth, not only in the editor, and pick settings that degrade acceptably rather than settings that only look correct on desktop Forward+.

### Phone acceptance target

- the sky is visible and no part of the beach reads as a black void
- bubbles visibly catch the sun, show a rim, and read as soap film rather than flat discs
- iridescence is present but not garish, and does not turn the family into a rainbow
- Basic, Fast, and Heavy remain instantly distinguishable at phone size and at speed
- Fast still reads as the urgent acid-lime threat
- the accepted POP still reads as a rupture, and droplets remain legible against the brighter scene
- castle damage and destruction remain legible
- HUD text, wave/castle messaging, terminal states, and the upgrade overlay stay readable against the brighter background
- glow does not bloom the HUD or wash out the upgrade buttons
- frame rate and thermal behaviour remain acceptable through a full three-wave run on the review phone
- no gameplay value, timing, or outcome changed anywhere

### Non-goals

- no new meshes, models, Meshy assets, textures, or fonts
- no sand shader, wet-sand shoreline, or animated water; those are a separate later slice
- no camera framing, shake, or field-of-view work
- no new enemy archetype, silhouette redesign, or roster art
- no post-processing beyond tonemapping and modest glow; no SSAO, SSR, depth of field, or volumetrics
- no re-choreographing the accepted POP, castle destruction, or HUD layout
- no gameplay tuning, wave rebalance, or upgrade changes
- no permanent numeric performance budgets before a target-device matrix exists

## Must not drift into

- generalized upgrade catalogs, currencies, shops, rarity, rerolls, or meta progression because one choice now exists
- generalized wave DSLs, registries, procedural spawning, or universal navigation without a concrete need
- multiple lanes/chunks, repair, or economy merely because they are future possibilities
- new weapons or enemy mechanics without a bounded gameplay question
- reopening accepted POP, castle, encounter, or upgrade behavior without new player evidence or a measured defect
- pooling or speculative optimization without measurements
- native-store packaging before platform/store priority is deliberately selected

## Immediate sequence

1. Implement the `WorldEnvironment` and the soap-film shader on `agent/lit-beach`.
2. Keep every accepted gameplay fixture green; presentation work must not move a gameplay assertion.
3. Add a deterministic structure proof that the environment owns a `WorldEnvironment` and that bubbles are no longer unshaded, so the lighting cannot silently regress.
4. Deploy the exact feature head to the phone review booth with a deliberate `workflow_dispatch` run.
5. Judge sky, bubble read, family distinguishability, POP legibility, HUD contrast, and sustained frame rate on a phone.
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
