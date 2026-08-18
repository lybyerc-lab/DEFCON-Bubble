# Implementation decisions

This is the concise repository mirror of implementation-critical decisions. The full historical decision log lives in the project Drive.

## DB-DEC-001 Engine

Godot 4.7.1 stable + GDScript. Reopen only for a concrete platform blocker or measured engine limitation.

## DB-DEC-002 Repository/IP

Repository remains public during foundation/early prototype work, but no open-source license is granted. Original project material remains all-rights-reserved unless explicitly licensed otherwise. Revisit at the vertical-slice/IP gate.

## DB-DEC-003 Castle destruction

Prototype destruction uses modular damageable castle chunks. Do not begin with voxels, runtime mesh cutting, fluid sand simulation, or uncontrolled rigid-body collapse.

## DB-DEC-004 Code navigation

Use semantic anchors and labels where they improve navigation, debugging, ownership, refactoring, or agent handoff. Code structure remains authoritative.

## DB-DEC-005 Damage boundary

All gameplay hits cross a shared typed `DamageRequest` contract. The routing component may validate and forward a request but does not own health, resistance, death, destruction, rewards, or VFX. The receiving gameplay domain owns the outcome. Damage categories begin with `PIERCE` and `IMPACT`; expanding that vocabulary requires an explicit contract and test change.

## DB-DEC-006 Primary platform

DEFCON BUBBLE is a native mobile-first game. The phone is the primary product and player-acceptance target. Desktop is a development, debugging, profiling, and automation environment. Web builds are rapid-access preview surfaces, not the shipped-product architecture.

The initial native storefront/platform order remains intentionally open until product intent and device evidence justify locking it.

## DB-DEC-007 Renderer policy

Keep Forward+ as the desktop development default. Native mobile uses the Godot Mobile renderer override. Web preview uses the Compatibility renderer override. The foundation smoke test must verify the mobile and Web overrides so platform intent cannot silently drift.

Reopen this decision only for measured compatibility, performance, or rendering-feature evidence.

## DB-DEC-008 Mobile ambition and performance

Mobile-first does not reduce the intended scale or personality of the game. Preserve the grand beach-war fantasy through staged spectacle, scalable presentation, controlled simulation, deterministic caps, and measured performance budgets.

Do not lock permanent numeric budgets until a representative target-device matrix exists. Once devices are selected, record concrete performance and memory budgets and enforce them with profiling evidence.

## DB-DEC-009 Preview delivery

Phone-accessible Web previews should be built from reviewable GitHub source revisions through repeatable automation rather than depending on manual local uploads. Preview hosting is replaceable infrastructure and must not become a gameplay dependency. A preview should be traceable to the exact source revision it represents.

## DB-DEC-010 Asset reuse and custom work

Prefer a proven asset with an appropriate project-compatible license when it already meets a commodity need. Record its source, creator, license, license URL, and local integrity hash where practical.

Use custom work when it materially expresses DEFCON BUBBLE's identity, solves a project-specific problem, or when available assets fail the creative or technical target. Do not prolong a bounded milestone by recreating a suitable commodity asset from scratch.
