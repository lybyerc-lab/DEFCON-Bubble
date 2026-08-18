extends SceneTree

# [DB:TEST:FIRST_DEFENSE]
# Deterministic proof of the exact three-bubble spawn schedule and both terminal outcomes.

const FIRST_DEFENSE_SCENE: PackedScene = preload("res://scenes/proof/first_defense_range.tscn")

var failures: Array[String] = []
var won_count: int = 0
var lost_count: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await _prove_surviving_castle_wins()
	await _prove_two_leaks_lose_and_stop_survivor()
	await _prove_early_loss_cancels_pending_spawns()
	_finish()


func _prove_surviving_castle_wins() -> void:
	var range_root: Node3D = FIRST_DEFENSE_SCENE.instantiate() as Node3D
	_check(range_root != null, "first-defense range must instantiate")
	if range_root == null:
		return
	var ready_wave: FirstDefenseWave = range_root.get_node("FirstDefenseWave") as FirstDefenseWave
	_check(ready_wave.current_state() == FirstDefenseWave.WaveState.READY, "wave must begin in authoritative READY state")

	get_root().add_child(range_root)
	await process_frame
	await process_frame

	var wave: FirstDefenseWave = range_root.get_node("FirstDefenseWave") as FirstDefenseWave
	var castle: CastleChunk = range_root.get_node("CastleChunk") as CastleChunk
	var spawn_marker: Marker3D = range_root.get_node("FirstDefenseWave/SpawnMarker") as Marker3D
	var status_label: Label = range_root.get_node("TouchHUD/WaveHUD/StatusLabel") as Label
	var remaining_label: Label = range_root.get_node("TouchHUD/WaveHUD/RemainingLabel") as Label
	var castle_label: Label = range_root.get_node("TouchHUD/WaveHUD/CastleLabel") as Label
	var fire_button: Button = range_root.get_node("TouchHUD/TouchControls/FireButton") as Button
	var reset_button: Button = range_root.get_node("TouchHUD/TouchControls/ResetButton") as Button
	wave.state_changed.connect(_on_wave_state_changed)
	wave.set_physics_process(false)

	_check(wave.current_state() == FirstDefenseWave.WaveState.RUNNING, "wave must leave READY and enter RUNNING")
	_check(wave.spawned_count() == 1, "first bubble must spawn immediately")
	_check(wave.remaining_count() == 3, "wave must begin with exactly three unresolved bubbles")
	_check(is_equal_approx(wave.spawn_interval_seconds, 1.6), "first-defense stagger must remain 1.6 seconds")
	_check(status_label.text == "DEFEND THE CASTLE!", "HUD must show the running state")
	_check(not fire_button.disabled, "FIRE must be enabled while the wave is running")
	_check(reset_button.text == "RESET", "reset control must read RESET while the wave is running")

	var first: BasicBubble = wave.bubble_at(0)
	_check(first != null, "first bubble must be available")
	if first != null:
		_check(first.bubble_id == &"enemy:basic_bubble:first_defense:01", "first bubble ID must be unique and stable")
		_check(first.advance_enabled, "spawned bubble must advance")
		_check(is_equal_approx(first.advance_speed_mps, 1.25), "first-defense speed must remain 1.25 m/s")
		_check(is_equal_approx(spawn_marker.global_position.x, 6.0), "first-defense bubbles must spawn at x=6.0")
		_check(first.attempt_castle_impact(castle), "one leaked bubble must request its IMPACT")

	_check(castle.current_health() == 1.0, "one leak must visibly leave the castle alive at one health")
	_check(wave.current_state() == FirstDefenseWave.WaveState.RUNNING, "one leak must not lose the wave")
	var remaining_after_first: int = wave.remaining_count()
	wave._on_bubble_popped(&"enemy:basic_bubble:first_defense:01")
	wave._on_bubble_popped(&"enemy:basic_bubble:first_defense:foreign")
	_check(wave.remaining_count() == remaining_after_first, "duplicate and foreign POP callbacks must not change remaining truth")
	_check(wave.current_state() == FirstDefenseWave.WaveState.RUNNING, "currently spawned resolutions must not win before all three threats exist")

	var until_second: float = wave.seconds_until_next_spawn()
	wave._physics_process(until_second - 0.001)
	_check(wave.spawned_count() == 1, "second bubble must not spawn before the 1.6 s stagger")
	wave._physics_process(0.002)
	_check(wave.spawned_count() == 2, "second bubble must spawn at the 1.6 s stagger")

	var second: BasicBubble = wave.bubble_at(1)
	_check(second != null, "second bubble must be available")
	if second != null:
		_check(second.bubble_id == &"enemy:basic_bubble:first_defense:02", "second bubble ID must be unique and stable")
		_pierce_bubble(second)

	wave._physics_process(3.2)
	_check(wave.spawned_count() == 3, "large delta must catch up the third spawn without creating a fourth")
	var third: BasicBubble = wave.bubble_at(2)
	_check(third != null, "third bubble must be available")
	if third != null:
		_check(third.bubble_id == &"enemy:basic_bubble:first_defense:03", "third bubble ID must be unique and stable")
		_pierce_bubble(third)

	_check(wave.spawned_count() == 3, "first defense must never spawn more than three bubbles")
	_check(wave.remaining_count() == 0, "all three resolved bubbles must leave zero remaining")
	_check(wave.current_state() == FirstDefenseWave.WaveState.WON, "three resolved bubbles with castle alive must win")
	_check(not castle.is_destroyed(), "damaged but surviving castle must satisfy the win condition")
	_check(won_count == 1, "win state must emit exactly once")
	_check(lost_count == 0, "surviving-castle fixture must not emit loss")
	_check(status_label.text == "CASTLE HOLDS!", "HUD must render the win state")
	_check(remaining_label.text == "BUBBLES: 0 / 3", "HUD must render zero remaining")
	_check(castle_label.text == "CASTLE: 1 / 2", "HUD must render localized castle health")
	_check(fire_button.disabled, "FIRE must be visibly disabled after victory")
	_check(reset_button.text == "RETRY", "terminal reset control must read RETRY")
	wave._on_bubble_popped(&"enemy:basic_bubble:first_defense:03")
	_check(wave.remaining_count() == 0, "late POP callbacks must not mutate won wave truth")
	_check(won_count == 1, "late POP callbacks must not repeat victory")

	range_root.queue_free()
	await process_frame


