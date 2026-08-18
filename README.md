# DEFCON BUBBLE

**THE CASTLE MUST HOLD.**

DEFCON BUBBLE is a 2.5D beach-defense game where a lone defender protects a sandcastle from bubble monsters advancing from the right. The starter weapon is a toothpick. The emergency will escalate accordingly.

## Project status

Foundation 0. No production gameplay exists yet.

## Technical baseline

- Godot 4.7.1 stable
- GDScript
- Desktop-first prototype
- 3D scenes constrained to readable side-scroller combat
- Data-first content and modular gameplay systems

## Development laws

- Left is home. Right is the bubble problem.
- The sandcastle is the heart of the game.
- Visible castle damage is gameplay truth, not decoration.
- Presentation may react to gameplay but never owns gameplay truth.
- Prefer composition, typed contracts, stable IDs, and small responsibilities.
- Use searchable semantic anchors such as `[DB:CASTLE:CHUNK]` where they materially improve navigation.
- `main` becomes a buildable protected baseline after Foundation 0 is accepted.

## Start

Open the repository in Godot 4.7.1 and run the project.

Foundation smoke test:

```bash
godot --headless --path . --script res://tests/foundation_smoke.gd
```

## Project truth

Start with `AGENT_CONTEXT.md` for a compact briefing and `AGENTS.md` for operating law. Deeper creative direction lives in the project Google Drive; repository implementation truth lives here.

## Rights

This repository is public for viewing, sharing, collaboration, and project development, but it is **not currently published under an open-source license**. See `RIGHTS.md`.
