class_name DamageRequest
extends RefCounted

# [DB:COMBAT:DAMAGE_REQUEST]
# Construct-once value object describing a requested gameplay hit.
# Targets decide resistance, health changes, destruction, and death outcomes.

enum DamageType {
	UNSPECIFIED = 0,
	PIERCE = 1,
	IMPACT = 2,
}

var source_id: StringName
var target_id: StringName
var amount: float
var damage_type: DamageType
var impact_position: Vector3


func _init(
	p_source_id: StringName,
	p_target_id: StringName,
	p_amount: float,
	p_damage_type: DamageType,
	p_impact_position: Vector3,
) -> void:
	source_id = p_source_id
	target_id = p_target_id
	amount = p_amount
	damage_type = p_damage_type
	impact_position = p_impact_position


func is_valid() -> bool:
	return (
		source_id != &""
		and target_id != &""
		and amount > 0.0
		and _is_supported_damage_type()
	)


func _is_supported_damage_type() -> bool:
	return damage_type == DamageType.PIERCE or damage_type == DamageType.IMPACT
