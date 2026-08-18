extends Node3D

# [DB:PRESENTATION:POP_FX]
# Reacts to Bubble #1's authoritative popped signal. This node owns only
# presentation: puncture-side membrane rupture, wet film remnants, mist, and audio.
# Gameplay still owns damage outcomes, death, collision shutdown, and despawn timing.

const POP_SOUND_SECONDS: float = 0.09
const POP_SAMPLE_RATE: int = 22050
const BUBBLE_FILM_RADIUS: float = 0.58
const ARC_SEGMENTS: int = 12
const ARC_DURATION: float = 0.105
const MIST_DURATION: float = 0.135
const MIST_ANGLE_OFFSETS := [
	-0.28,
	0.18,
	-0.62,
	0.52,
	-0.96,
	0.88,
	-1.28,
	1.22,
	-1.58,
	1.54,
	-1.92,
	1.86,
]

@onready var bubble: BasicBubble = get_parent() as BasicBubble
@onready var visual: Node3D = get_node("../Visual") as Node3D
@onready var damage_receiver: DamageReceiver = get_node("../DamageReceiver") as DamageReceiver
@onready var flash_shell: MeshInstance3D = $FlashShell
@onready var pop_audio: AudioStreamPlayer3D = $PopAudio

var _impact_direction: Vector3 = Vector3.LEFT
var _impact_local: Vector3 = Vector3.LEFT * BUBBLE_FILM_RADIUS


func _ready() -> void:
	assert(bubble != null, "[DB:PRESENTATION:POP_FX] BasicBubble parent is required.")
	assert(visual != null, "[DB:PRESENTATION:POP_FX] Bubble Visual is required.")
	assert(damage_receiver != null, "[DB:PRESENTATION:POP_FX] DamageReceiver is required.")
	assert(flash_shell != null, "[DB:PRESENTATION:POP_FX] FlashShell is required.")
	assert(pop_audio != null, "[DB:PRESENTATION:POP_FX] PopAudio is required.")

	# The old full-shell echo is intentionally retired. A complete expanding ring
	# reads as an energy shield; soap film should tear asymmetrically from the hit.
	flash_shell.visible = false
	flash_shell.transparency = 1.0
	pop_audio.volume_db = -5.0

	damage_receiver.damage_requested.connect(_on_damage_requested)
	bubble.popped.connect(_on_bubble_popped)


func _on_damage_requested(request: DamageRequest) -> void:
	# Presentation observes the canonical hit position without owning the damage result.
	# Cache only the screen-readable XY direction so the rupture starts where the
	# toothpick actually enters the bubble.
	if request == null:
		return

	var local_impact: Vector3 = to_local(request.impact_position)
	var flat_impact := Vector3(local_impact.x, local_impact.y, 0.0)
	if flat_impact.length_squared() <= 0.0001:
		return

	_impact_direction = flat_impact.normalized()
	_impact_local = _impact_direction * BUBBLE_FILM_RADIUS


func _on_bubble_popped(_bubble_id: StringName) -> void:
	_play_puncture_dimple()
	_spawn_puncture_glint()
	_spawn_membrane_arcs()
	_spawn_mist()
	_play_pop_audio()


func _play_puncture_dimple() -> void:
	# [DB:PRESENTATION:POP_MEMBRANE]
	# Hold the intact silhouette for a tiny puncture beat, then remove the closed
	# surface. The slight center shift moves away from the puncture instead of
	# inflating or shrinking like rubber.
	visual.scale = Vector3(0.90, 1.035, 1.0)
	visual.position = -_impact_direction * 0.026

	var dimple_tween: Tween = create_tween()
	dimple_tween.tween_property(visual, "scale", Vector3(0.965, 1.012, 1.0), 0.022).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	dimple_tween.tween_callback(_hide_bubble_visual)


func _hide_bubble_visual() -> void:
	visual.visible = false


