# DEFCON BUBBLE

**THE CASTLE MUST HOLD.**

DEFCON BUBBLE is a mobile-first 3D/2.5D beach-defense game where a lone defender protects a sandcastle from bubble monsters advancing from the right. The starter weapon is a toothpick. The emergency will escalate accordingly.

The intended game is not a reduced mobile side project. It is the full absurd beach-war fantasy, designed from the beginning to live in your hands.

## Project status

Foundation 0, the shared typed damage boundary, and the first Bubble #1 toothpick POP proof are accepted on `main`. The next bounded gameplay milestone has not been selected yet. Always verify live branches, PRs, and CI before trusting this summary.

## Product target

- **Primary shipped experience:** native mobile.
- **Desktop:** authoring, debugging, profiling, automation, and fast iteration.
- **Web:** rapid-access preview surface for opening exact-source candidates on a phone.
- **Initial native platform/store order:** intentionally not locked yet.

Mobile-first does not mean smaller ambition. Spectacle should come from strong staging, readable combat, responsive touch interaction, scalable effects, smart enemy presentation, and measured performance budgets rather than brute-force scene complexity.

## Technical baseline

- Godot 4.7.1 stable.
- GDScript.
- Desktop development keeps Forward+.
- Native mobile uses the Mobile renderer override.
- Web preview uses the Compatibility renderer override.
- 3D scenes are constrained to readable side-scroller combat.
- Data-first content and modular gameplay systems.
- Touch input and phone-scale readability are first-class product requirements.

## Development laws

- Left is home. Right is the bubble problem.
- The sandcastle is the heart of the game.
- Visible castle damage is gameplay truth, not decoration.
- Presentation may react to gameplay but never owns gameplay truth.
- Touch UI requests player intent; it does not own combat rules.
- Prefer composition, typed contracts, stable IDs, and small responsibilities.
- Use searchable semantic anchors such as `[DB:CASTLE:CHUNK]` and `[DB:PLATFORM:MOBILE]` where they materially improve navigation.
- Keep `main` buildable; automation proves and promotion remains deliberate.
- Player-facing mobile milestones require representative phone/touch evidence, not desktop-only confidence.

## Development start

Open the repository in Godot 4.7.1 and run the project for desktop development and debugging.

Headless verification:

```bash
godot --headless --path . --script res://tests/foundation_smoke.gd
godot --headless --path . --script res://tests/damage_contract_smoke.gd
```

Phone-facing preview and native export workflows should be source-driven and traceable to an exact Git revision. See `docs/MOBILE_FIRST.md`.

## Project truth

Start with `AGENT_CONTEXT.md` for a compact briefing and `AGENTS.md` for operating law. Read `docs/MOBILE_FIRST.md` for durable mobile product and engineering rules. Deeper creative direction lives in the project Google Drive; repository implementation truth lives here.

## Rights

This repository is public for viewing, sharing, collaboration, and project development, but it is **not currently published under an open-source license**. See `RIGHTS.md`.
