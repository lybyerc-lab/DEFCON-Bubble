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

`[DB:COMBAT:POP]` is accepted on `main` at `98ce22ed5f119bbb9d4adfc3f72e8468b1aafe58`. `[DB:CASTLE:IMPACT]` is accepted on `main` at `10cb2f20446c759dfa62a1303483552634fddda4`.

The accepted proofs establish:
- one basic bubble receiving a typed `PIERCE` request from one toothpick
- target-owned health, pop state, collision shutdown, and timed despawn
- presentation-owned soap-film rupture, centered droplet spray, mist, and CC0 POP audio
- Web FIRE/RESET controls for rapid phone review
- deterministic foundation, damage-contract, POP, import, and headless-boot verification
- exact-source GitHub Pages build and deployment
- one Bubble #1 advancing toward one modular CastleChunk
- exactly one typed `IMPACT` per leaked bubble
- chunk-owned health, local visible damage, collision shutdown, and destruction

The Game Director accepted both the final POP sound and the castle success/failure paths on a phone. Resolve live GitHub state for exact merge SHAs and current automation status.

## Current bounded milestone

`[DB:WAVE:FIRST_DEFENSE]` is the current gameplay milestone.

Prove one short defensive encounter with exactly three ordinary BasicBubbles attacking the existing one modular CastleChunk. Bubbles spawn at x=6.0, retain the accepted 1.25 m/s speed, and enter on a fixed 1.6 second stagger.

The proof must preserve the accepted toothpick, POP, impact, castle, and reset paths without reopening their ownership or presentation tuning.

### Acceptance target

- authoritative encounter state moves only through READY, RUNNING, WON, and LOST
- exactly three uniquely identified BasicBubbles spawn from one point, never a fourth
- spawn timing is delta-scaled, catches up safely after a long frame, and uses a 1.6 second stagger
- all three resolved bubbles with the castle alive produce WON, including a damaged-but-surviving castle
- castle destruction produces LOST immediately, cancels pending spawns, and stops surviving bubbles from advancing
- phone-readable UI observes remaining bubbles, castle health, and terminal state without owning outcomes
- deterministic positive and negative fixtures pass under pinned Godot 4.7.1
- exact-source Web preview builds and deploys for phone judgment

## Immediate sequence

After resolving live GitHub state:

1. Keep the encounter to three identical bubbles, one lane, and one existing modular chunk.
2. Preserve accepted toothpick, POP, castle-impact, touch, renderer, and preview contracts.
3. Prove exact spawn count/timing, unique IDs, damaged-castle victory, castle-destruction loss, pending-spawn cancellation, and stopped surviving advance.
4. Run pinned Godot verification and exact-source Web export/deployment.
5. Judge pressure, firing rhythm, spacing, status readability, and replay clarity on a phone.
6. Tune only bounded scene timing/spacing or presentation when player evidence identifies a defect.
7. Promote only after technical proof and Game Director acceptance.

## Must not drift into

- multiple lanes or chunks, full castle orchestration, or tactical target-priority claims
- reusable wave definitions, procedural spawning, or generalized enemy navigation
- repair, upgrades, progression, rewards, or economy
- new weapons, additional bubble types, or per-bubble stat variation
- reopening accepted POP tuning without new player evidence or a measured defect
- pooling or speculative mobile optimization without measurements
- native-store packaging

## Standing laws

- Targets own resistance, health, death, and destruction decisions.
- Presentation reacts to gameplay truth; it never becomes damage authority.
- Touch UI requests player intent; it never becomes combat authority.
- Mobile-first preserves the grand fantasy; performance constraints are handled deliberately rather than by automatic feature retreat.
- Keep `main` buildable.
- Automation proves; promotion is deliberate.
- Player-facing mobile behavior needs representative phone/touch evidence when materially relevant.
- No secrets in Git and no new dependency without explicit justification/provenance.
