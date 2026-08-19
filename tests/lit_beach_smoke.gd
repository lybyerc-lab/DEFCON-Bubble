extends SceneTree

# [DB:TEST:LIT_BEACH]
# Proves the beach is actually lit and that the bubble family is one shaded
# substance. Both are easy to lose silently: an Environment can be dropped in a
# merge and a material can regress to unshaded without any gameplay test noticing.
#
# This proof asserts structure and material contracts only. It does not judge how
# the scene looks; that stays a phone acceptance question.

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_environment_is_lit()
	_check_family_is_one_shaded_substance()
	_check_gameplay_truth_untouched()
	_finish()


func _check_environment_is_lit() -> void:
	var environment_scene: PackedScene = load("res://scenes/environment/beach_environment.tscn") as PackedScene
	_check(environment_scene != null, "beach environment scene must load")
	if environment_scene == null:
		return

	var environment: Node3D = environment_scene.instantiate() as Node3D
	var world_environment: WorldEnvironment = environment.get_node_or_null("WorldEnvironment") as WorldEnvironment
	_check(world_environment != null, "environment must own a WorldEnvironment")

	if world_environment != null:
		var env: Environment = world_environment.environment
		_check(env != null, "WorldEnvironment must carry an Environment resource")
		if env != null:
			_check(env.background_mode == Environment.BG_SKY, "background must be a sky, not a void")
			_check(env.sky != null, "environment must define a sky resource")
			_check(
				env.ambient_light_source == Environment.AMBIENT_SOURCE_SKY,
				"ambient light must come from the sky so shadowed surfaces are not black",
			)
			_check(
				env.tonemap_mode != Environment.TONE_MAPPER_LINEAR,
				"a tonemapper must be selected so bright film highlights roll off",
			)

	# The sun and the sky have to stay in the same scene, or one can be retuned
	# without the other and the lighting silently disagrees with itself.
	_check(environment.get_node_or_null("Sun") is DirectionalLight3D, "environment must still own its sun")
	environment.free()


func _check_family_is_one_shaded_substance() -> void:
	for scene_path: String in [
		"res://scenes/enemies/basic_bubble.tscn",
		"res://scenes/enemies/fast_bubble.tscn",
		"res://scenes/enemies/heavy_bubble.tscn",
	]:
		var scene: PackedScene = load(scene_path) as PackedScene
		_check(scene != null, "%s must load" % scene_path)
		if scene == null:
			continue

		var bubble: Node = scene.instantiate()
		var rig: Node = bubble.get_node_or_null("Visual/CreatureRig")
		_check(rig != null, "%s must keep its creature rig" % scene_path)

		if rig != null:
			var meshes: Array[Node] = rig.find_children("*", "MeshInstance3D", true, false)
			_check(not meshes.is_empty(), "%s must have appendage meshes" % scene_path)
			for mesh_node: Node in meshes:
				var mesh: MeshInstance3D = mesh_node as MeshInstance3D
				var authored: Material = mesh.material_override
				# An unshaded StandardMaterial3D here is the exact regression this
				# milestone removed: lit body, flat limbs.
				var standard: StandardMaterial3D = authored as StandardMaterial3D
				_check(
					standard == null or standard.shading_mode != BaseMaterial3D.SHADING_MODE_UNSHADED,
					"%s appendage '%s' must not be unshaded" % [scene_path, mesh.name],
				)
		bubble.free()

	var shader: Shader = load("res://shaders/soap_film.gdshader") as Shader
	_check(shader != null, "the shared soap-film shader must load")
	if shader != null:
		var code: String = shader.code
		_check(code.contains("shader_type spatial"), "soap film must be a lit spatial shader")
		_check(code.contains("SPECULAR"), "soap film must specify specular response to catch the sun")


func _check_gameplay_truth_untouched() -> void:
	# This milestone is presentation-only. If a lighting change ever moves a
	# gameplay number, this fails before anyone judges it on a phone.
	var expected: Dictionary = {
		"res://scenes/enemies/basic_bubble.tscn": {"health": 1.0, "speed": 1.25},
		"res://scenes/enemies/fast_bubble.tscn": {"health": 1.0, "speed": 2.25},
		"res://scenes/enemies/heavy_bubble.tscn": {"health": 5.0, "speed": 0.55},
	}
	for scene_path: String in expected:
		var scene: PackedScene = load(scene_path) as PackedScene
		if scene == null:
			continue
		var bubble: BasicBubble = scene.instantiate() as BasicBubble
		_check(bubble != null, "%s must instantiate as a BasicBubble" % scene_path)
		if bubble != null:
			var want: Dictionary = expected[scene_path]
			_check(
				is_equal_approx(bubble.max_health, want["health"]),
				"%s health must stay %s" % [scene_path, want["health"]],
			)
			_check(
				is_equal_approx(bubble.advance_speed_mps, want["speed"]),
				"%s speed must stay %s" % [scene_path, want["speed"]],
			)
			bubble.free()


func _finish() -> void:
	if failures.is_empty():
		print("[DB:TEST:LIT_BEACH] PASS")
		quit(0)
		return
	for failure: String in failures:
		push_error("[DB:TEST:LIT_BEACH] %s" % failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
