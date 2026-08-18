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

## Current bounded milestone

`[DB:COMBAT:POP]` remains the gameplay milestone.

Prove one basic bubble can receive a `PIERCE` request from a toothpick hit, own its resulting pop/despawn behavior through the shared damage boundary, and feel clean/readable through a phone-accessible touch preview.

The mobile preview is an acceptance surface for POP, not permission to expand the gameplay scope.

## Immediate sequence

After resolving live GitHub state:

1. Identify the current POP candidate and exact head SHA. PR #4 (`combat: prove first bubble pop`) is the known candidate at the time of this handoff, but live GitHub wins.
2. Reconcile the POP candidate with the canonical mobile-first law if `main` has advanced.
3. Keep the proof narrow: one basic bubble, one toothpick path, touch-accessible FIRE/RESET where needed, deterministic automated coverage, and minimal satisfying POP presentation.
4. Prefer a source-driven Web preview that maps to the exact candidate revision so the Game Director/player can open it on a phone without a desktop development setup.
5. Run automated proof, then perform the phone feel/readability check.
6. Tune only inside the POP milestone if the phone test exposes readability, touch, timing, audio, or presentation problems.
7. Promote only after both technical proof and player-facing mobile acceptance are satisfactory.

Native store packaging is not required to accept the first POP milestone.

## Must not drift into

- waves or procedural spawning
- castle damage
- upgrade systems
- repair systems
- save/meta progression
- large weapon trees
- pooling before profiling
- generalized enemy frameworks beyond what Bubble #1 actually needs
- full native-store packaging before POP needs it
- speculative mobile optimization without measurements

## Standing laws

- Targets own resistance, health, death, and destruction decisions.
- Presentation reacts to gameplay truth; it never becomes damage authority.
- Touch UI requests player intent; it never becomes combat authority.
- Mobile-first preserves the grand fantasy; performance constraints are handled deliberately rather than by automatic feature retreat.
- Keep `main` buildable.
- Automation proves; promotion is deliberate.
- Player-facing mobile behavior needs representative phone/touch evidence when materially relevant.
- No secrets in Git and no new dependency without explicit justification/provenance.
