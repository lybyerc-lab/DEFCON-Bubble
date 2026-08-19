class_name BubbleCreatureFx
extends Node3D

# [DB:PRESENTATION:BUBBLE_CREATURE]
# Gives every inherited BasicBubble a bipedal monster read. This component owns
# only the face/limb pose; gameplay movement, collision, damage, POP, and despawn
# remain with BasicBubble.

const SOAP_FILM_SHADER: Shader = preload("res://shaders/soap_film.gdshader")

# Limbs are small, so they need more base opacity than the body to keep the
# bipedal silhouette readable at phone size. Tints carry hue only; this alpha
# stays fixed so a variant recolour can never dissolve the creature's outline.
const APPENDAGE_FILM_ALPHA: float = 0.34
const APPENDAGE_BASE_COLOR := Color(0.58, 0.86, 1.0, APPENDAGE_FILM_ALPHA)
const APPENDAGE_IRIDESCENCE: float = 0.38

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
var _appendage_material: ShaderMaterial


func _ready() -> void:
	assert(bubble != null, "[DB:PRESENTATION:BUBBLE_CREATURE] BasicBubble parent is required.")
	assert(creature_rig != null, "[DB:PRESENTATION:BUBBLE_CREATURE] CreatureRig is required.")
	assert(left_leg != null and right_leg != null, "[DB:PRESENTATION:BUBBLE_CREATURE] Two legs are required.")
	assert(left_arm != null and right_arm != null, "[DB:PRESENTATION:BUBBLE_CREATURE] Two arms are required.")
	_apply_appendage_film()
	bubble.popped.connect(_on_bubble_popped)
	reset_walk_phase()


func _process(delta: float) -> void:
	if not bubble.advance_enabled or bubble.is_popped():
		return
	_elapsed_seconds += delta
	_apply_walk_pose()


func set_film_tint(tint: Color, iridescence: float) -> void:
	# [DB:PRESENTATION:SOAP_FILM]
	# Variants recolour the family through here. Only hue is taken; the limb
	# alpha is owned locally so a translucent body tint cannot erase the legs.
	if _appendage_material == null:
		return
	_appendage_material.set_shader_parameter(
		"base_color",
		Color(tint.r, tint.g, tint.b, APPENDAGE_FILM_ALPHA),
	)
	_appendage_material.set_shader_parameter("iridescence_intensity", iridescence)


func _apply_appendage_film() -> void:
	_appendage_material = ShaderMaterial.new()
	_appendage_material.shader = SOAP_FILM_SHADER
	_appendage_material.set_shader_parameter("base_color", APPENDAGE_BASE_COLOR)
	_appendage_material.set_shader_parameter("iridescence_intensity", APPENDAGE_IRIDESCENCE)

	var applied: int = 0
	for mesh: MeshInstance3D in _collect_appendage_meshes(creature_rig):
		mesh.material_override = _appendage_material
		applied += 1
	assert(applied > 0, "[DB:PRESENTATION:BUBBLE_CREATURE] Creature rig has no appendage meshes.")


func _collect_appendage_meshes(root: Node) -> Array[MeshInstance3D]:
	var found: Array[MeshInstance3D] = []
	for child: Node in root.get_children():
		var mesh: MeshInstance3D = child as MeshInstance3D
		if mesh != null:
			found.append(mesh)
		found.append_array(_collect_appendage_meshes(child))
	return found


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
