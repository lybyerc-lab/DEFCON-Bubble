class_name BubbleCreatureFx
extends Node3D

# [DB:PRESENTATION:BUBBLE_CREATURE]
# Gives every inherited BasicBubble a bipedal monster read. This component owns
# only the face/limb pose; gameplay movement, collision, damage, POP, and despawn
# remain with BasicBubble.

const LEG_SWING_DEGREES: float = 22.0
const ARM_SWING_DEGREES: float = 14.0
const BODY_BOB_METERS: float = 0.035

@export_range(0.1, 5.0, 0.05) var stride_hz: float = 2.5

@onready var bubble: BasicBubble = get_parent() as BasicBubble
@onready var creature_rig: Node3D = get_node("../Visual/CreatureRig") as Node3D
@onready var left_leg: Node3D = get_node("../Visual/CreatureRig/LeftLegPivot") as Node3D
@onready var right_leg: Node3D = get_node("../Visual/CreatureRig/RightLegPivot") as Node3D
@onready var left_arm: Node3D = get_node("../Visual/CreatureRig/LeftArmPivot") as Node3D
@onready var right_arm: Node3D = get_node("../Visual/CreatureRig/RightArmPivot") as Node3D

var _elapsed_seconds: float = 0.0


func _ready() -> void:
	assert(bubble != null, "[DB:PRESENTATION:BUBBLE_CREATURE] BasicBubble parent is required.")
	assert(creature_rig != null, "[DB:PRESENTATION:BUBBLE_CREATURE] CreatureRig is required.")
	assert(left_leg != null and right_leg != null, "[DB:PRESENTATION:BUBBLE_CREATURE] Two legs are required.")
	assert(left_arm != null and right_arm != null, "[DB:PRESENTATION:BUBBLE_CREATURE] Two arms are required.")
	bubble.popped.connect(_on_bubble_popped)
	reset_walk_phase()


func _process(delta: float) -> void:
	if not bubble.advance_enabled or bubble.is_popped():
		return
	_elapsed_seconds += delta
	_apply_walk_pose()


func reset_walk_phase() -> void:
	_elapsed_seconds = 0.0
	creature_rig.position.y = 0.0
	left_leg.rotation_degrees.z = 0.0
	right_leg.rotation_degrees.z = 0.0
	left_arm.rotation_degrees.z = -18.0
	right_arm.rotation_degrees.z = 18.0


func _apply_walk_pose() -> void:
	var stride: float = sin(_elapsed_seconds * TAU * stride_hz)
	var bounce: float = abs(sin(_elapsed_seconds * TAU * stride_hz))
	left_leg.rotation_degrees.z = stride * LEG_SWING_DEGREES
	right_leg.rotation_degrees.z = -stride * LEG_SWING_DEGREES
	left_arm.rotation_degrees.z = -18.0 - stride * ARM_SWING_DEGREES
	right_arm.rotation_degrees.z = 18.0 + stride * ARM_SWING_DEGREES
	creature_rig.position.y = bounce * BODY_BOB_METERS


func _on_bubble_popped(_bubble_id: StringName) -> void:
	set_process(false)
	creature_rig.visible = false
