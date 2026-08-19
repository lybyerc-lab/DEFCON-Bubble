extends SceneTree

# [DB:TEST:FAST_BUBBLE]
# Proves the Fast Bubble is inherited BasicBubble gameplay with authored speed,
# forgiving scaled collision, presentation-only acid-lime identity, and accepted POP.

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var fast_scene: PackedScene = load("res://scenes/enemies/fast_bubble.tscn") as PackedScene
	_check(fast_scene != null, "FastBubble scene must load")
	if fast_scene == null:
		_finish()
		return

	var fast: BasicBubble = fast_scene.instantiate() as BasicBubble
	_check(fast != null, "FastBubble must instantiate as BasicBubble gameplay")
	if fast == null:
		_finish()
		return

	var fast_fx: Node = fast.get_node("FastBubbleFx")
	fast_fx.set_process(false)
	get_root().add_child(fast)
	await process_frame
	await process_frame
	fast.set_physics_process(false)

	_check(is_equal_approx(fast.max_health, 1.0), "FastBubble must retain one health")
	_check(is_equal_approx(fast.advance_speed_mps, 2.25), "FastBubble speed must be 2.25 m/s")
	_check(fast.scale.is_equal_approx(Vector3.ONE * 0.85), "FastBubble root and collision scale must be 0.85")
	_check(fast.get_node_or_null("PopFx/PopAudio") != null, "FastBubble must inherit accepted POP audio")

	var start_x: float = fast.position.x
	fast.advance_enabled = true
	fast._physics_process(0.4)
	_check(is_equal_approx(fast.position.x, start_x - 0.9), "FastBubble movement must remain delta scaled")

	var bubble_mesh: MeshInstance3D = fast.get_node("Visual/BubbleMesh") as MeshInstance3D
	var film_material: ShaderMaterial = bubble_mesh.material_override as ShaderMaterial
	_check(film_material != null, "FastBubble must retain the soap-film shader")
	if film_material != null:
		var cue_color: Color = film_material.get_shader_parameter("base_color")
		_check(cue_color.g > cue_color.r and cue_color.g > cue_color.b, "FastBubble film must read acid lime")

	fast_fx.reset_pulse_phase()
	var visual: Node3D = fast.get_node("Visual") as Node3D
	_check(is_equal_approx(visual.scale.x, 1.10), "FastBubble must keep a forward-stretched x baseline")
	_check(is_equal_approx(visual.scale.y, 0.925), "FastBubble must keep a compressed y baseline")
	fast_fx._process(0.0625)
	_check(is_equal_approx(visual.scale.x, 1.16), "FastBubble 4 Hz pulse must reach authored x maximum")
	_check(is_equal_approx(visual.scale.y, 0.88), "FastBubble 4 Hz pulse must reach authored y minimum")
	fast_fx._process(0.125)
	_check(is_equal_approx(visual.scale.x, 1.04), "FastBubble 4 Hz pulse must reach authored x minimum")
	_check(is_equal_approx(visual.scale.y, 0.97), "FastBubble 4 Hz pulse must reach authored y maximum")

	var receiver: DamageReceiver = fast.get_node("DamageReceiver") as DamageReceiver
	var pierce := DamageRequest.new(
		&"test:toothpick",
		fast.bubble_id,
		1.0,
		DamageRequest.DamageType.PIERCE,
		fast.global_position,
	)
	_check(receiver.request_damage(pierce), "FastBubble must accept typed PIERCE routing")
	_check(fast.is_popped(), "one PIERCE must POP FastBubble through inherited gameplay")

	fast.queue_free()
	await process_frame
	_finish()


func _finish() -> void:
	if failures.is_empty():
		print("[DB:TEST:FAST_BUBBLE] PASS")
		quit(0)
		return

	for failure: String in failures:
		push_error("[DB:TEST:FAST_BUBBLE] %s" % failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
