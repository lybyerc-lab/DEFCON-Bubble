# DEFCON BUBBLE agent context

Read this after resolving live GitHub repository state.

## Pitch

A 2.5D beach-defense game. The player holds the left side and protects a sandcastle from bubble monsters advancing from the right, beginning with toothpick weapons.

## Locked laws

- Beach setting is core identity.
- Bubbles are enemies.
- Protect the sandcastle at all costs.
- Combat stays primarily left-to-right and immediately readable.
- Toothpick ranged combat is the starting weapon fantasy.
- Castle damage is visible and localized.
- Weapons and sand/castle defenses upgrade.
- Escalation from peaceful beach to absurdly serious beach warfare is part of the tone.

## Technical baseline

- Godot 4.7.1 stable
- GDScript
- Desktop-first prototype
- Modular castle chunks are the current destruction approach.
- Data-first definitions with stable IDs.
- Composition over deep inheritance.
- Presentation observes gameplay; it does not own gameplay truth.
- Shared typed damage boundary is canonical on `main`.

## Current development edge

Foundation 0 and `[DB:COMBAT:DAMAGE]` are accepted. The next bounded gameplay proof is `[DB:COMBAT:POP]`: one basic bubble, one toothpick hit path, and target-owned pop/despawn behavior through the shared damage contract.

Current execution detail belongs in `docs/ACTIVE_HANDOFF.md`. Current Game Director intent and cautions belong in `docs/DIRECTORS_NOTES.md`.

## Semantic anchors

Use stable searchable anchors only when they materially improve navigation or ownership. Vocabulary starts with `[DB:<DOMAIN>:<RESPONSIBILITY>]`.

Examples: `[DB:CORE:GAME_ROOT]`, `[DB:COMBAT:DAMAGE]`, `[DB:COMBAT:POP]`, `[DB:CASTLE:CHUNK]`, `[DB:WAVE:DIRECTOR]`, `[DB:DEBUG:SEED]`.

## Do not

- Broaden scope silently.
- Add dependencies casually.
- Introduce giant global managers or a universal event bus.
- Put gameplay truth in UI, VFX, audio, or animation.
- Use display text as stable gameplay/save identity.
- Commit secrets.
- Change locked game laws without recording a decision.

## Source of truth

Implementation truth is GitHub. Deeper creative/design truth is maintained in the DEFCON BUBBLE Google Drive project core. Director's Notes guide current judgment but do not override live implementation truth or locked decisions.
