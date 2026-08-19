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
- Castle owns castle chunks, localized destruction, durability changes, and survival evaluation.
- `CastleChunk` owns local `IMPACT` filtering, health, additive durability, collision shutdown, and destruction truth. Its presentation observer renders sand damage and optional shell reinforcement only.
- `FirstDefenseWave` owns only the frozen fixed three-bubble proof's READY/RUNNING/WON/LOST state, spawn timing/count, and terminal evaluation.
- Each spawned `BasicBubble` owns movement, its one castle-impact request, pop state, and despawn.
- `EncounterSpawnPlan` and `EncounterWavePlan` hold only the authored kind/time sequence and wave identity/title for the current mixed encounter. They are not a registry, procedural grammar, or rule engine.
- `MixedEncounter` owns the fixed three-wave order, per-wave clock, stable wave/slot IDs, and READY/WAVE_ACTIVE/INTERMISSION/WON/LOST outcome. A narrow hold/release seam may pause its existing intermission clock for a safe player choice; the encounter still owns wave progression after release.
- Fast Bubble instantiates inherited `BasicBubble` gameplay at 2.25 m/s with the same one-health, one-IMPACT, POP, collision, and despawn contracts. Its acid-lime pulse is presentation only.
- Heavy Bubble/Big Blub instantiates inherited `BasicBubble` gameplay at five health and `0.55 m/s`; its size, film color, and gait are presentation/configuration, not parallel death logic.
- `BubbleCreatureFx` poses the shared faceless bubble-appendage rig and hides it when BasicBubble emits `popped`. It does not translate the enemy or own collision, damage, death, or despawn.
- The mixed-range `ProjectileOrigin` is a child of `CastleChunk`, so its roof-relative launch point follows authored castle placement.
- The same `CastleChunk` instance persists through all three mixed waves; encounter transitions do not heal or recreate it.
- `UpgradeDefinition` is a data-only stable-ID resource containing the tiny tunable values needed by one offered upgrade.
- `FirstUpgradeChoice` owns `[DB:UPGRADE:FIRST_CHOICE]`: exactly one run-scoped selection after Wave 1, the selected stable ID, and the narrow effect application. It does not own hits, POP, castle damage, destruction, wave outcome, or UI state.
- SKEWER adds one configured damage to newly spawned `ToothpickProjectile` instances and lengthens their presentation/collision silhouette before they enter the tree. The projectile still creates the typed PIERCE request.
- SHELL REINFORCEMENT requests one additive durability change through `CastleChunk.add_durability()`. CastleChunk remains authority for the resulting current/max durability and later destruction.
- The first-upgrade HUD renders the two definitions and forwards only stable upgrade IDs. It never applies effects itself.
- The mixed-encounter HUD observes encounter and castle signals. FIRE/RESET/RETRY controls request intent and never set encounter, castle, or upgrade truth.
- `BeachEnvironment` owns only reusable sand, water, shoreline, and sunlight presentation. `BeachArena` composes it beside `MixedEncounterRange` and the camera.
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
