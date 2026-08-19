extends Node3D

# [DB:PROTO:WALL_RUN]
# THROWAWAY PROTOTYPE. Not a milestone, not a contract, no promotion path.
#
# It exists to answer one question with a thumb: does running along a wall in an
# elevated three-quarter view, while firing, feel good on a phone?
#
# Everything here is deliberately self-contained and disposable. It reuses the
# accepted bubble scenes and lit environment for an honest visual read, but owns
# its own movement, firing, and framing rather than touching any accepted system.
#
# Axis note: BasicBubble advances along its own -X. Rather than modify accepted
# code, enemies live under a container yawed 90 degrees, which turns that advance
# into world +Z, toward the wall and the camera. Their authored facing follows.

const BASIC_BUBBLE: PackedScene = preload("res://scenes/enemies/basic_bubble.tscn")
const FAST_BUBBLE: PackedScene = preload("res://scenes/enemies/fast_bubble.tscn")
const HEAVY_BUBBLE: PackedScene = preload("res://scenes/enemies/heavy_bubble.tscn")
const PROTO_PROJECTILE: PackedScene = preload("res://scenes/proto/proto_projectile.tscn")

# Wall and player
const WALL_HALF_LENGTH: float = 9.0
const WALL_TOP_Y: float = 1.2
const PLAYER_Y: float = 1.62
const PLAYER_SPEED_MPS: float = 9.0

# Camera. Yaw stays at zero so a horizontal drag maps to horizontal movement with
# nothing to learn. Raise it for a more isometric read once the control is judged.
const CAMERA_PITCH_DEGREES: float = -42.0
const CAMERA_YAW_DEGREES: float = 0.0
const CAMERA_FOV_DEGREES: float = 50.0
const FRAMED_HALF_WIDTH: float = 11.0
const FRAMED_HALF_HEIGHT: float = 6.0
const FRAME_TARGET := Vector3(0.0, 1.0, -3.0)

# Enemies
const SPAWN_Z: float = -16.0
const SPAWN_INTERVAL_SECONDS: float = 1.1
const FIRE_INTERVAL_SECONDS: float = 0.28

@onready var camera: Camera3D = $Camera3D
@onready var player: Node3D = $Player
@onready var enemy_root: Node3D = $EnemyRoot
@onready var projectile_root: Node3D = $ProjectileRoot
@onready var move_zone: Control = $ProtoHUD/MoveZone
@onready var fire_zone: Control = $ProtoHUD/FireZone
@onready var readout: Label = $ProtoHUD/Readout

var _target_x: float = 0.0
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
	enemy_root.rotation_degrees = Vector3(0.0, 90.0, 0.0)

	move_zone.gui_input.connect(_on_move_input)
	fire_zone.gui_input.connect(_on_fire_input)
	get_viewport().size_changed.connect(_reframe)
	_reframe()
	_update_readout()


func _process(delta: float) -> void:
	_advance_player(delta)
	_advance_enemies(delta)
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
	camera.rotation_degrees = Vector3(CAMERA_PITCH_DEGREES, CAMERA_YAW_DEGREES, 0.0)
	var forward: Vector3 = -camera.global_transform.basis.z
	camera.global_position = FRAME_TARGET - forward * distance


# --- player ------------------------------------------------------------------

func _on_move_input(event: InputEvent) -> void:
	# Drag anywhere in the left zone. The finger picks a point on the wall; the
	# player runs to it. One degree of freedom, no stick, nothing to learn.
	var pressed: bool = false
	var local_x: float = 0.0
	var touch := event as InputEventScreenTouch
	if touch != null and touch.pressed:
		pressed = true
		local_x = touch.position.x
	var drag := event as InputEventScreenDrag
	if drag != null:
		pressed = true
		local_x = drag.position.x
	var mouse := event as InputEventMouseButton
	if mouse != null and mouse.pressed:
		pressed = true
		local_x = mouse.position.x
	var motion := event as InputEventMouseMotion
	if motion != null and (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		pressed = true
		local_x = motion.position.x
	if not pressed:
		return

	var width: float = maxf(move_zone.size.x, 1.0)
	var t: float = clampf(local_x / width, 0.0, 1.0)
	_target_x = lerpf(-WALL_HALF_LENGTH, WALL_HALF_LENGTH, t)


func _advance_player(delta: float) -> void:
	var current: float = player.position.x
	var step: float = PLAYER_SPEED_MPS * delta
	player.position.x = clampf(
		move_toward(current, _target_x, step),
		-WALL_HALF_LENGTH,
		WALL_HALF_LENGTH,
	)
	player.position.y = PLAYER_Y


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
	projectile.global_position = Vector3(player.position.x, PLAYER_Y, -0.4)


# --- enemies -----------------------------------------------------------------

func _tick_spawning(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer > 0.0:
		return
	_spawn_timer = SPAWN_INTERVAL_SECONDS
	_spawn_bubble()


func _spawn_bubble() -> void:
	# A rough mix so all three silhouettes get judged at this camera angle.
	_spawn_cycle += 1
	var scene: PackedScene = BASIC_BUBBLE
	if _spawn_cycle % 5 == 0:
		scene = HEAVY_BUBBLE
	elif _spawn_cycle % 2 == 0:
		scene = FAST_BUBBLE

	var bubble: BasicBubble = scene.instantiate() as BasicBubble
	bubble.advance_enabled = true
	enemy_root.add_child(bubble)
	# EnemyRoot is yawed 90 degrees: local +X maps to world -Z, local +Z to world +X.
	var lateral: float = _rng.randf_range(-WALL_HALF_LENGTH + 1.0, WALL_HALF_LENGTH - 1.0)
	bubble.position = Vector3(-SPAWN_Z, 0.0, lateral)
	bubble.popped.connect(_on_bubble_popped)


func _advance_enemies(_delta: float) -> void:
	# BasicBubble moves itself. This only retires anything that reached the wall,
	# so the prototype can report leaks without owning combat rules.
	for child: Node in enemy_root.get_children():
		var bubble: BasicBubble = child as BasicBubble
		if bubble == null or bubble.is_popped():
			continue
		if bubble.global_position.z >= -0.6:
			_leaked_count += 1
			bubble.queue_free()
			_update_readout()


func _on_bubble_popped(_bubble_id: StringName) -> void:
	_popped_count += 1
	_update_readout()


func _update_readout() -> void:
	readout.text = "PROTOTYPE  drag left to run   hold right to fire\nPOPPED %d    REACHED WALL %d" % [
		_popped_count,
		_leaked_count,
	]
