extends Control

# [DB:PRESENTATION:FIRST_UPGRADE_HUD]
# Shows the one bounded intermission choice and forwards only stable upgrade IDs.
# It never owns upgrade effects, encounter timing, weapon damage, or castle health.

@export var upgrade_choice_path: NodePath

@onready var upgrade_choice: FirstUpgradeChoice = get_node(upgrade_choice_path) as FirstUpgradeChoice
@onready var choice_overlay: Control = $ChoiceOverlay
@onready var weapon_button: Button = $ChoiceOverlay/WeaponButton
@onready var defense_button: Button = $ChoiceOverlay/DefenseButton
@onready var active_upgrade_label: Label = $ActiveUpgradeLabel

var _weapon_upgrade_id: StringName = &""
var _defense_upgrade_id: StringName = &""


func _ready() -> void:
	assert(upgrade_choice != null, "[DB:PRESENTATION:FIRST_UPGRADE_HUD] FirstUpgradeChoice is required.")
	assert(choice_overlay != null, "[DB:PRESENTATION:FIRST_UPGRADE_HUD] ChoiceOverlay is required.")
	assert(weapon_button != null, "[DB:PRESENTATION:FIRST_UPGRADE_HUD] WeaponButton is required.")
	assert(defense_button != null, "[DB:PRESENTATION:FIRST_UPGRADE_HUD] DefenseButton is required.")
	assert(active_upgrade_label != null, "[DB:PRESENTATION:FIRST_UPGRADE_HUD] ActiveUpgradeLabel is required.")

	choice_overlay.visible = false
	active_upgrade_label.visible = false
	weapon_button.pressed.connect(_on_weapon_pressed)
	defense_button.pressed.connect(_on_defense_pressed)
	upgrade_choice.choice_required.connect(_on_choice_required)
	upgrade_choice.choice_applied.connect(_on_choice_applied)


func _on_choice_required(options: Array) -> void:
	assert(options.size() == 2, "[DB:PRESENTATION:FIRST_UPGRADE_HUD] Two upgrade options are required.")
	_weapon_upgrade_id = &""
	_defense_upgrade_id = &""

	for value: Variant in options:
		var definition: UpgradeDefinition = value as UpgradeDefinition
		assert(definition != null, "[DB:PRESENTATION:FIRST_UPGRADE_HUD] Upgrade option must be typed.")
		var button_text := "%s\n%s" % [definition.display_name, definition.description]
		if definition.kind == UpgradeDefinition.UpgradeKind.WEAPON_DAMAGE:
			_weapon_upgrade_id = definition.upgrade_id
			weapon_button.text = button_text
		elif definition.kind == UpgradeDefinition.UpgradeKind.CASTLE_DURABILITY:
			_defense_upgrade_id = definition.upgrade_id
			defense_button.text = button_text

	assert(not _weapon_upgrade_id.is_empty(), "[DB:PRESENTATION:FIRST_UPGRADE_HUD] Weapon option ID is required.")
	assert(not _defense_upgrade_id.is_empty(), "[DB:PRESENTATION:FIRST_UPGRADE_HUD] Defense option ID is required.")
	choice_overlay.visible = true


func _on_choice_applied(_upgrade_id: StringName, display_name: String) -> void:
	choice_overlay.visible = false
	active_upgrade_label.text = "UPGRADE: %s" % display_name
	active_upgrade_label.visible = true


func _on_weapon_pressed() -> void:
	if not upgrade_choice.choose_upgrade(_weapon_upgrade_id):
		push_error("[DB:PRESENTATION:FIRST_UPGRADE_HUD] Weapon upgrade request was rejected.")


func _on_defense_pressed() -> void:
	if not upgrade_choice.choose_upgrade(_defense_upgrade_id):
		push_error("[DB:PRESENTATION:FIRST_UPGRADE_HUD] Defense upgrade request was rejected.")
