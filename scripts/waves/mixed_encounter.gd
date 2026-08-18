class_name MixedEncounter
extends Node3D

# [DB:ENCOUNTER:MIXED_THREE_WAVE]
# Owns only the authored three-wave schedule, wave progression, and encounter
# outcome. Enemies and the persistent castle retain their accepted ownership.

signal state_changed(state: int)
signal wave_changed(current_wave: int, total_waves: int, title: String)
signal remaining_changed(remaining: int, total: int)

enum EncounterState {
	READY,
	WAVE_ACTIVE,
	INTERMISSION,
	WON,
	LOST,
}

const KIND_BASIC: StringName = &"basic"
const KIND_FAST: StringName = &"fast"
const KIND_HEAVY: StringName = &"heavy"
const BASIC_BUBBLE_SCENE: PackedScene = preload("res://scenes/enemies/basic_bubble.tscn")
const FAST_BUBBLE_SCENE: PackedScene = preload("res://scenes/enemies/fast_bubble.tscn")
const HEAVY_BUBBLE_SCENE: PackedScene = preload("res://scenes/enemies/heavy_bubble.tscn")
const INTERMISSION_SECONDS: float = 2.25

@export_category("Mixed Encounter Plans")
@export var waves: Array[EncounterWavePlan] = []
@export_category("Mixed Encounter Integration")
@export var castle_chunk_path: NodePath
@export var spawn_marker_path: NodePath
@export var bubble_container_path: NodePath

@onready var castle_chunk: CastleChunk = get_node(castle_chunk_path) as CastleChunk
@onready var spawn_marker: Marker3D = get_node(spawn_marker_path) as Marker3D
@onready var bubble_container: Node3D = get_node(bubble_container_path) as Node3D

var _state: EncounterState = EncounterState.READY
var _wave_index: int = -1
var _wave_elapsed_seconds: float = 0.0
var _intermission_elapsed_seconds: float = 0.0
var _next_spawn_index: int = 0
var _current_spawned_count: int = 0
var _current_resolved_ids: Dictionary = {}
var _current_spawned_ids: Dictionary = {}
var _all_bubbles: Array[BasicBubble] = []


func _ready() -> void:
	assert(castle_chunk != null, "[DB:ENCOUNTER:MIXED_THREE_WAVE] CastleChunk is required.")
	assert(spawn_marker != null, "[DB:ENCOUNTER:MIXED_THREE_WAVE] SpawnMarker is required.")
	assert(bubble_container != null, "[DB:ENCOUNTER:MIXED_THREE_WAVE] BubbleContainer is required.")
	_validate_authored_waves()
	castle_chunk.destroyed.connect(_on_castle_destroyed)
	call_deferred("start_encounter")


func _physics_process(delta: float) -> void:
	if _state == EncounterState.WAVE_ACTIVE:
		_wave_elapsed_seconds += delta
		_spawn_due_bubbles()
	elif _state == EncounterState.INTERMISSION:
		_intermission_elapsed_seconds += delta
		if _intermission_elapsed_seconds >= INTERMISSION_SECONDS:
			# Deliberately discard excess time. Every wave begins from its authored zero.
			_enter_wave(_wave_index + 1)


func start_encounter() -> void:
	if _state != EncounterState.READY:
		return
	_enter_wave(0)


func current_state() -> int:
	return _state


func current_wave_number() -> int:
	return _wave_index + 1


func total_wave_count() -> int:
	return waves.size()


func current_wave_title() -> String:
	if _wave_index < 0 or _wave_index >= waves.size():
		return ""
	return waves[_wave_index].title


func next_wave_title() -> String:
	var next_index: int = _wave_index + 1
	if next_index < 0 or next_index >= waves.size():
		return ""
	return waves[next_index].title


func current_remaining_count() -> int:
	if _wave_index < 0 or _wave_index >= waves.size():
		return 0
	return waves[_wave_index].spawns.size() - _current_resolved_ids.size()


func current_spawned_count() -> int:
	return _current_spawned_count


func all_spawned_count() -> int:
	return _all_bubbles.size()


func bubble_at(index: int) -> BasicBubble:
	if index < 0 or index >= _all_bubbles.size():
		return null
	return _all_bubbles[index]


func seconds_until_next_event() -> float:
	if _state == EncounterState.INTERMISSION:
		return maxf(0.0, INTERMISSION_SECONDS - _intermission_elapsed_seconds)
	if _state != EncounterState.WAVE_ACTIVE:
		return 0.0
	var plan: EncounterWavePlan = waves[_wave_index]
	if _next_spawn_index >= plan.spawns.size():
		return 0.0
	return maxf(0.0, plan.spawns[_next_spawn_index].spawn_at_seconds - _wave_elapsed_seconds)


func _enter_wave(next_wave_index: int) -> void:
	assert(next_wave_index >= 0 and next_wave_index < waves.size())
	_wave_index = next_wave_index
	_wave_elapsed_seconds = 0.0
	_intermission_elapsed_seconds = 0.0
	_next_spawn_index = 0
	_current_spawned_count = 0
	_current_resolved_ids.clear()
	_current_spawned_ids.clear()

	var plan: EncounterWavePlan = waves[_wave_index]
	wave_changed.emit(current_wave_number(), total_wave_count(), plan.title)
	remaining_changed.emit(plan.spawns.size(), plan.spawns.size())
	_set_state(EncounterState.WAVE_ACTIVE)
	_spawn_due_bubbles()


