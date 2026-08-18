extends Node3D

# [DB:PRESENTATION:POP_FX]
# Reacts to Bubble #1's authoritative popped signal. This node owns only
# presentation: squash/overshoot, flash shell, spray, and placeholder audio.

const POP_SOUND_SECONDS: float = 0.055
const POP_SAMPLE_RATE: int = 22050
const DROPLET_DISTANCE: float = 0.95
const DROPLET_DURATION: float = 0.16
const DROPLET_DIRECTIONS := [
	Vector3(1.0, 0.55, 0.0),
	Vector3(0.65, 0.95, 0.25),
	Vector3(0.35, 0.45, 0.95),
	Vector3(-0.2, 0.85, -0.75),
	Vector3(-0.55, 0.35, 0.65),
	Vector3(0.15, 1.0, -0.2),
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
	bubble.popped.connect(_on_bubble_popped)


func _on_bubble_popped(_bubble_id: StringName) -> void:
	_play_body_snap()
	_play_flash_shell()
	_spawn_droplets()
	_play_pop_audio()


func _play_body_snap() -> void:
	# Contact squish, quick elastic overshoot, then decisive collapse.
	visual.scale = Vector3(0.78, 1.12, 1.12)
	var snap_tween: Tween = create_tween()
	snap_tween.tween_property(visual, "scale", Vector3.ONE * 1.38, 0.045).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	snap_tween.tween_property(visual, "scale", Vector3.ONE * 0.03, 0.085).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _play_flash_shell() -> void:
	flash_shell.visible = true
	flash_shell.scale = Vector3.ONE * 0.82
	flash_shell.transparency = 0.05

	var scale_tween: Tween = create_tween()
	scale_tween.tween_property(flash_shell, "scale", Vector3.ONE * 1.85, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(flash_shell, "transparency", 1.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _spawn_droplets() -> void:
	for direction: Vector3 in DROPLET_DIRECTIONS:
		var droplet: MeshInstance3D = MeshInstance3D.new()
		var droplet_mesh: SphereMesh = SphereMesh.new()
		droplet_mesh.radius = 0.055
		droplet_mesh.height = 0.11
		droplet.mesh = droplet_mesh
		droplet.scale = Vector3.ONE * 0.8
		droplet.transparency = 0.05
		add_child(droplet)

		var target_position: Vector3 = direction.normalized() * DROPLET_DISTANCE
		var move_tween: Tween = create_tween()
		move_tween.tween_property(droplet, "position", target_position, DROPLET_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		var shrink_tween: Tween = create_tween()
		shrink_tween.tween_property(droplet, "scale", Vector3.ONE * 0.08, DROPLET_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(droplet, "transparency", 1.0, DROPLET_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _play_pop_audio() -> void:
	pop_audio.stream = _build_pop_stream()
	pop_audio.play()


func _build_pop_stream() -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = POP_SAMPLE_RATE
	stream.stereo = false

	var frame_count: int = int(POP_SAMPLE_RATE * POP_SOUND_SECONDS)
	var data: PackedByteArray = PackedByteArray()
	data.resize(frame_count * 2)

	for frame: int in range(frame_count):
		var time_seconds: float = float(frame) / float(POP_SAMPLE_RATE)
		var progress: float = time_seconds / POP_SOUND_SECONDS
		var envelope: float = pow(1.0 - progress, 2.2)
		var transient: float = sin(TAU * 1250.0 * time_seconds) * 0.72
		var body_frequency: float = 420.0 - (180.0 * progress)
		var body: float = sin(TAU * body_frequency * time_seconds) * 0.28
		var crackle: float = sin(TAU * 3100.0 * time_seconds) * sin(TAU * 1730.0 * time_seconds) * 0.12
		var sample: float = clampf((transient + body + crackle) * envelope, -1.0, 1.0)
		data.encode_s16(frame * 2, int(sample * 32767.0))

	stream.data = data
	return stream
