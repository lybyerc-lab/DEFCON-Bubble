extends Node3D

# [DB:PRESENTATION:FAST_BUBBLE]
# Adds an acid-lime cue and subtle 4 Hz membrane pulse. Gameplay speed, health,
# damage, collision, POP, and despawn remain owned by the inherited BasicBubble.

const PULSE_HZ: float = 4.0
const STRETCH_BASE_X: float = 1.10
const STRETCH_BASE_Y: float = 0.925
const STRETCH_PULSE_X: float = 0.06
const STRETCH_PULSE_Y: float = 0.045
const ACID_LIME := Color(0.54, 1.0, 0.08, 0.16)

@onready var bubble: BasicBubble = get_parent() as BasicBubble
@onready var visual: Node3D = get_node("../Visual") as Node3D
@onready var bubble_mesh: MeshInstance3D = get_node("../Visual/BubbleMesh") as MeshInstance3D

var _elapsed_seconds: float = 0.0


func _ready() -> void:
	assert(bubble != null, "[DB:PRESENTATION:FAST_BUBBLE] BasicBubble parent is required.")
	assert(visual != null, "[DB:PRESENTATION:FAST_BUBBLE] Visual is required.")
	assert(bubble_mesh != null, "[DB:PRESENTATION:FAST_BUBBLE] BubbleMesh is required.")
	bubble.popped.connect(_on_bubble_popped)
	call_deferred("_apply_acid_lime_cue")
	reset_pulse_phase()


func _process(delta: float) -> void:
	_elapsed_seconds += delta
	_apply_stretch()


func reset_pulse_phase() -> void:
	_elapsed_seconds = 0.0
	_apply_stretch()


func _apply_stretch() -> void:
	var pulse: float = sin(_elapsed_seconds * TAU * PULSE_HZ)
	visual.scale = Vector3(
		STRETCH_BASE_X + pulse * STRETCH_PULSE_X,
		STRETCH_BASE_Y - pulse * STRETCH_PULSE_Y,
		1.0,
	)


func _apply_acid_lime_cue() -> void:
	var film_material: ShaderMaterial = bubble_mesh.material_override as ShaderMaterial
	assert(film_material != null, "[DB:PRESENTATION:FAST_BUBBLE] Soap-film material is required.")
	film_material.set_shader_parameter("base_color", ACID_LIME)
	film_material.set_shader_parameter("iridescence_intensity", 0.22)


func _on_bubble_popped(_bubble_id: StringName) -> void:
	set_process(false)
	visual.scale = Vector3.ONE
