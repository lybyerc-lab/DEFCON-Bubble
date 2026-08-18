extends SceneTree

# [DB:TEST:HEAVY_BUBBLE]
# Proves Big Blub remains inherited BasicBubble gameplay while requiring five
# typed PIERCE hits and advancing at its authored slow speed.

var failures: Array[String] = []
var pop_count: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var heavy_scene: PackedScene = load("res://scenes/enemies/heavy_bubble.tscn") as PackedScene
	_check(heavy_scene != null, "HeavyBubble scene must load")
	if heavy_scene == null:
		_finish()
		return

	var heavy: BasicBubble = heavy_scene.instantiate() as BasicBubble
	_check(heavy != null, "HeavyBubble must instantiate as BasicBubble gameplay")
	if heavy == null:
		_finish()
		return

	get_root().add_child(heavy)
	heavy.popped.connect(_on_popped)
	await process_frame
	await process_frame
	heavy.set_physics_process(false)

	_check(is_equal_approx(heavy.max_health, 5.0), "Big Blub must have exactly five health")
	_check(is_equal_approx(heavy.advance_speed_mps, 0.55), "Big Blub speed must be 0.55 m/s")
	_check(heavy.scale.is_equal_approx(Vector3.ONE * 1.7), "Big Blub root and collision scale must be 1.7")
	_check(heavy.has_node("HeavyBubbleFx") and heavy.has_node("BubbleCreatureFx"), "Big Blub must inherit creature presentation and add heavy identity")
	var visual: Node3D = heavy.get_node("Visual") as Node3D
	_check(visual.scale.x > visual.scale.y, "Big Blub must have the widest authored silhouette")

	var start_x: float = heavy.position.x
	heavy.advance_enabled = true
	heavy._physics_process(2.0)
	_check(is_equal_approx(heavy.position.x, start_x - 1.1), "Big Blub movement must remain delta scaled")

	var receiver: DamageReceiver = heavy.get_node("DamageReceiver") as DamageReceiver
	for hit_index: int in range(4):
		_check(receiver.request_damage(_pierce_request(heavy, hit_index)), "each of the first four PIERCE hits must route")
		_check(not heavy.is_popped(), "Big Blub must survive the first four PIERCE hits")
	_check(receiver.request_damage(_pierce_request(heavy, 4)), "fifth PIERCE hit must route")
	_check(heavy.is_popped(), "fifth PIERCE hit must POP Big Blub")
	_check(pop_count == 1, "Big Blub must emit one POP")

	heavy.queue_free()
	await process_frame
	_finish()


func _pierce_request(heavy: BasicBubble, hit_index: int) -> DamageRequest:
	return DamageRequest.new(
		StringName("test:toothpick:%d" % hit_index),
		heavy.bubble_id,
		1.0,
		DamageRequest.DamageType.PIERCE,
		heavy.global_position,
	)


func _on_popped(_bubble_id: StringName) -> void:
	pop_count += 1


func _finish() -> void:
	if failures.is_empty():
		print("[DB:TEST:HEAVY_BUBBLE] PASS")
		quit(0)
		return
	for failure: String in failures:
		push_error("[DB:TEST:HEAVY_BUBBLE] %s" % failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
