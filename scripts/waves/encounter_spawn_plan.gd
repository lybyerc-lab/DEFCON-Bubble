class_name EncounterSpawnPlan
extends Resource

# [DB:DATA:ENCOUNTER_SPAWN_PLAN]
# One authored spawn in the bounded mixed encounter. No weights or conditions.

@export var kind: StringName
@export var spawn_at_seconds: float = 0.0
# [DB:PLAYER:WALL_DEFENDER]
# Where along the wall's depth this spawn arrives, relative to the spawn marker.
# Zero keeps the accepted single-file behaviour, so an unedited wave is unchanged.
@export var spawn_depth_meters: float = 0.0
