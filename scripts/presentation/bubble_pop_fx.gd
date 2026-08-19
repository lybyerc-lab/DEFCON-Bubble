extends Node3D

# [DB:PRESENTATION:POP_FX]
# Reacts to Bubble #1's authoritative popped signal. This node owns only
# presentation: living soap film, single-frame rupture, fluid spray, mist, and audio.
# Gameplay still owns damage outcomes, death, collision shutdown, and despawn timing.

const BUBBLE_FILM_RADIUS: float = 0.65
const SOAP_FILM_SHADER: Shader = preload("res://shaders/soap_film.gdshader")
const RUPTURE_SECONDS: float = 0.016
const SPRAY_DROPLET_COUNT: int = 22
const SPRAY_DURATION: float = 0.125
const MIST_MOTE_COUNT: int = 6
const MIST_DURATION: float = 0.09

@onready var bubble: BasicBubble = get_parent() as BasicBubble
@onready var visual: Node3D = get_node("../Visual") as Node3D
@onready var bubble_mesh: MeshInstance3D = get_node("../Visual/BubbleMesh") as MeshInstance3D
@onready var damage_receiver: DamageReceiver = get_node("../DamageReceiver") as DamageReceiver
@onready var flash_shell: MeshInstance3D = $FlashShell
@onready var pop_audio: AudioStreamPlayer3D = $PopAudio

var _impact_direction: Vector3 = Vector3.LEFT
var _idle_material: ShaderMaterial
var _rupture_material: ShaderMaterial


func _ready() -> void:
	assert(bubble != null, "[DB:PRESENTATION:POP_FX] BasicBubble parent is required.")
	assert(visual != null, "[DB:PRESENTATION:POP_FX] Bubble Visual is required.")
	assert(bubble_mesh != null, "[DB:PRESENTATION:POP_FX] BubbleMesh is required.")
	assert(damage_receiver != null, "[DB:PRESENTATION:POP_FX] DamageReceiver is required.")
	assert(flash_shell != null, "[DB:PRESENTATION:POP_FX] FlashShell is required.")
	assert(pop_audio != null, "[DB:PRESENTATION:POP_FX] PopAudio is required.")
	assert(pop_audio.stream != null, "[DB:PRESENTATION:POP_FX] CC0 bubble POP stream is required.")

	# [DB:PRESENTATION:BUBBLE_FILM]
	# The living bubble should read as a thin soap membrane before POP. Keep the
	# animated film pattern anchored in object space so camera movement cannot make
	# the rainbow appear painted onto the screen.
	_idle_material = _build_idle_film_material()
	bubble_mesh.material_override = _idle_material

	# Full-shell flashes and complete rings are intentionally retired. They read as
	# shields/sonar. The bubble's own surface must be the thing that disappears.
	flash_shell.visible = false
	flash_shell.transparency = 1.0
	pop_audio.volume_db = -3.0

	damage_receiver.damage_requested.connect(_on_damage_requested)
	bubble.popped.connect(_on_bubble_popped)


func _on_damage_requested(request: DamageRequest) -> void:
	# Presentation observes the canonical hit position without owning the result.
	if request == null:
		return

	var local_impact: Vector3 = to_local(request.impact_position)
	var flat_impact := Vector3(local_impact.x, local_impact.y, 0.0)
	if flat_impact.length_squared() <= 0.0001:
		return

	_impact_direction = flat_impact.normalized()


func _on_bubble_popped(_bubble_id: StringName) -> void:
	_play_single_frame_rupture()
	_spawn_surface_droplet_spray()
	_spawn_mist_puff()
	_play_pop_audio()


