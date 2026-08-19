extends SceneTree

# [DB:TEST:FIRST_UPGRADE_CHOICE]
# Deterministic proof that Wave 1 holds for one explicit upgrade choice and that
# each option changes the next-wave rules in the promised measurable way.

const RANGE_SCENE_PATH := "res://scenes/proof/mixed_encounter_range.tscn"
const TOOTHPICK_SCENE_PATH := "res://scenes/weapons/toothpick_projectile.tscn"
const HEAVY_SCENE_PATH := "res://scenes/enemies/heavy_bubble.tscn"
const SKEWER_ID: StringName = &"upgrade:weapon:skewer"
const SHELL_ID: StringName = &"upgrade:defense:shell_reinforcement"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await _test_skewer_choice()
	await _test_shell_choice()
	_finish()


func _test_skewer_choice() -> void:
	var range_root: Node3D = await _spawn_range()
	if range_root == null:
		return

	var encounter: MixedEncounter = range_root.get_node("MixedEncounter") as MixedEncounter
	var choice: FirstUpgradeChoice = range_root.get_node("FirstUpgradeChoice") as FirstUpgradeChoice
	var overlay: Control = range_root.get_node("TouchHUD/UpgradeHUD/ChoiceOverlay") as Control
	var active_label: Label = range_root.get_node("TouchHUD/UpgradeHUD/ActiveUpgradeLabel") as Label
	_check(encounter != null, "Skewer path requires MixedEncounter")
	_check(choice != null, "Skewer path requires FirstUpgradeChoice")
	_check(overlay != null, "Skewer path requires upgrade overlay")
	_check(active_label != null, "Skewer path requires active-upgrade label")
	if encounter == null or choice == null:
		range_root.queue_free()
		await process_frame
		return

	_resolve_wave_one(encounter)
	_check(encounter.current_state() == MixedEncounter.EncounterState.INTERMISSION, "Wave 1 clear must enter intermission")
	_check(choice.is_choice_pending(), "Wave 1 clear must require one upgrade choice")
	_check(encounter.is_intermission_held(), "Upgrade choice must hold the intermission clock")
	_check(overlay.visible, "Upgrade overlay must be visible while the choice is pending")

	var held_seconds: float = encounter.seconds_until_next_event()
	encounter._physics_process(20.0)
	_check(encounter.current_wave_number() == 1, "Held upgrade intermission must not advance waves")
	_check(
		is_equal_approx(encounter.seconds_until_next_event(), held_seconds),
		"Held upgrade intermission must not consume its authored delay",
	)

	_check(choice.choose_upgrade(SKEWER_ID), "Skewer must be selectable once")
	_check(choice.selected_upgrade_id() == SKEWER_ID, "Skewer stable ID must become run truth")
	_check(is_equal_approx(choice.weapon_damage_bonus(), 1.0), "Skewer must add exactly one damage")
	_check(choice.projectile_length_scale() >= 1.5, "Skewer must visibly lengthen the projectile")
	_check(not choice.is_choice_pending(), "Skewer selection must close the pending choice")
	_check(not encounter.is_intermission_held(), "Skewer selection must release intermission")
	_check(not choice.choose_upgrade(SHELL_ID), "A run may not take both first-choice upgrades")
	_check(not overlay.visible, "Upgrade overlay must hide after selection")
	_check(active_label.visible and active_label.text.contains("SKEWER"), "HUD must retain the selected upgrade read")

	encounter._physics_process(MixedEncounter.INTERMISSION_SECONDS + 0.01)
	_check(encounter.current_wave_number() == 2, "Released intermission must advance to Wave 2")
	_check(encounter.current_state() == MixedEncounter.EncounterState.WAVE_ACTIVE, "Wave 2 must become active after release")

	var heavy_scene: PackedScene = load(HEAVY_SCENE_PATH) as PackedScene
	var toothpick_scene: PackedScene = load(TOOTHPICK_SCENE_PATH) as PackedScene
	_check(heavy_scene != null, "Heavy scene must load for Skewer proof")
	_check(toothpick_scene != null, "Toothpick scene must load for Skewer proof")
	if heavy_scene != null and toothpick_scene != null:
		var heavy: BasicBubble = heavy_scene.instantiate() as BasicBubble
		get_root().add_child(heavy)
		for hit_index: int in range(3):
			var projectile: ToothpickProjectile = toothpick_scene.instantiate() as ToothpickProjectile
			_check(choice.configure_projectile(projectile), "Skewer must configure each new projectile")
			_check(is_equal_approx(projectile.damage_amount, 2.0), "Skewer projectile must deal two damage")
			_check(projectile.length_scale >= 1.5, "Skewer projectile must keep its longer silhouette")
			get_root().add_child(projectile)
			projectile.global_position = heavy.global_position
			_check(projectile.attempt_hit(heavy), "Configured Skewer hit must route through DamageReceiver")
			if hit_index < 2:
				_check(not heavy.is_popped(), "Five-health Big Blub must survive the first two Skewer hits")
		_check(heavy.is_popped(), "Five-health Big Blub must pop on the third two-damage Skewer hit")

	range_root.queue_free()
	await process_frame


