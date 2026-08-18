class_name FirstDefenseWave
extends Node3D

# [DB:WAVE:FIRST_DEFENSE]
# Owns only the exact three-bubble encounter's spawn clock and terminal state.
# Bubbles own their movement/pop/despawn; the castle owns health/destruction.

signal state_changed(state: int)
signal remaining_changed(remaining: int, total: int)

enum WaveState {
	READY,
	RUNNING,
	WON,
	LOST,
}

const BUBBLE_SCENE: PackedScene = preload("res://scenes/enemies/basic_bubble.tscn")
const TOTAL_BUBBLES: int = 3
const BUBBLE_SPEED_MPS: float = 1.25

@export_category("First Defense Timing")
@export var spawn_interval_seconds: float = 1.6
@export_category("First Defense Integration")
@export var castle_chunk_path: NodePath
@export var spawn_marker_path: NodePath
@export var bubble_container_path: NodePath

@onready var castle_chunk: CastleChunk = get_node(castle_chunk_path) as CastleChunk
@onready var spawn_marker: Marker3D = get_node(spawn_marker_path) as Marker3D
@onready var bubble_container: Node3D = get_node(bubble_container_path) as Node3D

var _state: WaveState = WaveState.READY
var _spawn_elapsed_seconds: float = 0.0
var _spawned_count: int = 0
var _resolved_count: int = 0
var _bubbles: Array[BasicBubble] = []
var _spawned_ids: Dictionary = {}
var _resolved_ids: Dictionary = {}


func _ready() -> void:
	assert(castle_chunk != null, "[DB:WAVE:FIRST_DEFENSE] CastleChunk is required.")
	assert(spawn_marker != null, "[DB:WAVE:FIRST_DEFENSE] SpawnMarker is required.")
	assert(bubble_container != null, "[DB:WAVE:FIRST_DEFENSE] BubbleContainer is required.")
	assert(spawn_interval_seconds > 0.0, "[DB:WAVE:FIRST_DEFENSE] Spawn interval must be positive.")

	castle_chunk.destroyed.connect(_on_castle_destroyed)
	call_deferred("start_wave")


func _physics_process(delta: float) -> void:
	if _state != WaveState.RUNNING or _spawned_count >= TOTAL_BUBBLES:
		return

	_spawn_elapsed_seconds += delta
	while _state == WaveState.RUNNING \
		and _spawned_count < TOTAL_BUBBLES \
		and _spawn_elapsed_seconds >= spawn_interval_seconds:
		_spawn_elapsed_seconds -= spawn_interval_seconds
		_spawn_next_bubble()


func start_wave() -> void:
	if _state != WaveState.READY:
		return

	_set_state(WaveState.RUNNING)
	remaining_changed.emit(TOTAL_BUBBLES, TOTAL_BUBBLES)
	_spawn_next_bubble()


func current_state() -> int:
	return _state


func remaining_count() -> int:
	return TOTAL_BUBBLES - _resolved_count


func spawned_count() -> int:
	return _spawned_count


func bubble_at(index: int) -> BasicBubble:
	if index < 0 or index >= _bubbles.size():
		return null
	return _bubbles[index]


func seconds_until_next_spawn() -> float:
	if _state != WaveState.RUNNING or _spawned_count >= TOTAL_BUBBLES:
		return 0.0
	return maxf(0.0, spawn_interval_seconds - _spawn_elapsed_seconds)


func _spawn_next_bubble() -> void:
	var bubble: BasicBubble = BUBBLE_SCENE.instantiate() as BasicBubble
	assert(bubble != null, "[DB:WAVE:FIRST_DEFENSE] BasicBubble must instantiate.")

	_spawned_count += 1
	bubble.bubble_id = StringName("enemy:basic_bubble:first_defense:%02d" % _spawned_count)
	bubble.advance_speed_mps = BUBBLE_SPEED_MPS
	bubble.advance_enabled = true
	bubble.popped.connect(_on_bubble_popped)
	_spawned_ids[bubble.bubble_id] = true
	bubble_container.add_child(bubble)
	bubble.global_position = spawn_marker.global_position
	_bubbles.append(bubble)


func _on_bubble_popped(bubble_id: StringName) -> void:
	if _state != WaveState.RUNNING:
		return
	if not _spawned_ids.has(bubble_id) or _resolved_ids.has(bubble_id):
		return

	_resolved_ids[bubble_id] = true
	_resolved_count = _resolved_ids.size()
	remaining_changed.emit(remaining_count(), TOTAL_BUBBLES)

	if _resolved_count == TOTAL_BUBBLES \
		and _spawned_count == TOTAL_BUBBLES \
		and not castle_chunk.is_destroyed():
		_set_state(WaveState.WON)


func _on_castle_destroyed(_chunk_id: StringName) -> void:
	if _state != WaveState.RUNNING:
		return

	_set_state(WaveState.LOST)
	for bubble: BasicBubble in _bubbles:
		if is_instance_valid(bubble) and not bubble.is_popped():
			bubble.advance_enabled = false


func _set_state(next_state: WaveState) -> void:
	if _state == next_state:
		return
	_state = next_state
	state_changed.emit(_state)
