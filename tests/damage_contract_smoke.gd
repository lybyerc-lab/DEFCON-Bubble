extends SceneTree

# [DB:TEST:DAMAGE_CONTRACT]
# Headless proof that damage requests stay typed, validated, routed, and
# outcome-agnostic before the first production enemy or castle target exists.

var failures: Array[String] = []
var received_requests: Array[DamageRequest] = []


func _init() -> void:
	var receiver: DamageReceiver = DamageReceiver.new()
	receiver.target_id = &"test:target"
	receiver.damage_requested.connect(_on_damage_requested)
	get_root().add_child(receiver)

	var request: DamageRequest = DamageRequest.new(
		&"test:toothpick",
		&"test:target",
		12.5,
		DamageRequest.DamageType.PIERCE,
		Vector3(1.0, 2.0, 3.0),
	)

	_check(request.is_valid(), "well-formed request must validate")
	_check(receiver.request_damage(request), "matching receiver must accept valid request")
	_check(received_requests.size() == 1, "accepted request must emit exactly once")
	if received_requests.size() == 1:
		_check(received_requests[0] == request, "receiver must forward the original request object")
		_check(received_requests[0].amount == 12.5, "receiver must not rewrite damage amount")
		_check(
			received_requests[0].impact_position == Vector3(1.0, 2.0, 3.0),
			"receiver must preserve impact position",
		)

	var wrong_target: DamageRequest = DamageRequest.new(
		&"test:toothpick",
		&"test:other-target",
		12.5,
		DamageRequest.DamageType.PIERCE,
		Vector3.ZERO,
	)
	_check(wrong_target.is_valid(), "wrong-target request can still be structurally valid")
	_check(not receiver.request_damage(wrong_target), "receiver must reject requests for another target")
	_check(received_requests.size() == 1, "rejected target mismatch must not emit")

	var invalid_source: DamageRequest = DamageRequest.new(
		&"",
		&"test:target",
		1.0,
		DamageRequest.DamageType.PIERCE,
		Vector3.ZERO,
	)
	_check(not invalid_source.is_valid(), "empty source ID must be invalid")

	var invalid_amount: DamageRequest = DamageRequest.new(
		&"test:source",
		&"test:target",
		0.0,
		DamageRequest.DamageType.IMPACT,
		Vector3.ZERO,
	)
	_check(not invalid_amount.is_valid(), "non-positive damage amount must be invalid")

	var invalid_type: DamageRequest = DamageRequest.new(
		&"test:source",
		&"test:target",
		1.0,
		DamageRequest.DamageType.UNSPECIFIED,
		Vector3.ZERO,
	)
	_check(not invalid_type.is_valid(), "unspecified damage type must be invalid")

	receiver.free()

	if failures.is_empty():
		print("[DB:TEST:DAMAGE_CONTRACT] PASS")
		quit(0)
		return

	for failure: String in failures:
		push_error("[DB:TEST:DAMAGE_CONTRACT] %s" % failure)
	quit(1)


func _on_damage_requested(request: DamageRequest) -> void:
	received_requests.append(request)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
