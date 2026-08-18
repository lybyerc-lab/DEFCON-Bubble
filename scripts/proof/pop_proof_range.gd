extends Node3D

# [DB:COMBAT:POP_PROOF]
# Temporary bounded proof harness. It exists only to prove the first toothpick-to-bubble path.

const TOOTHPICK_SCENE: PackedScene = preload("res://scenes/weapons/toothpick_projectile.tscn")
const FIRE_ACTION: StringName = &"fire_primary"

@onready var projectile_origin: Marker3D = $ProjectileOrigin
@onready var touch_controls: Control = $TouchHUD/TouchControls
@onready var fire_button: Button = $TouchHUD/TouchControls/FireButton
@onready var reset_button: Button = $TouchHUD/TouchControls/ResetButton


func _ready() -> void:
	assert(projectile_origin != null, "[DB:COMBAT:POP_PROOF] ProjectileOrigin is required.")
	assert(touch_controls != null, "[DB:INPUT:TOUCH_PROOF] TouchControls is required.")
	assert(fire_button != null, "[DB:INPUT:TOUCH_PROOF] FireButton is required.")
	assert(reset_button != null, "[DB:INPUT:TOUCH_PROOF] ResetButton is required.")

	fire_button.pressed.connect(_fire_projectile)
	reset_button.pressed.connect(_reset_proof)
	touch_controls.visible = OS.has_feature("web")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(FIRE_ACTION):
		_fire_projectile()


func _fire_projectile() -> void:
	var projectile: ToothpickProjectile = TOOTHPICK_SCENE.instantiate() as ToothpickProjectile
	assert(projectile != null, "[DB:COMBAT:POP_PROOF] Toothpick scene must instantiate.")
	add_child(projectile)
	projectile.global_position = projectile_origin.global_position


func _reset_proof() -> void:
	var reload_error: Error = get_tree().reload_current_scene()
	if reload_error != OK:
		push_error("[DB:INPUT:TOUCH_PROOF] Reset failed with error %s." % reload_error)
