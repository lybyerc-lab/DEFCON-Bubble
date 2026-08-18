# System map

## Layers

1. Run orchestration: boot, run lifecycle, wave lifecycle, restart, transitions.
2. Gameplay domain: player, weapons, projectiles, enemies, damage, castle, upgrades, repair.
3. Content/data: definitions and stable IDs.
4. Presentation: camera, models, animation, VFX, audio, HUD, menus.
5. Infrastructure: input mapping, content registry, seeded RNG, persistence, platform adapters.
6. Debug/test: smoke tests, debug overlay, deterministic reproduction, profiling.

## Ownership law

- GameRoot owns top-level run orchestration, not gameplay rules.
- Player owns player-local input interpretation/state.
- Weapon owns firing rules.
- Projectile owns travel and hit request only.
- Enemy owns its behavior and requests damage.
- Castle owns castle chunks, localized destruction, and survival evaluation.
- WaveDirector will own wave state/timing.
- HUD renders and requests choices; it never becomes gameplay truth.

## Damage contract

- `DamageRequest` carries source ID, target ID, positive amount, typed damage category, and impact position.
- Requests are construct-once messages. Callers must not mutate a request after dispatch.
- `DamageReceiver` validates request structure and target routing, then emits the typed request to the owning gameplay domain.
- `DamageReceiver` owns no health, resistance, death, destruction, reward, or presentation behavior.
- A projectile or enemy may request damage; the receiving target domain decides the outcome.
- Initial damage categories are `PIERCE` and `IMPACT`. New categories require an explicit contract/test update rather than ad-hoc strings.
