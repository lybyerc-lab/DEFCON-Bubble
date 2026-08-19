class_name ToothpickProjectile
extends Area3D

# [DB:COMBAT:TOOTHPICK]
# Owns toothpick travel and hit requests only. Targets own damage outcomes.
# Run upgrades may configure damage/length before this projectile enters the tree.

@export_category("Toothpick Identity")
@export var source_id: StringName = &"weapon:toothpick:proof"
@export_category("Toothpick Damage")
@export var damage_amount: float = 1.0
@export_category("Toothpick Travel")
@export var speed_mps: float = 14.0
@export var length_scale: float = 1.0

@onready var projectile_mesh: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var _spent: bool = false


func _ready() -> void:
	assert(projectile_mesh != null, "[DB:COMBAT:TOOTHPICK] MeshInstance3D is required.")
	assert(collision_shape != null, "[DB:COMBAT:TOOTHPICK] CollisionShape3D is required.")
	assert(damage_amount > 0.0, "[DB:COMBAT:TOOTHPICK] damage_amount must be positive.")
	assert(speed_mps > 0.0, "[DB:COMBAT:TOOTHPICK] speed_mps must be positive.")
	assert(length_scale > 0.0, "[DB:COMBAT:TOOTHPICK] length_scale must be positive.")
	projectile_mesh.scale.x = length_scale
	collision_shape.scale.x = length_scale
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
		damage_amount,
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
