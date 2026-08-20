# DEFCON BUBBLE agent context

Read this after resolving live GitHub repository state.

## Pitch

DEFCON BUBBLE is a mobile-first 3D/2.5D beach-defense game. The player holds the left side and protects a sandcastle from bubble monsters advancing from the right, beginning with toothpick weapons.

The intended shipped experience is a grand native mobile game. Desktop is a development, debugging, profiling, and automation environment. Web builds are rapid-access previews, not the final product.

## Locked laws

- Beach setting is core identity.
- Bubbles are enemies.
- Protect the sandcastle at all costs.
- Combat stays primarily left-to-right and immediately readable.
- Toothpick ranged combat is the starting weapon fantasy.
- Castle damage is visible and localized.
- Weapons and sand/castle defenses upgrade.
- Escalation from peaceful beach to absurdly serious beach warfare is part of the tone.
- Native mobile is the primary product target.
- Mobile-first does not mean reduced ambition. Preserve the grand beach-war fantasy through disciplined staging, scalable presentation, and measured performance work.

## Platform law

- The phone is a first-class design and acceptance surface, not a later port target.
- Touch input, phone-scale readability, safe areas, pause/resume behavior, audio interruption, thermal pressure, memory use, and performance are first-class concerns.
- Desktop remains valuable for authoring and proof, but desktop-only success is not sufficient acceptance for player-facing mobile behavior.
- Web builds exist to make exact-source previews easy to open on a phone. They are disposable delivery infrastructure, not gameplay architecture.
- The game is played in landscape. `display/window/handheld/orientation` is `sensor_landscape` and the foundation proof asserts it. Combat runs left to right and the approach axis owns the long edge of the screen (`DB-DEC-013`).
- The initial native storefront/platform order is not locked yet. Do not silently turn that open question into an iOS-only or Android-only assumption.

## Technical baseline

- Godot 4.7.1 stable.
- GDScript.
- Desktop development uses the existing Forward+ default.
- Native mobile uses Godot's Mobile renderer override.
- Web preview uses the Compatibility renderer override.
- Modular castle chunks are the current destruction approach.
- Data-first definitions with stable IDs.
- Composition over deep inheritance.
- Presentation observes gameplay; it does not own gameplay truth.
- Shared typed damage boundary is canonical on `main`.

## Current development edge

Foundation 0, `[DB:COMBAT:DAMAGE]`, `[DB:COMBAT:POP]`, `[DB:CASTLE:IMPACT]`, `[DB:WAVE:FIRST_DEFENSE]`, `[DB:ENCOUNTER:MIXED_THREE_WAVE]`, and `[DB:UPGRADE:FIRST_CHOICE]` are accepted on `main`.

The mixed three-wave encounter was phone-tested and promoted at `942083789e8d7dc4c61e9aad78757d95eb083451`. It establishes Basic/Brute, Fast/Runner, and Heavy/Big Blub; a persistent castle with roof-mounted toothpick origin; authored BASIC TRAINING, FAST BUBBLES, and FINAL PUSH escalation; and a separately composed `BeachEnvironment` that owns presentation only.

The first upgrade choice was phone-tested and promoted at `56f62eac8370c6b065aab5926d3716a81ce3418f`. After Wave 1 clears, the encounter holds its intermission until the player takes exactly one run-scoped upgrade:
- `upgrade:weapon:skewer`: +1 toothpick damage, producing a two-damage visibly longer Skewer.
- `upgrade:defense:shell_reinforcement`: +1 maximum and current CastleChunk durability, shown with presentation-only shell bands.

`UpgradeDefinition` is data with stable IDs. `FirstUpgradeChoice` owns the one decision and applies its narrow effect. `MixedEncounter` exposes only a hold/release seam and still owns wave progression. The HUD forwards stable IDs and owns no gameplay effect. There is no currency, shop, rarity, repair, permanent progression, upgrade tree, or save work, and the accepted wave schedule, enemy ownership, POP, and damage contracts are unchanged.