func _spawn_puncture_glint() -> void:
	# A tiny wet highlight marks the puncture for only a few frames. It must never
	# become a full halo or starburst.
	var glint := MeshInstance3D.new()
	var glint_mesh := SphereMesh.new()
	glint_mesh.radius = 0.034
	glint_mesh.height = 0.068
	glint.mesh = glint_mesh
	glint.position = _impact_local + Vector3(0.0, 0.0, 0.035)
	glint.material_override = _build_film_material(Color(0.92, 0.99, 1.0, 0.58))
	add_child(glint)

	var drift_tween: Tween = create_tween()
	drift_tween.tween_property(glint, "position", glint.position - (_impact_direction * 0.035), 0.045).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(glint, "transparency", 1.0, 0.045).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _spawn_membrane_arcs() -> void:
	# [DB:PRESENTATION:POP_FILM_ARCS]
	# Partial irregular ribbons represent the last wet edges of the membrane.
	# Their center of mass lives opposite the puncture and retracts farther away
	# from the hole. No complete circles are generated in this effect.
	var impact_angle: float = atan2(_impact_direction.y, _impact_direction.x)
	var far_side_angle: float = impact_angle + PI
	var retract_axis: Vector3 = -_impact_direction
	var tangent := Vector3(-retract_axis.y, retract_axis.x, 0.0)

	_spawn_arc(
		far_side_angle - 1.18,
		far_side_angle - 0.12,
		0.56,
		0.024,
		0.17,
		Color(0.82, 0.97, 1.0, 0.46),
		retract_axis * 0.13 + tangent * 0.035,
		ARC_DURATION,
	)
	_spawn_arc(
		far_side_angle + 0.20,
		far_side_angle + 1.42,
		0.585,
		0.019,
		0.61,
		Color(0.95, 0.91, 1.0, 0.34),
		retract_axis * 0.16 - tangent * 0.028,
		ARC_DURATION * 0.92,
	)
	_spawn_arc(
		far_side_angle - 0.08,
		far_side_angle + 0.52,
		0.535,
		0.016,
		1.07,
		Color(0.86, 1.0, 0.94, 0.28),
		retract_axis * 0.19 + Vector3(0.0, -0.025, 0.0),
		ARC_DURATION * 0.80,
	)


