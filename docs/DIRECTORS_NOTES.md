# Game Director notes

## Purpose

This is the lightweight strategic layer between durable project law and the current task handoff. Read it in every fresh DEFCON BUBBLE chat after `AGENT_CONTEXT.md` and `docs/ACTIVE_HANDOFF.md`.

Keep this file short. It should preserve judgment, emphasis, risks, and creative/technical intent that would otherwise disappear when a chat is retired.

## Current notes

- DEFCON BUBBLE is a native mobile-first game. The phone is the battlefield and a real acceptance surface, not a later port target.
- Do not shrink the fantasy because the target is mobile. Keep the escalating beach-war spectacle and solve cost through staging, scalable presentation, controlled simulation, and measurement.
- Design from the thumb outward. Prefer direct, forgiving touch interaction that preserves battlefield visibility; do not default to virtual sticks or control clutter.
- Web preview is a review booth, not the finished building. Browser-on-phone evidence is excellent for rapid feel review; representative native-device evidence becomes required before player-facing behavior is considered platform-ready.
- The booth serves an exported release build, and an exported build can behave differently from the editor. Judge player-facing behavior against the booth, and be suspicious when something works on desktop but reads wrong on the phone — that gap has already hidden one real defect.
- Foundation, typed damage, the accepted soap-film POP, castle impact, First Defense, the mixed three-wave encounter, the first upgrade choice, and the lit beach are promoted on `main`.
- Framing is a gameplay-readability concern wearing a presentation costume. A battlefield the player cannot take in at a glance is a worse problem than a surface that lacks detail, which is why framing goes ahead of sand and water.
- Do not let framing quietly become level design. If the arena has to change proportions, the gameplay distances built on it are deliberate decisions to preserve and prove, not numbers to nudge until the camera looks right.
- Treat accepted POP, castle consequence, enemy identities, mixed-encounter timing, the upgrade seam, and now scene lighting and the shared soap film as reusable contracts. Reopen them only for new player evidence, a measured defect, or production-scale requirements.
- The faceless bipedal bubble-creature family is the accepted visual baseline. Basic/Brute, Fast/Runner, and Heavy/Big Blub are the first accepted roster interpretations. Do not collapse the approved seven-character family into one generic stat blob.
- One accepted between-wave choice is the single most tempting place for scope to escape. A working choice is not a mandate for currency, prices, rarity, rerolls, shops, repair AI, permanent progression, or a generic upgrade tree. The next upgrade-adjacent step needs its own bounded question and its own phone gate.
- Upgrade UI is a messenger, not authority. Stable IDs and run-scoped state own the choice; projectile and castle domains still own their outcomes.
- Lighting is accepted. The next question is `[DB:CAMERA:ORIENTATION_FRAMING]`: the battlefield must frame deliberately on a phone in both orientations instead of inheriting an engine default.
- Light first was the right call and it paid off as a diagnostic. Lighting the scene immediately exposed two pre-existing defects the void background had been hiding: flat sand and a shallow playable strip in landscape. Expect later presentation slices to keep revealing things rather than only adding them.
- Iridescence is identity, not decoration, and it has a taste ceiling. The accepted tuning reads as soap film catching the sun. Reopen it only if the family stops reading as one faceless species at phone size and speed.
- Readability of wave, castle, terminal, and upgrade messaging is part of every visual gate, not a separate concern. Framing work puts it at risk the same way brightening did.
- Keep upgrade payoffs legible against a concrete yardstick the way Skewer was judged against Big Blub's hit count. An upgrade whose effect cannot be seen in play is not finished, however correct its arithmetic.
- Gameplay truth comes first; juice follows immediately after the truth works. Player feel remains a real gate.
- Prefer appropriately licensed commodity assets when they genuinely fit. Meshy is available as an offline 3D asset forge, but approved exported assets belong to DEFCON BUBBLE and the shipped game must not depend on the service at runtime.
- Codex and AG can be used as specialist engineering/review partners, but repository law and Game Director acceptance remain authoritative.
- Keep the humble beach identity visible even as intensity grows. Serious systems should serve the absurd beach-defense fantasy.
- Do not invent device budgets or silently choose iOS versus Android launch priority before evidence and intent support locking them.
- New chats must verify live GitHub state before trusting prose. Automation proves, the Game Director inspects evidence, the player judges feel, and promotion to `main` stays deliberate.

## Update discipline

Add or revise a note only when it would materially change how a future session should make a decision. When a note becomes a settled rule, move it into the appropriate decision/system document. When it stops affecting judgment, remove it.

Target size: roughly one screen to one page. This is a compass, not a diary.
