class_name DamageReceiver
extends Node

# [DB:COMBAT:DAMAGE_RECEIVER]
# Narrow routing component for typed damage requests. It owns no health,
# resistance, death, or destruction rules; the target domain owns outcomes.

signal damage_requested(request: DamageRequest)

@export_category("Damage Identity")
@export var target_id: StringName = &""


func request_damage(request: DamageRequest) -> bool:
	if target_id == &"":
		push_warning("[DB:COMBAT:DAMAGE_RECEIVER] Rejected request: receiver target_id is empty.")
		return false

	if request == null or not request.is_valid():
		push_warning("[DB:COMBAT:DAMAGE_RECEIVER] Rejected invalid damage request.")
		return false

	if request.target_id != target_id:
		return false

	damage_requested.emit(request)
	return true
