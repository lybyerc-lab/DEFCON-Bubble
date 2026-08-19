extends Node3D

# [DB:PRESENTATION:CASTLE_CHUNK]
# Renders local sand damage and shell reinforcement from CastleChunk signals.
# It never changes health, collision, survival, or destruction truth.

const HEALTHY_SAND := Color(0.88, 0.68, 0.33, 1.0)
const DAMAGED_SAND := Color(0.58, 0.34, 0.14, 1.0)
const SHELL_ARMOR := Color(0.96, 0.89, 0.68, 1.0)

@onready var chunk: CastleChunk = get_parent() as CastleChunk
@onready var visual: Node3D = get_node("../Visual") as Node3D
@onready var chunk_mesh: MeshInstance3D = get_node("../Visual/ChunkMesh") as MeshInstance3D

var _material: StandardMaterial3D
var _reinforcement_root: Node3D


func _ready() -> void:
	assert(chunk != null, "[DB:PRESENTATION:CASTLE_CHUNK] CastleChunk parent is required.")
	assert(visual != null, "[DB:PRESENTATION:CASTLE_CHUNK] Visual is required.")
	assert(chunk_mesh != null, "[DB:PRESENTATION:CASTLE_CHUNK] ChunkMesh is required.")

	_material = StandardMaterial3D.new()
	_material.albedo_color = HEALTHY_SAND
	_material.roughness = 0.92
	chunk_mesh.material_override = _material

	chunk.damaged.connect(_on_chunk_damaged)
	chunk.reinforced.connect(_on_chunk_reinforced)
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


func _on_chunk_reinforced(
	_chunk_id: StringName,
	_remaining_health: float,
	_maximum_health: float,
	_added_durability: float,
) -> void:
	# [DB:PRESENTATION:SHELL_REINFORCEMENT]
	# Pale shell bands make the added protection visible without changing the
	# existing sand-damage presentation underneath them.
	if _reinforcement_root == null:
		_reinforcement_root = Node3D.new()
		_reinforcement_root.name = "ShellReinforcementFx"
		visual.add_child(_reinforcement_root)
		var shell_material := StandardMaterial3D.new()
		shell_material.albedo_color = SHELL_ARMOR
		shell_material.roughness = 0.54
		for y: float in [-0.36, 0.0, 0.36]:
			var band := MeshInstance3D.new()
			var band_mesh := BoxMesh.new()
			band_mesh.size = Vector3(1.84, 0.12, 1.30)
			band.mesh = band_mesh
			band.material_override = shell_material
			band.position.y = y
			_reinforcement_root.add_child(band)

	_reinforcement_root.scale = Vector3(0.84, 0.84, 0.84)
	var reinforcement_tween: Tween = create_tween()
	reinforcement_tween.tween_property(
		_reinforcement_root,
		"scale",
		Vector3.ONE,
		0.18,
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_chunk_destroyed(_chunk_id: StringName) -> void:
	var collapse_tween: Tween = create_tween()
	collapse_tween.tween_property(visual, "scale", Vector3(1.08, 0.10, 1.12), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	collapse_tween.parallel().tween_property(visual, "position:y", -0.52, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
