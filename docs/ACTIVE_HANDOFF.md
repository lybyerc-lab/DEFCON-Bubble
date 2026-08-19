# Active handoff

## Recovery rule

Resolve live GitHub state first. Then read `AGENT_CONTEXT.md`, this handoff, `docs/DIRECTORS_NOTES.md`, and `docs/MOBILE_FIRST.md` before acting on player-facing or platform work.

Do not assume this file's PR numbers or branch state are current. Verify them live.

## Canonical baseline

Foundation 0 is accepted on `main`.

The shared damage boundary is:
- `DamageRequest`: source ID, target ID, positive amount, typed damage category, impact position.
- `DamageReceiver`: validates/routes and emits the request; owns no health, resistance, death, destruction, reward, or presentation outcome.
- Initial damage categories: `PIERCE` and `IMPACT`.

The product direction is mobile-first:
- native mobile is the intended shipped experience
- desktop is development/debug/profiling/automation
- Web is rapid phone-accessible preview infrastructure
- native mobile renderer override is `mobile`
- Web renderer override is `gl_compatibility`

## Accepted gameplay edge

Accepted on `main`:
- `[DB:COMBAT:POP]` at `98ce22ed5f119bbb9d4adfc3f72e8468b1aafe58`
- `[DB:CASTLE:IMPACT]` at `10cb2f20446c759dfa62a1303483552634fddda4`
- `[DB:WAVE:FIRST_DEFENSE]` at `306f7a8c94fe55e17b7dd29850f9f327211ccb9c`
- `[DB:ENCOUNTER:MIXED_THREE_WAVE]` at `942083789e8d7dc4c61e9aad78757d95eb083451`

The accepted proofs establish:
- typed toothpick `PIERCE` damage into target-owned health and POP/despawn truth
- one modular CastleChunk with typed `IMPACT`, local damage, destruction, and persistent health
- accepted soap-film POP presentation and CC0 POP audio
- a fixed first defense encounter with authoritative outcome and RETRY
- Basic/Brute, Fast/Runner, and Heavy/Big Blub as phone-accepted members of one faceless bubble-monster family
- Fast at `2.25 m/s`, forgiving `0.85` root/collision scale, one health, and acid-lime presentation
- Big Blub at five health, `0.55 m/s`, `1.7` scale, wide silhouette, and slow presentation-only gait
- authored BASIC TRAINING, FAST BUBBLES, and FINAL PUSH waves with 2.25-second intermissions
- one persistent two-health castle across the mixed encounter and roof-mounted toothpick origin
- FINAL PUSH beginning with Big Blub
- phone-readable wave/castle/terminal messaging and a phone-tested pristine RETRY path
- a separately composed `BeachEnvironment` owning sand, water, shoreline, and sunlight presentation only
- deterministic foundation, damage, POP, castle, first-defense, creature, Fast, Heavy, environment, and mixed-encounter fixtures
- exact-source GitHub Pages build and deployment for phone review

The Game Director tested and accepted the mixed encounter on a phone, including Fast readability, approach pressure, intermission clarity, final-wave tension, one-leak recoverability, second-leak defeat, and RETRY behavior.

## Current bounded milestone

No new gameplay milestone is selected yet.

Do not infer the next task from the remaining monster roster or from previously discussed systems. The next slice must be chosen deliberately from current design intent and must state one bounded player-facing question plus its acceptance target before implementation begins.

The approved but not-yet-implemented roster still includes Stiltwalker, Weaver, Mutant, and Bubble King. Their concept roles are not permission to invent mechanics early.

## Immediate sequence

1. Keep accepted `main` green and recoverable.
2. Resolve current Game Director intent and live repo state before selecting the next milestone.
3. Define the next bounded player-facing question, ownership boundaries, non-goals, and phone acceptance gate.
4. Create a fresh feature branch only after that scope is explicit.
5. Promote only after automation is green and the relevant player-facing behavior is accepted on a phone.

## Must not drift into

- generalized wave DSLs, registries, procedural spawning, or universal navigation without a concrete need
- multiple lanes/chunks, repair, upgrades, progression, rewards, or economy merely because they are future possibilities
- new weapons or enemy mechanics without a bounded gameplay question
- reopening accepted POP, castle, or encounter behavior without new player evidence or a measured defect
- pooling or speculative optimization without measurements
- native-store packaging before platform/store priority is deliberately selected

## Standing laws

- Targets own resistance, health, death, and destruction decisions.
- Presentation reacts to gameplay truth; it never becomes damage authority.
- Touch UI requests player intent; it never becomes combat authority.
- Mobile-first preserves the grand fantasy; performance constraints are handled deliberately rather than by automatic feature retreat.
- Keep `main` buildable.
- Automation proves; promotion is deliberate.
- Player-facing mobile behavior needs representative phone/touch evidence when materially relevant.
- No secrets in Git and no new dependency without explicit justification/provenance.
