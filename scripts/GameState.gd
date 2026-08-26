extends Node

signal score_updated(new_score: int)
signal achievement_unlocked(id)
signal buff_unlocked(id)

const ACHIEVEMENTS: Dictionary = {
	"dawn_breaks": {
		"icon": "res://assets/ui/achievements/sunset.png",
		"title_en": "Dawn Breaks",
		"title_kr": "새벽이 밝다",
		"desc_en": "Beat Level 5 in Normal Mode.",
		"desc_kr": "일반 모드에서 레벨 5를 클리어하세요."
	},
	"arcade_legend": {
		"icon": "res://assets/ui/achievements/trophy.png",
		"title_en": "Arcade Legend",
		"title_kr": "아케이드 전설",
		"desc_en": "Score over 10,000 points in a single run.",
		"desc_kr": "한 게임에서 10,000점 이상을 달성하세요."
	},
	"slam_dunk": {
		"icon": "res://assets/ui/achievements/water-splash.png",
		"title_en": "Slam Dunk",
		"title_kr": "슬램 덩크",
		"desc_en": "Successfully use the Catastrom ultimate.",
		"desc_kr": "카타스트롬 궁극기를 성공적으로 사용하세요."
	},
	"untouchable": {
		"icon": "res://assets/ui/achievements/water-recycling.png",
		"title_en": "Untouchable",
		"title_kr": "언터처블",
		"desc_en": "Reach the maximum 3.0x Water Combo multiplier.",
		"desc_kr": "최대 3.0배의 물줄기 콤보 배율에 도달하세요."
	},
	"rock_solid": {
		"icon": "res://assets/ui/achievements/ball-glow.png",
		"title_en": "Rock Solid",
		"title_kr": "단단한 바위",
		"desc_en": "Evaporate a Magma Rock using the water gun.",
		"desc_kr": "물총을 사용하여 마그마 파편을 증발시키세요."
	},
	"shadow_walker": {
		"icon": "res://assets/ui/achievements/eclipse.png",
		"title_en": "Shadow Walker",
		"title_kr": "그림자 걷는 자",
		"desc_en": "Survive a Solar Eclipse.",
		"desc_kr": "일식 이벤트에서 생존하세요."
	},
	"bird_watcher": {
		"icon": "res://assets/ui/achievements/seagull.png",
		"title_en": "Shoo!",
		"title_kr": "훠이!",
		"desc_en": "Shoo away 50 seagulls.",
		"desc_kr": "갈매기 50마리를 쫓아내세요."
	},
	"flare_catcher": {
		"icon": "res://assets/ui/achievements/fireball.png",
		"title_en": "Flare Catcher",
		"title_kr": "플레어 사냥꾼",
		"desc_en": "Intercept 10 Solar Flares.",
		"desc_kr": "태양 플레어를 10회 요격하세요."
	}
}