func _spawn_due_bubbles() -> void:
	if _state != EncounterState.WAVE_ACTIVE:
		return

	var plan: EncounterWavePlan = waves[_wave_index]
	while _next_spawn_index < plan.spawns.size() \
		and plan.spawns[_next_spawn_index].spawn_at_seconds <= _wave_elapsed_seconds:
		_spawn_bubble(plan.spawns[_next_spawn_index], _next_spawn_index)
		_next_spawn_index += 1


func _spawn_bubble(spawn_plan: EncounterSpawnPlan, slot_index: int) -> void:
	var packed_scene: PackedScene = _scene_for_kind(spawn_plan.kind)
	var bubble: BasicBubble = packed_scene.instantiate() as BasicBubble
	assert(bubble != null, "[DB:ENCOUNTER:MIXED_THREE_WAVE] Bubble scene must instantiate as BasicBubble.")

	var bubble_id := StringName(
		"enemy:%s:mixed_encounter:w%02d:s%02d" % [
			String(spawn_plan.kind),
			current_wave_number(),
			slot_index + 1,
		]
	)
	bubble.bubble_id = bubble_id
	bubble.advance_enabled = true
	bubble.popped.connect(_on_bubble_popped)
	_current_spawned_ids[bubble_id] = true
	_current_spawned_count += 1
	bubble_container.add_child(bubble)
	bubble.global_position = spawn_marker.global_position
	_all_bubbles.append(bubble)


func _on_bubble_popped(bubble_id: StringName) -> void:
	if _state != EncounterState.WAVE_ACTIVE:
		return
	if not _current_spawned_ids.has(bubble_id) or _current_resolved_ids.has(bubble_id):
		return

	_current_resolved_ids[bubble_id] = true
	var plan: EncounterWavePlan = waves[_wave_index]
	remaining_changed.emit(current_remaining_count(), plan.spawns.size())

	if _next_spawn_index < plan.spawns.size():
		return
	if _current_resolved_ids.size() < plan.spawns.size():
		return
	if castle_chunk.is_destroyed():
		return

	if _wave_index == waves.size() - 1:
		_set_state(EncounterState.WON)
	else:
		_intermission_elapsed_seconds = 0.0
		_set_state(EncounterState.INTERMISSION)


func _on_castle_destroyed(_chunk_id: StringName) -> void:
	if _state == EncounterState.WON or _state == EncounterState.LOST:
		return

	_set_state(EncounterState.LOST)
	for bubble: BasicBubble in _all_bubbles:
		if is_instance_valid(bubble) and not bubble.is_popped():
			bubble.advance_enabled = false


func _scene_for_kind(kind: StringName) -> PackedScene:
	match kind:
		KIND_BASIC:
			return BASIC_BUBBLE_SCENE
		KIND_FAST:
			return FAST_BUBBLE_SCENE
		KIND_HEAVY:
			return HEAVY_BUBBLE_SCENE
		_:
			assert(false, "[DB:ENCOUNTER:MIXED_THREE_WAVE] Unknown authored bubble kind: %s" % kind)
			return null


func _validate_authored_waves() -> void:
	assert(waves.size() == 3, "[DB:ENCOUNTER:MIXED_THREE_WAVE] Exactly three waves are required.")
	var known_wave_ids: Dictionary = {}
	for wave: EncounterWavePlan in waves:
		assert(wave != null, "[DB:ENCOUNTER:MIXED_THREE_WAVE] Wave plans cannot be null.")
		assert(not wave.wave_id.is_empty(), "[DB:ENCOUNTER:MIXED_THREE_WAVE] wave_id is required.")
		assert(not known_wave_ids.has(wave.wave_id), "[DB:ENCOUNTER:MIXED_THREE_WAVE] wave_id must be unique.")
		assert(not wave.title.is_empty(), "[DB:ENCOUNTER:MIXED_THREE_WAVE] Wave title is required.")
		assert(not wave.spawns.is_empty(), "[DB:ENCOUNTER:MIXED_THREE_WAVE] Every wave needs authored spawns.")
		known_wave_ids[wave.wave_id] = true

		var previous_time: float = -1.0
		for spawn: EncounterSpawnPlan in wave.spawns:
			assert(spawn != null, "[DB:ENCOUNTER:MIXED_THREE_WAVE] Spawn plans cannot be null.")
			assert(
				spawn.kind == KIND_BASIC or spawn.kind == KIND_FAST or spawn.kind == KIND_HEAVY,
				"[DB:ENCOUNTER:MIXED_THREE_WAVE] Unknown spawn kind.",
			)
			assert(spawn.spawn_at_seconds >= 0.0, "[DB:ENCOUNTER:MIXED_THREE_WAVE] Spawn time cannot be negative.")
			assert(spawn.spawn_at_seconds >= previous_time, "[DB:ENCOUNTER:MIXED_THREE_WAVE] Spawn plans must be time ordered.")
			previous_time = spawn.spawn_at_seconds


func _set_state(next_state: EncounterState) -> void:
	if _state == next_state:
		return
	_state = next_state
	state_changed.emit(_state)
