extends SceneTree

# [DB:TEST:BEACH_ENVIRONMENT]
# Proves environment presentation is reusable and remains separate from encounter
# gameplay ownership.

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var environment_scene: PackedScene = load("res://scenes/environment/beach_environment.tscn") as PackedScene
	var arena_scene: PackedScene = load("res://scenes/arena/beach_arena.tscn") as PackedScene
	_check(environment_scene != null and arena_scene != null, "environment and arena scenes must load")
	if environment_scene == null or arena_scene == null:
		_finish()
		return

	var environment: Node3D = environment_scene.instantiate() as Node3D
	var arena: Node3D = arena_scene.instantiate() as Node3D
	_check(environment.get_node_or_null("Sand") is MeshInstance3D, "environment must own the sand presentation")
	_check(environment.get_node_or_null("Water") is MeshInstance3D, "environment must own the water presentation")
	_check(environment.get_node_or_null("ShoreFoam") is MeshInstance3D, "environment must own the shoreline presentation")
	_check(environment.get_node_or_null("Sun") is DirectionalLight3D, "environment must own its lighting")
	_check(environment.find_children("*", "Area3D", true, false).is_empty(), "environment presentation must not own gameplay collision")
	_check(arena.get_node_or_null("BeachEnvironment") != null, "arena must compose the reusable beach environment")
	_check(arena.get_node_or_null("MixedEncounterRange") != null, "arena must compose encounter gameplay separately")
	_check(arena.get_node_or_null("Camera3D") != null, "arena must retain the battlefield camera")

	environment.free()
	arena.free()
	_finish()


func _finish() -> void:
	if failures.is_empty():
		print("[DB:TEST:BEACH_ENVIRONMENT] PASS")
		quit(0)
		return
	for failure: String in failures:
		push_error("[DB:TEST:BEACH_ENVIRONMENT] %s" % failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
