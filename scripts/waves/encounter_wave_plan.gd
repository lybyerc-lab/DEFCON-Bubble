class_name EncounterWavePlan
extends Resource

# [DB:DATA:ENCOUNTER_WAVE_PLAN]
# Ordered authored spawns for one wave in the bounded mixed encounter.

@export var wave_id: StringName
@export var title: String = ""
@export var spawns: Array[EncounterSpawnPlan] = []
