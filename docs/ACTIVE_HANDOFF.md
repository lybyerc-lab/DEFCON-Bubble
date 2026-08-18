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

`[DB:COMBAT:POP]` is accepted on `main` at `98ce22ed5f119bbb9d4adfc3f72e8468b1aafe58`. `[DB:CASTLE:IMPACT]` is accepted at `10cb2f20446c759dfa62a1303483552634fddda4`. `[DB:WAVE:FIRST_DEFENSE]` is accepted on `main` at `306f7a8c94fe55e17b7dd29850f9f327211ccb9c`.

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
- one fixed three-BasicBubble wave with unique IDs, authoritative outcome, readable HUD, and RETRY

The Game Director accepted the final POP sound, castle success/failure paths, and First Defense encounter on a phone.

## Current bounded milestone

`[DB:ENCOUNTER:MIXED_THREE_WAVE]` is the current gameplay milestone.

Present Basic and Fast enemies as faceless, elongated bipedal bubble monsters. Their horns, arms, segmented legs, and feet are smaller translucent bubbles driven by a presentation-only walk cycle. Introduce Fast Bubble as inherited BasicBubble gameplay at 2.25 m/s with a smaller forgiving 0.85 root/collision scale and an unmistakable acid-lime 4 Hz pulse. In the mixed range, move the persistent two-health CastleChunk to x=-4.4 and fire toothpicks from a marker parented to its roof.

The authored schedule is BASIC TRAINING (`basic` at 0.0, 1.6, 3.2), FAST BUBBLES (`fast` 0.0, `basic` 1.2, `fast` 4.2, `basic` 5.4), and FINAL PUSH (`heavy` 0.0, `fast` 0.9, `basic` 2.0, `fast` 5.1, 6.0). Intermissions are exactly 2.25 seconds with no clock carry.

### Acceptance target

- Fast Bubble retains one health, one IMPACT, accepted POP/despawn, and BasicBubble gameplay ownership
- Big Blub inherits the same ownership with five health, `0.55 m/s` advance, a 1.7 scale, wide silhouette, and slow presentation-only gait
- Basic and Fast both inherit the same readable bipedal monster rig; its animation never changes movement, collision, damage, or outcome
- creature limbs disappear on authoritative POP so the accepted membrane rupture remains the death read
- no eyes, pupils, brows, or mouth remain; silhouette and motion carry the creature identity
- the mixed-range castle is farther left and owns the roof launcher transform; toothpick damage and travel remain unchanged
- `BeachEnvironment` owns sand, water, shoreline, and sunlight while the arena separately composes encounter gameplay and camera
- authoritative encounter state moves only through READY, WAVE_ACTIVE, INTERMISSION, WON, and LOST
- small typed `EncounterSpawnPlan` and `EncounterWavePlan` Resources hold only the exact kind/time and wave identity/title
- every authored spawn receives a unique wave+slot ID; duplicate, foreign, stale, and terminal callbacks cannot mutate truth
- wave progression waits for all authored threats to spawn and resolve; only FINAL PUSH clear wins
- the same CastleChunk health persists across all waves; its second lifetime leak loses immediately
- loss cancels current/future spawns and stops every surviving bubble without declaring it dead
- phone-readable HUD shows wave X/3, current-wave LEFT, castle health, incoming/clear/next/final messaging, and the terminal RETRY affordance
- automation proves the RETRY control state; actual scene reload/restart behavior remains a phone runtime acceptance gate
- deterministic positive and negative fixtures pass under pinned Godot 4.7.1
- exact-source Web preview builds and deploys for phone judgment

## Live candidate status

The current candidate is local and uncommitted until the implementation, pinned tests, and exact-source preview are reviewed:

- branch: `agent/fast-bubble-encounter`
- base: accepted `main` at `306f7a8c94fe55e17b7dd29850f9f327211ccb9c`
- pull request: none yet
- pinned Godot 4.7.1 local verification: passed (import, all ten fixtures, and headless boot)
- exact-source Pages preview: pending

FirstDefenseWave, its range, HUD, and deterministic test remain unchanged as frozen accepted regression proof.

## Immediate sequence

After completing the local candidate:

1. Publish the draft candidate and confirm the exact-source CI and Web preview.
2. Confirm Fast Bubble's lime identity and speed remain readable on a phone without changing accepted POP.
3. Confirm authored wave timing, persistent one-leak damage, second-leak defeat, intermission controls, final victory, and actual RETRY scene reload on a phone.
4. Tune only an evidenced Fast presentation or authored timing defect within this milestone.
5. Promote only after explicit Game Director acceptance.

## Must not drift into

- multiple lanes or chunks, aiming, full castle orchestration, or tactical target-priority claims
- registries, reusable wave DSLs, procedural spawning, or generalized enemy navigation
- repair, upgrades, progression, rewards, or economy
- new weapons, additional bubble types, or new sounds
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
