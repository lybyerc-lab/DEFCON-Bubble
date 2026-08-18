# DEFCON BUBBLE agent context

Read this before changing the repository.

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

## Current milestone

Foundation 0. Establish a clean, recoverable, testable repository before production gameplay begins.

## Semantic anchors

Use stable searchable anchors only when they materially improve navigation or ownership. Vocabulary starts with `[DB:<DOMAIN>:<RESPONSIBILITY>]`.

Examples: `[DB:CORE:GAME_ROOT]`, `[DB:COMBAT:DAMAGE]`, `[DB:CASTLE:CHUNK]`, `[DB:WAVE:DIRECTOR]`, `[DB:DEBUG:SEED]`.

## Do not

- Broaden scope silently.
- Add dependencies casually.
- Introduce giant global managers or a universal event bus.
- Put gameplay truth in UI, VFX, audio, or animation.
- Use display text as stable gameplay/save identity.
- Commit secrets.
- Change locked game laws without recording a decision.

## Source of truth

Implementation truth is GitHub. Deeper creative/design truth is maintained in the DEFCON BUBBLE Google Drive project core.
