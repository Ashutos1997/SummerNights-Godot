extends Node

var level: int = 1
var sfx_volume: float = 1.0
var mouse_sensitivity: float = 1.0
var reduce_motion: bool = false
var fullscreen: bool = false
var language: String = "EN"  # "EN" or "KR"

func reset() -> void:
	level = 1
	# language intentionally not reset — persists across playthroughs