func _prove_two_leaks_lose_and_stop_survivor() -> void:
	var range_root: Node3D = FIRST_DEFENSE_SCENE.instantiate() as Node3D
	get_root().add_child(range_root)
	await process_frame
	await process_frame

	var wave: FirstDefenseWave = range_root.get_node("FirstDefenseWave") as FirstDefenseWave
	var castle: CastleChunk = range_root.get_node("CastleChunk") as CastleChunk
	var status_label: Label = range_root.get_node("TouchHUD/WaveHUD/StatusLabel") as Label
	var fire_button: Button = range_root.get_node("TouchHUD/TouchControls/FireButton") as Button
	var reset_button: Button = range_root.get_node("TouchHUD/TouchControls/ResetButton") as Button
	wave.state_changed.connect(_on_wave_state_changed)
	wave.set_physics_process(false)
	wave._physics_process(3.2)
	_check(wave.spawned_count() == 3, "loss ordering fixture must spawn all three ordinary bubbles")
	var first_leak: BasicBubble = wave.bubble_at(0)
	var second_leak: BasicBubble = wave.bubble_at(1)
	var surviving_bubble: BasicBubble = wave.bubble_at(2)
	_check(first_leak.attempt_castle_impact(castle), "first ordinary bubble must leak through IMPACT")
	_check(wave.current_state() == FirstDefenseWave.WaveState.RUNNING, "one leaked bubble must remain recoverable")
	_check(second_leak.attempt_castle_impact(castle), "second ordinary bubble must leak through IMPACT")

	_check(first_leak.is_popped() and second_leak.is_popped(), "both leaked bubbles must own their POP state")
	_check(castle.is_destroyed(), "second leaked bubble must destroy the two-health castle chunk")
	_check(wave.current_state() == FirstDefenseWave.WaveState.LOST, "castle destruction must lose immediately")
	_check(lost_count == 1, "loss state must emit exactly once")
	_check(won_count == 1, "loss ordering must not emit a new victory")
	_check(surviving_bubble != null, "loss fixture must have one spawned survivor")
	if surviving_bubble != null:
		_check(not surviving_bubble.advance_enabled, "loss must stop every surviving spawned bubble")
		var stopped_x: float = surviving_bubble.position.x
		surviving_bubble._physics_process(1.0)
		_check(is_equal_approx(surviving_bubble.position.x, stopped_x), "surviving bubble position must remain stopped after loss")
	_check(status_label.text == "CASTLE FALLS!", "HUD must render the loss state")
	_check(fire_button.disabled, "FIRE must be visibly disabled after loss")
	_check(reset_button.text == "RETRY", "loss control must offer RETRY")
	wave._on_bubble_popped(&"enemy:basic_bubble:first_defense:03")
	wave._on_castle_destroyed(castle.chunk_id)
	_check(wave.current_state() == FirstDefenseWave.WaveState.LOST, "late callbacks must not change terminal loss")
	_check(lost_count == 1, "terminal loss must remain idempotent")
	_check(won_count == 1, "late loss callbacks must not emit victory")

	range_root.queue_free()
	await process_frame


