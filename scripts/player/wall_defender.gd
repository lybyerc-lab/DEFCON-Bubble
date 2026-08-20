class_name WallDefender
extends Node3D

# [DB:PLAYER:WALL_DEFENDER]
# The player's body. It owns exactly two things: where it stands along the
# patrol path, and where its toothpicks leave from.
#
# It owns no damage outcome, no enemy state, no wave progression, and no castle
# truth. It does not know enemies exist. Touch input requests a destination; the
# defender decides where it can actually stand and how fast it gets there.
#
# The patrol runs along depth. Combat still runs left to right, so standing in
# the wrong place costs shots rather than changing what a shot does.

signal patrol_position_changed(depth_meters: float)

@export_category("Patrol Path")
@export var patrol_half_length_meters: float = 3.0
@export var move_speed_mps: float = 8.0

@onready var firing_origin: Marker3D = $FiringOrigin

# Captured from the authored placement so the path is expressed relative to
# where the defender was posted, not to a magic world coordinate.
var _patrol_center_z: float = 0.0
var _target_depth: float = 0.0


func _ready() -> void:
	assert(firing_origin != null, "[DB:PLAYER:WALL_DEFENDER] FiringOrigin is required.")
	assert(patrol_half_length_meters > 0.0, "[DB:PLAYER:WALL_DEFENDER] patrol length must be positive.")
	assert(move_speed_mps > 0.0, "[DB:PLAYER:WALL_DEFENDER] move speed must be positive.")
	_patrol_center_z = position.z
	_target_depth = position.z


func _physics_process(delta: float) -> void:
	var previous: float = position.z
	position.z = clampf(
		move_toward(position.z, _target_depth, move_speed_mps * delta),
		patrol_min_depth(),
		patrol_max_depth(),
	)
	if not is_equal_approx(previous, position.z):
		patrol_position_changed.emit(position.z)


func request_move_to_ratio(ratio: float) -> void:
	# [DB:INPUT:PLAYER_INTENT]
	# Touch hands over a normalised position along the path. It never sets the
	# defender's transform, and it cannot ask for somewhere off the path.
	_target_depth = lerpf(patrol_min_depth(), patrol_max_depth(), clampf(ratio, 0.0, 1.0))


func patrol_min_depth() -> float:
	return _patrol_center_z - patrol_half_length_meters


func patrol_max_depth() -> float:
	return _patrol_center_z + patrol_half_length_meters


func current_depth() -> float:
	return position.z


func target_depth() -> float:
	return _target_depth


func projectile_origin_position() -> Vector3:
	# Toothpicks leave from the body, so where the defender stands decides which
	# depth lane a shot travels down.
	return firing_origin.global_position
