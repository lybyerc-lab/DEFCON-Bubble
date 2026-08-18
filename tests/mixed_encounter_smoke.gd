extends SceneTree

# [DB:TEST:MIXED_ENCOUNTER]
# Deterministic positive and negative fixtures for the authored three-wave run.

const ENCOUNTER_SCENE: PackedScene = preload("res://scenes/proof/mixed_encounter_range.tscn")

var failures: Array[String] = []
var state_events: Array[int] = []
var wave_events: Array[String] = []
var won_events: int = 0
var lost_events: int = 0
var destroyed_before_pop_observed: bool = false
var loss_order_encounter: MixedEncounter
var loss_remaining_before_impact: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await _prove_three_wave_victory_with_persistent_damage()
	await _prove_cross_wave_defeat_stops_future_threats()
	_finish()


func _prove_three_wave_victory_with_persistent_damage() -> void:
	var range_root: Node3D = ENCOUNTER_SCENE.instantiate() as Node3D
	var ready_encounter: MixedEncounter = range_root.get_node("MixedEncounter") as MixedEncounter
	_reset_signal_log()
	_connect_encounter_signals(ready_encounter)
	_check(ready_encounter.current_state() == MixedEncounter.EncounterState.READY, "encounter must begin in READY")
	_check(_authored_schedule_is_exact(ready_encounter), "three-wave authored schedule must match the milestone")

	get_root().add_child(range_root)
	await process_frame
	await process_frame

	var encounter: MixedEncounter = range_root.get_node("MixedEncounter") as MixedEncounter
	var castle: CastleChunk = range_root.get_node("CastleChunk") as CastleChunk
	var fire_button: Button = range_root.get_node("TouchHUD/TouchControls/FireButton") as Button
	var reset_button: Button = range_root.get_node("TouchHUD/TouchControls/ResetButton") as Button
	var status_label: Label = range_root.get_node("TouchHUD/EncounterHUD/StatusLabel") as Label
	var wave_label: Label = range_root.get_node("TouchHUD/EncounterHUD/WaveLabel") as Label
	var remaining_label: Label = range_root.get_node("TouchHUD/EncounterHUD/RemainingLabel") as Label
	var castle_label: Label = range_root.get_node("TouchHUD/EncounterHUD/CastleLabel") as Label
	encounter.set_physics_process(false)

	_check(encounter.current_state() == MixedEncounter.EncounterState.WAVE_ACTIVE, "READY must enter WAVE_ACTIVE")
	_check(state_events == [MixedEncounter.EncounterState.WAVE_ACTIVE], "encounter must emit WAVE_ACTIVE exactly once at start")
	_check(wave_events == ["1/3:BASIC TRAINING"], "encounter must announce wave 1 exactly once")
	_check(encounter.current_wave_number() == 1 and encounter.all_spawned_count() == 1, "wave 1 must spawn slot 1 at t=0")
	_check(encounter.bubble_at(0).bubble_id == &"enemy:basic:mixed_encounter:w01:s01", "wave+slot ID must be stable")
	_check(status_label.text == "BASIC TRAINING - INCOMING!", "HUD must announce incoming basic training")
	_check(wave_label.text == "WAVE 1 / 3" and remaining_label.text == "LEFT: 3", "HUD must show wave 1 and current-wave remaining")
	_check(not fire_button.disabled and reset_button.text == "RESET", "FIRE and RESET must be active during a wave")

	_check(encounter.bubble_at(0).attempt_castle_impact(castle), "one wave-1 leak must impact the persistent castle")
	_check(castle.current_health() == 1.0, "one leak must leave persistent castle health at one")
	var remaining_after_first: int = encounter.current_remaining_count()
	encounter._on_bubble_popped(&"enemy:basic:mixed_encounter:w01:s01")
	encounter._on_bubble_popped(&"enemy:foreign:mixed_encounter:w01:s99")
	_check(encounter.current_remaining_count() == remaining_after_first, "active duplicate and foreign POP callbacks must not change remaining truth")
	_spawn_next(encounter)
	_pierce(encounter.bubble_at(1))
	_spawn_next(encounter)
	_pierce(encounter.bubble_at(2))

	_check(encounter.current_state() == MixedEncounter.EncounterState.INTERMISSION, "wave 1 clear must enter INTERMISSION, not victory")
	_check(status_label.text == "BASIC TRAINING CLEAR!  NEXT: FAST BUBBLES", "intermission HUD must announce clear and warn about the next wave")
	_check(fire_button.disabled and reset_button.text == "RESET", "FIRE must disable during intermission without offering terminal retry")
	var intermission_left: float = encounter.seconds_until_next_event()
	encounter._physics_process(intermission_left - 0.001)
	_check(encounter.current_wave_number() == 1, "next wave must not begin before 2.25 seconds")
	encounter._physics_process(0.002)

	_check(encounter.current_wave_number() == 2, "intermission must advance exactly once to wave 2")
	_check(wave_events == ["1/3:BASIC TRAINING", "2/3:FAST BUBBLES"], "wave 2 must be announced exactly once")
	_check(encounter.current_spawned_count() == 1, "wave 2 must spawn only its authored t=0 Fast Bubble with no clock carry")
	_check(encounter.bubble_at(3).advance_speed_mps == 2.25, "wave 2 first slot must be Fast Bubble")
	_check(castle.current_health() == 1.0 and castle_label.text == "CASTLE: 1 / 2", "castle damage must persist into wave 2")
	encounter._physics_process(5.401)
	_check(encounter.current_spawned_count() == 4, "wave 2 long delta must catch up its four authored slots")
	var wave_two_remaining: int = encounter.current_remaining_count()
	encounter._on_bubble_popped(&"enemy:basic:mixed_encounter:w01:s03")
	encounter._on_bubble_popped(&"enemy:foreign:mixed_encounter:w02:s99")
	_check(encounter.current_remaining_count() == wave_two_remaining, "stale and foreign callbacks must not mutate wave 2")
	for index: int in range(3, 7):
		_pierce(encounter.bubble_at(index))
	_check(encounter.current_state() == MixedEncounter.EncounterState.INTERMISSION, "wave 2 clear must enter second intermission")

	encounter._physics_process(encounter.seconds_until_next_event() + 0.001)
	_check(encounter.current_wave_number() == 3 and encounter.current_spawned_count() == 1, "wave 3 must begin at authored zero without carry")
	encounter._physics_process(6.001)
	_check(encounter.current_spawned_count() == 5, "final wave must spawn exactly five threats")
	_assert_all_spawn_contracts(encounter)
	for index: int in range(7, 12):
		_pierce(encounter.bubble_at(index))

	_check(encounter.current_state() == MixedEncounter.EncounterState.WON, "clearing wave 3 with castle alive must win")
	_check(encounter.all_spawned_count() == 12, "encounter must spawn exactly twelve authored threats")
	_check(not castle.is_destroyed() and castle.current_health() == 1.0, "victory must preserve the same damaged castle")
	_check(status_label.text == "FINAL CLEAR - CASTLE HOLDS!", "HUD must render final victory")
	_check(fire_button.disabled and reset_button.text == "RETRY", "terminal victory must disable FIRE and offer RETRY")
	_check(wave_events == ["1/3:BASIC TRAINING", "2/3:FAST BUBBLES", "3/3:FINAL PUSH"], "all three wave announcements must emit exactly once")
	_check(state_events == [
		MixedEncounter.EncounterState.WAVE_ACTIVE,
		MixedEncounter.EncounterState.INTERMISSION,
		MixedEncounter.EncounterState.WAVE_ACTIVE,
		MixedEncounter.EncounterState.INTERMISSION,
		MixedEncounter.EncounterState.WAVE_ACTIVE,
		MixedEncounter.EncounterState.WON,
	], "victory state progression must be exact")
	_check(won_events == 1 and lost_events == 0, "victory fixture must emit WON once and LOST zero times")
	var won_remaining: int = encounter.current_remaining_count()
	encounter._on_bubble_popped(&"enemy:fast:mixed_encounter:w03:s05")
	encounter._on_bubble_popped(&"enemy:foreign:mixed_encounter:w03:s99")
	encounter._on_castle_destroyed(castle.chunk_id)
	encounter._physics_process(100.0)
	_check(encounter.current_state() == MixedEncounter.EncounterState.WON and encounter.current_remaining_count() == won_remaining, "post-WON callbacks must not mutate terminal truth")
	_check(encounter.all_spawned_count() == 12, "post-WON time must never spawn a thirteenth threat")
	_check(won_events == 1 and lost_events == 0, "post-WON callbacks must not repeat terminal signals")

	range_root.queue_free()
	await process_frame


