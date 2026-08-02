extends Node

const LEVEL_CONFIG = {
	1: {
		"timer": 45.0,
		"sun_sway_amplitude": 0.0,
		"sun_sway_speed": 0.0,
		"sun_figure8": false,
		"heat_regen_base": 2.5,
		"water_drain": 8.75,
		"two_phase": false,
		"phase2_heat": 0.0,
		"ice_charges": 0,
		"solar_wind": false,
	},
	2: {
		"timer": 45.0,
		"sun_sway_amplitude": 3.0,
		"sun_sway_speed": 0.8,
		"sun_figure8": false,
		"heat_regen_base": 3.5,
		"water_drain": 8.75,
		"two_phase": false,
		"phase2_heat": 0.0,
		"ice_charges": 0,
		"solar_wind": false,
	},
	3: {
		"timer": 45.0,
		"sun_sway_amplitude": 5.0,
		"sun_sway_speed": 1.0,
		"sun_figure8": false,
		"heat_regen_base": 4.5,
		"water_drain": 10.0,
		"two_phase": false,
		"phase2_heat": 0.0,
		"ice_charges": 3,
		"solar_wind": false,
	},
	4: {
		"timer": 45.0,
		"sun_sway_amplitude": 5.0,
		"sun_sway_speed": 1.2,
		"sun_figure8": true,
		"heat_regen_base": 6.0,
		"water_drain": 11.0,
		"two_phase": false,
		"phase2_heat": 0.0,
		"ice_charges": 3,
		"solar_wind": true,
	},
	5: {
		"timer": 90.0,
		"sun_sway_amplitude": 6.0,
		"sun_sway_speed": 1.5,
		"sun_figure8": true,
		"heat_regen_base": 8.0,
		"water_drain": 11.0,
		"two_phase": true,
		"phase2_heat": 60.0,
		"ice_charges": 5,
		"solar_wind": true,
	},
}

const WEAPONS = {
	"standard": {
		"name": "Standard Blaster",
		"model": "res://assets/blaster.glb",
		"scale": Vector3(1, 1, 1),
		"water_capacity": 100.0,
		"water_drain": 1.0,
		"cooling_power": 15.0,
		"crit_multiplier": 2.0,
		"recharge_rate": 18.0,
		"unlock_level": 1
	},
	"heavy": {
		"name": "Heavy Cannon",
		"model": "res://assets/blaster.glb",
		"scale": Vector3(1.5, 1.5, 1.5),
		"water_capacity": 200.0,
		"water_drain": 1.8,
		"cooling_power": 28.0,
		"crit_multiplier": 1.1,
		"recharge_rate": 12.0,
		"unlock_level": 3
	},
	"precision": {
		"name": "Precision Stream",
		"model": "res://assets/blaster.glb",
		"scale": Vector3(0.5, 0.5, 1.5),
		"water_capacity": 60.0,
		"water_drain": 0.7,
		"cooling_power": 8.0,
		"crit_multiplier": 4.5,
		"recharge_rate": 15.0,
		"unlock_level": 2
	}
}

var current_weapon_id: String = "standard"
var level: int = 1
var sfx_volume: float = 1.0
var mouse_sensitivity: float = 1.0
var reduce_motion: bool = false
var fullscreen: bool = false
var language: String = "EN"  # "EN" or "KR"
var ice_charges_remaining: int = 0
var is_survival_mode: bool = false

func reset() -> void:
	level = 1
	ice_charges_remaining = 0