const BUFFS: Dictionary = {
	"tank_upgrade": {
		"icon": "res://assets/ui/achievements/water-recycling.png",
		"title_en": "Deep Reserves",
		"title_kr": "깊은 저장고",
		"desc_en": "Max Water Tank capacity is permanently increased.",
		"desc_kr": "최대 물탱크 용량이 영구적으로 증가했습니다."
	},
	"cooling_upgrade": {
		"icon": "res://assets/ui/achievements/water-splash.png",
		"title_en": "Liquid Nitrogen",
		"title_kr": "액체 질소",
		"desc_en": "Water gun cooling power is permanently increased.",
		"desc_kr": "물총의 냉각력이 영구적으로 증가했습니다."
	},
	"ice_upgrade": {
		"icon": "res://assets/ui/ui_adventure/PNG/Default/minimap_icon_star_white.png",
		"title_en": "Extra Ice Charge",
		"title_kr": "추가 얼음 충전",
		"desc_en": "Spawn with an additional Ice Burst charge.",
		"desc_kr": "얼음 폭발 스킬이 1회 추가 충전된 상태로 시작합니다."
	},
	"gold_weapon": {
		"icon": "res://assets/ui/achievements/trophy.png",
		"title_en": "Solid Gold",
		"title_kr": "순금",
		"desc_en": "All weapons are forged from solid gold.",
		"desc_kr": "모든 무기가 순금으로 도금됩니다."
	},
	"catastrom_buff": {
		"icon": "res://assets/ui/achievements/water-splash.png",
		"title_en": "Catastrom Flow",
		"title_kr": "카타스트롬 흐름",
		"desc_en": "Increases Catastrom charge rate by 10%.",
		"desc_kr": "카타스트롬 충전 속도가 10% 증가합니다."
	},
	"combo_grace": {
		"icon": "res://assets/ui/achievements/water-recycling.png",
		"title_en": "Combo Grace",
		"title_kr": "콤보 유예",
		"desc_en": "Combo pauses an extra 0.5s before decaying.",
		"desc_kr": "콤보가 감소하기 전 0.5초의 추가 유예 시간이 주어집니다."
	},
	"flare_boost": {
		"icon": "res://assets/ui/achievements/fireball.png",
		"title_en": "Flare Refill Boost",
		"title_kr": "플레어 충전 부스트",
		"desc_en": "Intercepting flares refills 40% water (up from 30%).",
		"desc_kr": "플레어 요격 시 물이 30%가 아닌 40% 충전됩니다."
	},
	"heat_resist": {
		"icon": "res://assets/ui/achievements/ball-glow.png",
		"title_en": "Heat Resistance",
		"title_kr": "열 저항",
		"desc_en": "Permanent 5% Heat Resistance across all waves.",
		"desc_kr": "모든 웨이브에서 열 저항이 5% 증가합니다."
	},
	"featherweight": {
		"icon": "res://assets/ui/achievements/seagull.png",
		"title_en": "Featherweight",
		"title_kr": "깃털 같은 가벼움",
		"desc_en": "Weapon swaps are 50% faster, and sun sway is reduced.",
		"desc_kr": "무기 교체가 50% 빨라지고 태양의 흔들림이 감소합니다."
	},
	"eclipse_timer": {
		"icon": "res://assets/ui/achievements/eclipse.png",
		"title_en": "Eclipse Warning",
		"title_kr": "일식 경고",
		"desc_en": "Displays a precise countdown timer during Eclipses.",
		"desc_kr": "일식 이벤트 동안 정확한 카운트다운 타이머가 표시됩니다."
	}
}

var unlocked_achievements: Array[String] = []
var is_retrying: bool = false
var has_completed_tutorial: bool = false

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
		"weather_weights": {"none": 60, "rain": 40, "eclipse": 0},
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
		"weather_weights": {"none": 30, "rain": 50, "eclipse": 20},
	},
	3: {
		"timer": 45.0,
		"sun_sway_amplitude": 5.0,
		"sun_sway_speed": 1.0,
		"sun_figure8": false,
		"heat_regen_base": 4.8,
		"water_drain": 10.0,
		"two_phase": false,
		"phase2_heat": 0.0,
		"ice_charges": 3,
		"solar_wind": false,
		"weather_weights": {"none": 30, "rain": 50, "eclipse": 20},
	},
	4: {
		"timer": 45.0,
		"sun_sway_amplitude": 5.0,
		"sun_sway_speed": 1.3,
		"sun_figure8": true,
		"heat_regen_base": 6.5,
		"water_drain": 11.0,
		"two_phase": false,
		"phase2_heat": 0.0,
		"ice_charges": 3,
		"solar_wind": true,
		"weather_weights": {"none": 20, "rain": 40, "eclipse": 40},
	},
	5: {
		"timer": 90.0,
		"sun_sway_amplitude": 6.0,
		"sun_sway_speed": 1.5,
		"sun_figure8": true,
		"heat_regen_base": 7.5,
		"water_drain": 11.0,
		"two_phase": true,
		"phase2_heat": 75.0,
		"ice_charges": 5,
		"solar_wind": true,
		"weather_weights": {"none": 0, "rain": 20, "eclipse": 80},
	},
	6: {
		"timer": 120.0,
		"sun_sway_amplitude": 7.5,
		"sun_sway_speed": 1.8,
		"sun_figure8": true,
		"heat_regen_base": 8.5,
		"water_drain": 12.0,
		"two_phase": true,
		"phase2_heat": 100.0,
		"ice_charges": 6,
		"solar_wind": true,
		"has_mirage": true,
		"weather_weights": {"none": 50, "rain": 0, "eclipse": 50},
	},
}

