extends SceneTree

# [DB:TEST:WALL_DEFENDER]
# Proves the defender owns exactly two things -- where it stands and where its
# toothpicks leave from -- and that giving the game a body moved no accepted
# gameplay value.
#
# The ownership assertions matter more than the movement ones. A body is the
# most tempting place in this project for damage, health, or encounter rules to
# accumulate, and the milestone's drift list forbids all three.

const DEFENDER_SCENE: PackedScene = preload("res://scenes/player/wall_defender.tscn")
const RANGE_SCENE: PackedScene = preload("res://scenes/proof/mixed_encounter_range.tscn")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await _prove_patrol_path()
	await _prove_defender_owns_nothing_else()
	await _prove_accepted_values_unmoved()
	_finish()


func _prove_patrol_path() -> void:
	var defender: WallDefender = DEFENDER_SCENE.instantiate() as WallDefender
	defender.position = Vector3(-4.05, 0.0, 0.0)
	get_root().add_child(defender)
	await process_frame

	var centre: float = defender.current_depth()
	_check(is_equal_approx(centre, 0.0), "the defender must start where it was posted")
	_check(
		is_equal_approx(defender.patrol_max_depth() - defender.patrol_min_depth(), defender.patrol_half_length_meters * 2.0),
		"the patrol path must span twice its half length",
	)

	# Intent is a request, not a teleport: the body still has to travel.
	defender.request_move_to_ratio(1.0)
	_check(is_equal_approx(defender.current_depth(), centre), "requesting a move must not teleport the defender")

	for _step: int in range(120):
		defender._physics_process(1.0 / 60.0)
	_check(
		is_equal_approx(defender.current_depth(), defender.patrol_max_depth()),
		"the defender must reach the far end of the patrol",
	)

	# Off-path requests are clamped by the defender, not trusted from input.
	defender.request_move_to_ratio(9.0)
	for _step: int in range(120):
		defender._physics_process(1.0 / 60.0)
	_check(
		defender.current_depth() <= defender.patrol_max_depth() + 0.001,
		"an out-of-range request must not push the defender off the path",
	)
	defender.request_move_to_ratio(-9.0)
	for _step: int in range(240):
		defender._physics_process(1.0 / 60.0)
	_check(
		defender.current_depth() >= defender.patrol_min_depth() - 0.001,
		"an out-of-range request must not push the defender off the other end",
	)

	# Patrolling changes the firing lane and nothing about the shot itself.
	var lane_x: float = defender.projectile_origin_position().x
	var lane_y: float = defender.projectile_origin_position().y
	defender.request_move_to_ratio(0.5)
	for _step: int in range(240):
		defender._physics_process(1.0 / 60.0)
	_check(is_equal_approx(defender.projectile_origin_position().x, lane_x), "patrolling must not change the firing origin's reach")
	_check(is_equal_approx(defender.projectile_origin_position().y, lane_y), "patrolling must not change the firing origin's height")
	defender.free()


func _prove_defender_owns_nothing_else() -> void:
	var defender: WallDefender = DEFENDER_SCENE.instantiate() as WallDefender
	get_root().add_child(defender)
	await process_frame

	# is_class rather than `is`: the static analyser rejects `is Area3D` on a
	# Node3D subclass as provably false, but a runtime check still catches
	# someone re-parenting WallDefender onto Area3D later.
	_check(not defender.is_class("Area3D"), "the defender must not be a collision volume")
	_check(defender.get_node_or_null("DamageReceiver") == null, "the defender must not receive damage")
	for forbidden: String in [
		"request_damage",
		"take_damage",
		"current_health",
		"attempt_castle_impact",
	]:
		_check(not defender.has_method(forbidden), "the defender must not expose %s" % forbidden)
	defender.free()


func _prove_accepted_values_unmoved() -> void:
	var range_root: Node3D = RANGE_SCENE.instantiate() as Node3D
	get_root().add_child(range_root)
	await process_frame
	await process_frame

	var defender: WallDefender = range_root.get_node_or_null("WallDefender") as WallDefender
	var castle: CastleChunk = range_root.get_node_or_null("CastleChunk") as CastleChunk
	_check(defender != null, "the range must post a defender")
	_check(castle != null, "the range must keep its castle")

	if castle != null:
		_check(castle.position.is_equal_approx(Vector3(-4.4, 0.7, 0.0)), "the castle must not move")
		_check(is_equal_approx(castle.current_health(), 2.0), "the castle must keep its accepted health")
		_check(castle.get_node_or_null("ProjectileOrigin") == null, "the castle must no longer own a launcher")

	# The wall is presentation and a path. It is not a second damageable thing.
	_check(
		range_root.find_children("*", "CastleChunk", true, false).size() == 1,
		"there must still be exactly one damageable castle",
	)

	if defender != null:
		var toothpick: ToothpickProjectile = preload("res://scenes/weapons/toothpick_projectile.tscn").instantiate() as ToothpickProjectile
		_check(is_equal_approx(toothpick.damage_amount, 1.0), "base toothpick damage must stay one")
		toothpick.free()

	range_root.free()


func _finish() -> void:
	if failures.is_empty():
		print("[DB:TEST:WALL_DEFENDER] PASS")
		quit(0)
		return
	for failure: String in failures:
		push_error("[DB:TEST:WALL_DEFENDER] %s" % failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
