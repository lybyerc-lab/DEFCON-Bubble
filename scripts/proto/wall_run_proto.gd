extends Node3D

# [DB:PROTO:WALL_RUN]
# THROWAWAY PROTOTYPE. Not a milestone, not a contract, no promotion path.
#
# Rotated iteration with the beach inverted: the sea owns the foreground strip
# nearest the camera and the beach runs away from it, so the defender sits back
# in the frame instead of pressed against the bottom edge.
#
# Combat runs left to right, as the locked law has always
# said: enemies advance along -X, from the right of the screen toward the wall
# on the left. What is new is that the defender has a body and patrols the wall
# in depth, along Z, which reads as up and down the screen.
#
# The rotation matters for two reasons beyond taste. Enemies are seen in profile
# again, so the bipedal silhouettes the roster is built on still read. And the
# approach axis gets the long edge of the screen, which is where the accepted
# tension lives. Neither was true when the wall ran across the screen.
#
# Because combat stays left to right, this needs no locked law superseded. It is
# additive: a defender with a body, not a re-founding.

const BASIC_BUBBLE: PackedScene = preload("res://scenes/enemies/basic_bubble.tscn")
const FAST_BUBBLE: PackedScene = preload("res://scenes/enemies/fast_bubble.tscn")
const HEAVY_BUBBLE: PackedScene = preload("res://scenes/enemies/heavy_bubble.tscn")
const PROTO_PROJECTILE: PackedScene = preload("res://scenes/proto/proto_projectile.tscn")

# Wall and defender. The wall runs along Z; the defender patrols its length.
const WALL_X: float = -6.0
# The patrol band sits back from the camera so the sea can own the foreground.
const PATROL_CENTER_Z: float = -3.0
const PATROL_HALF_LENGTH: float = 3.0
const PLAYER_Y: float = 1.12
const PLAYER_SPEED_MPS: float = 8.0

# Bubbles ride at y=1.0, the same height the accepted encounter's SpawnMarker
# uses. Toothpicks fire just above their centre. The first pass spawned them at
# y=0 and fired from the defender's shoulder, so every shot flew overhead and
# nothing could be damaged.
const BUBBLE_Y: float = 1.0
const PROJECTILE_Y: float = 1.10

# THE DIAL. Shallower sits closer to the accepted side-on view and foreshortens
# depth movement less. Steeper reads more tactical but costs enemy silhouette.
const CAMERA_PITCH_DEGREES: float = -36.0

const CAMERA_FOV_DEGREES: float = 50.0
const FRAMED_HALF_WIDTH: float = 8.5
const FRAMED_HALF_HEIGHT: float = 4.2
const FRAME_TARGET := Vector3(1.5, 1.0, 0.0)

# Enemies advance -X natively, so no container rotation is needed here.
const SPAWN_X: float = 9.0
const WALL_REACH_X: float = -5.4
const SPAWN_INTERVAL_SECONDS: float = 1.1
const FIRE_INTERVAL_SECONDS: float = 0.28

@onready var camera: Camera3D = $Camera3D
@onready var player: Node3D = $Player
@onready var enemy_root: Node3D = $EnemyRoot
@onready var projectile_root: Node3D = $ProjectileRoot
@onready var move_zone: Control = $ProtoHUD/MoveZone
@onready var fire_zone: Control = $ProtoHUD/FireZone
@onready var readout: Label = $ProtoHUD/Readout

var _target_z: float = PATROL_CENTER_Z
var _spawn_timer: float = 0.0
var _fire_timer: float = 0.0
var _firing: bool = false
var _popped_count: int = 0
var _leaked_count: int = 0
var _spawn_cycle: int = 0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 20260819
	camera.fov = CAMERA_FOV_DEGREES
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	camera.current = true

	move_zone.gui_input.connect(_on_move_input)
	fire_zone.gui_input.connect(_on_fire_input)
	get_viewport().size_changed.connect(_reframe)
	_reframe()
	_update_readout()


func _process(delta: float) -> void:
	_advance_player(delta)
	_retire_reached_enemies()
	_tick_spawning(delta)
	_tick_firing(delta)


# --- framing -----------------------------------------------------------------

