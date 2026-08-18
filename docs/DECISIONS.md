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