func _play_single_frame_rupture() -> void:
	# [DB:PRESENTATION:POP_SINGLE_FRAME]
	# The puncture immediately opens a hole. During roughly one 60 Hz frame the
	# remaining spherical film snaps toward the antipode, then the closed surface
	# ceases to exist. We do not scale the sphere like rubber.
	visual.position = Vector3.ZERO
	visual.scale = Vector3.ONE
	visual.visible = true

	_rupture_material = _build_rupture_material()
	bubble_mesh.material_override = _rupture_material
	_rupture_material.set_shader_parameter("impact_dir", _impact_direction)
	_rupture_material.set_shader_parameter("rupture_progress", 0.0)
	_rupture_material.set_shader_parameter("collapse_progress", 0.0)

	var rupture_tween: Tween = create_tween()
	rupture_tween.tween_method(_set_rupture_frame, 0.0, 1.0, RUPTURE_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	rupture_tween.tween_callback(_hide_bubble_visual)


func _set_rupture_frame(progress: float) -> void:
	if _rupture_material == null:
		return
	_rupture_material.set_shader_parameter("rupture_progress", clampf(progress * 1.08, 0.0, 1.0))
	_rupture_material.set_shader_parameter("collapse_progress", progress)


func _hide_bubble_visual() -> void:
	visual.visible = false


func _build_idle_film_material() -> ShaderMaterial:
	# [DB:PRESENTATION:SOAP_FILM]
	# Shared with every limb through BubbleCreatureFx so one creature is one
	# substance. Tinting stays per-instance; the shader source is common.
	var material := ShaderMaterial.new()
	material.shader = SOAP_FILM_SHADER
	return material


func _build_rupture_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform vec3 impact_dir = vec3(-1.0, 0.0, 0.0);
uniform float rupture_progress : hint_range(0.0, 1.0) = 0.0;
uniform float collapse_progress : hint_range(0.0, 1.0) = 0.0;

varying float hit_alignment;
varying float surface_phase;

void vertex() {
	vec3 direction = normalize(impact_dir);
	vec3 surface_normal = normalize(VERTEX);
	hit_alignment = dot(surface_normal, direction);
	surface_phase = (1.0 - hit_alignment) * 0.5;

	// Surface tension races from puncture (phase 0) toward the antipode (phase 1).
	float local_collapse = smoothstep(surface_phase - 0.18, surface_phase + 0.08, collapse_progress);
	vec3 antipode = -direction * 0.65;
	VERTEX = mix(VERTEX, antipode, local_collapse);
}

void fragment() {
	// The puncture starts as a tiny cap and races across the shell in the same frame.
	float hole_threshold = mix(0.985, -1.05, rupture_progress);
	if (hit_alignment > hole_threshold) {
		discard;
	}

	// Fleeting soap-film iridescence only while the membrane still exists.
	float iridescence = 0.5 + 0.5 * sin(surface_phase * 11.0 + TIME * 20.0);
	vec3 cool_film = vec3(0.72, 0.94, 1.0);
	vec3 warm_film = vec3(1.0, 0.86, 0.97);
	ALBEDO = mix(cool_film, warm_film, iridescence);
	EMISSION = ALBEDO * 0.055;
	ALPHA = 0.34 * (1.0 - rupture_progress * 0.78);
}
"""

	var material := ShaderMaterial.new()
	material.shader = shader
	return material


func _spawn_surface_droplet_spray() -> void:
	# [DB:PRESENTATION:POP_SPRAY]
	# The membrane now converts into liquid at the bubble's center rather than
	# visibly detonating at the antipode. Tiny seed positions form an irregular
	# 3D cloud around center, then pressure sends droplets outward in all directions.
	var retract_axis: Vector3 = -_impact_direction
	var droplet_material: StandardMaterial3D = _build_film_material(Color(0.88, 0.98, 1.0, 0.54))

	for index: int in range(SPRAY_DROPLET_COUNT):
		# Deterministic spherical distribution, slightly compressed in depth for
		# phone readability. This avoids both a rear-edge belt and a perfect ring.
		var fraction: float = (float(index) + 0.5) / float(SPRAY_DROPLET_COUNT)
		var vertical: float = 1.0 - 2.0 * fraction
		var radial: float = sqrt(maxf(0.0, 1.0 - vertical * vertical))
		var azimuth: float = float(index) * 2.39996323 + sin(float(index) * 1.31) * 0.09
		var seed_direction := Vector3(cos(azimuth) * radial, vertical, sin(azimuth) * radial * 0.72).normalized()
		var seed_radius: float = 0.042 + float(index % 4) * 0.007
		var origin: Vector3 = seed_direction * seed_radius

		var droplet := MeshInstance3D.new()
		var droplet_mesh := SphereMesh.new()
		var droplet_radius: float = 0.010 + float(index % 4) * 0.0035
		droplet_mesh.radius = droplet_radius
		droplet_mesh.height = droplet_radius * 2.0
		droplet.mesh = droplet_mesh
		droplet.material_override = droplet_material
		droplet.position = origin
		add_child(droplet)

		var pressure_direction: Vector3 = seed_direction * 0.86 + retract_axis * 0.14
		pressure_direction += Vector3(
			sin(float(index) * 3.91) * 0.055,
			cos(float(index) * 2.17) * 0.035,
			cos(float(index) * 2.63) * 0.045
		)
		pressure_direction = pressure_direction.normalized()

		var travel: float = 0.16 + float(index % 6) * 0.022
		var gravity_drop: float = 0.018 + float(index % 4) * 0.010
		var target_position: Vector3 = origin + pressure_direction * travel
		target_position.y -= gravity_drop
		var duration: float = SPRAY_DURATION * (0.82 + float(index % 5) * 0.045)

		var move_tween: Tween = create_tween()
		move_tween.tween_property(droplet, "position", target_position, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		var scale_tween: Tween = create_tween()
		scale_tween.tween_property(droplet, "scale", Vector3.ONE * 0.58, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(droplet, "transparency", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _spawn_mist_puff() -> void:
	# [DB:PRESENTATION:POP_MIST]
	# The remnant also lives at the bubble center now. Loose offsets and short drift
	# keep it organic without turning it into another halo or rear-edge marker.
	var retract_axis: Vector3 = -_impact_direction
	var tangent := Vector3(-retract_axis.y, retract_axis.x, 0.0).normalized()
	var mist_material: StandardMaterial3D = _build_film_material(Color(0.92, 0.99, 1.0, 0.12))
	var mist_center: Vector3 = Vector3.ZERO

	for index: int in range(MIST_MOTE_COUNT):
		var mote := MeshInstance3D.new()
		var mote_mesh := SphereMesh.new()
		var radius: float = 0.052 + float(index % 3) * 0.011
		mote_mesh.radius = radius
		mote_mesh.height = radius * 2.0
		mote.mesh = mote_mesh
		mote.material_override = mist_material
		mote.position = mist_center
		mote.position += tangent * sin(float(index) * 2.4) * 0.055
		mote.position += Vector3(0.0, cos(float(index) * 1.9) * 0.038, float((index % 3) - 1) * 0.035)
		mote.scale = Vector3.ONE * 0.68
		add_child(mote)

		var drift: Vector3 = retract_axis * (0.020 + float(index % 2) * 0.012)
		drift += tangent * sin(float(index) * 1.7) * 0.025
		drift.y += 0.012
		var target_position: Vector3 = mote.position + drift

		var move_tween: Tween = create_tween()
		move_tween.tween_property(mote, "position", target_position, MIST_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		var expand_tween: Tween = create_tween()
		expand_tween.tween_property(mote, "scale", Vector3.ONE * 1.28, MIST_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(mote, "transparency", 1.0, MIST_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _build_film_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.roughness = 0.18
	return material


func _play_pop_audio() -> void:
	pop_audio.play()
