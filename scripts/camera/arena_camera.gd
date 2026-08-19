class_name ArenaCamera
extends Camera3D

# [DB:CAMERA:ORIENTATION_FRAMING]
# Frames the battlefield deliberately instead of inheriting an engine default.
#
# Godot's default keep_aspect is KEEP_HEIGHT: vertical FOV is locked and
# horizontal grows with the display. DEFCON BUBBLE's combat lane is horizontal,
# so that default protects the axis the game does not use. On a 20:9 phone in
# landscape the lane occupied 23% of the visible width; at 9:20 it did not fit
# at all and an end of the lane fell off-screen.
#
# This camera instead guarantees a framed box in metres and moves itself to the
# distance where that box fits the current viewport, in both axes. Field of view
# stays fixed so the perspective read never changes with orientation; only the
# distance and pitch respond.
#
# Framing is presentation. This node never moves the castle, the spawn edge, or
# any gameplay distance; it only decides where the camera stands to see them.

# The lane this camera must always contain, in world metres. These mirror the
# authored castle and spawn positions plus readable margin. The margin is
# generous on purpose: framing the lane tightly reads as crowded on a phone, so
# the lane is sized to occupy roughly 58% of the width rather than filling it. If the encounter ever
# moves them, these change deliberately and the proof fails until they agree.
const LANE_CENTER := Vector3(0.8, 1.0, 0.0)
const FRAMED_HALF_WIDTH_METERS: float = 9.0
const FRAMED_HALF_HEIGHT_METERS: float = 3.0

# Landscape keeps a narrow, undistorted read. Portrait has to open up: reaching
# the same horizontal span on a tall screen at 50 degrees would need the camera
# 31 metres back, well off the authored beach.
const LANDSCAPE_FOV_DEGREES: float = 50.0
const PORTRAIT_FOV_DEGREES: float = 70.0

# Landscape keeps the accepted shallow beach angle. Portrait has to look further
# down or it frames mostly sky to reach the same horizontal span.
const LANDSCAPE_PITCH_DEGREES: float = -22.0
const PORTRAIT_PITCH_DEGREES: float = -34.0
const LANDSCAPE_ASPECT: float = 16.0 / 9.0
const PORTRAIT_ASPECT: float = 9.0 / 16.0

# A hard stop on retreat, so an extreme aspect cannot walk the camera off the
# authored beach to satisfy the width term. It is set beyond what any tested
# aspect needs: if it ever binds, the frame is being decided by a safety limit
# instead of by the framing solve, which the proof treats as a failure.
const MAX_FRAMING_DISTANCE_METERS: float = 30.0


func _ready() -> void:
	# fov is the vertical angle under KEEP_HEIGHT, which is what the distance
	# solve below assumes. State it rather than inheriting it.
	keep_aspect = Camera3D.KEEP_HEIGHT
	current = true
	var viewport: Viewport = get_viewport()
	if viewport != null:
		viewport.size_changed.connect(_on_viewport_size_changed)
	reframe()


func _on_viewport_size_changed() -> void:
	# Rotating the device mid-run lands here.
	reframe()


func reframe() -> void:
	var viewport: Viewport = get_viewport()
	if viewport == null:
		return
	var size: Vector2 = viewport.get_visible_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return
	apply_framing(size.x / size.y)


func apply_framing(aspect: float) -> void:
	# Kept parameterised so the proof can frame representative phone aspects
	# without a real viewport.
	if aspect <= 0.0:
		return
	var pitch_degrees: float = pitch_for_aspect(aspect)
	var distance: float = framing_distance(aspect)
	fov = fov_for_aspect(aspect)
	rotation_degrees = Vector3(pitch_degrees, 0.0, 0.0)
	# Stand back along the view direction from the lane centre.
	var forward: Vector3 = Vector3(0.0, 0.0, -1.0).rotated(Vector3.RIGHT, deg_to_rad(pitch_degrees))
	global_position = LANE_CENTER - forward * distance


func pitch_for_aspect(aspect: float) -> float:
	return lerpf(PORTRAIT_PITCH_DEGREES, LANDSCAPE_PITCH_DEGREES, _orientation_blend(aspect))


func fov_for_aspect(aspect: float) -> float:
	return lerpf(PORTRAIT_FOV_DEGREES, LANDSCAPE_FOV_DEGREES, _orientation_blend(aspect))


func _orientation_blend(aspect: float) -> float:
	# 0.0 at portrait, 1.0 at landscape, smooth between so a rotation does not snap.
	return clampf(inverse_lerp(PORTRAIT_ASPECT, LANDSCAPE_ASPECT, aspect), 0.0, 1.0)


func framing_distance(aspect: float) -> float:
	# Distance at which the framed box fits, solved separately per axis. The
	# larger requirement wins, so both always fit: in landscape the height term
	# governs, in portrait the width term does.
	var tan_half: float = tan(deg_to_rad(fov_for_aspect(aspect)) * 0.5)
	var distance_for_height: float = FRAMED_HALF_HEIGHT_METERS / tan_half
	var distance_for_width: float = FRAMED_HALF_WIDTH_METERS / (tan_half * aspect)
	return minf(maxf(distance_for_height, distance_for_width), MAX_FRAMING_DISTANCE_METERS)


func visible_half_width(aspect: float) -> float:
	# What the frame actually contains horizontally at the chosen distance.
	# Below FRAMED_HALF_WIDTH_METERS means the clamp bit and the lane is cropped.
	var tan_half: float = tan(deg_to_rad(fov_for_aspect(aspect)) * 0.5)
	return framing_distance(aspect) * tan_half * aspect
