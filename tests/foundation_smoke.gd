extends SceneTree

# [DB:TEST:FOUNDATION_SMOKE]
# Headless proof that the repository's first contracts are loadable and named correctly.

var failures: Array[String] = []


func _init() -> void:
	_check(
		ProjectSettings.get_setting("application/run/main_scene", "") == "res://scenes/boot/game_root.tscn",
		"main scene must be GameRoot",
	)
	_check(InputMap.has_action(&"restart_run"), "restart_run input action must exist")
	_check(
		ProjectSettings.get_setting("layer_names/3d_physics/layer_1", "") == "world",
		"3D collision layer 1 must be world",
	)
	_check(
		ProjectSettings.get_setting("layer_names/3d_physics/layer_6", "") == "castle",
		"3D collision layer 6 must be castle",
	)
	_check(
		ProjectSettings.get_setting("rendering/renderer/rendering_method.mobile", "") == "mobile",
		"native mobile must use the Mobile renderer override",
	)
	_check(
		ProjectSettings.get_setting("rendering/renderer/rendering_method.web", "") == "gl_compatibility",
		"Web preview must use the Compatibility renderer override",
	)
	_check(
		ProjectSettings.get_setting("rendering/textures/vram_compression/import_etc2_astc", false) == true,
		"mobile/Web texture import must enable ETC2/ASTC for the Web export preset",
	)

	var main_scene: PackedScene = load("res://scenes/boot/game_root.tscn") as PackedScene
	_check(main_scene != null, "GameRoot scene must load")

	if main_scene != null:
		var instance: Node = main_scene.instantiate()
		_check(instance != null, "GameRoot scene must instantiate")
		if instance != null:
			instance.free()

	if failures.is_empty():
		print("[DB:TEST:FOUNDATION_SMOKE] PASS")
		quit(0)
		return

	for failure: String in failures:
		push_error("[DB:TEST:FOUNDATION_SMOKE] %s" % failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