Two engineering laws were promoted alongside it and are enforced rather than advisory. Godot strips `assert()` from release builds, so an essential call inside an assert runs in CI and vanishes from the exported phone build; `scripts/check_release_safe_asserts.py` fails Godot Verify when that happens (`DB-DEC-011`). The Pages review booth is a single site, so only `main` deploys on push and branch previews are deliberate `workflow_dispatch` runs (`DB-DEC-012`).

The lit beach was phone-tested and promoted at `27f0e660f1bcf6341ca0b672b20c5e4de840df16`. `BeachEnvironment` owns a `WorldEnvironment` with a procedural sky, sky-sourced ambient, ACES tonemapping, and restrained glow, and `shaders/soap_film.gdshader` is the single source of truth for the bubble family's surface, shared by the body and every limb.

The orientation framing milestone is accepted, and the game is locked to landscape (`DB-DEC-013`).

The current bounded milestone is `[DB:PLAYER:WALL_DEFENDER]`: the game gets a player. Until now firing came from a marker on the castle roof and there was no body, so a run's only decisions were when to fire and which upgrade to take. The defender patrols a wall along the depth axis with one degree of freedom, fires from its own position at enemy height, and owns no damage or encounter outcome. Authored spawns gain a depth position so a wave arrives spread across the wall.

This was prototyped and phone-tested before being scoped. Because the layout keeps combat running left to right, the locked left-to-right law needs no superseding; this milestone is additive.

Do not let it widen into a multi-chunk or damageable castle, defender health or death, aiming or a second weapon, auto-fire, new archetypes, wave rebalance, upgrade catalog growth, or surface shaders. See `docs/ACTIVE_HANDOFF.md` for the exact proof, ownership, and phone acceptance gate.

See `docs/ACTIVE_HANDOFF.md` for current execution state and `docs/MONSTER_ROSTER.md` for the approved enemy-family source.

Resolve live GitHub state before assuming the status of any branch, pull request, workflow, or preview. Current execution detail belongs in `docs/ACTIVE_HANDOFF.md`. Current Game Director intent and cautions belong in `docs/DIRECTORS_NOTES.md`.

## Semantic anchors

Use stable searchable anchors only when they materially improve navigation or ownership. Vocabulary starts with `[DB:<DOMAIN>:<RESPONSIBILITY>]`.

Examples: `[DB:CORE:GAME_ROOT]`, `[DB:COMBAT:DAMAGE]`, `[DB:COMBAT:POP]`, `[DB:CASTLE:CHUNK]`, `[DB:WAVE:FIRST_DEFENSE]`, `[DB:ENCOUNTER:MIXED_THREE_WAVE]`, `[DB:UPGRADE:DEFINITION]`, `[DB:UPGRADE:FIRST_CHOICE]`, `[DB:PLAYER:WALL_DEFENDER]`, `[DB:INPUT:PLAYER_INTENT]`, `[DB:PLATFORM:MOBILE]`, `[DB:PLATFORM:WEB_PREVIEW]`, `[DB:PERF:QUALITY]`.

## Do not

- Broaden scope silently.
- Treat desktop-only behavior as sufficient acceptance when the feature is player-facing on mobile.
- Couple touch UI directly to gameplay truth when an input/action boundary can keep them separate.
- Reduce the core fantasy merely to avoid doing profiling, budgeting, or scalable presentation work.
- Add dependencies casually.
- Introduce giant global managers or a universal event bus.
- Put gameplay truth in UI, VFX, audio, or animation.
- Use display text as stable gameplay/save identity.
- Commit secrets.
- Change locked game laws without recording a decision.

## Source of truth

Implementation truth is GitHub. Deeper creative/design truth is maintained in the DEFCON BUBBLE Google Drive project core. Director's Notes guide current judgment but do not override live implementation truth or locked decisions.
