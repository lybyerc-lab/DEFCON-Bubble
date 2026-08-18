extends Node3D

# [DB:PRESENTATION:POP_FX]
# Reacts to Bubble #1's authoritative popped signal. This node owns only
# presentation: membrane rupture, film ripple, mist, and placeholder audio.
# Gameplay still owns death, collision shutdown, and despawn timing.

const POP_SOUND_SECONDS: float = 0.09
const POP_SAMPLE_RATE: int = 22050
const MIST_DISTANCE: float = 0.5
const MIST_DURATION: float = 0.12
const MIST_DIRECTIONS := [
	Vector3(1.0, 0.35, 0.0),
	Vector3(0.9, 0.7, 0.15),
	Vector3(0.55, 1.0, -0.1),
	Vector3(0.15, 0.9, 0.55),
	Vector3(-0.2, 0.75, -0.65),
	Vector3(-0.55, 0.45, 0.4),
	Vector3(-0.75, 0.15, -0.2),
	Vector3(0.45, 0.3, 0.85),
	Vector3(0.25, 0.15, -0.9),
	Vector3(-0.1, 1.0, 0.15),
]

@onready var bubble: BasicBubble = get_parent() as BasicBubble
@onready var visual: Node3D = get_node("../Visual") as Node3D
@onready var flash_shell: MeshInstance3D = $FlashShell
@onready var pop_audio: AudioStreamPlayer3D = $PopAudio


func _ready() -> void:
	assert(bubble != null, "[DB:PRESENTATION:POP_FX] BasicBubble parent is required.")
	assert(visual != null, "[DB:PRESENTATION:POP_FX] Bubble Visual is required.")
	assert(flash_shell != null, "[DB:PRESENTATION:POP_FX] FlashShell is required.")
	assert(pop_audio != null, "[DB:PRESENTATION:POP_FX] PopAudio is required.")
	flash_shell.visible = false
	flash_shell.transparency = 1.0
	flash_shell.material_override = _build_film_material(Color(0.78, 0.95, 1.0, 0.24))
	pop_audio.volume_db = -5.0
	bubble.popped.connect(_on_bubble_popped)


func _on_bubble_popped(_bubble_id: StringName) -> void:
	_play_membrane_rupture()
	_play_film_echo()
	_spawn_film_ripple()
	_spawn_mist()
	_play_pop_audio()


func _play_membrane_rupture() -> void:
	# A soap film dimples at the puncture and then ceases to be a closed surface.
	# Do not shrink the whole sphere to zero; that reads as rubber/balloon material.
	visual.scale = Vector3(0.86, 1.07, 1.07)
	var rupture_tween: Tween = create_tween()
	rupture_tween.tween_property(visual, "scale", Vector3(0.94, 1.03, 1.03), 0.026).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rupture_tween.tween_callback(_hide_bubble_visual)


func _hide_bubble_visual() -> void:
	visual.visible = false


func _play_film_echo() -> void:
	# A faint near-stationary ghost of the membrane sells disappearing film,
	# rather than an exploding solid shell.
	flash_shell.visible = true
	flash_shell.scale = Vector3.ONE * 0.96
	flash_shell.transparency = 0.08

	var scale_tween: Tween = create_tween()
	scale_tween.tween_property(flash_shell, "scale", Vector3.ONE * 1.09, 0.065).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(flash_shell, "transparency", 1.0, 0.065).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _spawn_film_ripple() -> void:
	# [DB:PRESENTATION:POP_FILM_RIPPLE]
	# Two very thin translucent rings suggest the collapsing edge of soap film.
	_spawn_ring(Color(0.72, 0.95, 1.0, 0.46), Vector3(0.78, 0.72, 0.78), Vector3(1.48, 1.36, 1.48), 0.11)
	_spawn_ring(Color(1.0, 0.78, 0.96, 0.28), Vector3(0.72, 0.78, 0.72), Vector3(1.28, 1.42, 1.28), 0.095)


func _spawn_ring(color: Color, start_scale: Vector3, end_scale: Vector3, duration: float) -> void:
	var ring: MeshInstance3D = MeshInstance3D.new()
	var ring_mesh: TorusMesh = TorusMesh.new()
	ring_mesh.inner_radius = 0.56
	ring_mesh.outer_radius = 0.61
	ring_mesh.ring_segments = 8
	ring_mesh.rings = 32
	ring.mesh = ring_mesh
	ring.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	ring.scale = start_scale
	ring.material_override = _build_film_material(color)
	add_child(ring)

	var scale_tween: Tween = create_tween()
	scale_tween.tween_property(ring, "scale", end_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(ring, "transparency", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _spawn_mist() -> void:
	# Small, short-travel droplets read as suspended liquid film instead of shrapnel.
	var mist_material: StandardMaterial3D = _build_film_material(Color(0.83, 0.96, 1.0, 0.48))
	for index: int in range(MIST_DIRECTIONS.size()):
		var direction: Vector3 = MIST_DIRECTIONS[index]
		var droplet: MeshInstance3D = MeshInstance3D.new()
		var droplet_mesh: SphereMesh = SphereMesh.new()
		var radius: float = 0.018 + (float(index % 3) * 0.005)
		droplet_mesh.radius = radius
		droplet_mesh.height = radius * 2.0
		droplet.mesh = droplet_mesh
		droplet.material_override = mist_material
		droplet.position = direction.normalized() * 0.08
		droplet.scale = Vector3.ONE
		droplet.transparency = 0.08
		add_child(droplet)

		var distance_scale: float = 0.8 + (float(index % 4) * 0.08)
		var target_position: Vector3 = direction.normalized() * MIST_DISTANCE * distance_scale
		var duration: float = MIST_DURATION * (0.88 + float(index % 3) * 0.08)

		var move_tween: Tween = create_tween()
		move_tween.tween_property(droplet, "position", target_position, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(droplet, "transparency", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _build_film_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
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
	# A soap-film snap should be mostly a tiny broadband air burst with almost no
	# ringing body. Stable sine overtones read as glass, so keep tonal energy low.
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = POP_SAMPLE_RATE
	stream.stereo = false

	var frame_count: int = int(POP_SAMPLE_RATE * POP_SOUND_SECONDS)
	var data: PackedByteArray = PackedByteArray()
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
