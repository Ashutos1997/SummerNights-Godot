extends Node

const LEVEL_CONFIG = {
	1: {
		"timer": 45.0,
		"sun_sway_amplitude": 0.0,
		"sun_sway_speed": 0.0,
		"sun_figure8": false,
		"heat_regen_base": 2.0,
		"water_drain": 8.75,
		"two_phase": false,
		"phase2_heat": 0.0,
	},
	2: {
		"timer": 40.0,
		"sun_sway_amplitude": 3.0,
		"sun_sway_speed": 0.8,
		"sun_figure8": false,
		"heat_regen_base": 3.0,
		"water_drain": 8.75,
		"two_phase": false,
		"phase2_heat": 0.0,
	},
	3: {
		"timer": 40.0,
		"sun_sway_amplitude": 5.0,
		"sun_sway_speed": 1.0,
		"sun_figure8": false,
		"heat_regen_base": 4.0,
		"water_drain": 10.0,
		"two_phase": false,
		"phase2_heat": 0.0,
	},
	4: {
		"timer": 40.0,
		"sun_sway_amplitude": 5.0,
		"sun_sway_speed": 1.2,
		"sun_figure8": true,
		"heat_regen_base": 5.0,
		"water_drain": 11.0,
		"two_phase": false,
		"phase2_heat": 0.0,
	},
	5: {
		"timer": 90.0,
		"sun_sway_amplitude": 6.0,
		"sun_sway_speed": 1.5,
		"sun_figure8": true,
		"heat_regen_base": 6.0,
		"water_drain": 11.0,
		"two_phase": true,
		"phase2_heat": 60.0,
	},
}

var level: int = 1
var sfx_volume: float = 1.0
var mouse_sensitivity: float = 1.0
var reduce_motion: bool = false
var fullscreen: bool = false
var language: String = "EN"  # "EN" or "KR"

func reset() -> void:
	level = 1
	# language intentionally not reset — persists across playthroughs
