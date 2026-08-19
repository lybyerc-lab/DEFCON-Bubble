class_name UpgradeDefinition
extends Resource

# [DB:UPGRADE:DEFINITION]
# Stable data-only description of one bounded upgrade option. Runtime gameplay
# consumes this definition; display text never becomes gameplay identity.

enum UpgradeKind {
	WEAPON_DAMAGE,
	CASTLE_DURABILITY,
}

@export_category("Upgrade Identity")
@export var upgrade_id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_category("Upgrade Effect")
@export var kind: UpgradeKind = UpgradeKind.WEAPON_DAMAGE
@export var amount: float = 1.0
@export var projectile_length_scale: float = 1.0


func is_valid() -> bool:
	if upgrade_id.is_empty() or display_name.is_empty() or description.is_empty():
		return false
	if amount <= 0.0:
		return false
	if kind == UpgradeKind.WEAPON_DAMAGE and projectile_length_scale < 1.0:
		return false
	return true
