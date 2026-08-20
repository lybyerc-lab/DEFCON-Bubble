extends Node3D

# [DB:ENCOUNTER:MIXED_PROOF]
# Player-intent, run-upgrade integration, and retry glue for the bounded phone proof.

const TOOTHPICK_SCENE: PackedScene = preload("res://scenes/weapons/toothpick_projectile.tscn")
const FIRE_ACTION: StringName = &"fire_primary"

@onready var encounter: MixedEncounter = $MixedEncounter
@onready var upgrade_choice: FirstUpgradeChoice = $FirstUpgradeChoice
@onready var defender: WallDefender = $WallDefender
@onready var touch_controls: Control = $TouchHUD/TouchControls
@onready var patrol_zone: Control = $TouchHUD/PatrolZone
@onready var fire_button: Button = $TouchHUD/TouchControls/FireButton
@onready var reset_button: Button = $TouchHUD/TouchControls/ResetButton


func _ready() -> void:
	assert(encounter != null, "[DB:ENCOUNTER:MIXED_PROOF] MixedEncounter is required.")
	assert(upgrade_choice != null, "[DB:UPGRADE:FIRST_CHOICE] FirstUpgradeChoice is required.")
	assert(defender != null, "[DB:PLAYER:WALL_DEFENDER] WallDefender is required.")
	assert(touch_controls != null, "[DB:INPUT:TOUCH_PROOF] TouchControls is required.")
	assert(patrol_zone != null, "[DB:INPUT:PLAYER_INTENT] PatrolZone is required.")
	assert(fire_button != null, "[DB:INPUT:TOUCH_PROOF] FireButton is required.")
	assert(reset_button != null, "[DB:INPUT:TOUCH_PROOF] ResetButton is required.")

	patrol_zone.gui_input.connect(_on_patrol_input)
	fire_button.pressed.connect(_fire_projectile)
	reset_button.pressed.connect(_reset_encounter)
	encounter.state_changed.connect(_on_encounter_state_changed)
	touch_controls.visible = OS.has_feature("web")
	_on_encounter_state_changed(encounter.current_state())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(FIRE_ACTION):
		_fire_projectile()


func _fire_projectile() -> void:
	if encounter.current_state() != MixedEncounter.EncounterState.WAVE_ACTIVE:
		return

	var projectile: ToothpickProjectile = TOOTHPICK_SCENE.instantiate() as ToothpickProjectile
	assert(projectile != null, "[DB:ENCOUNTER:MIXED_PROOF] Toothpick scene must instantiate.")
	# Run upgrades must configure every exported-build projectile, so this call
	# never hides inside assert().
	if not upgrade_choice.configure_projectile(projectile):
		push_error("[DB:UPGRADE:FIRST_CHOICE] Projectile configuration must succeed.")
	add_child(projectile)
	# Toothpicks leave from the defender, so where the player stands decides
	# which depth lane the shot travels down.
	projectile.global_position = defender.projectile_origin_position()


func _on_patrol_input(event: InputEvent) -> void:
	# [DB:INPUT:PLAYER_INTENT]
	# A vertical drag names a point along the wall. The defender owns whether it
	# can stand there and how fast it arrives; this only forwards the request.
	var pointer_y: float = -1.0
	var touch := event as InputEventScreenTouch
	if touch != null and touch.pressed:
		pointer_y = touch.position.y
	var drag := event as InputEventScreenDrag
	if drag != null:
		pointer_y = drag.position.y
	var button := event as InputEventMouseButton
	if button != null and button.pressed:
		pointer_y = button.position.y
	var motion := event as InputEventMouseMotion
	if motion != null and (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		pointer_y = motion.position.y
	if pointer_y < 0.0:
		return
	defender.request_move_to_ratio(pointer_y / maxf(patrol_zone.size.y, 1.0))


func _reset_encounter() -> void:
	var reload_error: Error = get_tree().reload_current_scene()
	if reload_error != OK:
		push_error("[DB:ENCOUNTER:MIXED_PROOF] Retry failed with error %s." % reload_error)


func _on_encounter_state_changed(state: int) -> void:
	var is_active: bool = state == MixedEncounter.EncounterState.WAVE_ACTIVE
	var is_terminal: bool = state == MixedEncounter.EncounterState.WON \
		or state == MixedEncounter.EncounterState.LOST
	fire_button.disabled = not is_active
	reset_button.text = "RETRY" if is_terminal else "RESET"
