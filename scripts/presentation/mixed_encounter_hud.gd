extends Control

# [DB:PRESENTATION:MIXED_ENCOUNTER_HUD]
# Renders encounter and persistent-castle truth without deciding either.

@export var encounter_path: NodePath
@export var castle_chunk_path: NodePath

@onready var encounter: MixedEncounter = get_node(encounter_path) as MixedEncounter
@onready var castle_chunk: CastleChunk = get_node(castle_chunk_path) as CastleChunk
@onready var status_label: Label = $StatusLabel
@onready var wave_label: Label = $WaveLabel
@onready var remaining_label: Label = $RemainingLabel
@onready var castle_label: Label = $CastleLabel


func _ready() -> void:
	assert(encounter != null, "[DB:PRESENTATION:MIXED_ENCOUNTER_HUD] MixedEncounter is required.")
	assert(castle_chunk != null, "[DB:PRESENTATION:MIXED_ENCOUNTER_HUD] CastleChunk is required.")

	encounter.state_changed.connect(_on_encounter_state_changed)
	encounter.wave_changed.connect(_on_wave_changed)
	encounter.remaining_changed.connect(_on_remaining_changed)
	castle_chunk.damaged.connect(_on_castle_damaged)
	castle_chunk.reinforced.connect(_on_castle_reinforced)
	castle_chunk.destroyed.connect(_on_castle_destroyed)

	_on_wave_changed(encounter.current_wave_number(), encounter.total_wave_count(), encounter.current_wave_title())
	_on_remaining_changed(encounter.current_remaining_count(), encounter.current_remaining_count())
	_on_encounter_state_changed(encounter.current_state())
	_update_castle_health(castle_chunk.current_health(), castle_chunk.max_health)


func _on_encounter_state_changed(state: int) -> void:
	match state:
		MixedEncounter.EncounterState.READY:
			status_label.text = "READY"
		MixedEncounter.EncounterState.WAVE_ACTIVE:
			status_label.text = "%s - INCOMING!" % encounter.current_wave_title()
		MixedEncounter.EncounterState.INTERMISSION:
			status_label.text = "%s CLEAR!  NEXT: %s" % [
				encounter.current_wave_title(),
				encounter.next_wave_title(),
			]
		MixedEncounter.EncounterState.WON:
			status_label.text = "FINAL CLEAR - CASTLE HOLDS!"
		MixedEncounter.EncounterState.LOST:
			status_label.text = "THE CASTLE FALLS!"


func _on_wave_changed(current_wave: int, total_waves: int, _title: String) -> void:
	wave_label.text = "WAVE %d / %d" % [current_wave, total_waves]


func _on_remaining_changed(remaining: int, _total: int) -> void:
	remaining_label.text = "LEFT: %d" % remaining


func _on_castle_damaged(
	_chunk_id: StringName,
	remaining_health: float,
	maximum_health: float,
) -> void:
	_update_castle_health(remaining_health, maximum_health)


func _on_castle_reinforced(
	_chunk_id: StringName,
	remaining_health: float,
	maximum_health: float,
	_added_durability: float,
) -> void:
	_update_castle_health(remaining_health, maximum_health)


func _on_castle_destroyed(_chunk_id: StringName) -> void:
	_update_castle_health(0.0, castle_chunk.max_health)


func _update_castle_health(remaining_health: float, maximum_health: float) -> void:
	castle_label.text = "CASTLE: %d / %d" % [roundi(remaining_health), roundi(maximum_health)]
