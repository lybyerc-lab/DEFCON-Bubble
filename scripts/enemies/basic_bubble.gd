class_name BasicBubble
extends Area3D

# [DB:COMBAT:POP]
# Bubble #1 owns its damage outcome. DamageReceiver only routes requests here.

signal popped(bubble_id: StringName)

const POP_LINGER_SECONDS: float = 0.18

@export_category("Bubble Identity")
@export var bubble_id: StringName = &"enemy:basic_bubble:proof"
@export_category("Bubble Durability")
@export var max_health: float = 1.0
@export_category("Bubble Advance")
@export var advance_enabled: bool = false
@export var advance_speed_mps: float = 1.25

@onready var damage_receiver: DamageReceiver = $DamageReceiver
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var _health: float
var _is_popped: bool = false
var _castle_impact_spent: bool = false


func _ready() -> void:
	assert(damage_receiver != null, "[DB:COMBAT:POP] DamageReceiver is required.")
	assert(max_health > 0.0, "[DB:COMBAT:POP] max_health must be positive.")
	assert(advance_speed_mps > 0.0, "[DB:CASTLE:IMPACT] advance_speed_mps must be positive.")
	_health = max_health
	damage_receiver.target_id = bubble_id
	damage_receiver.damage_requested.connect(_on_damage_requested)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if not advance_enabled or _is_popped:
		return

	position.x -= advance_speed_mps * delta


func is_popped() -> bool:
	return _is_popped


func attempt_castle_impact(target_area: Area3D) -> bool:
	# [DB:CASTLE:IMPACT]
	# Bubble #1 requests one typed IMPACT on contact. The castle target decides
	# whether that request changes health or destruction state.
	if _is_popped or _castle_impact_spent or target_area == null:
		return false

	var receiver: DamageReceiver = target_area.get_node_or_null("DamageReceiver") as DamageReceiver
	if receiver == null:
		return false

	var request := DamageRequest.new(
		bubble_id,
		receiver.target_id,
		1.0,
		DamageRequest.DamageType.IMPACT,
		global_position,
	)
	if not receiver.request_damage(request):
		return false

	_castle_impact_spent = true
	_pop()
	return true


func _on_area_entered(area: Area3D) -> void:
	if advance_enabled:
		attempt_castle_impact(area)


func _on_damage_requested(request: DamageRequest) -> void:
	if _is_popped:
		return

	if request.damage_type != DamageRequest.DamageType.PIERCE:
		return

	_health = maxf(0.0, _health - request.amount)
	if _health <= 0.0:
		_pop()


func _pop() -> void:
	if _is_popped:
		return

	_is_popped = true
	set_physics_process(false)
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	collision_shape.set_deferred("disabled", true)
	popped.emit(bubble_id)

	# Gameplay owns the despawn clock. Presentation may react inside this window,
	# but it cannot decide whether the bubble is dead or keep it alive.
	var pop_timer: SceneTreeTimer = get_tree().create_timer(POP_LINGER_SECONDS)
	pop_timer.timeout.connect(queue_free)