func _prove_cross_wave_defeat_stops_future_threats() -> void:
	var range_root: Node3D = ENCOUNTER_SCENE.instantiate() as Node3D
	var ready_encounter: MixedEncounter = range_root.get_node("MixedEncounter") as MixedEncounter
	_reset_signal_log()
	_connect_encounter_signals(ready_encounter)
	get_root().add_child(range_root)
	await process_frame
	await process_frame

	var encounter: MixedEncounter = range_root.get_node("MixedEncounter") as MixedEncounter
	var castle: CastleChunk = range_root.get_node("CastleChunk") as CastleChunk
	var fire_button: Button = range_root.get_node("TouchHUD/TouchControls/FireButton") as Button
	var reset_button: Button = range_root.get_node("TouchHUD/TouchControls/ResetButton") as Button
	var status_label: Label = range_root.get_node("TouchHUD/EncounterHUD/StatusLabel") as Label
	encounter.set_physics_process(false)

	_check(encounter.bubble_at(0).attempt_castle_impact(castle), "wave-1 leak must damage castle")
	_spawn_next(encounter)
	_pierce(encounter.bubble_at(1))
	_spawn_next(encounter)
	_pierce(encounter.bubble_at(2))
	encounter._physics_process(encounter.seconds_until_next_event() + 0.001)

	_check(encounter.current_wave_number() == 2 and encounter.all_spawned_count() == 4, "loss fixture must reach wave 2 Fast Bubble")
	var remaining_before_stale: int = encounter.current_remaining_count()
	encounter._on_bubble_popped(&"enemy:basic:mixed_encounter:w01:s03")
	_check(encounter.current_remaining_count() == remaining_before_stale, "stale prior-wave POP must not alter active-wave truth")
	_spawn_next(encounter)
	var fast_leak: BasicBubble = encounter.bubble_at(3)
	var surviving_basic: BasicBubble = encounter.bubble_at(4)
	loss_order_encounter = encounter
	loss_remaining_before_impact = encounter.current_remaining_count()
	destroyed_before_pop_observed = false
	fast_leak.popped.connect(_on_loss_leak_popped)
	_check(fast_leak.attempt_castle_impact(castle), "wave-2 Fast Bubble leak must retain one IMPACT")

	_check(castle.is_destroyed(), "second encounter-wide leak must destroy persistent two-health castle")
	_check(encounter.current_state() == MixedEncounter.EncounterState.LOST, "castle destruction must defeat encounter immediately")
	_check(destroyed_before_pop_observed, "castle destruction must freeze survivors and enter LOST before the leaking bubble emits POP")
	_check(encounter.current_remaining_count() == loss_remaining_before_impact, "destroyed-before-POP ordering must freeze remaining truth")
	_check(not surviving_basic.advance_enabled, "defeat must stop a surviving active-wave bubble")
	_assert_live_survivors_stopped(encounter)
	var spawned_at_loss: int = encounter.all_spawned_count()
	encounter._physics_process(100.0)
	_check(encounter.all_spawned_count() == spawned_at_loss, "defeat must cancel current and future authored spawns")
	_check(status_label.text == "THE CASTLE FALLS!", "HUD must render defeat")
	_check(fire_button.disabled and reset_button.text == "RETRY", "defeat must disable FIRE and offer RETRY")
	_check(wave_events == ["1/3:BASIC TRAINING", "2/3:FAST BUBBLES"], "defeat fixture must announce only reached waves")
	_check(state_events == [
		MixedEncounter.EncounterState.WAVE_ACTIVE,
		MixedEncounter.EncounterState.INTERMISSION,
		MixedEncounter.EncounterState.WAVE_ACTIVE,
		MixedEncounter.EncounterState.LOST,
	], "defeat state progression must be exact")
	_check(lost_events == 1 and won_events == 0, "destroyed-before-POP loss must emit LOST once and WON zero times")
	var lost_remaining: int = encounter.current_remaining_count()
	encounter._on_bubble_popped(fast_leak.bubble_id)
	encounter._on_bubble_popped(surviving_basic.bubble_id)
	encounter._on_bubble_popped(&"enemy:foreign:mixed_encounter:w02:s99")
	encounter._on_castle_destroyed(castle.chunk_id)
	_check(encounter.current_state() == MixedEncounter.EncounterState.LOST and encounter.current_remaining_count() == lost_remaining, "post-LOST callbacks must not mutate terminal truth")
	_check(lost_events == 1 and won_events == 0, "post-LOST callbacks must not repeat terminal signals")

	range_root.queue_free()
	await process_frame


