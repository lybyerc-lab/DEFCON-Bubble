extends SceneTree

# [DB:TEST:POP_PROOF]
# Headless proof that one toothpick can route PIERCE damage into Bubble #1,
# and that the target owns the resulting pop/despawn behavior.

var failures: Array[String] = []
var pop_count: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_check(InputMap.has_action(&"fire_primary"), "fire_primary input action must exist")

	var bubble_scene: PackedScene = load("res://scenes/enemies/basic_bubble.tscn") as PackedScene
	var toothpick_scene: PackedScene = load("res://scenes/weapons/toothpick_projectile.tscn") as PackedScene
	_check(bubble_scene != null, "BasicBubble scene must load")
	_check(toothpick_scene != null, "ToothpickProjectile scene must load")

	if bubble_scene == null or toothpick_scene == null:
		_finish()
		return

	var bubble: BasicBubble = bubble_scene.instantiate() as BasicBubble
	var toothpick: ToothpickProjectile = toothpick_scene.instantiate() as ToothpickProjectile
	_check(bubble != null, "BasicBubble must instantiate")
	_check(toothpick != null, "ToothpickProjectile must instantiate")

	if bubble == null or toothpick == null:
		_finish()
		return

	get_root().add_child(bubble)
	get_root().add_child(toothpick)
	bubble.popped.connect(_on_bubble_popped)
	await process_frame

	toothpick.global_position = bubble.global_position
	var accepted: bool = toothpick.attempt_hit(bubble)
	_check(accepted, "toothpick hit must be accepted through DamageReceiver")
	_check(bubble.is_popped(), "Bubble #1 must own and enter popped state")
	_check(pop_count == 1, "Bubble #1 must emit exactly one pop event")
	_check(toothpick.is_queued_for_deletion(), "accepted toothpick must despawn after its hit")

	await create_timer(0.2).timeout
	_check(not is_instance_valid(bubble), "popped Bubble #1 must despawn after minimal pop feedback")

	_finish()


func _on_bubble_popped(_bubble_id: StringName) -> void:
	pop_count += 1


func _finish() -> void:
	if failures.is_empty():
		print("[DB:TEST:POP_PROOF] PASS")
		quit(0)
		return

	for failure: String in failures:
		push_error("[DB:TEST:POP_PROOF] %s" % failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
