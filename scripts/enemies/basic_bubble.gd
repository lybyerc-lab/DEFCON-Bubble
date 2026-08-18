class_name BasicBubble
extends Area3D

# [DB:COMBAT:POP]
# Bubble #1 owns its damage outcome. DamageReceiver only routes requests here.

signal popped(bubble_id: StringName)

@export_category("Bubble Identity")
@export var bubble_id: StringName = &"enemy:basic_bubble:proof"
@export_category("Bubble Durability")
@export var max_health: float = 1.0

@onready var damage_receiver: DamageReceiver = $DamageReceiver
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var visual: Node3D = $Visual

var _health: float
var _is_popped: bool = false


func _ready() -> void:
	assert(damage_receiver != null, "[DB:COMBAT:POP] DamageReceiver is required.")
	assert(max_health > 0.0, "[DB:COMBAT:POP] max_health must be positive.")
	_health = max_health
	damage_receiver.target_id = bubble_id
	damage_receiver.damage_requested.connect(_on_damage_requested)


func is_popped() -> bool:
	return _is_popped


func _on_damage_requested(request: DamageRequest) -> void:
	if _is_popped:
		return

	if request.damage_type != DamageRequest.DamageType.PIERCE:
		return

	_health = maxf(0.0, _health - request.amount)
	if _health <= 0.0:
		_pop()


func _pop() -> void:
	if _is_popped:
		return

	_is_popped = true
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	collision_shape.set_deferred("disabled", true)
	popped.emit(bubble_id)

	# Minimal POP juice stays presentation-only: gameplay truth is already settled.
	var tween: Tween = create_tween()
	tween.tween_property(visual, "scale", Vector3.ONE * 1.35, 0.05)
	tween.tween_property(visual, "scale", Vector3.ONE * 0.05, 0.07)
	tween.finished.connect(queue_free)
