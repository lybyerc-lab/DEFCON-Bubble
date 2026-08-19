extends SceneTree

# [DB:TEST:CAMERA_FRAMING]
# Proves the battlefield frames deliberately at real phone aspects, and that
# framing stayed presentation.
#
# The defect this milestone fixed was invisible to every other proof: Godot's
# default keep_aspect protected the vertical axis while the combat lane runs
# horizontally, so a wider screen bought dead space instead of battlefield. The
# assertions below are the ones that would have caught it.

const CASTLE_X: float = -4.4
const SPAWN_X: float = 6.0

# Aspects a phone actually presents, plus the authoring window.
const TEST_ASPECTS: Array[float] = [
	16.0 / 9.0,
	20.0 / 9.0,
	4.0 / 3.0,
	1.0,
	9.0 / 16.0,
	9.0 / 20.0,
]

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_arena_uses_deliberate_framing()
	_check_lane_is_framed_at_every_aspect()
	_check_gameplay_positions_unchanged()
	_finish()


func _check_arena_uses_deliberate_framing() -> void:
	var arena_scene: PackedScene = load("res://scenes/arena/beach_arena.tscn") as PackedScene
	_check(arena_scene != null, "arena scene must load")
	if arena_scene == null:
		return

	var arena: Node3D = arena_scene.instantiate() as Node3D
	var camera: ArenaCamera = arena.get_node_or_null("Camera3D") as ArenaCamera
	_check(camera != null, "arena camera must be an ArenaCamera rather than a bare Camera3D")
	arena.free()


func _check_lane_is_framed_at_every_aspect() -> void:
	var camera := ArenaCamera.new()

	for aspect: float in TEST_ASPECTS:
		var half_width: float = camera.visible_half_width(aspect)
		var center_x: float = ArenaCamera.LANE_CENTER.x
		var left_edge: float = center_x - half_width
		var right_edge: float = center_x + half_width

		# Both ends of the combat lane have to be inside the frame in every
		# orientation, or the player loses the castle or the spawn edge.
		_check(
			left_edge <= CASTLE_X,
			"aspect %.3f must frame the castle at x=%.1f (left edge %.2f)" % [aspect, CASTLE_X, left_edge],
		)
		_check(
			right_edge >= SPAWN_X,
			"aspect %.3f must frame the spawn edge at x=%.1f (right edge %.2f)" % [aspect, SPAWN_X, right_edge],
		)

		# The reported defect was dead space, not a missing lane. At 20:9 the
		# lane filled 23% of the width. Require it to dominate the frame.
		var lane_share: float = (SPAWN_X - CASTLE_X) / (half_width * 2.0)
		_check(
			lane_share >= 0.5,
			"aspect %.3f must not read as a narrow strip (lane fills %.0f%% of width)" % [aspect, lane_share * 100.0],
		)

		# The clamp must never be what decides the frame; if it binds, the lane
		# is being cropped by a safety limit rather than framed.
		_check(
			camera.framing_distance(aspect) < ArenaCamera.MAX_FRAMING_DISTANCE_METERS,
			"aspect %.3f must frame within the retreat limit" % aspect,
		)

	# Rotation must not snap: neighbouring aspects must frame similarly.
	var portrait_share: float = (SPAWN_X - CASTLE_X) / (camera.visible_half_width(9.0 / 16.0) * 2.0)
	var landscape_share: float = (SPAWN_X - CASTLE_X) / (camera.visible_half_width(16.0 / 9.0) * 2.0)
	_check(
		absf(portrait_share - landscape_share) < 0.15,
		"the lane must occupy a comparable share of the screen in both orientations",
	)
	camera.free()


func _check_gameplay_positions_unchanged() -> void:
	# Framing is presentation. If a camera change ever moves the castle or the
	# spawn edge, this fails before anyone judges it on a phone.
	var proof_scene: PackedScene = load("res://scenes/proof/mixed_encounter_range.tscn") as PackedScene
	_check(proof_scene != null, "encounter proof scene must load")
	if proof_scene == null:
		return

	var proof: Node3D = proof_scene.instantiate() as Node3D
	var castle: Node3D = proof.get_node_or_null("CastleChunk") as Node3D
	var spawn: Node3D = proof.get_node_or_null("MixedEncounter/SpawnMarker") as Node3D
	_check(castle != null and spawn != null, "castle and spawn marker must still exist")

	if castle != null:
		_check(is_equal_approx(castle.position.x, CASTLE_X), "castle must stay at x=%.1f" % CASTLE_X)
	if spawn != null:
		_check(is_equal_approx(spawn.position.x, SPAWN_X), "spawn edge must stay at x=%.1f" % SPAWN_X)
	proof.free()


func _finish() -> void:
	if failures.is_empty():
		print("[DB:TEST:CAMERA_FRAMING] PASS")
		quit(0)
		return
	for failure: String in failures:
		push_error("[DB:TEST:CAMERA_FRAMING] %s" % failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