const WEAPONS = {
	"standard": {
		"name": "Standard Blaster",
		"model": "res://assets/blaster.glb",
		"scale": Vector3(1, 1, 1),
		"water_capacity": 100.0,
		"water_drain": 3.5,
		"cooling_power": 18.0,
		"crit_multiplier": 2.0,
		"recharge_rate": 18.0,
		"unlock_level": 1
	},
	"heavy": {
		"name": "Heavy Cannon",
		"model": "res://assets/blaster.glb",
		"scale": Vector3(1.5, 1.5, 1.5),
		"water_capacity": 200.0,
		"water_drain": 8.5,
		"cooling_power": 32.0,
		"crit_multiplier": 1.0,
		"recharge_rate": 12.0,
		"unlock_level": 3
	},
	"precision": {
		"name": "Precision Stream",
		"model": "res://assets/blaster.glb",
		"scale": Vector3(0.5, 0.5, 1.5),
		"water_capacity": 75.0,
		"water_drain": 2.0,
		"cooling_power": 12.0,
		"crit_multiplier": 4.0,
		"recharge_rate": 15.0,
		"unlock_level": 2
	},
	"scatter": {
		"name": "Scatter Nozzle",
		"model": "res://assets/blaster_scatter.glb",
		"scale": Vector3(1, 1, 1),
		"water_capacity": 100.0,
		"water_drain": 6.5,
		"cooling_power": 22.0,
		"crit_multiplier": 1.0,
		"recharge_rate": 10.0,
		"unlock_level": 4
	},
	"tidal": {
		"name": "Tidal Gatling",
		"model": "res://assets/blaster_gatling.glb",
		"scale": Vector3(1.2, 1.2, 1.5),
		"water_capacity": 250.0,
		"water_drain": 25.0,
		"cooling_power": 40.0,
		"crit_multiplier": 1.0,
		"recharge_rate": 8.0,
		"unlock_achievement": "arcade_legend"
	}
}

var current_weapon_id: String = "standard"
var level: int = 1
var sfx_volume: float = 1.0
var mouse_sensitivity: float = 1.0
var reduce_motion: bool = false
var vibration_enabled: bool = true
var fullscreen: bool = true
var language: String = "EN"  # "EN" or "KR"
var ice_charges_remaining: int = 0
var is_survival_mode: bool = false
var is_dev_mode: bool = false
var current_wave: int = 1
var survival_time: float = 0.0
var best_survival_time: float = 0.0
var current_score: int = 0
var high_score: int = 0
var seagulls_shooed: int = 0
var flares_intercepted: int = 0

const SETTINGS_FILE_PATH = "user://settings.cfg"

# Shop Upgrades
var max_water_mult: float = 1.0
var cooling_power_mult: float = 1.0
var heat_resistance: float = 0.0
var bonus_ice_charges: int = 0
var catastrom_charge: float = 0.0

func reset() -> void:
	level = 1
	ice_charges_remaining = 0
	current_wave = 1
	survival_time = 0.0
	current_score = 0
	
	max_water_mult = 1.0
	cooling_power_mult = 1.0
	heat_resistance = 0.0
	bonus_ice_charges = 0
	catastrom_charge = 0.0