func _test_shell_choice() -> void:
	var range_root: Node3D = await _spawn_range()
	if range_root == null:
		return

	var encounter: MixedEncounter = range_root.get_node("MixedEncounter") as MixedEncounter
	var choice: FirstUpgradeChoice = range_root.get_node("FirstUpgradeChoice") as FirstUpgradeChoice
	var castle: CastleChunk = range_root.get_node("CastleChunk") as CastleChunk
	var overlay: Control = range_root.get_node("TouchHUD/UpgradeHUD/ChoiceOverlay") as Control
	var active_label: Label = range_root.get_node("TouchHUD/UpgradeHUD/ActiveUpgradeLabel") as Label
	_check(encounter != null, "Shell path requires MixedEncounter")
	_check(choice != null, "Shell path requires FirstUpgradeChoice")
	_check(castle != null, "Shell path requires CastleChunk")
	if encounter == null or choice == null or castle == null:
		range_root.queue_free()
		await process_frame
		return

	_resolve_wave_one(encounter)
	_check(choice.is_choice_pending(), "Shell path must reach the same one-choice gate")
	_check(choice.choose_upgrade(SHELL_ID), "Shell Reinforcement must be selectable once")
	_check(choice.selected_upgrade_id() == SHELL_ID, "Shell stable ID must become run truth")
	_check(is_equal_approx(castle.max_health, 3.0), "Shell Reinforcement must raise maximum durability from 2 to 3")
	_check(is_equal_approx(castle.current_health(), 3.0), "Shell Reinforcement must add one current durability")
	_check(not castle.is_destroyed(), "Reinforcement cannot destroy the castle")
	_check(not overlay.visible, "Shell selection must close the upgrade overlay")
	_check(active_label.visible and active_label.text.contains("SHELL"), "HUD must retain the Shell upgrade read")
	_check(not choice.choose_upgrade(SKEWER_ID), "Shell path may not also take Skewer")

	_check(_impact_castle(castle, &"enemy:test:leak:01"), "First post-upgrade IMPACT request must route")
	_check(is_equal_approx(castle.current_health(), 2.0), "First leak after Shell must leave two durability")
	_check(not castle.is_destroyed(), "First leak after Shell must be recoverable")
	_check(_impact_castle(castle, &"enemy:test:leak:02"), "Second post-upgrade IMPACT request must route")
	_check(is_equal_approx(castle.current_health(), 1.0), "Second leak after Shell must leave one durability")
	_check(not castle.is_destroyed(), "Second leak after Shell must still leave the castle standing")
	_check(_impact_castle(castle, &"enemy:test:leak:03"), "Third post-upgrade IMPACT request must route")
	_check(castle.is_destroyed(), "Third lifetime leak after Shell must destroy the three-durability castle")

	range_root.queue_free()
	await process_frame


func _spawn_range() -> Node3D:
	var range_scene: PackedScene = load(RANGE_SCENE_PATH) as PackedScene
	_check(range_scene != null, "Mixed encounter range must load")
	if range_scene == null:
		return null
	var range_root: Node3D = range_scene.instantiate() as Node3D
	_check(range_root != null, "Mixed encounter range must instantiate")
	if range_root == null:
		return null
	get_root().add_child(range_root)
	await process_frame
	await process_frame
	var encounter: MixedEncounter = range_root.get_node("MixedEncounter") as MixedEncounter
	if encounter != null:
		encounter.set_physics_process(false)
	return range_root


func _resolve_wave_one(encounter: MixedEncounter) -> void:
	encounter._physics_process(3.25)
	_check(encounter.all_spawned_count() == 3, "Wave 1 must spawn its three authored Basic bubbles")
	var toothpick_scene: PackedScene = load(TOOTHPICK_SCENE_PATH) as PackedScene
	_check(toothpick_scene != null, "Base toothpick scene must load")
	if toothpick_scene == null:
		return

	for bubble_index: int in range(3):
		var bubble: BasicBubble = encounter.bubble_at(bubble_index)
		_check(bubble != null, "Wave 1 bubble %d must exist" % bubble_index)
		if bubble == null:
			continue
		var projectile: ToothpickProjectile = toothpick_scene.instantiate() as ToothpickProjectile
		get_root().add_child(projectile)
		projectile.global_position = bubble.global_position
		_check(projectile.attempt_hit(bubble), "Base toothpick must resolve Wave 1 bubble %d" % bubble_index)


func _impact_castle(castle: CastleChunk, source_id: StringName) -> bool:
	var request := DamageRequest.new(
		source_id,
		castle.damage_receiver.target_id,
		1.0,
		DamageRequest.DamageType.IMPACT,
		castle.global_position,
	)
	return castle.damage_receiver.request_damage(request)


func _finish() -> void:
	if failures.is_empty():
		print("[DB:TEST:FIRST_UPGRADE_CHOICE] PASS")
		quit(0)
		return

	for failure: String in failures:
		push_error("[DB:TEST:FIRST_UPGRADE_CHOICE] %s" % failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
