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

No next gameplay milestone is selected yet. Do not infer one from the system map, long-term fantasy, or previously excluded POP scope.

## Immediate sequence

After resolving live GitHub state:

1. Get explicit Game Director direction for one next player-facing question.
2. Record that question here as a bounded milestone with acceptance evidence and non-goals.
3. Branch from current `main`; do not continue feature work on the merged POP branch.
4. Preserve the accepted damage, POP ownership, mobile-first, renderer, and preview contracts.
5. Prefer existing licensed assets for commodity needs when they meet the creative target; record provenance and license.
6. Build the smallest playable proof that answers the selected question.
7. Run deterministic automation, then collect the representative player/device evidence required by the risk.
8. Promote only after technical proof and Game Director acceptance.

## Until the next milestone is selected

- do not silently choose waves, castle damage, upgrades, repair, progression, or another major system
- do not reopen accepted POP tuning without new player evidence or a measured defect
- do not build generalized frameworks ahead of a selected gameplay need
- do not add pooling or speculative mobile optimization without measurements
- do not begin native-store packaging without an explicit platform/release milestone

## Standing laws

- Targets own resistance, health, death, and destruction decisions.
- Presentation reacts to gameplay truth; it never becomes damage authority.
- Touch UI requests player intent; it never becomes combat authority.
- Mobile-first preserves the grand fantasy; performance constraints are handled deliberately rather than by automatic feature retreat.
- Keep `main` buildable.
- Automation proves; promotion is deliberate.
- Player-facing mobile behavior needs representative phone/touch evidence when materially relevant.
- No secrets in Git and no new dependency without explicit justification/provenance.