func _reframe() -> void:
	var size: Vector2 = get_viewport().get_visible_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var aspect: float = size.x / size.y
	var tan_half: float = tan(deg_to_rad(CAMERA_FOV_DEGREES) * 0.5)
	var distance: float = maxf(
		FRAMED_HALF_HEIGHT / tan_half,
		FRAMED_HALF_WIDTH / (tan_half * aspect),
	)
	camera.rotation_degrees = Vector3(CAMERA_PITCH_DEGREES, 0.0, 0.0)
	var forward: Vector3 = -camera.global_transform.basis.z
	camera.global_position = FRAME_TARGET - forward * distance


# --- defender ----------------------------------------------------------------

func _on_move_input(event: InputEvent) -> void:
	# Vertical drag picks a point along the wall's depth. Screen up is further
	# away, screen down is nearer the camera. One degree of freedom, no stick.
	var pressed: bool = false
	var local_y: float = 0.0
	var touch := event as InputEventScreenTouch
	if touch != null and touch.pressed:
		pressed = true
		local_y = touch.position.y
	var drag := event as InputEventScreenDrag
	if drag != null:
		pressed = true
		local_y = drag.position.y
	var mouse := event as InputEventMouseButton
	if mouse != null and mouse.pressed:
		pressed = true
		local_y = mouse.position.y
	var motion := event as InputEventMouseMotion
	if motion != null and (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		pressed = true
		local_y = motion.position.y
	if not pressed:
		return

	var height: float = maxf(move_zone.size.y, 1.0)
	var t: float = clampf(local_y / height, 0.0, 1.0)
	_target_z = lerpf(
		PATROL_CENTER_Z - PATROL_HALF_LENGTH,
		PATROL_CENTER_Z + PATROL_HALF_LENGTH,
		t,
	)


func _advance_player(delta: float) -> void:
	player.position.x = WALL_X
	player.position.y = PLAYER_Y
	player.position.z = clampf(
		move_toward(player.position.z, _target_z, PLAYER_SPEED_MPS * delta),
		PATROL_CENTER_Z - PATROL_HALF_LENGTH,
		PATROL_CENTER_Z + PATROL_HALF_LENGTH,
	)


# --- firing ------------------------------------------------------------------

func _on_fire_input(event: InputEvent) -> void:
	var touch := event as InputEventScreenTouch
	if touch != null:
		_firing = touch.pressed
	var mouse := event as InputEventMouseButton
	if mouse != null:
		_firing = mouse.pressed


func _tick_firing(delta: float) -> void:
	_fire_timer -= delta
	if not _firing or _fire_timer > 0.0:
		return
	_fire_timer = FIRE_INTERVAL_SECONDS
	var projectile: Area3D = PROTO_PROJECTILE.instantiate() as Area3D
	projectile_root.add_child(projectile)
	projectile.global_position = Vector3(WALL_X + 0.6, PROJECTILE_Y, player.position.z)


# --- enemies -----------------------------------------------------------------

func _tick_spawning(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer > 0.0:
		return
	_spawn_timer = SPAWN_INTERVAL_SECONDS
	_spawn_bubble()


func _spawn_bubble() -> void:
	# A rough mix so all three silhouettes get judged in profile at this angle.
	_spawn_cycle += 1
	var scene: PackedScene = BASIC_BUBBLE
	if _spawn_cycle % 5 == 0:
		scene = HEAVY_BUBBLE
	elif _spawn_cycle % 2 == 0:
		scene = FAST_BUBBLE

	var bubble: BasicBubble = scene.instantiate() as BasicBubble
	bubble.advance_enabled = true
	enemy_root.add_child(bubble)
	bubble.position = Vector3(
		SPAWN_X,
		BUBBLE_Y,
		_rng.randf_range(
			PATROL_CENTER_Z - PATROL_HALF_LENGTH,
			PATROL_CENTER_Z + PATROL_HALF_LENGTH,
		),
	)
	bubble.popped.connect(_on_bubble_popped)


func _retire_reached_enemies() -> void:
	# BasicBubble moves itself along -X. This only retires what reached the wall,
	# so the prototype can report leaks without owning combat rules.
	for child: Node in enemy_root.get_children():
		var bubble: BasicBubble = child as BasicBubble
		if bubble == null or bubble.is_popped():
			continue
		if bubble.position.x <= WALL_REACH_X:
			_leaked_count += 1
			bubble.queue_free()
			_update_readout()


func _on_bubble_popped(_bubble_id: StringName) -> void:
	_popped_count += 1
	_update_readout()


func _update_readout() -> void:
	readout.text = "PROTOTYPE  drag left up/down to patrol   hold right to fire\nPOPPED %d    REACHED WALL %d" % [
		_popped_count,
		_leaked_count,
	]
