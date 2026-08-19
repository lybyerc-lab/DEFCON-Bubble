class_name CastleChunk
extends Area3D

# [DB:CASTLE:CHUNK]
# One modular sandcastle chunk owns its health, damage filtering, collision, and
# destruction truth. DamageReceiver routes requests; presentation observes signals.

signal damaged(chunk_id: StringName, remaining_health: float, maximum_health: float)
signal reinforced(
	chunk_id: StringName,
	remaining_health: float,
	maximum_health: float,
	added_durability: float,
)
signal destroyed(chunk_id: StringName)

@export_category("Castle Chunk Identity")
@export var chunk_id: StringName = &"castle:chunk:gate:proof"
@export_category("Castle Chunk Durability")
@export var max_health: float = 2.0

@onready var damage_receiver: DamageReceiver = $DamageReceiver
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var _health: float
var _is_destroyed: bool = false


func _ready() -> void:
	assert(damage_receiver != null, "[DB:CASTLE:CHUNK] DamageReceiver is required.")
	assert(collision_shape != null, "[DB:CASTLE:CHUNK] CollisionShape3D is required.")
	assert(max_health > 0.0, "[DB:CASTLE:CHUNK] max_health must be positive.")

	_health = max_health
	damage_receiver.target_id = chunk_id
	damage_receiver.damage_requested.connect(_on_damage_requested)


func current_health() -> float:
	return _health


func is_damaged() -> bool:
	return _health < max_health


func is_destroyed() -> bool:
	return _is_destroyed


func add_durability(amount: float) -> bool:
	# [DB:UPGRADE:CASTLE_DURABILITY]
	# Adds new protection instead of healing old damage. Current and maximum
	# durability rise together, so any existing sand wound remains meaningful.
	if _is_destroyed or amount <= 0.0:
		return false

	max_health += amount
	_health += amount
	reinforced.emit(chunk_id, _health, max_health, amount)
	return true


func _on_damage_requested(request: DamageRequest) -> void:
	if _is_destroyed or request.damage_type != DamageRequest.DamageType.IMPACT:
		return

	_health = maxf(0.0, _health - request.amount)
	damaged.emit(chunk_id, _health, max_health)
	if _health <= 0.0:
		_destroy()


func _destroy() -> void:
	if _is_destroyed:
		return

	_is_destroyed = true
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	collision_shape.set_deferred("disabled", true)
	destroyed.emit(chunk_id)