func _spawn_arc(
	start_angle: float,
	end_angle: float,
	radius: float,
	half_width: float,
	phase: float,
	color: Color,
	drift: Vector3,
	duration: float,
) -> void:
	var arc := MeshInstance3D.new()
	var arc_mesh := ImmediateMesh.new()
	var arc_material: StandardMaterial3D = _build_film_material(color)
	arc_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	arc_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, arc_material)
	for segment: int in range(ARC_SEGMENTS + 1):
		var t: float = float(segment) / float(ARC_SEGMENTS)
		var angle: float = lerpf(start_angle, end_angle, t)
		var wobble: float = sin((t * 2.4 + phase) * TAU) * 0.014
		wobble += sin((t * 4.7 + phase * 0.63) * TAU) * 0.006
		var local_radius: float = radius + wobble
		var radial := Vector3(cos(angle), sin(angle), 0.0)
		var center := radial * local_radius
		center.z = 0.035 + (sin((t + phase) * PI) * 0.014)
		var width_variation: float = half_width * (0.72 + 0.28 * sin((t + 0.18) * PI))

		arc_mesh.surface_add_vertex(center + radial * width_variation)
		arc_mesh.surface_add_vertex(center - radial * width_variation)
	arc_mesh.surface_end()

	arc.mesh = arc_mesh
	add_child(arc)

	var retract_tween: Tween = create_tween()
	retract_tween.tween_property(arc, "position", drift, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var scale_tween: Tween = create_tween()
	scale_tween.tween_property(arc, "scale", Vector3(0.91, 0.91, 0.91), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(arc, "transparency", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _spawn_mist() -> void:
	# [DB:PRESENTATION:POP_MIST]
	# Microdroplets begin along the tear path, travel only a short distance, and
	# sag downward. That gravity bias helps them read as liquid rather than sparks.
	var impact_angle: float = atan2(_impact_direction.y, _impact_direction.x)
	var retract_axis: Vector3 = -_impact_direction
	var tangent := Vector3(-retract_axis.y, retract_axis.x, 0.0)
	var mist_material: StandardMaterial3D = _build_film_material(Color(0.88, 0.98, 1.0, 0.42))

	for index: int in range(MIST_ANGLE_OFFSETS.size()):
		var tear_angle: float = impact_angle + MIST_ANGLE_OFFSETS[index]
		var radial := Vector3(cos(tear_angle), sin(tear_angle), 0.0)
		var droplet := MeshInstance3D.new()
		var droplet_mesh := SphereMesh.new()
		var radius: float = 0.012 + float(index % 3) * 0.004
		droplet_mesh.radius = radius
		droplet_mesh.height = radius * 2.0
		droplet.mesh = droplet_mesh
		droplet.material_override = mist_material
		droplet.position = radial * (BUBBLE_FILM_RADIUS * (0.88 + float(index % 2) * 0.05))
		droplet.position.z = (float((index % 5) - 2) * 0.018)
		add_child(droplet)

		var sideways: float = (float((index % 4) - 1) - 0.5) * 0.032
		var retract_distance: float = 0.10 + float(index % 4) * 0.018
		var gravity_drop: float = 0.055 + float(index % 3) * 0.018
		var depth_drift: float = float((index % 3) - 1) * 0.025
		var target_position: Vector3 = droplet.position
		target_position += retract_axis * retract_distance
		target_position += tangent * sideways
		target_position += Vector3(0.0, -gravity_drop, depth_drift)

		var duration: float = MIST_DURATION * (0.82 + float(index % 4) * 0.055)
		var move_tween: Tween = create_tween()
		move_tween.tween_property(droplet, "position", target_position, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(droplet, "transparency", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _build_film_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.roughness = 0.15
	return material


func _play_pop_audio() -> void:
	pop_audio.stream = _build_pop_stream()
	pop_audio.play()


func _build_pop_stream() -> AudioStreamWAV:
	# [DB:PRESENTATION:POP_AUDIO]
	# Keep pass #2's sound recipe unchanged for the next phone test so the visual
	# correction and audio judgment remain separable. The user will evaluate this
	# with device volume enabled on the next pass.
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = POP_SAMPLE_RATE
	stream.stereo = false

	var frame_count: int = int(POP_SAMPLE_RATE * POP_SOUND_SECONDS)
	var data := PackedByteArray()
	data.resize(frame_count * 2)
	var previous_noise: float = 0.0

	for frame: int in range(frame_count):
		var time_seconds: float = float(frame) / float(POP_SAMPLE_RATE)
		var progress: float = time_seconds / POP_SOUND_SECONDS

		# Deterministic pseudo-noise keeps the placeholder reproducible in tests/builds.
		var noise_hash: float = sin(float(frame) * 12.9898 + 78.233) * 43758.5453
		var noise: float = ((noise_hash - floor(noise_hash)) * 2.0) - 1.0
		var noise_edge: float = noise - previous_noise
		previous_noise = noise

		var snap_window: float = maxf(0.0, 1.0 - (progress * 5.4))
		var snap_envelope: float = pow(snap_window, 1.8)
		var air_envelope: float = pow(1.0 - progress, 4.0)
		var membrane_envelope: float = pow(1.0 - progress, 5.5)

		var snap: float = noise_edge * 0.18 * snap_envelope
		var air: float = noise * 0.085 * air_envelope
		var membrane_frequency: float = 620.0 - (220.0 * progress)
		var membrane: float = sin(TAU * membrane_frequency * time_seconds) * 0.045 * membrane_envelope
		var soft_body: float = sin(TAU * 155.0 * time_seconds) * 0.035 * air_envelope
		var sample: float = clampf(snap + air + membrane + soft_body, -1.0, 1.0)
		data.encode_s16(frame * 2, int(sample * 32767.0))

	stream.data = data
	return stream
