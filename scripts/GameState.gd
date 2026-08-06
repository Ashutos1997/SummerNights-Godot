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
		"water_drain": 3.5,
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
		"water_drain": 7.5,
		"cooling_power": 38.0,
		"crit_multiplier": 1.0,
		"recharge_rate": 12.0,
		"unlock_level": 3
	},
	"precision": {
		"name": "Precision Stream",
		"model": "res://assets/blaster.glb",
		"scale": Vector3(0.5, 0.5, 1.5),
		"water_capacity": 60.0,
		"water_drain": 2.0,
		"cooling_power": 8.0,
		"crit_multiplier": 5.5,
		"recharge_rate": 15.0,
		"unlock_level": 2
	},
	"scatter": {
		"name": "Scatter Nozzle",
		"model": "res://assets/blaster.glb",
		"scale": Vector3(1, 1, 1),
		"water_capacity": 150.0,
		"water_drain": 4.5,
		"cooling_power": 45.0,
		"crit_multiplier": 1.0,
		"recharge_rate": 14.0,
		"unlock_level": 4
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
var is_dev_mode: bool = false
var current_wave: int = 1
var survival_time: float = 0.0
var best_survival_time: float = 0.0

const SETTINGS_FILE_PATH = "user://settings.cfg"

# Shop Upgrades
var max_water_mult: float = 1.0
var cooling_power_mult: float = 1.0
var heat_resistance: float = 0.0
var bonus_ice_charges: int = 0

func reset() -> void:
	level = 1
	ice_charges_remaining = 0
	current_wave = 1
	survival_time = 0.0
	
	max_water_mult = 1.0
	cooling_power_mult = 1.0
	heat_resistance = 0.0
	bonus_ice_charges = 0

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("Audio", "sfx_volume", sfx_volume)
	config.set_value("Controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("Accessibility", "reduce_motion", reduce_motion)
	config.set_value("Video", "fullscreen", fullscreen)
	config.set_value("Localization", "language", language)
	config.set_value("Stats", "best_survival_time", best_survival_time)
	config.save(SETTINGS_FILE_PATH)

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(SETTINGS_FILE_PATH) == OK:
		sfx_volume = config.get_value("Audio", "sfx_volume", 1.0)
		mouse_sensitivity = config.get_value("Controls", "mouse_sensitivity", 1.0)
		reduce_motion = config.get_value("Accessibility", "reduce_motion", false)
		fullscreen = config.get_value("Video", "fullscreen", false)
		language = config.get_value("Localization", "language", "EN")
		best_survival_time = config.get_value("Stats", "best_survival_time", 0.0)
		
		# Apply loaded fullscreen state immediately
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
