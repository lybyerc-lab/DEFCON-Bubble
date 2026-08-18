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
- The project has crossed from architecture setup into accepted gameplay proof. Foundation, typed damage, and the first toothpick-to-bubble POP are now proven on `main`.
- Treat the accepted POP as a reusable contract, not a standing invitation for more polish. Reopen it only for new player evidence, a measured defect, or production-scale requirements.
- The accepted castle-impact proof showed that failure visibly damages the castle and successful defense preserves it. Starting-distance tuning was deliberately deferred until several bubbles could expose the actual rhythm.
- The first three-bubble defense is accepted on a phone. It proved the loop and exposed the next need: a visually unmistakable faster threat plus wave-to-wave escalation while castle damage persists.
- The current question is whether Fast Bubble reads immediately and whether BASIC TRAINING, FAST BUBBLES, and FINAL PUSH feel like one short escalating encounter rather than three disconnected proofs.
- The Game Director requested a bipedal people/monster direction after the mixed encounter worked well. Candidate one makes the bubbles themselves small two-legged monsters while retaining the soap-film body and accepted POP; judge charm, threat, face readability, and whether the walk feels intentional on a phone.
- Automated proof covers the terminal RETRY affordance, not a real phone reload. Judge the actual restart boundary on the phone before accepting the encounter.
- Protect the mixed encounter from becoming a generalized wave framework, target-priority claim, multiple lanes or chunks, navigation, repair, upgrades, progression, rewards, economy, or new weapon work. Authored timing and strong silhouettes are enough for this slice.
- Gameplay truth comes first; juice follows immediately after the truth works. Player feel remains a real gate, as the POP audio acceptance demonstrated.
- Prefer a proven, appropriately licensed asset when a commodity sound, image, font, or similar resource already meets the need. Reserve custom work for DEFCON BUBBLE's identity and project-specific problems; always record provenance and license.
- Keep the humble beach identity visible even as intensity grows. Serious systems should serve the absurd beach-defense fantasy, not sand off its personality.
- Do not invent device budgets or silently choose iOS versus Android launch priority before we have the evidence and intent to lock them.
- New chats must verify live GitHub state before trusting metadata or stale prose. Contents, refs, commits, PRs, and CI are authoritative for implementation state.
- Continue the discipline: automation proves, the Game Director inspects evidence, the player judges feel, and promotion to `main` stays deliberate.

## Update discipline

Add or revise a note only when it would materially change how a future session should make a decision. When a note becomes a settled rule, move it into the appropriate decision/system document. When it stops affecting judgment, remove it.

Target size: roughly one screen to one page. This is a compass, not a diary.