func _authored_schedule_is_exact(encounter: MixedEncounter) -> bool:
	if encounter.waves.size() != 3:
		return false
	var expected_kinds: Array = [
		[&"basic", &"basic", &"basic"],
		[&"fast", &"basic", &"fast", &"basic"],
		[&"fast", &"fast", &"basic", &"fast", &"fast"],
	]
	var expected_times: Array = [
		[0.0, 1.6, 3.2],
		[0.0, 1.2, 4.2, 5.4],
		[0.0, 0.9, 2.0, 5.1, 6.0],
	]
	var expected_titles: Array[String] = ["BASIC TRAINING", "FAST BUBBLES", "FINAL PUSH"]
	var expected_wave_ids: Array[StringName] = [
		&"wave:basic_training",
		&"wave:fast_bubbles",
		&"wave:final_push",
	]
	for wave_index: int in range(3):
		var wave: EncounterWavePlan = encounter.waves[wave_index]
		if wave.wave_id != expected_wave_ids[wave_index]:
			return false
		if wave.title != expected_titles[wave_index] or wave.spawns.size() != expected_kinds[wave_index].size():
			return false
		for slot_index: int in range(wave.spawns.size()):
			if wave.spawns[slot_index].kind != expected_kinds[wave_index][slot_index]:
				return false
			if not is_equal_approx(wave.spawns[slot_index].spawn_at_seconds, expected_times[wave_index][slot_index]):
				return false
	return true


