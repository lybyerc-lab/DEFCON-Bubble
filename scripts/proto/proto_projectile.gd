extends Area3D

# [DB:PROTO:WALL_RUN]
# THROWAWAY. Exists only to answer one question on a phone. Not a contract, not
# a milestone, not something to build on. Delete with the branch.
#
# Flies +X from the wall into the advancing line, piercing up to two bubbles, so the same prototype
# also lets the Skewer question be felt rather than argued.

const SPEED_MPS: float = 16.0
const PIERCE_BUDGET: int = 2
const LIFETIME_SECONDS: float = 2.5

var _hits_left: int = PIERCE_BUDGET
var _already_hit: Dictionary = {}
var _age: float = 0.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position.x += SPEED_MPS * delta
	_age += delta
	if _age >= LIFETIME_SECONDS:
		queue_free()


func _on_area_entered(area: Area3D) -> void:
	if area == null or _hits_left <= 0:
		return
	# One toothpick must not damage the same bubble twice while passing through it.
	var key: int = area.get_instance_id()
	if _already_hit.has(key):
		return

	var receiver: DamageReceiver = area.get_node_or_null("DamageReceiver") as DamageReceiver
	if receiver == null:
		return

	var request := DamageRequest.new(
		&"proto:toothpick",
		receiver.target_id,
		1.0,
		DamageRequest.DamageType.PIERCE,
		global_position,
	)
	if not receiver.request_damage(request):
		return

	_already_hit[key] = true
	_hits_left -= 1
	if _hits_left <= 0:
		queue_free()
