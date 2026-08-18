extends Node3D

# [DB:CORE:GAME_ROOT]
# Owns only top-level run boot/restart coordination at Foundation 0.

const RESTART_ACTION: StringName = &"restart_run"

@onready var beach_arena: Node3D = $BeachArena


func _ready() -> void:
	assert(beach_arena != null, "[DB:CORE:GAME_ROOT] BeachArena is required.")
	print("[DB:CORE:GAME_ROOT] Foundation boot ready.")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(RESTART_ACTION):
		get_viewport().set_input_as_handled()
		call_deferred("_restart_run")


func _restart_run() -> void:
	if get_tree().current_scene == null:
		push_error("[DB:CORE:GAME_ROOT] Cannot restart without a current scene.")
		return

	var reload_error: Error = get_tree().reload_current_scene()
	if reload_error != OK:
		push_error("[DB:CORE:GAME_ROOT] Restart failed with error %s." % reload_error)