func _assert_all_spawn_contracts(encounter: MixedEncounter) -> void:
	var expected_kinds: Array[StringName] = [
		&"basic", &"basic", &"basic",
		&"fast", &"basic", &"fast", &"basic",
		&"fast", &"fast", &"basic", &"fast", &"fast",
	]
	var expected_ids: Array[StringName] = [
		&"enemy:basic:mixed_encounter:w01:s01",
		&"enemy:basic:mixed_encounter:w01:s02",
		&"enemy:basic:mixed_encounter:w01:s03",
		&"enemy:fast:mixed_encounter:w02:s01",
		&"enemy:basic:mixed_encounter:w02:s02",
		&"enemy:fast:mixed_encounter:w02:s03",
		&"enemy:basic:mixed_encounter:w02:s04",
		&"enemy:fast:mixed_encounter:w03:s01",
		&"enemy:fast:mixed_encounter:w03:s02",
		&"enemy:basic:mixed_encounter:w03:s03",
		&"enemy:fast:mixed_encounter:w03:s04",
		&"enemy:fast:mixed_encounter:w03:s05",
	]
	_check(encounter.all_spawned_count() == expected_ids.size(), "all twelve authored slots must exist before contract inspection")
	for index: int in range(expected_ids.size()):
		var bubble: BasicBubble = encounter.bubble_at(index)
		_check(bubble != null, "every authored slot must instantiate a bubble")
		if bubble == null:
			continue
		_check(bubble.bubble_id == expected_ids[index], "every generated ID must encode exact wave and slot")
		var expects_fast: bool = expected_kinds[index] == &"fast"
		_check(bubble.has_node("FastBubbleFx") == expects_fast, "every slot must instantiate its authored Basic/Fast scene type")
		var expected_speed: float = 2.25 if expects_fast else 1.25
		_check(is_equal_approx(bubble.advance_speed_mps, expected_speed), "every slot must retain its authored type speed")


