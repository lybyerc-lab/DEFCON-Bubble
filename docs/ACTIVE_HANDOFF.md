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

`[DB:COMBAT:POP]` is accepted and promoted to `main` at `98ce22ed5f119bbb9d4adfc3f72e8468b1aafe58`.

The accepted proof establishes:
- one basic bubble receiving a typed `PIERCE` request from one toothpick
- target-owned health, pop state, collision shutdown, and timed despawn
- presentation-owned soap-film rupture, centered droplet spray, mist, and CC0 POP audio
- Web FIRE/RESET controls for rapid phone review
- deterministic foundation, damage-contract, POP, import, and headless-boot verification
- exact-source GitHub Pages build and deployment

Godot Verify #26 passed on the accepted PR head. The post-merge `main` verification and production Pages deployment also passed. The Game Director accepted the final POP sound on a phone.

## Current bounded milestone

`[DB:CASTLE:IMPACT]` is the current gameplay milestone.

Prove one Bubble #1 can advance from the right, contact one modular sandcastle chunk, request one typed `IMPACT` through the accepted damage boundary, and produce a local visible damage response owned by that chunk.

The proof must preserve the accepted POP path: the defender can still shoot the approaching bubble with one toothpick before it reaches the castle.

### Acceptance target

- bubble advance is frame-rate independent and disabled outside the proof unless explicitly enabled
- bubble contact requests exactly one valid `IMPACT` and cannot damage the chunk twice
- the chunk ignores `PIERCE`, owns health, and owns destruction at zero health
- presentation observes chunk damage/destruction signals without becoming gameplay authority
- the arena shows one readable castle chunk, one approaching bubble, and the accepted FIRE/RESET path
- deterministic positive and negative fixtures pass under pinned Godot 4.7.1
- exact-source Web preview builds and deploys for phone judgment

## Immediate sequence

After resolving live GitHub state:

1. Keep the proof to one advancing bubble and one modular chunk.
2. Preserve the accepted toothpick, POP, touch, renderer, and preview contracts.
3. Prove valid contact, ignored damage type, wrong-target rejection, one-impact idempotence, localized damage, and chunk-owned destruction.
4. Run pinned Godot verification and exact-source Web export/deployment.
5. Judge approach timing, castle readability, impact feel, and defensive urgency on a phone.
6. Tune only inside this milestone when evidence identifies a defect.
7. Promote only after technical proof and Game Director acceptance.

## Must not drift into

- multiple chunks, full castle survival, or castle-wide orchestration
- waves, procedural spawning, or generalized enemy navigation
- repair, upgrades, progression, rewards, or economy
- new weapons or additional bubble types
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
