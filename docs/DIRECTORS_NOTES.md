# Game Director notes

## Purpose

This is the lightweight strategic layer between durable project law and the current task handoff. Read it in every fresh DEFCON BUBBLE chat after `AGENT_CONTEXT.md` and `docs/ACTIVE_HANDOFF.md`.

Keep this file short. It should preserve judgment, emphasis, risks, and creative/technical intent that would otherwise disappear when a chat is retired.

## Current notes

- The product target is now unambiguous: DEFCON BUBBLE is a native mobile-first game. The phone is the battlefield and a real acceptance surface, not a later port target.
- Do not shrink the fantasy because the target is mobile. Keep the escalating beach-war spectacle and solve cost through staging, scalable presentation, controlled simulation, and measurement.
- Design from the thumb outward. Prefer direct, forgiving touch interaction that preserves battlefield visibility; do not default to virtual sticks or control clutter just because the game is on a phone.
- Perceived scale matters more than brute-force object counts. Timing, layered action, silhouettes, destruction, sound, escalation, and smart staging should make the beach war feel enormous without treating raw simulation count as the goal.
- Desktop remains invaluable for development and automation, but do not let desktop convenience quietly dictate controls, readability, UI density, lifecycle behavior, or performance assumptions.
- Web preview is a review booth, not the finished building. Prefer exact-source, GitHub-driven previews that are easy to open on a phone and easy to replace when hosting changes.
- Browser-on-phone evidence is excellent for rapid feel review; representative native-device evidence becomes required before player-facing behavior is considered platform-ready.
- The project has crossed from architecture setup into gameplay proof. Resist reopening broad foundation work unless a measured problem requires it.
- The next important gameplay question remains whether shooting a toothpick into Bubble #1 produces a clean, readable, satisfying POP through the architecture we established, now judged on the phone as well as through automation.
- Protect the narrow milestone. Do not let POP quietly become waves, castle damage, upgrades, a generalized enemy framework, pooling, native-store release engineering, or meta progression.
- Gameplay truth comes first; juice follows immediately after the truth works. A technically correct pop that feels lifeless is not the final POP milestone.
- Keep the humble beach identity visible even as intensity grows. Serious systems should serve the absurd beach-defense fantasy, not sand off its personality.
- Do not invent device budgets or silently choose iOS versus Android launch priority before we have the evidence and intent to lock them.
- New chats must verify live GitHub state before trusting metadata or stale prose. Contents, refs, commits, PRs, and CI are authoritative for implementation state.
- Continue the discipline: automation proves, the Game Director inspects evidence, the player judges feel, and promotion to `main` stays deliberate.

## Update discipline

Add or revise a note only when it would materially change how a future session should make a decision. When a note becomes a settled rule, move it into the appropriate decision/system document. When it stops affecting judgment, remove it.

Target size: roughly one screen to one page. This is a compass, not a diary.