func _assert_live_survivors_stopped(encounter: MixedEncounter) -> void:
	var survivor_count: int = 0
	for index: int in range(encounter.all_spawned_count()):
		var bubble: BasicBubble = encounter.bubble_at(index)
		if bubble == null or bubble.is_popped():
			continue
		survivor_count += 1
		_check(not bubble.advance_enabled, "every live survivor must have advance disabled after defeat")
		var stopped_position: Vector3 = bubble.position
		bubble._physics_process(1.0)
		_check(bubble.position.is_equal_approx(stopped_position), "every live survivor position must remain unchanged after manual physics")
	_check(survivor_count > 0, "defeat fixture must exercise at least one live survivor")


func _reset_signal_log() -> void:
	state_events.clear()
	wave_events.clear()
	won_events = 0
	lost_events = 0
	destroyed_before_pop_observed = false
	loss_order_encounter = null
	loss_remaining_before_impact = 0


func _connect_encounter_signals(encounter: MixedEncounter) -> void:
	encounter.state_changed.connect(_on_state_changed)
	encounter.wave_changed.connect(_on_wave_changed)


func _on_state_changed(state: int) -> void:
	state_events.append(state)
	if state == MixedEncounter.EncounterState.WON:
		won_events += 1
	elif state == MixedEncounter.EncounterState.LOST:
		lost_events += 1


func _on_wave_changed(current_wave: int, total_waves: int, title: String) -> void:
	wave_events.append("%d/%d:%s" % [current_wave, total_waves, title])


func _on_loss_leak_popped(_bubble_id: StringName) -> void:
	if loss_order_encounter == null:
		return
	destroyed_before_pop_observed = loss_order_encounter.current_state() == MixedEncounter.EncounterState.LOST \
		and loss_order_encounter.current_remaining_count() == loss_remaining_before_impact
	for index: int in range(loss_order_encounter.all_spawned_count()):
		var bubble: BasicBubble = loss_order_encounter.bubble_at(index)
		if bubble != null and not bubble.is_popped():
			destroyed_before_pop_observed = destroyed_before_pop_observed and not bubble.advance_enabled


func _spawn_next(encounter: MixedEncounter) -> void:
	encounter._physics_process(encounter.seconds_until_next_event() + 0.001)


func _pierce(bubble: BasicBubble) -> void:
	var receiver: DamageReceiver = bubble.get_node("DamageReceiver") as DamageReceiver
	var request := DamageRequest.new(
		&"test:toothpick",
		bubble.bubble_id,
		1.0,
		DamageRequest.DamageType.PIERCE,
		bubble.global_position,
	)
	_check(receiver.request_damage(request), "PIERCE must cross the inherited bubble damage boundary")
	_check(bubble.is_popped(), "one PIERCE must resolve each authored bubble")


func _finish() -> void:
	if failures.is_empty():
		print("[DB:TEST:MIXED_ENCOUNTER] PASS")
		quit(0)
		return

	for failure: String in failures:
		push_error("[DB:TEST:MIXED_ENCOUNTER] %s" % failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
