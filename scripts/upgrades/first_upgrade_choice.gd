class_name FirstUpgradeChoice
extends Node

# [DB:UPGRADE:FIRST_CHOICE]
# Owns one run-scoped Wave-1 upgrade decision for the vertical-slice proof.
# HUD requests a stable upgrade ID; this node applies the bounded gameplay effect.

signal choice_required(options: Array)
signal choice_applied(upgrade_id: StringName, display_name: String)

@export_category("First Upgrade Choice")
@export var options: Array[UpgradeDefinition] = []
@export var trigger_after_wave: int = 1
@export_category("Upgrade Integration")
@export var encounter_path: NodePath
@export var castle_chunk_path: NodePath

@onready var encounter: MixedEncounter = get_node(encounter_path) as MixedEncounter
@onready var castle_chunk: CastleChunk = get_node(castle_chunk_path) as CastleChunk

var _choice_pending: bool = false
var _selected_upgrade: UpgradeDefinition
var _weapon_damage_bonus: float = 0.0
var _projectile_length_scale: float = 1.0


func _ready() -> void:
	assert(encounter != null, "[DB:UPGRADE:FIRST_CHOICE] MixedEncounter is required.")
	assert(castle_chunk != null, "[DB:UPGRADE:FIRST_CHOICE] CastleChunk is required.")
	assert(trigger_after_wave > 0, "[DB:UPGRADE:FIRST_CHOICE] trigger_after_wave must be positive.")
	_validate_options()
	encounter.state_changed.connect(_on_encounter_state_changed)


func is_choice_pending() -> bool:
	return _choice_pending


func selected_upgrade_id() -> StringName:
	if _selected_upgrade == null:
		return &""
	return _selected_upgrade.upgrade_id


func weapon_damage_bonus() -> float:
	return _weapon_damage_bonus


func projectile_length_scale() -> float:
	return _projectile_length_scale


func choose_upgrade(upgrade_id: StringName) -> bool:
	if not _choice_pending or _selected_upgrade != null:
		return false

	var definition: UpgradeDefinition = _definition_for_id(upgrade_id)
	if definition == null:
		return false

	match definition.kind:
		UpgradeDefinition.UpgradeKind.WEAPON_DAMAGE:
			_weapon_damage_bonus += definition.amount
			_projectile_length_scale = maxf(
				_projectile_length_scale,
				definition.projectile_length_scale,
			)
		UpgradeDefinition.UpgradeKind.CASTLE_DURABILITY:
			if not castle_chunk.add_durability(definition.amount):
				return false
		_:
			return false

	_selected_upgrade = definition
	_choice_pending = false
	choice_applied.emit(definition.upgrade_id, definition.display_name)
	# Release must run in exported builds too, so it never hides inside assert().
	if not encounter.release_intermission():
		push_error("[DB:UPGRADE:FIRST_CHOICE] Upgrade choice must release the held intermission.")
	return true


func configure_projectile(projectile: ToothpickProjectile) -> bool:
	if projectile == null:
		return false
	projectile.damage_amount += _weapon_damage_bonus
	projectile.length_scale = maxf(projectile.length_scale, _projectile_length_scale)
	return true


func _on_encounter_state_changed(state: int) -> void:
	if state != MixedEncounter.EncounterState.INTERMISSION:
		return
	if encounter.current_wave_number() != trigger_after_wave:
		return
	if _selected_upgrade != null or _choice_pending:
		return

	# The hold must run in exported builds too, so it never hides inside assert().
	# Without a held clock the choice would be decoration over a running encounter.
	if not encounter.hold_intermission():
		push_error("[DB:UPGRADE:FIRST_CHOICE] Wave-1 clear must be holdable before the choice.")
		return

	_choice_pending = true
	choice_required.emit(options)


func _definition_for_id(upgrade_id: StringName) -> UpgradeDefinition:
	for definition: UpgradeDefinition in options:
		if definition != null and definition.upgrade_id == upgrade_id:
			return definition
	return null


func _validate_options() -> void:
	assert(options.size() == 2, "[DB:UPGRADE:FIRST_CHOICE] Exactly two options are required.")
	var seen_ids: Dictionary = {}
	var has_weapon: bool = false
	var has_defense: bool = false

	for definition: UpgradeDefinition in options:
		assert(definition != null, "[DB:UPGRADE:FIRST_CHOICE] Upgrade definitions cannot be null.")
		assert(definition.is_valid(), "[DB:UPGRADE:FIRST_CHOICE] Upgrade definition must be valid.")
		assert(
			not seen_ids.has(definition.upgrade_id),
			"[DB:UPGRADE:FIRST_CHOICE] Upgrade IDs must be unique.",
		)
		seen_ids[definition.upgrade_id] = true
		if definition.kind == UpgradeDefinition.UpgradeKind.WEAPON_DAMAGE:
			has_weapon = true
		elif definition.kind == UpgradeDefinition.UpgradeKind.CASTLE_DURABILITY:
			has_defense = true

	assert(has_weapon and has_defense, "[DB:UPGRADE:FIRST_CHOICE] One weapon and one defense option are required.")
