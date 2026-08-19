extends Node3D

# [DB:ENCOUNTER:MIXED_PROOF]
# Player-intent, run-upgrade integration, and retry glue for the bounded phone proof.

const TOOTHPICK_SCENE: PackedScene = preload("res://scenes/weapons/toothpick_projectile.tscn")
const FIRE_ACTION: StringName = &"fire_primary"

@onready var encounter: MixedEncounter = $MixedEncounter
@onready var upgrade_choice: FirstUpgradeChoice = $FirstUpgradeChoice
@onready var projectile_origin: Marker3D = $CastleChunk/ProjectileOrigin
@onready var touch_controls: Control = $TouchHUD/TouchControls
@onready var fire_button: Button = $TouchHUD/TouchControls/FireButton
@onready var reset_button: Button = $TouchHUD/TouchControls/ResetButton


func _ready() -> void:
	assert(encounter != null, "[DB:ENCOUNTER:MIXED_PROOF] MixedEncounter is required.")
	assert(upgrade_choice != null, "[DB:UPGRADE:FIRST_CHOICE] FirstUpgradeChoice is required.")
	assert(projectile_origin != null, "[DB:ENCOUNTER:MIXED_PROOF] ProjectileOrigin is required.")
	assert(touch_controls != null, "[DB:INPUT:TOUCH_PROOF] TouchControls is required.")
	assert(fire_button != null, "[DB:INPUT:TOUCH_PROOF] FireButton is required.")
	assert(reset_button != null, "[DB:INPUT:TOUCH_PROOF] ResetButton is required.")

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
	assert(
		upgrade_choice.configure_projectile(projectile),
		"[DB:UPGRADE:FIRST_CHOICE] Projectile configuration must succeed.",
	)
	add_child(projectile)
	projectile.global_position = projectile_origin.global_position


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
