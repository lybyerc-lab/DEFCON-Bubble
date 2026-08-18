# Active handoff

## Recovery rule
Resolve live GitHub state first. Then read `AGENT_CONTEXT.md`, this handoff, and `docs/DIRECTORS_NOTES.md` before acting.

- If PR #2 (`combat: establish typed damage contract`) is still open, verify its exact live head and finish that promotion before starting gameplay integration.
- If PR #2 is merged, the damage contract is canonical and the next bounded milestone is the first POP proof.

## Canonical baseline
Foundation 0 is accepted on `main`.

The shared damage boundary is:
- `DamageRequest`: source ID, target ID, positive amount, typed damage category, impact position.
- `DamageReceiver`: validates/routes and emits the request; owns no health, resistance, death, destruction, reward, or presentation outcome.
- Initial damage categories: `PIERCE` and `IMPACT`.

## Next bounded milestone
`[DB:COMBAT:POP]` first POP proof.

Prove one basic bubble can receive a `PIERCE` request from a toothpick hit and own its resulting pop/despawn behavior through the shared damage boundary.

Keep the first POP proof narrow: one basic bubble, one toothpick projectile/hit path, deterministic test coverage, and satisfying-but-minimal pop feedback only after gameplay truth works.

## Must not drift into
- waves or procedural spawning
- castle damage
- upgrade systems
- repair systems
- save/meta progression
- large weapon trees
- pooling before profiling
- generalized enemy frameworks beyond what Bubble #1 actually needs

## Standing laws
- Targets own resistance, health, death, and destruction decisions.
- Presentation reacts to gameplay truth; it never becomes damage authority.
- Keep `main` buildable.
- Automation proves; promotion is deliberate.
- No secrets in Git and no new dependency without explicit justification/provenance.
