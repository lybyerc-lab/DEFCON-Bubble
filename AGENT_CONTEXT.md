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

Foundation 0, `[DB:COMBAT:DAMAGE]`, `[DB:COMBAT:POP]`, `[DB:CASTLE:IMPACT]`, and `[DB:WAVE:FIRST_DEFENSE]` are accepted on `main`. Those proofs establish the toothpick hit path, target-owned pop/despawn, one modular castle chunk with local health/destruction, a fixed three-bubble defense, presentation-owned feedback, and a phone-accessible Web review path through the shared damage contract.

The current bounded milestone is `[DB:ENCOUNTER:MIXED_THREE_WAVE]`: present inherited BasicBubble enemies as bipedal bubble monsters, introduce the Fast variant, then run one authored three-wave Basic/Fast encounter against the same persistent two-health CastleChunk. Creature limbs/faces and locomotion poses are presentation-only. Small typed spawn/wave Resources describe only the exact schedule; MixedEncounter owns READY/WAVE_ACTIVE/INTERMISSION/WON/LOST progression. This is not a reusable wave DSL, registry, upgrade loop, or economy.

Resolve live GitHub state before assuming the status of any branch, pull request, workflow, or preview. Current execution detail belongs in `docs/ACTIVE_HANDOFF.md`. Current Game Director intent and cautions belong in `docs/DIRECTORS_NOTES.md`.

## Semantic anchors

Use stable searchable anchors only when they materially improve navigation or ownership. Vocabulary starts with `[DB:<DOMAIN>:<RESPONSIBILITY>]`.

Examples: `[DB:CORE:GAME_ROOT]`, `[DB:COMBAT:DAMAGE]`, `[DB:COMBAT:POP]`, `[DB:INPUT:PLAYER_INTENT]`, `[DB:PLATFORM:MOBILE]`, `[DB:PLATFORM:WEB_PREVIEW]`, `[DB:PERF:QUALITY]`, `[DB:CASTLE:CHUNK]`, `[DB:WAVE:FIRST_DEFENSE]`, `[DB:ENEMY:FAST_BUBBLE]`, `[DB:ENCOUNTER:MIXED_THREE_WAVE]`.

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
