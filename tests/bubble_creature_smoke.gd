extends SceneTree

# [DB:TEST:BUBBLE_CREATURE]
# Deterministic proof that Basic and Fast bubbles inherit one presentation-only
# bipedal monster rig without changing their accepted gameplay contracts.

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var basic_scene: PackedScene = load("res://scenes/enemies/basic_bubble.tscn") as PackedScene
	var fast_scene: PackedScene = load("res://scenes/enemies/fast_bubble.tscn") as PackedScene
	_check(basic_scene != null and fast_scene != null, "Basic and Fast scenes must load")
	if basic_scene == null or fast_scene == null:
		_finish()
		return

	var basic: BasicBubble = basic_scene.instantiate() as BasicBubble
	var fast: BasicBubble = fast_scene.instantiate() as BasicBubble
	var creature_fx: BubbleCreatureFx = basic.get_node("BubbleCreatureFx") as BubbleCreatureFx
	creature_fx.set_process(false)
	get_root().add_child(basic)
	get_root().add_child(fast)
	await process_frame

	_check(basic.get_node_or_null("Visual/CreatureRig/LeftLegPivot/Foot") != null, "Basic Bubble must have a left leg and foot")
	_check(basic.get_node_or_null("Visual/CreatureRig/RightLegPivot/Foot") != null, "Basic Bubble must have a right leg and foot")
	_check(basic.get_node_or_null("Visual/CreatureRig/Face") == null, "Bubble Creature must remain faceless")
	_check(basic.get_node_or_null("Visual/CreatureRig/LeftHorn/TipBubble") != null, "left horn must be built from bubbles")
	_check(basic.get_node_or_null("Visual/CreatureRig/RightHorn/TipBubble") != null, "right horn must be built from bubbles")
	_check(basic.get_node_or_null("Visual/CreatureRig/LeftLegPivot/LowerBubble") != null, "legs must be built from bubble segments")
	var body_mesh: MeshInstance3D = basic.get_node("Visual/BubbleMesh") as MeshInstance3D
	_check(body_mesh.scale.y > body_mesh.scale.x, "main bubble body must use a less-round elongated silhouette")
	_check(fast.get_node_or_null("Visual/CreatureRig/RightLegPivot/Foot") != null, "Fast Bubble must inherit the bipedal rig")
	_check(is_equal_approx(basic.advance_speed_mps, 1.25), "creature presentation must not change Basic speed")
	_check(is_equal_approx(fast.advance_speed_mps, 2.25), "creature presentation must not change Fast speed")

	basic.advance_enabled = true
	creature_fx.reset_walk_phase()
	creature_fx._process(0.1)
	var left_leg: Node3D = basic.get_node("Visual/CreatureRig/LeftLegPivot") as Node3D
	var right_leg: Node3D = basic.get_node("Visual/CreatureRig/RightLegPivot") as Node3D
	_check(is_equal_approx(left_leg.rotation_degrees.z, 22.0), "left leg must reach the authored forward stride")
	_check(is_equal_approx(right_leg.rotation_degrees.z, -22.0), "right leg must counter-swing")

	var receiver: DamageReceiver = basic.get_node("DamageReceiver") as DamageReceiver
	var request := DamageRequest.new(
		&"test:toothpick",
		basic.bubble_id,
		1.0,
		DamageRequest.DamageType.PIERCE,
		basic.global_position,
	)
	_check(receiver.request_damage(request), "bipedal Basic Bubble must retain typed PIERCE routing")
	_check(basic.is_popped(), "bipedal Basic Bubble must retain accepted POP ownership")
	_check(not basic.get_node("Visual/CreatureRig").visible, "monster limbs must disappear at authoritative POP")

	basic.queue_free()
	fast.queue_free()
	await process_frame
	_finish()


func _finish() -> void:
	if failures.is_empty():
		print("[DB:TEST:BUBBLE_CREATURE] PASS")
		quit(0)
		return
	for failure: String in failures:
		push_error("[DB:TEST:BUBBLE_CREATURE] %s" % failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
