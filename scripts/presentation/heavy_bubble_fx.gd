extends Node3D

# [DB:PRESENTATION:HEAVY_BUBBLE]
# Gives Big Blub its wide siege-tank silhouette and slow gait. Gameplay health,
# movement, damage, POP, collision, and despawn remain inherited BasicBubble truth.

const HEAVY_VISUAL_SCALE := Vector3(1.35, 0.88, 1.08)
const HEAVY_FILM_COLOR := Color(0.52, 0.78, 1.0, 0.13)

@onready var bubble: BasicBubble = get_parent() as BasicBubble
@onready var visual: Node3D = get_node("../Visual") as Node3D
@onready var bubble_mesh: MeshInstance3D = get_node("../Visual/BubbleMesh") as MeshInstance3D
@onready var creature_fx: BubbleCreatureFx = get_node("../BubbleCreatureFx") as BubbleCreatureFx


func _ready() -> void:
	assert(bubble != null, "[DB:PRESENTATION:HEAVY_BUBBLE] BasicBubble parent is required.")
	assert(visual != null, "[DB:PRESENTATION:HEAVY_BUBBLE] Visual is required.")
	assert(bubble_mesh != null, "[DB:PRESENTATION:HEAVY_BUBBLE] BubbleMesh is required.")
	assert(creature_fx != null, "[DB:PRESENTATION:HEAVY_BUBBLE] BubbleCreatureFx is required.")
	visual.scale = HEAVY_VISUAL_SCALE
	creature_fx.stride_hz = 0.75
	call_deferred("_apply_heavy_film")


func _apply_heavy_film() -> void:
	var film_material: ShaderMaterial = bubble_mesh.material_override as ShaderMaterial
	assert(film_material != null, "[DB:PRESENTATION:HEAVY_BUBBLE] Soap-film material is required.")
	film_material.set_shader_parameter("base_color", HEAVY_FILM_COLOR)
	film_material.set_shader_parameter("iridescence_intensity", 0.46)
