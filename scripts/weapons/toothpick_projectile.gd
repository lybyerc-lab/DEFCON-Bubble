class_name ToothpickProjectile
extends Area3D

# [DB:COMBAT:TOOTHPICK]
# Owns toothpick travel and hit requests only. Targets own damage outcomes.

const DAMAGE_AMOUNT: float = 1.0

@export_category("Toothpick Identity")
@export var source_id: StringName = &"weapon:toothpick:proof"
@export_category("Toothpick Travel")
@export var speed_mps: float = 14.0

var _spent: bool = false


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position.x += speed_mps * delta


func attempt_hit(target_area: Area3D) -> bool:
	if _spent or target_area == null:
		return false

	var receiver: DamageReceiver = target_area.get_node_or_null("DamageReceiver") as DamageReceiver
	if receiver == null:
		return false

	var request: DamageRequest = DamageRequest.new(
		source_id,
		receiver.target_id,
		DAMAGE_AMOUNT,
		DamageRequest.DamageType.PIERCE,
		global_position,
	)
	var accepted: bool = receiver.request_damage(request)
	if not accepted:
		return false

	_spent = true
	set_physics_process(false)
	monitoring = false
	collision_layer = 0
	collision_mask = 0
	queue_free()
	return true


func _on_area_entered(area: Area3D) -> void:
	attempt_hit(area)
