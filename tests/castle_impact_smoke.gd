extends SceneTree

# [DB:TEST:CASTLE_IMPACT]
# Deterministic proof that one bubble requests one IMPACT, the chunk owns the
# health outcome, non-IMPACT requests do not damage it, and destruction is local.

var failures: Array[String] = []
var damage_count: int = 0
var destroy_count: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var bubble_scene: PackedScene = load("res://scenes/enemies/basic_bubble.tscn") as PackedScene
	var chunk_scene: PackedScene = load("res://scenes/castle/castle_chunk.tscn") as PackedScene
	_check(bubble_scene != null, "BasicBubble scene must load")
	_check(chunk_scene != null, "CastleChunk scene must load")
	if bubble_scene == null or chunk_scene == null:
		_finish()
		return

	var bubble: BasicBubble = bubble_scene.instantiate() as BasicBubble
	var chunk: CastleChunk = chunk_scene.instantiate() as CastleChunk
	_check(bubble != null, "BasicBubble must instantiate")
	_check(chunk != null, "CastleChunk must instantiate")
	if bubble == null or chunk == null:
		_finish()
		return

	get_root().add_child(chunk)
	get_root().add_child(bubble)
	chunk.damaged.connect(_on_chunk_damaged)
	chunk.destroyed.connect(_on_chunk_destroyed)
	await process_frame

	bubble.advance_enabled = true
	bubble.advance_speed_mps = 2.0
	var advance_start_x: float = bubble.position.x
	bubble._physics_process(0.25)
	_check(
		is_equal_approx(bubble.position.x, advance_start_x - 0.5),
		"bubble advance must scale with physics delta",
	)

	var receiver: DamageReceiver = chunk.get_node("DamageReceiver") as DamageReceiver
	var pierce_request := DamageRequest.new(
		&"test:toothpick",
		chunk.chunk_id,
		1.0,
		DamageRequest.DamageType.PIERCE,
		Vector3.ZERO,
	)
	_check(receiver.request_damage(pierce_request), "valid PIERCE request must cross routing boundary")
	_check(chunk.current_health() == 2.0, "castle chunk must ignore PIERCE damage")
	_check(damage_count == 0, "ignored PIERCE must not emit castle damage")

	_check(bubble.attempt_castle_impact(chunk), "bubble contact must request one castle IMPACT")
	_check(bubble.is_popped(), "bubble must own and enter popped state after accepted impact")
	_check(chunk.current_health() == 1.0, "first IMPACT must remove exactly one chunk health")
	_check(chunk.is_damaged(), "first IMPACT must leave localized chunk damage truth")
	_check(not chunk.is_destroyed(), "one IMPACT must not destroy a two-health chunk")
	_check(damage_count == 1, "first IMPACT must emit exactly one damage event")
	var chunk_visual: Node3D = chunk.get_node("Visual") as Node3D
	_check(chunk_visual.scale.y < 1.0, "chunk presentation must render local impact damage")
	var stopped_x: float = bubble.position.x
	bubble._physics_process(1.0)
	_check(is_equal_approx(bubble.position.x, stopped_x), "popped bubble must stop advancing")
	_check(not bubble.attempt_castle_impact(chunk), "spent bubble must not damage castle twice")
	_check(chunk.current_health() == 1.0, "repeated contact from spent bubble must not change health")

	var second_impact := DamageRequest.new(
		&"enemy:basic_bubble:test-two",
		chunk.chunk_id,
		1.0,
		DamageRequest.DamageType.IMPACT,
		Vector3(0.25, 0.0, 0.0),
	)
	_check(receiver.request_damage(second_impact), "second valid IMPACT must cross routing boundary")
	_check(chunk.current_health() == 0.0, "second IMPACT must reduce chunk health to zero")
	_check(chunk.is_destroyed(), "chunk must own destruction at zero health")
	_check(damage_count == 2, "two accepted IMPACT outcomes must emit two damage events")
	_check(destroy_count == 1, "chunk destruction must emit exactly once")

	var wrong_target := DamageRequest.new(
		&"enemy:basic_bubble:wrong-target",
		&"castle:chunk:other",
		1.0,
		DamageRequest.DamageType.IMPACT,
		Vector3.ZERO,
	)
	_check(not receiver.request_damage(wrong_target), "receiver must reject IMPACT for another chunk")
	_check(destroy_count == 1, "rejected IMPACT must not repeat destruction")

	bubble.queue_free()
	chunk.queue_free()
	_finish()


func _on_chunk_damaged(_chunk_id: StringName, _remaining: float, _maximum: float) -> void:
	damage_count += 1


func _on_chunk_destroyed(_chunk_id: StringName) -> void:
	destroy_count += 1


func _finish() -> void:
	if failures.is_empty():
		print("[DB:TEST:CASTLE_IMPACT] PASS")
		quit(0)
		return

	for failure: String in failures:
		push_error("[DB:TEST:CASTLE_IMPACT] %s" % failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