func _ready() -> void:
	load_settings()
	_evaluate_milestones()

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("Audio", "sfx_volume", sfx_volume)
	config.set_value("Controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("Accessibility", "reduce_motion", reduce_motion)
	config.set_value("Accessibility", "vibration_enabled", vibration_enabled)
	config.set_value("Video", "fullscreen", fullscreen)
	config.set_value("Localization", "language", language)
	config.set_value("Stats", "high_score", high_score)
	config.set_value("Stats", "unlocked_achievements", unlocked_achievements)
	config.set_value("Stats", "seagulls_shooed", seagulls_shooed)
	config.set_value("Stats", "flares_intercepted", flares_intercepted)
	config.set_value("Stats", "has_completed_tutorial", has_completed_tutorial)
	config.save(SETTINGS_FILE_PATH)

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(SETTINGS_FILE_PATH) == OK:
		sfx_volume = config.get_value("Audio", "sfx_volume", 1.0)
		mouse_sensitivity = config.get_value("Controls", "mouse_sensitivity", 1.0)
		reduce_motion = config.get_value("Accessibility", "reduce_motion", false)
		vibration_enabled = config.get_value("Accessibility", "vibration_enabled", true)
		fullscreen = config.get_value("Video", "fullscreen", true)
		language = config.get_value("Localization", "language", "EN")
		best_survival_time = config.get_value("Stats", "best_survival_time", 0.0)
		high_score = config.get_value("Stats", "high_score", 0)
		seagulls_shooed = config.get_value("Stats", "seagulls_shooed", 0)
		flares_intercepted = config.get_value("Stats", "flares_intercepted", 0)
		has_completed_tutorial = config.get_value("Stats", "has_completed_tutorial", false)
		var loaded_achievements = config.get_value("Stats", "unlocked_achievements", [])
		unlocked_achievements.assign(loaded_achievements)
		
		# Apply loaded fullscreen state immediately only if it differs from current mode
		var current_mode = DisplayServer.window_get_mode()
		var is_currently_fullscreen = (current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN or current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		
		if fullscreen and not is_currently_fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		elif not fullscreen and is_currently_fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(1280, 720))
			var screen = DisplayServer.window_get_current_screen()
			var screen_size = DisplayServer.screen_get_size(screen)
			DisplayServer.window_set_position(screen_size / 2 - Vector2i(1280, 720) / 2)

func add_score(amount: int) -> void:
	if amount <= 0: return
	current_score += amount
	if current_score > high_score:
		var old_high = high_score
		high_score = current_score
		_evaluate_milestones(old_high)
	emit_signal("score_updated", current_score)
	
	if current_score >= 10000:
		unlock_achievement("arcade_legend")

func _evaluate_milestones(old_high: int = -1) -> void:
	# Base values
	max_water_mult = 1.0
	cooling_power_mult = 1.0
	bonus_ice_charges = 0
	heat_resistance = 0.05 if "rock_solid" in unlocked_achievements else 0.0
	
	if high_score >= 5000:
		max_water_mult = 1.1
		if old_high >= 0 and old_high < 5000: emit_signal("buff_unlocked", "tank_upgrade")
	if high_score >= 15000:
		cooling_power_mult = 1.1
		if old_high >= 0 and old_high < 15000: emit_signal("buff_unlocked", "cooling_upgrade")
	if high_score >= 20000:
		bonus_ice_charges = 1
		if old_high >= 0 and old_high < 20000: emit_signal("buff_unlocked", "ice_upgrade")
	if high_score >= 50000:
		if old_high >= 0 and old_high < 50000: emit_signal("buff_unlocked", "gold_weapon")

func unlock_achievement(id: String) -> void:
	if id in unlocked_achievements: return
	if not ACHIEVEMENTS.has(id): return
	
	unlocked_achievements.append(id)
	save_settings()
	emit_signal("achievement_unlocked", id)
