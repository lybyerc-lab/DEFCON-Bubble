extends Node3D

# [DB:PRESENTATION:CASTLE_CHUNK]
# Renders local sand damage from CastleChunk signals. It never changes health,
# collision, survival, or destruction truth.

const HEALTHY_SAND := Color(0.88, 0.68, 0.33, 1.0)
const DAMAGED_SAND := Color(0.58, 0.34, 0.14, 1.0)

@onready var chunk: CastleChunk = get_parent() as CastleChunk
@onready var visual: Node3D = get_node("../Visual") as Node3D
@onready var chunk_mesh: MeshInstance3D = get_node("../Visual/ChunkMesh") as MeshInstance3D

var _material: StandardMaterial3D


func _ready() -> void:
	assert(chunk != null, "[DB:PRESENTATION:CASTLE_CHUNK] CastleChunk parent is required.")
	assert(visual != null, "[DB:PRESENTATION:CASTLE_CHUNK] Visual is required.")
	assert(chunk_mesh != null, "[DB:PRESENTATION:CASTLE_CHUNK] ChunkMesh is required.")

	_material = StandardMaterial3D.new()
	_material.albedo_color = HEALTHY_SAND
	_material.roughness = 0.92
	chunk_mesh.material_override = _material

	chunk.damaged.connect(_on_chunk_damaged)
	chunk.destroyed.connect(_on_chunk_destroyed)


func _on_chunk_damaged(
	_chunk_id: StringName,
	remaining_health: float,
	maximum_health: float,
) -> void:
	var damage_ratio: float = 1.0 - clampf(remaining_health / maximum_health, 0.0, 1.0)
	_material.albedo_color = HEALTHY_SAND.lerp(DAMAGED_SAND, damage_ratio)
	visual.scale = Vector3(1.0 - damage_ratio * 0.08, 1.0 - damage_ratio * 0.24, 1.0)
	visual.position.y = -damage_ratio * 0.12
	visual.rotation_degrees.z = damage_ratio * -4.0


func _on_chunk_destroyed(_chunk_id: StringName) -> void:
	var collapse_tween: Tween = create_tween()
	collapse_tween.tween_property(visual, "scale", Vector3(1.08, 0.10, 1.12), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	collapse_tween.parallel().tween_property(visual, "position:y", -0.52, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
