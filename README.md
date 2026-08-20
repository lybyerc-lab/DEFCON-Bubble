# DEFCON BUBBLE

**THE CASTLE MUST HOLD.**

DEFCON BUBBLE is a mobile-first 3D/2.5D beach-defense game where a lone defender protects a sandcastle from bubble monsters advancing from the right. The starter weapon is a toothpick. The emergency will escalate accordingly.

The intended game is not a reduced mobile side project. It is the full absurd beach-war fantasy, designed from the beginning to live in your hands.

## Project status

Foundation 0, the shared typed damage boundary, Bubble #1 POP, castle impact, First Defense, the phone-accepted mixed three-wave Basic/Fast/Heavy encounter, `[DB:UPGRADE:FIRST_CHOICE]`, and `[DB:PRESENTATION:LIT_BEACH]` are accepted on `main`. The upgrade edge is one safe post-Wave-1 choice between a two-damage longer Skewer and +1 Shell Reinforcement durability, with no currency or progression tree. The beach is lit by a sky-sourced `WorldEnvironment`, and one shared soap-film shader covers the whole bubble family. The game is locked to landscape. The current bounded milestone is `[DB:PLAYER:WALL_DEFENDER]`: a defender who patrols the wall, making where you stand a real decision. Always verify live branches, PRs, and CI before trusting this summary.

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
godot --headless --path . --script res://tests/pop_proof_smoke.gd
godot --headless --path . --script res://tests/castle_impact_smoke.gd
godot --headless --path . --script res://tests/first_defense_smoke.gd
godot --headless --path . --script res://tests/fast_bubble_smoke.gd
godot --headless --path . --script res://tests/bubble_creature_smoke.gd
godot --headless --path . --script res://tests/heavy_bubble_smoke.gd
godot --headless --path . --script res://tests/environment_structure_smoke.gd
godot --headless --path . --script res://tests/mixed_encounter_smoke.gd
godot --headless --path . --script res://tests/first_upgrade_choice_smoke.gd
```

## Phone review booth

The replaceable Web review booth is available at <https://lybyerc-lab.github.io/DEFCON-Bubble/>. Always use `docs/ACTIVE_HANDOFF.md` and live GitHub state to confirm which exact revision is deployed before judging a candidate.

Phone-facing preview and native export workflows must remain source-driven and traceable to an exact Git revision. See `docs/MOBILE_FIRST.md`.

## Project truth

Start with `AGENT_CONTEXT.md` for a compact briefing and `AGENTS.md` for operating law. Read `docs/MOBILE_FIRST.md` for durable mobile product and engineering rules. Deeper creative direction lives in the project Google Drive; repository implementation truth lives here.

## Rights

This repository is public for viewing, sharing, collaboration, and project development, but it is **not currently published under an open-source license**. See `RIGHTS.md`.
