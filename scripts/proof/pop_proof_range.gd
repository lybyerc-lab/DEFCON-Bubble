extends Node3D

# [DB:COMBAT:POP_PROOF]
# Temporary bounded proof harness. It exists only to prove the first toothpick-to-bubble path.

const TOOTHPICK_SCENE: PackedScene = preload("res://scenes/weapons/toothpick_projectile.tscn")
const FIRE_ACTION: StringName = &"fire_primary"

@onready var projectile_origin: Marker3D = $ProjectileOrigin


func _ready() -> void:
	assert(projectile_origin != null, "[DB:COMBAT:POP_PROOF] ProjectileOrigin is required.")


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(FIRE_ACTION):
		return

	var projectile: ToothpickProjectile = TOOTHPICK_SCENE.instantiate() as ToothpickProjectile
	assert(projectile != null, "[DB:COMBAT:POP_PROOF] Toothpick scene must instantiate.")
	add_child(projectile)
	projectile.global_position = projectile_origin.global_position
