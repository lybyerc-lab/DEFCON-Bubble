extends Control

# [DB:PRESENTATION:FIRST_DEFENSE_HUD]
# Observes wave and castle truth. It never decides wave or damage outcomes.

@export var wave_path: NodePath
@export var castle_chunk_path: NodePath

@onready var wave: FirstDefenseWave = get_node(wave_path) as FirstDefenseWave
@onready var castle_chunk: CastleChunk = get_node(castle_chunk_path) as CastleChunk
@onready var status_label: Label = $StatusLabel
@onready var remaining_label: Label = $RemainingLabel
@onready var castle_label: Label = $CastleLabel


func _ready() -> void:
	assert(wave != null, "[DB:PRESENTATION:FIRST_DEFENSE_HUD] FirstDefenseWave is required.")
	assert(castle_chunk != null, "[DB:PRESENTATION:FIRST_DEFENSE_HUD] CastleChunk is required.")

	wave.state_changed.connect(_on_wave_state_changed)
	wave.remaining_changed.connect(_on_remaining_changed)
	castle_chunk.damaged.connect(_on_castle_damaged)
	castle_chunk.destroyed.connect(_on_castle_destroyed)

	_on_wave_state_changed(wave.current_state())
	_on_remaining_changed(wave.remaining_count(), FirstDefenseWave.TOTAL_BUBBLES)
	_update_castle_health(castle_chunk.current_health(), castle_chunk.max_health)


func _on_wave_state_changed(state: int) -> void:
	match state:
		FirstDefenseWave.WaveState.READY:
			status_label.text = "READY"
		FirstDefenseWave.WaveState.RUNNING:
			status_label.text = "DEFEND THE CASTLE!"
		FirstDefenseWave.WaveState.WON:
			status_label.text = "CASTLE HOLDS!"
		FirstDefenseWave.WaveState.LOST:
			status_label.text = "CASTLE FALLS!"


func _on_remaining_changed(remaining: int, total: int) -> void:
	remaining_label.text = "BUBBLES: %d / %d" % [remaining, total]


func _on_castle_damaged(
	_chunk_id: StringName,
	remaining_health: float,
	maximum_health: float,
) -> void:
	_update_castle_health(remaining_health, maximum_health)


func _on_castle_destroyed(_chunk_id: StringName) -> void:
	_update_castle_health(0.0, castle_chunk.max_health)


func _update_castle_health(remaining_health: float, maximum_health: float) -> void:
	castle_label.text = "CASTLE: %d / %d" % [roundi(remaining_health), roundi(maximum_health)]