func _prove_early_loss_cancels_pending_spawns() -> void:
	var range_root: Node3D = FIRST_DEFENSE_SCENE.instantiate() as Node3D
	get_root().add_child(range_root)
	await process_frame
	await process_frame

	var wave: FirstDefenseWave = range_root.get_node("FirstDefenseWave") as FirstDefenseWave
	var castle: CastleChunk = range_root.get_node("CastleChunk") as CastleChunk
	wave.state_changed.connect(_on_wave_state_changed)
	wave.set_physics_process(false)
	var surviving_bubble: BasicBubble = wave.bubble_at(0)
	_request_direct_impact(castle, &"test:early-loss-one")
	_request_direct_impact(castle, &"test:early-loss-two")

	_check(wave.current_state() == FirstDefenseWave.WaveState.LOST, "early castle destruction must lose")
	_check(lost_count == 2, "each independent loss fixture must emit exactly one loss")
	_check(won_count == 1, "early loss must not emit victory")
	_check(surviving_bubble != null and not surviving_bubble.advance_enabled, "early loss must stop the one spawned survivor")
	wave._physics_process(10.0)
	_check(wave.spawned_count() == 1, "early loss must cancel both pending bubble spawns")

	range_root.queue_free()
	await process_frame


func _pierce_bubble(bubble: BasicBubble) -> void:
	var receiver: DamageReceiver = bubble.get_node("DamageReceiver") as DamageReceiver
	var request := DamageRequest.new(
		&"test:toothpick",
		bubble.bubble_id,
		1.0,
		DamageRequest.DamageType.PIERCE,
		bubble.global_position,
	)
	_check(receiver.request_damage(request), "PIERCE must cross the bubble damage boundary")
	_check(bubble.is_popped(), "PIERCE must resolve the ordinary basic bubble")


func _request_direct_impact(castle: CastleChunk, source_id: StringName) -> void:
	var receiver: DamageReceiver = castle.get_node("DamageReceiver") as DamageReceiver
	var request := DamageRequest.new(
		source_id,
		castle.chunk_id,
		1.0,
		DamageRequest.DamageType.IMPACT,
		castle.global_position,
	)
	_check(receiver.request_damage(request), "valid IMPACT must cross the castle damage boundary")


func _on_wave_state_changed(state: int) -> void:
	if state == FirstDefenseWave.WaveState.WON:
		won_count += 1
	elif state == FirstDefenseWave.WaveState.LOST:
		lost_count += 1


func _finish() -> void:
	if failures.is_empty():
		print("[DB:TEST:FIRST_DEFENSE] PASS")
		quit(0)
		return

	for failure: String in failures:
		push_error("[DB:TEST:FIRST_DEFENSE] %s" % failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
