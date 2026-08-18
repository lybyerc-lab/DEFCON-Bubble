# System map

## Layers

1. Run orchestration: boot, run lifecycle, wave lifecycle, restart, transitions.
2. Gameplay domain: player, weapons, projectiles, enemies, damage, castle, upgrades, repair.
3. Content/data: definitions and stable IDs.
4. Presentation: camera, models, animation, VFX, audio, HUD, menus.
5. Input/platform: player-intent adapters, touch UI, safe-area handling, lifecycle adapters, renderer/platform policy.
6. Infrastructure: content registry, seeded RNG, persistence, build/export plumbing, platform services.
7. Debug/test/performance: smoke tests, debug overlay, deterministic reproduction, profiling, quality verification.

## Ownership law

- GameRoot owns top-level run orchestration, not gameplay rules.
- Player owns player-local intent/state, not platform widgets.
- Input adapters translate touch, keyboard, controller, or future platform input into shared player intent.
- Touch UI requests player intent and remains presentation/platform glue. It does not own weapon, damage, upgrade, repair, or movement outcomes.
- Weapon owns firing rules.
- Projectile owns travel and hit request only.
- Enemy owns its behavior and requests damage.
- Castle owns castle chunks, localized destruction, and survival evaluation.
- `CastleChunk` currently proves local `IMPACT` filtering, health, collision shutdown, and destruction truth for one modular chunk; its presentation observer only renders damage.
- `FirstDefenseWave` currently owns the fixed three-bubble proof's READY/RUNNING/WON/LOST state, spawn timing/count, and terminal evaluation. It is not a generalized wave framework.
- Each spawned `BasicBubble` still owns movement, its one castle-impact request, pop state, and despawn. `FirstDefenseWave` may stop surviving advance after terminal castle loss but does not declare those enemies dead.
- The first-defense HUD observes wave and castle signals; it owns no spawn, health, damage, or terminal outcome.
- `EncounterSpawnPlan` and `EncounterWavePlan` hold only the authored kind/time sequence and wave identity/title for the current mixed encounter. They are not a registry, procedural grammar, or rule engine.
- `MixedEncounter` owns the fixed three-wave order, per-wave clock, 2.25-second intermissions, stable wave/slot IDs, and READY/WAVE_ACTIVE/INTERMISSION/WON/LOST outcome. It does not own enemy damage/death or castle health.
- Fast Bubble instantiates inherited `BasicBubble` gameplay at 2.25 m/s with the same one-health, one-IMPACT, POP, collision, and despawn contracts. Its acid-lime pulse component is presentation only.
- The same `CastleChunk` instance persists through all three mixed waves; no encounter transition heals or recreates it.
- The mixed-encounter HUD observes encounter and castle signals. FIRE/RESET/RETRY controls request intent and never set encounter or castle truth.
- HUD renders and requests choices; it never becomes gameplay truth.
- Platform lifecycle adapters will own focus/background/resume and system-interruption translation without owning run rules.
- Quality/presentation policy may reduce rendering cost but must not change authoritative gameplay outcomes.

## Platform boundaries

- Native mobile is the primary product target.
- Desktop is a development, debugging, profiling, and automation surface.
- Web is a rapid-access preview surface.
- Desktop development keeps Forward+.
- Native mobile uses the Mobile renderer override.
- Web preview uses the Compatibility renderer override.
- Build/hosting services are infrastructure and must remain replaceable.
- Signing keys, store secrets, and credentials stay outside source control.

## Mobile performance boundary

- Gameplay truth must remain independent of frame rate and quality tier.
- Presentation systems should support scalable cost where needed.
- Object-count caps, pooling, batching, culling, LOD choices, audio limits, and effect budgets are introduced from profiling evidence or known device constraints.
- Concrete budgets are recorded only after representative target devices are chosen.

## Damage contract

- `DamageRequest` carries source ID, target ID, positive amount, typed damage category, and impact position.
- Requests are construct-once messages. Callers must not mutate a request after dispatch.
- `DamageReceiver` validates request structure and target routing, then emits the typed request to the owning gameplay domain.
- `DamageReceiver` owns no health, resistance, death, destruction, reward, or presentation behavior.
- A projectile or enemy may request damage; the receiving target domain decides the outcome.
- Initial damage categories are `PIERCE` and `IMPACT`. New categories require an explicit contract/test update rather than ad-hoc strings.
