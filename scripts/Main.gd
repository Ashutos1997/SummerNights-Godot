extends Node3D
## Summer Nights 3D - Water Gun vs The Sun

# ─── Game State ──────────────────────────────────────────────────────────────
var temperature: float    = 100.0
const MAX_TEMP: float     = 100.0
var water_tank: float     = 100.0
var MAX_WATER: float      = 100.0
var current_weapon_power: float = 14.0
var current_weapon_crit: float = 2.0
var current_weapon_recharge: float = 15.0
var WATER_DRAIN_RATE: float = 8.75 # Base drain rate
var is_shooting: bool     = false
var is_firing: bool       = false
var fire_stop_timer: float = 0.0
const FIRE_STOP_DELAY: float = 0.12
var hit_cooldown: float    = 0.0
const HIT_COOLDOWN: float  = 0.08
var can_shoot: bool       = true
var game_over: bool       = false
var defeat_triggered: bool = false
signal heat_changed(value: float, max_value: float)
signal water_changed(value: float, max_value: float)
signal sun_defeated(level: int)
signal game_complete()
signal projectile_hit()
signal level_config_loaded(timer_duration: float)
signal timer_tick(seconds_remaining: float)
signal timer_expired()
signal phase2_started()
var hud: CanvasLayer
var shoot_loop_sfx: AudioStreamPlayer
var hit_sfx: AudioStreamPlayer
var sun_defeated_sfx: AudioStreamPlayer
var water_empty_sfx: AudioStreamPlayer
var ambient_sfx: AudioStreamPlayer
var sun_hit_tween: Tween
var is_shaking: bool = false
var level: int            = 1
var mouse_sensitivity: float = 1.0
var reduce_motion: bool   = false
signal crosshair_moved(screen_pos: Vector2, is_behind: bool)

# ─── Diagnostics & Testing ──────────────────────────────────────────────────
var cooldown_timer: float = 0.0
var is_measuring: bool = false
var water_refill_count: int = 0

# ─── New Level Config Variables ──────────────────────────────────────────────
var current_config: Dictionary = {}
var heat_regen_base: float = 2.0
var sun_sway_amplitude: float = 0.0
var sun_sway_speed: float = 0.0
var sun_figure8: bool = false
var sun_move_time: float = 0.0
var level_timer: float = 0.0
var wave_timer: float = 0.0
var timer_running: bool = false
var max_survival_ice_charges: int = 3
var is_two_phase: bool = false
var phase2_triggered: bool = false
var phase2_heat: float = 0.0

# ─── Solar Wind Hazard ───────────────────────────────────────────────────────
var solar_wind_enabled: bool = false
var wind_state: int = 0  # 0=idle, 1=warning, 2=active
var wind_timer: float = 0.0
var wind_direction: float = 0.0  # -1.0 or 1.0
var wind_strength: float = 0.0  # Current drift force (pixels/sec)
const WIND_IDLE_MIN: float = 12.0
const WIND_IDLE_MAX: float = 16.0
const WIND_WARN_DURATION: float = 1.5
const WIND_ACTIVE_DURATION: float = 3.0
const WIND_DRIFT_SPEED: float = 280.0  # pixels/sec at full strength (level 4 base)
var wind_particles: GPUParticles3D = null
var wind_warn_label: Label3D = null
var wind_sfx: AudioStreamPlayer = null
var wind_elapsed: float = 0.0  # time accumulator for turbulence
var wind_level_mult: float = 1.0  # scales intensity per level

var title_screen_ui: Control = null
var is_title_screen: bool = true
var title_cam_angle: float = 0.0


# ─── Sky colours at each temp threshold ──────────────────────────────────────
const SKY := [
	{"t": 100, "bg": Color(0.88, 0.14, 0.03)},
	{"t":  75, "bg": Color(1.00, 0.40, 0.00)},
	{"t":  50, "bg": Color(1.00, 0.68, 0.00)},
	{"t":  25, "bg": Color(0.38, 0.73, 0.93)},
	{"t":   0, "bg": Color(0.08, 0.53, 0.85)},
]

var gun_model: Node3D
 
func _on_weapon_changed(w_id: String) -> void:
	GameState.current_weapon_id = w_id
	_load_weapon_model()

func _load_weapon_model() -> void:
	if gun_model:
		gun_model.queue_free()
		
	var w_cfg = GameState.WEAPONS[GameState.current_weapon_id]
	gun_model = load(w_cfg.model).instantiate()
	gun_model.rotation_degrees = Vector3(0, 180, 0)
	gun_model.scale = w_cfg.scale
	gun_model.position = Vector3(0, -0.3, -0.1)
	_adjust_gun_materials(gun_model)
	gun.add_child(gun_model)
	
	MAX_WATER = w_cfg.water_capacity * GameState.max_water_mult
	water_tank = MAX_WATER
	current_weapon_power = w_cfg.cooling_power * GameState.cooling_power_mult
	current_weapon_crit = w_cfg.crit_multiplier
	current_weapon_recharge = w_cfg.recharge_rate
	
	var base_drain = 8.75
	if current_config.has("water_drain"):
		base_drain = current_config.water_drain
	WATER_DRAIN_RATE = base_drain + w_cfg.water_drain
	
	if shoot_loop_sfx:
		if GameState.current_weapon_id == "heavy":
			shoot_loop_sfx.pitch_scale = 0.6
		elif GameState.current_weapon_id == "precision":
			shoot_loop_sfx.pitch_scale = 1.5
		else:
			shoot_loop_sfx.pitch_scale = 1.0

	if gun_spray:
		var p_mat = gun_spray.process_material as ParticleProcessMaterial
		var g_mesh = gun_spray.draw_pass_1 as BoxMesh
		var g_mat = g_mesh.material as StandardMaterial3D
		if GameState.current_weapon_id == "heavy":
			gun_spray.amount = 200
			p_mat.spread = 12.0
			g_mesh.size = Vector3(0.3, 0.3, 0.3)
			g_mat.albedo_color = Color(0.0, 0.4, 0.9, 0.9) # Deep heavy blue
		elif GameState.current_weapon_id == "precision":
			gun_spray.amount = 60
			p_mat.spread = 0.5
			g_mesh.size = Vector3(0.05, 0.05, 0.5)
			g_mat.albedo_color = Color(0.8, 0.9, 1.0, 0.8) # Laser blue
			p_mat.initial_velocity_min = 40.0
			p_mat.initial_velocity_max = 50.0
		else:
			gun_spray.amount = 100
			p_mat.spread = 5.0
			g_mesh.size = Vector3(0.15, 0.15, 0.15)
			g_mat.albedo_color = Color(0.0, 0.8, 1.0, 0.8) # Cyan
			p_mat.initial_velocity_min = 25.0
			p_mat.initial_velocity_max = 35.0
	
	water_changed.emit(water_tank, MAX_WATER)

# ─── End Game & Level Transitions ─────────────────────────────────────────

# ─── Node references ─────────────────────────────────────────────────────────
var world_env:   WorldEnvironment
var env_res:     Environment
var sky_mat:     ProceduralSkyMaterial
var _sky_shader_mat: ShaderMaterial
var haze_mat:    ShaderMaterial
var steam_particles: GPUParticles3D
var splash_particles_pool: Array[GPUParticles3D] = []
var splash_idx: int = 0
var dir_light:   DirectionalLight3D
var camera:      Camera3D
var sun:         Node3D
var sun_mesh:    MeshInstance3D
var sun_mat:     StandardMaterial3D
var sun_ray_mat: StandardMaterial3D
var sun_rays_node: Node3D
var sun_face:    Sprite3D
var face_textures: Dictionary = {}
var gun:         Node3D
var frost_aura:  GPUParticles3D
var muzzle:      Marker3D
var seagull_layer: Node3D = null
var virtual_mouse_pos: Vector2
var blasts:      Node3D
var particles:   GPUParticles3D
var sun_shatter_particles: GPUParticles3D
signal critical_hit
var sunspot_node: MeshInstance3D
var sunspot_timer: float = 0.0
var sunspot_local_pos: Vector3 = Vector3.ZERO
var sunspot_tween: Tween
var sizzle_sfx: AudioStreamPlayer

var ice_blast_scene = preload("res://scenes/IceBlast.tscn")
var ice_shoot_sfx: AudioStreamPlayer
var ice_hit_sfx: AudioStreamPlayer
var is_sun_frozen: bool = false
var sun_freeze_timer: float = 0.0

var active_flares: Array[Dictionary] = []
var flare_spawn_timer: float = 8.0
var flare_mat: StandardMaterial3D
var flare_intercept_sfx: AudioStreamPlayer

# Weather system
var is_dragging_sun: bool = false
var is_catastrom_active: bool = false
var was_catastrom_charged: bool = false
var catastrom_sfx: AudioStreamPlayer
var active_weather: String = "none" # "none", "rain", "eclipse"
var weather_timer: float = 0.0
var weather_duration: float = 0.0
var weather_rain_particles: GPUParticles3D
var weather_blend: float = 0.0

var foliage_props: Array[Node3D] = []

var combo_timer: float = 0.0
var combo_active: bool = false

var magma_rock_prefabs: Array[PackedScene] = [
	preload("res://ultimate-stylized-nature/prefabs/rock_1.tscn"),
	preload("res://ultimate-stylized-nature/prefabs/rock_2.tscn"),
	preload("res://ultimate-stylized-nature/prefabs/rock_3.tscn"),
	preload("res://ultimate-stylized-nature/prefabs/rock_4.tscn"),
	preload("res://ultimate-stylized-nature/prefabs/rock_5.tscn")
]
var active_magma_rocks: Array[RigidBody3D] = []

var water_mat:   Material

var sun_time:    float = 0.0
var sun_base_pos := Vector3(0, 10.5, -42) # Raised height so sun sits majestically in upper sky
var gun_base_pos := Vector3(0, -1.0, 2.8) # Raised to match crosshair better
var sun_bob_speed := 1.5
var sun_bob_amp := 0.8

var gun_spray:   GPUParticles3D
var wet_spawn_timer: float = 0.0

func _ready() -> void:
	ice_shoot_sfx = AudioStreamPlayer.new()
	ice_shoot_sfx.stream = preload("res://assets/audio/sfx/ice_shoot.ogg")
	ice_shoot_sfx.volume_db = -5.0
	add_child(ice_shoot_sfx)
	
	ice_hit_sfx = AudioStreamPlayer.new()
	ice_hit_sfx.stream = preload("res://assets/audio/sfx/ice_hit.ogg")
	ice_hit_sfx.volume_db = -2.0
	add_child(ice_hit_sfx)
	
	flare_intercept_sfx = AudioStreamPlayer.new()
	flare_intercept_sfx.stream = preload("res://assets/audio/sfx/hit_sun.ogg")
	flare_intercept_sfx.pitch_scale = 0.6
	flare_intercept_sfx.volume_db = -4.0
	add_child(flare_intercept_sfx)
	
	catastrom_sfx = AudioStreamPlayer.new()
	catastrom_sfx.stream = preload("res://assets/audio/sfx/catastrom_dunk.mp3")
	catastrom_sfx.volume_db = 0.0
	add_child(catastrom_sfx)
	
	ambient_sfx = AudioStreamPlayer.new()
	var ocean_stream = load("res://assets/audio/sfx/ocean_waves.wav")
	ambient_sfx.stream = ocean_stream
	ambient_sfx.bus = "SFX_UI"  # Respect SFX volume slider
	ambient_sfx.volume_db = -80.0  # Start silent, fade in below
	add_child(ambient_sfx)
	ambient_sfx.play()
	# Fade in ocean ambient over 2s on title screen
	var ocean_tw = create_tween()
	ocean_tw.tween_property(ambient_sfx, "volume_db", -8.0, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	# Heat Haze screen distortion overlay (drawn under HUD text)
	var haze_layer = CanvasLayer.new()
	haze_layer.layer = 0 # HUD CanvasLayer is layer 1, so layer 0 is under HUD text
	add_child(haze_layer)
	
	var haze_rect = ColorRect.new()
	haze_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 0)
	haze_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	haze_mat = ShaderMaterial.new()
	haze_mat.shader = load("res://assets/heat_haze.gdshader")
	haze_mat.set_shader_parameter("heat_ratio", 1.0)
	haze_rect.material = haze_mat
	haze_layer.add_child(haze_rect)

	_build_scene()
	_build_environment()
	_update_sky(true)
	_sync_light_to_sun()
	

	level = GameState.level
	defeat_triggered = false
	cooldown_timer = 0.0
	water_refill_count = 0
	is_measuring = true

	current_config = GameState.LEVEL_CONFIG[GameState.level]
	var cfg = current_config
	WATER_DRAIN_RATE = cfg.water_drain + GameState.WEAPONS[GameState.current_weapon_id].water_drain
	heat_regen_base = cfg.heat_regen_base
	sun_sway_amplitude = cfg.sun_sway_amplitude
	sun_sway_speed = cfg.sun_sway_speed
	sun_figure8 = cfg.sun_figure8
	is_two_phase = cfg.two_phase
	phase2_heat = cfg.phase2_heat
	phase2_triggered = false
	
	solar_wind_enabled = cfg.get("solar_wind", false)
	wind_state = 0
	wind_timer = randf_range(WIND_IDLE_MIN, WIND_IDLE_MAX)
	wind_strength = 0.0
	wind_elapsed = 0.0
	# Level 5 gets 30% stronger, more frequent gusts
	wind_level_mult = 1.3 if GameState.level >= 5 else 1.0

	heat_regen_base = cfg.heat_regen_base
	if GameState.is_survival_mode:
		level_timer = 60.0
		wave_timer = 0.0
		heat_regen_base = 2.5 # Initial base heat for Wave 1
	else:
		level_timer = cfg.timer
	timer_running = true
	_reset_weather()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	hud = load("res://scenes/HUD.tscn").instantiate()
	add_child(hud)
	hud.visible = false
	gun.visible = false
	
	heat_changed.connect(hud._on_heat_changed)
	water_changed.connect(hud._on_water_changed)
	sun_defeated.connect(hud._on_sun_defeated)
	game_complete.connect(hud.show_end_screen)
	hud.game_paused.connect(_on_game_paused)
	hud.game_resumed.connect(_on_game_resumed)
	hud.weapon_changed.connect(_on_weapon_changed)
	
	
	
	if GameState.is_survival_mode:
		GameState.ice_charges_remaining = 0 # Start with 0 ice in Endless Mode
		hud.update_ice_charges(GameState.ice_charges_remaining, max_survival_ice_charges)
		hud.ice_row.visible = false
	else:
		GameState.ice_charges_remaining = cfg.ice_charges
		hud.update_ice_charges(GameState.ice_charges_remaining, cfg.ice_charges)
		if GameState.level == 2:
			hud.show_weapon_unlock()
		elif GameState.level == 3:
			hud.show_ice_unlock()
		
	projectile_hit.connect(hud._on_projectile_hit)
	timer_tick.connect(hud._on_timer_tick)
	timer_expired.connect(hud._on_timer_expired)
	phase2_started.connect(hud._on_phase2_started)
	emit_signal("level_config_loaded", cfg.timer)
	crosshair_moved.connect(hud._on_crosshair_moved)
	hud.sensitivity_changed.connect(func(val): GameState.mouse_sensitivity = val)
	hud.reduce_motion_changed.connect(func(enabled):
		reduce_motion = enabled
		if enabled and is_instance_valid(sunspot_tween):
			sunspot_tween.kill()
			if sunspot_node: sunspot_node.scale = Vector3(1.0, 1.0, 1.0)
	)
	mouse_sensitivity = GameState.mouse_sensitivity
	reduce_motion = GameState.reduce_motion
	heat_changed.emit(temperature, MAX_TEMP)
	water_changed.emit(water_tank, MAX_WATER)

	shoot_loop_sfx = _create_sfx("res://assets/audio/sfx/shoot_loop.ogg", -10.0, 1, "SFX_WEAPON")
	hit_sfx = _create_sfx("res://assets/audio/sfx/hit_sun.ogg", -2.0, 2, "SFX_WEAPON")
	sun_defeated_sfx = _create_sfx("res://assets/audio/sfx/sun_defeated.ogg", 0.0, 1, "SFX_UI")
	water_empty_sfx = _create_sfx("res://assets/audio/sfx/water_empty.ogg", -8.0, 1, "SFX_UI")
	sizzle_sfx = _create_sfx("res://assets/sizzle.ogg", -4.0, 2, "SFX_WEAPON")
	if hud and hud.has_method("_on_critical_hit"):
		critical_hit.connect(hud._on_critical_hit)

	flare_mat = StandardMaterial3D.new()
	flare_mat.albedo_color = Color(1.0, 0.35, 0.05)
	flare_mat.emission_enabled = true
	flare_mat.emission = Color(1.0, 0.45, 0.05)
	flare_mat.emission_energy_multiplier = 4.0
	
	frost_aura = GPUParticles3D.new()
	var fa_mat = ParticleProcessMaterial.new()
	fa_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	fa_mat.emission_sphere_radius = 6.0
	fa_mat.gravity = Vector3(0, -1.0, 0)
	fa_mat.scale_min = 0.2
	fa_mat.scale_max = 0.6
	var fa_mesh = BoxMesh.new()
	var fa_mmat = StandardMaterial3D.new()
	fa_mmat.albedo_color = Color(0.8, 0.9, 1.0, 0.5)
	fa_mmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fa_mesh.material = fa_mmat
	frost_aura.process_material = fa_mat
	frost_aura.draw_pass_1 = fa_mesh
	frost_aura.amount = 50
	frost_aura.lifetime = 2.0
	frost_aura.emitting = false
	if sun:
		sun.add_child(frost_aura)
	
	_load_weapon_model()

	title_screen_ui = load("res://scenes/TitleScreen.tscn").instantiate()
	add_child(title_screen_ui)
	title_screen_ui.start_game.connect(_on_title_start_game)

	# Handshake with persistent LoadingScreen on root viewport
	var persistent_loader = get_tree().root.get_node_or_null("LoadingScreen")
	if persistent_loader and persistent_loader.has_method("finish_sequence"):
		await persistent_loader.finish_sequence(level)
	else:
		var overlay = ColorRect.new()
		overlay.color = Color(0, 0, 0, 1)
		overlay.anchor_right = 1.0
		overlay.anchor_bottom = 1.0
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.z_index = 100
		add_child(overlay)
		var tw = create_tween()
		tw.tween_property(overlay, "modulate:a", 0.0, 0.3)
		tw.tween_callback(overlay.queue_free)

func _on_title_start_game(is_survival: bool) -> void:
	if title_screen_ui:
		var tw = create_tween()
		tw.tween_property(title_screen_ui, "modulate:a", 0.0, 0.5)
		tw.tween_callback(title_screen_ui.queue_free)
	
	# Duck ocean ambient during gameplay
	if ambient_sfx:
		var vol_tw = create_tween()
		vol_tw.tween_property(ambient_sfx, "volume_db", -20.0, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	is_title_screen = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hud._apply_language(GameState.language)
	hud.visible = true
	
	gun.visible = true
	gun.position.y = gun_base_pos.y - 1.0
	var gtw = create_tween()
	gtw.tween_property(gun, "position:y", gun_base_pos.y, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	var cam_tw = create_tween()
	cam_tw.set_parallel(true)
	cam_tw.tween_property(camera, "position", Vector3(0, 0, 5), 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	cam_tw.tween_property(camera, "rotation", Vector3.ZERO, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	timer_running = true
	virtual_mouse_pos = get_viewport().get_visible_rect().size / 2.0

# ─────────────────────────────────────────────────────────────────────────────
# Build Scene
# ─────────────────────────────────────────────────────────────────────────────
func _build_scene() -> void:
	# ── Environment ──────────────────────────────────────────────────────────
	world_env = WorldEnvironment.new()
	env_res = Environment.new()
	env_res.background_mode = Environment.BG_SKY
	
	var sky = Sky.new()
	var sky_shader_mat = ShaderMaterial.new()
	sky_shader_mat.shader = load("res://assets/summer_night_sky.gdshader")
	sky_shader_mat.set_shader_parameter("sun_heat", 1.0)
	# Store reference for runtime updates via _update_sky
	sky_mat = null  # ProceduralSkyMaterial cleared; use sky_shader_mat directly
	_sky_shader_mat = sky_shader_mat
	sky.sky_material = sky_shader_mat
	sky.radiance_size = Sky.RADIANCE_SIZE_256
	
	env_res.sky = sky
	
	# Ambient: warm neutral beige fill (no blue-purple tint)
	env_res.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env_res.ambient_light_color = Color(0.75, 0.65, 0.6) # Warm neutral beige
	env_res.ambient_light_sky_contribution = 0.5
	env_res.ambient_light_energy = 0.55
	
	# ── Tone Mapping — Filmic for cinematic highlight roll-off
	env_res.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env_res.tonemap_exposure = 1.15
	env_res.tonemap_white = 5.5
	
	# ── Glow — disabled to eliminate glare
	env_res.glow_enabled = false
	
	# ── SSAO — rich contact ambient occlusion under palm trees & model bases
	env_res.ssao_enabled = true
	env_res.ssao_radius = 1.5
	env_res.ssao_intensity = 1.8
	env_res.ssao_power = 1.2
	env_res.ssao_detail = 0.5
	env_res.ssao_horizon = 0.06
	env_res.ssao_sharpness = 0.98
	
	# ── SSIL — near-field indirect light bleeding
	env_res.ssil_enabled = true
	env_res.ssil_radius = 5.0
	env_res.ssil_intensity = 1.0
	env_res.ssil_sharpness = 0.98
	
	# ── SSR — ocean reflections
	env_res.ssr_enabled = true
	env_res.ssr_max_steps = 48
	env_res.ssr_fade_in = 0.15
	env_res.ssr_fade_out = 2.0
	env_res.ssr_depth_tolerance = 0.2
	
	# ── SDFGI — disabled at runtime (requires editor bake); SSIL + SSAO cover GI
	# env_res.sdfgi_enabled = true  # Only works when set in editor
	
	# ── Volumetric Fog — warm atmospheric haze
	env_res.volumetric_fog_enabled = true
	env_res.volumetric_fog_density = 0.01
	env_res.volumetric_fog_albedo = Color(0.9, 0.6, 0.3, 1.0)
	env_res.volumetric_fog_emission = Color(0.0, 0.0, 0.0)
	env_res.volumetric_fog_emission_energy = 0.0
	env_res.volumetric_fog_gi_inject = 1.0
	env_res.volumetric_fog_anisotropy = 0.2
	env_res.volumetric_fog_length = 64.0
	env_res.volumetric_fog_sky_affect = 0.3
	
	# Color grading
	env_res.adjustment_enabled = true
	env_res.adjustment_brightness = 1.0
	env_res.adjustment_contrast = 1.12
	env_res.adjustment_saturation = 1.08
	
	world_env.environment = env_res
	add_child(world_env)
	
	# Main DirectionalLight (Key Light / Sun) — high resolution, soft penumbra shadows
	dir_light = DirectionalLight3D.new()
	dir_light.light_color = Color(1.0, 0.75, 0.35)  # Warm golden
	dir_light.light_energy = 1.35
	dir_light.shadow_enabled = true
	dir_light.shadow_blur = 3.5
	dir_light.shadow_bias = 0.03
	dir_light.shadow_normal_bias = 2.0
	dir_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
	dir_light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	dir_light.directional_shadow_max_distance = 55.0
	dir_light.directional_shadow_blend_splits = true
	add_child(dir_light)
	
	# Enable high quality soft shadow filtering
	RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
	
	# Fill Light (Soft Warm Shadow Fill — prevents harsh purple cast)
	var fill_light = DirectionalLight3D.new()
	fill_light.light_color = Color(0.55, 0.45, 0.4) # Soft warm shadow fill
	fill_light.light_energy = 0.4
	fill_light.position = Vector3(0, 5, 20)
	fill_light.shadow_enabled = false
	fill_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
	add_child(fill_light)
	fill_light.look_at(Vector3.ZERO, Vector3.UP)

	# ── ReflectionProbe — wide-field ocean reflections
	var ref_probe = ReflectionProbe.new()
	ref_probe.position = Vector3(0, 2.5, -20)           # Above ocean midpoint
	ref_probe.size = Vector3(60, 6, 80)                  # Wide X/Z, shallow Y
	ref_probe.update_mode = ReflectionProbe.UPDATE_ALWAYS
	ref_probe.ambient_mode = ReflectionProbe.AMBIENT_DISABLED
	ref_probe.interior = false
	ref_probe.enable_shadows = true
	add_child(ref_probe)

	# ── Camera ───────────────────────────────────────────────────────────────
	camera = Camera3D.new()
	camera.position = Vector3(0, 0, 5)
	add_child(camera)
	
	# ── Weather Rain Particles ───────────────────────────────────────────────
	weather_rain_particles = GPUParticles3D.new()
	weather_rain_particles.name = "RainStorm"
	
	var rain_mat = StandardMaterial3D.new()
	rain_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rain_mat.albedo_color = Color(0.6, 0.8, 1.0, 0.4)
	rain_mat.emission_enabled = true
	rain_mat.emission = Color(0.3, 0.5, 0.8)
	rain_mat.emission_energy_multiplier = 0.2
	rain_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	var rain_mesh = QuadMesh.new()
	rain_mesh.size = Vector2(0.04, 1.2)
	rain_mesh.material = rain_mat
	
	weather_rain_particles.draw_pass_1 = rain_mesh
	weather_rain_particles.amount = 800
	weather_rain_particles.lifetime = 1.0
	weather_rain_particles.fixed_fps = 60
	weather_rain_particles.visibility_aabb = AABB(Vector3(-50, -50, -50), Vector3(100, 100, 100))
	
	var rain_proc = ParticleProcessMaterial.new()
	rain_proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	rain_proc.emission_box_extents = Vector3(40.0, 2.0, 40.0)
	rain_proc.direction = Vector3(0, -1, 0)
	rain_proc.spread = 5.0
	rain_proc.initial_velocity_min = 35.0
	rain_proc.initial_velocity_max = 45.0
	rain_proc.gravity = Vector3(0, -20.0, 0)
	weather_rain_particles.process_material = rain_proc
	
	camera.add_child(weather_rain_particles)
	weather_rain_particles.position = Vector3(0, 15, 0)
	weather_rain_particles.emitting = false


	# ── Animated Drifting Low-Poly 3D Cloud Layer ───────────────────────────
	var cloud_layer_script = load("res://scripts/CloudLayer.gd")
	if cloud_layer_script:
		var clouds_node = Node3D.new()
		clouds_node.name = "CloudLayer"
		clouds_node.set_script(cloud_layer_script)
		add_child(clouds_node)

	# ── Circling Low-Poly Seagulls ──────────────────────────────────────────
	var seagull_script = load("res://scripts/SeagullLayer.gd")
	if seagull_script:
		var gulls = Node3D.new()
		gulls.name = "SeagullLayer"
		gulls.set_script(seagull_script)
		add_child(gulls)
		seagull_layer = gulls

	blasts = Node3D.new()
	add_child(blasts)

	# ── Sun ──────────────────────────────────────────────────────────────────
	sun = Node3D.new()
	sun.position = sun_base_pos
	add_child(sun)

	var sun_model_instance = load("res://assets/models/sun_lowpoly.glb").instantiate()
	sun.add_child(sun_model_instance)
	sun_model_instance.scale = Vector3(0.32, 0.32, 0.32) # Increased Sun size by ~25%
	sun_mesh = _setup_sun_mesh_and_material(sun_model_instance)
	
	# Ray material (deeper reddish orange, lower emission to prevent blob fusion)
	sun_ray_mat = StandardMaterial3D.new()
	sun_ray_mat.albedo_color = Color(0.95, 0.35, 0.1) # Red-orange
	sun_ray_mat.emission_enabled = true
	sun_ray_mat.emission = Color(0.95, 0.35, 0.1)
	sun_ray_mat.emission_energy_multiplier = 1.5 # Toned down to maintain distinct silhouette
	
	# Spawn 12 rotating cone sunbeams (retro-arcade style)
	sun_rays_node = Node3D.new()
	sun.add_child(sun_rays_node)
	
	for i in range(12):
		var angle = i * (TAU / 12.0)
		var ray = MeshInstance3D.new()
		var cone = CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = 0.4
		cone.height = 2.4
		ray.mesh = cone
		ray.material_override = sun_ray_mat
		
		# Position outwards from sun center
		var dist = 3.8
		ray.position = Vector3(cos(angle) * dist, sin(angle) * dist, 0.0)
		# Rotate to point outwards (align cylinder height to face away from center)
		ray.rotation.z = angle - PI/2.0
		sun_rays_node.add_child(ray)
	
	# Stylized Low-Poly Corona Ring (matches retro arcade 3D aesthetic)
	var corona_mesh = TorusMesh.new()
	corona_mesh.inner_radius = 3.0
	corona_mesh.outer_radius = 3.6
	corona_mesh.rings = 20
	corona_mesh.ring_segments = 8
	
	var corona_node = MeshInstance3D.new()
	corona_node.mesh = corona_mesh
	corona_node.material_override = sun_ray_mat
	corona_node.rotation.x = PI / 2.0 # Face camera
	sun.add_child(corona_node)
	
	sun_shatter_particles = GPUParticles3D.new()
	sun_shatter_particles.emitting = false
	sun_shatter_particles.amount = 120
	sun_shatter_particles.lifetime = 2.0
	sun_shatter_particles.visibility_aabb = AABB(Vector3(-50, -50, -50), Vector3(100, 100, 100))
	
	var shatter_mat = ParticleProcessMaterial.new()
	shatter_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	shatter_mat.emission_sphere_radius = 5.0
	shatter_mat.direction = Vector3(0, 1, 0)
	shatter_mat.spread = 180.0
	shatter_mat.initial_velocity_min = 15.0
	shatter_mat.initial_velocity_max = 30.0
	shatter_mat.gravity = Vector3(0, 8.0, 0) # chunks float up slightly then fall or fly out
	shatter_mat.scale_min = 0.5
	shatter_mat.scale_max = 2.0
	sun_shatter_particles.process_material = shatter_mat
	
	var chunk_mesh = BoxMesh.new()
	chunk_mesh.size = Vector3(1.5, 1.5, 1.5)
	sun_shatter_particles.draw_pass_1 = chunk_mesh
	sun_shatter_particles.material_override = sun_ray_mat
	add_child(sun_shatter_particles)

 
	var sun_light = OmniLight3D.new()
	sun_light.light_color = Color(1.0, 0.7, 0.3)
	sun_light.light_energy = 2.0
	sun_light.omni_range = 30.0
	sun.add_child(sun_light)
	
	var face_sprite = Sprite3D.new()
	face_sprite.name = "SunFace"
	face_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	face_sprite.pixel_size = 0.08
	face_sprite.position = Vector3(0, 0, 3.4)
	face_sprite.no_depth_test = true
	face_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	sun.add_child(face_sprite)
	sun_face = face_sprite
	
	face_textures = {
		"angry":   _draw_face("angry"),
		"annoyed": _draw_face("annoyed"),
		"neutral": _draw_face("neutral"),
		"happy":   _draw_face("happy"),
		"dizzy":   _draw_face("dizzy"),
	}
	sun_face.texture = face_textures["angry"]
	
	# ── Sunspot / White-Hot Critical Heat Vent Target ──────────────────
	# Balanced 1.6m White-Hot Core + Fiery Orange Outer Rim
	var spot_core_mesh = CylinderMesh.new()
	spot_core_mesh.top_radius = 0.9
	spot_core_mesh.bottom_radius = 1.2
	spot_core_mesh.height = 0.15
	
	var spot_mat = StandardMaterial3D.new()
	spot_mat.albedo_color = Color(1.0, 0.98, 0.8) # White-hot core
	spot_mat.emission_enabled = true
	spot_mat.emission = Color(1.0, 0.95, 0.7) # Intense golden-white glow
	spot_mat.emission_energy_multiplier = 5.0
	spot_mat.roughness = 0.1
	
	sunspot_node = MeshInstance3D.new()
	sunspot_node.mesh = spot_core_mesh
	sunspot_node.material_override = spot_mat
	
	# Outer Fiery Rim Ring
	var spot_rim_mesh = TorusMesh.new()
	spot_rim_mesh.inner_radius = 1.1
	spot_rim_mesh.outer_radius = 1.6
	spot_rim_mesh.rings = 18
	spot_rim_mesh.ring_segments = 8
	
	var rim_mat = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(1.0, 0.35, 0.05) # Fiery orange-red
	rim_mat.emission_enabled = true
	rim_mat.emission = Color(1.0, 0.35, 0.05)
	rim_mat.emission_energy_multiplier = 4.0
	
	var rim_inst = MeshInstance3D.new()
	rim_inst.mesh = spot_rim_mesh
	rim_inst.material_override = rim_mat
	sunspot_node.add_child(rim_inst)
	
	# Continuous Steam Geyser Plume rising from vent location
	var vent_geyser = GPUParticles3D.new()
	var vg_mat = ParticleProcessMaterial.new()
	vg_mat.direction = Vector3(0, 1, 0)
	vg_mat.spread = 20.0
	vg_mat.initial_velocity_min = 3.0
	vg_mat.initial_velocity_max = 6.0
	vg_mat.gravity = Vector3(0, 6.0, 0) # Rises up into sky
	vg_mat.scale_min = 0.4
	vg_mat.scale_max = 1.6
	var vg_mesh = SphereMesh.new()
	vg_mesh.radius = 0.4
	vg_mesh.height = 0.8
	var vg_mesh_mat = StandardMaterial3D.new()
	vg_mesh_mat.albedo_color = Color(1.0, 1.0, 0.9, 0.6) # Bright steam plume
	vg_mesh_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vg_mesh.material = vg_mesh_mat
	vent_geyser.process_material = vg_mat
	vent_geyser.draw_pass_1 = vg_mesh
	vent_geyser.amount = 20
	vent_geyser.lifetime = 0.9
	sunspot_node.add_child(vent_geyser)

	# Warm White-Hot OmniLight
	var spot_light = OmniLight3D.new()
	spot_light.light_color = Color(1.0, 0.9, 0.6)
	spot_light.light_energy = 5.0
	spot_light.omni_range = 12.0
	sunspot_node.add_child(spot_light)
	
	sun.add_child(sunspot_node)
	_relocate_sunspot()
	
	# Splash particles (vibrant cyan water splash drops falling down)
	particles = GPUParticles3D.new()
	var p_mat = ParticleProcessMaterial.new()
	p_mat.direction = Vector3(0, 1, 0)
	p_mat.spread = 60.0
	p_mat.initial_velocity_min = 5.0
	p_mat.initial_velocity_max = 10.0
	p_mat.gravity = Vector3(0, -12.0, 0) # drops down quickly
	p_mat.scale_min = 0.2
	p_mat.scale_max = 0.5
	var p_mesh = SphereMesh.new()
	p_mesh.radius = 0.3
	p_mesh.height = 0.6
	var p_mesh_mat = StandardMaterial3D.new()
	p_mesh_mat.albedo_color = Color(0.0, 0.8, 1.0, 0.7) # Cyan water drops
	p_mesh_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	p_mesh.material = p_mesh_mat
	particles.process_material = p_mat
	particles.draw_pass_1 = p_mesh
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.amount = 20
	particles.lifetime = 0.8
	sun.add_child(particles)

	# Steam evaporation particles (expanding white steam clouds rising up)
	steam_particles = GPUParticles3D.new()
	var s_mat = ParticleProcessMaterial.new()
	s_mat.direction = Vector3(0, 1, 0)
	s_mat.spread = 45.0
	s_mat.initial_velocity_min = 2.0
	s_mat.initial_velocity_max = 4.0
	s_mat.gravity = Vector3(0, 6.0, 0) # rises up quickly
	s_mat.scale_min = 0.4
	s_mat.scale_max = 1.6
	var s_mesh = SphereMesh.new()
	s_mesh.radius = 0.4
	s_mesh.height = 0.8
	var s_mesh_mat = StandardMaterial3D.new()
	s_mesh_mat.albedo_color = Color(1.0, 1.0, 1.0, 0.4) # Soft white steam cloud
	s_mesh_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	s_mesh.material = s_mesh_mat
	steam_particles.process_material = s_mat
	steam_particles.draw_pass_1 = s_mesh
	steam_particles.emitting = false
	steam_particles.one_shot = true
	steam_particles.explosiveness = 0.85
	steam_particles.amount = 15
	steam_particles.lifetime = 1.2
	sun.add_child(steam_particles)
	
	# Water splash particles pool
	for i in range(10):
		var splash = GPUParticles3D.new()
		var sp_mat = ParticleProcessMaterial.new()
		sp_mat.direction = Vector3(0, 1, 0)
		sp_mat.spread = 70.0
		sp_mat.initial_velocity_min = 4.0
		sp_mat.initial_velocity_max = 8.0
		sp_mat.gravity = Vector3(0, -12.0, 0)
		sp_mat.scale_min = 0.1
		sp_mat.scale_max = 0.3
		var sp_mesh = SphereMesh.new()
		sp_mesh.radius = 0.2
		sp_mesh.height = 0.4
		var sp_mesh_mat = StandardMaterial3D.new()
		sp_mesh_mat.albedo_color = Color(0.2, 0.7, 1.0, 0.8)
		sp_mesh_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		sp_mesh.material = sp_mesh_mat
		splash.process_material = sp_mat
		splash.draw_pass_1 = sp_mesh
		splash.emitting = false
		splash.one_shot = true
		splash.explosiveness = 0.95
		splash.amount = 25
		splash.lifetime = 0.6
		add_child(splash)
		splash_particles_pool.append(splash)
 
	# ── Gun ──────────────────────────────────────────────────────────────────
	gun = Node3D.new()
	gun.position = gun_base_pos
	add_child(gun)
	
	muzzle = Marker3D.new()
	muzzle.name = "Muzzle"
	muzzle.position = Vector3(0, 0, -1.0)
	gun.add_child(muzzle)
	
	
	# Water spray particles (attached to gun)
	gun_spray = GPUParticles3D.new()
	var g_mat = ParticleProcessMaterial.new()
	g_mat.direction = Vector3(0, 0, -1)
	g_mat.spread = 5.0
	g_mat.initial_velocity_min = 25.0
	g_mat.initial_velocity_max = 35.0
	g_mat.gravity = Vector3(0, -5.0, 0)
	# Tumbling behavior
	g_mat.angle_min = 0.0
	g_mat.angle_max = 360.0
	
	# Low-poly tumbling cubes for water
	var g_mesh = BoxMesh.new()
	g_mesh.size = Vector3(0.15, 0.15, 0.15)
	
	var g_mesh_mat = StandardMaterial3D.new()
	g_mesh_mat.albedo_color = Color(0.0, 0.8, 1.0, 0.8) # 10% Accent: Vibrant Cyan Water
	g_mesh_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	g_mesh.material = g_mesh_mat
	gun_spray.process_material = g_mat
	gun_spray.draw_pass_1 = g_mesh
	gun_spray.emitting = false
	gun_spray.amount = 100
	gun_spray.lifetime = 1.0
	gun_spray.position = Vector3(0, 0.15, -1.2) # Adjusted for blaster.glb barrel tip
	gun.add_child(gun_spray)


# ─────────────────────────────────────────────────────────────────────────────
# Procedural Environment
# ─────────────────────────────────────────────────────────────────────────────
func _find_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found = _find_mesh(child)
		if found:
			return found
	return null

func _build_environment() -> void:
	var env_node = Node3D.new()
	add_child(env_node)
	
	# Create Water (Ocean)
	var ocean = MeshInstance3D.new()
	var plane_water = PlaneMesh.new()
	plane_water.size = Vector2(200, 200)
	ocean.mesh = plane_water
	var ocean_mat = StandardMaterial3D.new()
	ocean_mat.albedo_color = Color(0.1, 0.45, 0.7, 0.8) # Soft tropical blue ocean
	ocean_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ocean_mat.roughness = 0.1
	ocean.material_override = ocean_mat
	ocean.position = Vector3(0, -3.8, 0)
	env_node.add_child(ocean)
	# Base island (Cylinder for a flat surface)
	var ground_mesh = CylinderMesh.new()
	ground_mesh.top_radius = 40.0
	ground_mesh.bottom_radius = 40.0
	ground_mesh.height = 2.0
	
	# Stylized Sand Texture with Normal Map & Detail Layer
	var g_noise = FastNoiseLite.new()
	g_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	g_noise.frequency = 0.15
	g_noise.fractal_octaves = 2
	
	var g_tex = NoiseTexture2D.new()
	g_tex.width = 128
	g_tex.height = 128
	g_tex.noise = g_noise
	
	var g_normal_tex = NoiseTexture2D.new()
	g_normal_tex.width = 128
	g_normal_tex.height = 128
	g_normal_tex.noise = g_noise
	g_normal_tex.as_normal_map = true
	g_normal_tex.bump_strength = 3.0
	
	var ground_mat = StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.85, 0.55, 0.35) # Warm tropical sand tone
	ground_mat.albedo_texture = g_tex
	ground_mat.uv1_scale = Vector3(8.0, 8.0, 8.0)
	ground_mat.roughness = 0.88
	ground_mat.roughness_texture = g_tex
	
	# Normal Map detail
	ground_mat.normal_enabled = true
	ground_mat.normal_texture = g_normal_tex
	ground_mat.normal_scale = 0.4
	
	# Detail texture layer for subtle sand color variation
	ground_mat.detail_enabled = true
	ground_mat.detail_blend_mode = 0 # MIX / MUL blend mode
	ground_mat.detail_uv_layer = 0   # UV1
	ground_mat.detail_albedo = g_tex
	
	ground_mesh.material = ground_mat
	var ground = MeshInstance3D.new()
	ground.mesh = ground_mesh
	ground.position = Vector3(0, -3.0, 0) # Top of cylinder at Y = -2.0
	env_node.add_child(ground)
	ground.create_trimesh_collision()
	
	# Water
	var water_mesh = PlaneMesh.new()
	water_mesh.size = Vector2(200, 200)
	water_mesh.subdivide_width = 80
	water_mesh.subdivide_depth = 80
	
	water_mat = ShaderMaterial.new()
	water_mat.shader = load("res://assets/stylized_water.gdshader")
	
	water_mesh.material = water_mat
	var water = MeshInstance3D.new()
	water.mesh = water_mesh
	water.position = Vector3(0, -4.0, 0)
	env_node.add_child(water)
	
	var palm_tall = load("res://ultimate-stylized-nature/prefabs/palm_tree_1.tscn")
	var palm_short = load("res://ultimate-stylized-nature/prefabs/palm_tree_2.tscn")
	var rock_a = load("res://ultimate-stylized-nature/prefabs/rock_1.tscn")
	var rock_b = load("res://ultimate-stylized-nature/prefabs/rock_2.tscn")
	var bush = load("res://ultimate-stylized-nature/prefabs/bush_large.tscn")
	var grass = load("res://ultimate-stylized-nature/prefabs/grass_large.tscn")
	var flower = load("res://ultimate-stylized-nature/prefabs/flower_1_clump.tscn")
	
	# Scatter foliage and props
	seed("summer_nights".hash())
	
	for i in range(125):
		var x = randf_range(4.0, 40.0) # Right side only
		var z = randf_range(-40.0, 5.0)
		
		var dist_from_center = Vector2(x, z).length()
		if dist_from_center > 36.0: continue
		
		var y_pos = -2.0 # Flat cylinder top
		
		var prop_type = randf()
		var scale_mult = randf_range(1.0, 2.5)
		var rot = randf_range(0, 360)
		
		for side in [1.0, -1.0]:
			var prop: Node3D
			if prop_type > 0.95: prop = palm_tall.instantiate()
			elif prop_type > 0.90: prop = palm_short.instantiate()
			elif prop_type > 0.85: prop = rock_a.instantiate()
			elif prop_type > 0.80: prop = rock_b.instantiate()
			elif prop_type > 0.70: prop = bush.instantiate()
			elif prop_type > 0.35: prop = grass.instantiate()
			else: prop = flower.instantiate()
			
			prop.position = Vector3(x * side, y_pos, z)
			prop.rotation_degrees = Vector3(0, rot * side, 0) # Mirror rotation
			prop.scale = Vector3(scale_mult, scale_mult, scale_mult)
			
			if prop_type > 0.80:
				_add_collision_to_prop(prop)
				
			env_node.add_child(prop)
	
	# Set Dressing: Asset Clumping (Biomes) for deliberate level design
	var num_groves = 6
	for g in range(num_groves):
		var grove_x = randf_range(8.0, 35.0) # Right side only
		var grove_z = randf_range(-35.0, 4.0) 
		
		var props_in_grove = randi_range(12, 18)
		for i in range(props_in_grove):

			var angle = randf_range(0, TAU)
			var rad = randf_range(0.0, 6.0) # Cluster radius
			var x = grove_x + cos(angle) * rad
			var z = grove_z + sin(angle) * rad
			
			if z > 2.0: continue # Prevent bleeding too close
			if z < 0.0 and abs(x) < 4.5: continue # Keep central lane perfectly clear
			
			var dist_from_center = Vector2(x, z).length()
			if dist_from_center > 36.0: continue # Don't fall in water
			
			var y_drop = (40.0 - sqrt(max(0.0, 1600.0 - dist_from_center * dist_from_center))) * 0.1
			var y_pos = -2.0 - y_drop
			
			var r = randf()
			var scale_mult = randf_range(1.5, 3.5)
			var rot = randf_range(0, 360)
			
			for side in [1.0, -1.0]:
				var prop
				var current_scale = scale_mult
				if r > 0.8: prop = palm_tall.instantiate()
				elif r > 0.6: prop = palm_short.instantiate()
				elif r > 0.4: prop = rock_a.instantiate()
				elif r > 0.2: prop = rock_b.instantiate()
				else: 
					prop = bush.instantiate()
					current_scale *= 1.2
				
				prop.position = Vector3(x * side, y_pos, z)
				prop.rotation_degrees = Vector3(0, rot * side, 0)
				prop.scale = Vector3(current_scale, current_scale, current_scale)
				
				if r > 0.2:
					_add_collision_to_prop(prop)
					
				if r > 0.6 or r <= 0.2:
					foliage_props.append(prop)
					
				env_node.add_child(prop)
		
	

func _relocate_sunspot() -> void:
	sunspot_timer = 4.5
	var offset_x = randf_range(-2.0, 2.0)
	var offset_y = randf_range(-2.0, 2.0)
	var R = 3.3
	var offset_z = sqrt(max(0.2, R * R - offset_x * offset_x - offset_y * offset_y))
	sunspot_local_pos = Vector3(offset_x, offset_y, offset_z)
	if sunspot_node:
		sunspot_node.position = sunspot_local_pos
		sunspot_node.look_at(sunspot_node.global_position + sunspot_local_pos.normalized(), Vector3.UP)
		sunspot_node.rotate_object_local(Vector3(1, 0, 0), PI / 2.0)
		
		if is_instance_valid(sunspot_tween): sunspot_tween.kill()
		sunspot_node.scale = Vector3(1.0, 1.0, 1.0)
		if not reduce_motion:
			sunspot_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			sunspot_tween.tween_property(sunspot_node, "scale", Vector3(1.25, 1.25, 1.25), 0.5)
			sunspot_tween.tween_property(sunspot_node, "scale", Vector3(1.0, 1.0, 1.0), 0.5)

func _spawn_solar_flare() -> void:
	var lvl = float(GameState.level)
	if active_weather == "eclipse":
		flare_spawn_timer = randf_range(1.5, 3.0) # Spam shadow flares
	else:
		flare_spawn_timer = randf_range(12.0 - lvl, 15.0 - lvl)
	var flare_root = Node3D.new()
	
	# Low-Poly Solar Mass Cluster (5 overlapping low-poly spheres matching CloudLayer style)
	var puff_offsets = [
		Vector3(0, 0, 0),
		Vector3(0.6, 0.2, 0.1),
		Vector3(-0.5, -0.2, -0.1),
		Vector3(0.2, 0.4, -0.2),
		Vector3(-0.3, -0.3, 0.2)
	]
	
	for offset in puff_offsets:
		var mesh_inst = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = randf_range(0.6, 1.0)
		sphere.height = sphere.radius * 2.0
		sphere.radial_segments = 8
		sphere.rings = 6
		mesh_inst.mesh = sphere
		if active_weather == "eclipse":
			var shadow_mat = StandardMaterial3D.new()
			shadow_mat.albedo_color = Color(0.1, 0.0, 0.2)
			shadow_mat.emission_enabled = true
			shadow_mat.emission = Color(0.4, 0.0, 0.8)
			shadow_mat.emission_energy_multiplier = 3.0
			mesh_inst.material_override = shadow_mat
		else:
			mesh_inst.material_override = flare_mat
		mesh_inst.position = offset
		flare_root.add_child(mesh_inst)
		
	var flare_spin_speed = Vector3(randf_range(-2.0, 2.0), randf_range(1.0, 3.0), randf_range(-2.0, 2.0))

	# Fiery OmniLight Aura
	var f_light = OmniLight3D.new()
	if active_weather == "eclipse":
		f_light.light_color = Color(0.5, 0.1, 1.0)
	else:
		f_light.light_color = Color(1.0, 0.55, 0.1)
	f_light.light_energy = 3.5
	f_light.omni_range = 8.0
	flare_root.add_child(f_light)

	# Embers trail
	var trail = GPUParticles3D.new()
	var t_mat = ParticleProcessMaterial.new()
	t_mat.direction = Vector3(0, 0, 1)
	t_mat.spread = 40.0
	t_mat.initial_velocity_min = 2.0
	t_mat.initial_velocity_max = 6.0
	t_mat.scale_min = 0.3
	t_mat.scale_max = 0.9
	var t_mesh = SphereMesh.new()
	t_mesh.radius = 0.3
	t_mesh.height = 0.6
	var t_mesh_mat = StandardMaterial3D.new()
	if active_weather == "eclipse":
		t_mesh_mat.albedo_color = Color(0.3, 0.0, 0.6)
		t_mesh_mat.emission_enabled = true
		t_mesh_mat.emission = Color(0.5, 0.1, 0.9)
	else:
		t_mesh_mat.albedo_color = Color(1.0, 0.5, 0.1)
		t_mesh_mat.emission_enabled = true
		t_mesh_mat.emission = Color(1.0, 0.6, 0.1)
	t_mesh_mat.emission_energy_multiplier = 4.0
	t_mesh.material = t_mesh_mat
	trail.process_material = t_mat
	trail.draw_pass_1 = t_mesh
	trail.amount = 16
	flare_root.add_child(trail)
	
	add_child(flare_root)
	flare_root.global_position = sun.global_position
	
	var start_pos = sun.global_position
	var target_pos = Vector3(randf_range(-8.0, 8.0), -1.0, randf_range(1.0, 5.0))
	var duration = randf_range(3.8, 4.4) # Comfortable 4-second readable flight duration
	if active_weather == "eclipse":
		duration = randf_range(1.8, 2.4) # Shadow flares move significantly faster!
	
	active_flares.append({
		"node": flare_root,
		"start_pos": start_pos,
		"target_pos": target_pos,
		"progress": 0.0,
		"duration": duration,
		"spin": flare_spin_speed,
		"hp": 1.0
	})
	
	if sizzle_sfx and not sizzle_sfx.playing:
		sizzle_sfx.play()

func _update_flares(delta: float) -> void:
	var to_remove = []
	for flare in active_flares:
		var node = flare["node"] as Node3D
		if not is_instance_valid(node):
			to_remove.append(flare)
			continue
			
		flare["progress"] += delta / (flare["duration"] as float)
		var p = flare["progress"] as float
		
		# Tumbling spin rotation
		var spin = flare["spin"] as Vector3
		node.rotation += spin * delta
		
		if p >= 1.0:
			if steam_particles:
				steam_particles.global_position = node.global_position
				steam_particles.restart()
			temperature = min(MAX_TEMP, temperature + 4.0)
			node.queue_free()
			to_remove.append(flare)
		else:
			var curr_pos = (flare["start_pos"] as Vector3).lerp(flare["target_pos"] as Vector3, p)
			curr_pos.y += sin(p * PI) * 6.0
			node.global_position = curr_pos
			
	for f in to_remove:
		active_flares.erase(f)

# ─────────────────────────────────────────────────────────────────────────────
# Main loop
# ─────────────────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if hud and "lose_screen" in hud and hud.lose_screen != null and hud.lose_screen.visible:
		return

	if game_over:
		if is_instance_valid(shoot_loop_sfx):
			shoot_loop_sfx.stop()
		return
	if hud and (hud.settings_screen.visible or hud.credits_screen.visible or hud.pause_screen.visible):
		if gun_spray: gun_spray.emitting = false
		is_shooting = false
		timer_running = false
		if is_instance_valid(shoot_loop_sfx):
			shoot_loop_sfx.stop()
		return
		
	timer_running = true
	
	if is_title_screen:
		title_cam_angle += 0.3 * delta  # time accumulator (not a rotation angle)
		var swing = sin(title_cam_angle) * 0.52  # ±~30° arc in radians
		var cam_dist = 6.0
		camera.position = Vector3(sin(swing) * cam_dist, 2.0, cos(swing) * cam_dist)
		camera.look_at(Vector3(0, 1, 0), Vector3.UP)
		
		# Slowly drift the sun and clouds
		if sun_mesh:
			sun_mesh.rotation.y += 0.2 * delta
		if sun_rays_node:
			sun_rays_node.rotation.z += 0.1 * delta
		return

	if timer_running and not defeat_triggered:
		if is_sun_frozen:
			sun_freeze_timer -= delta
			if sun_freeze_timer <= 0.0:
				is_sun_frozen = false
				if frost_aura:
					frost_aura.emitting = false
				if sun_mat:
					var tw = create_tween()
					tw.tween_property(sun_mat, "albedo_color", Color(1.0, 1.0, 1.0), 0.5)
					tw.parallel().tween_property(sun_mat, "emission", Color(1.0, 0.7, 0.2), 0.5)
				if sun_ray_mat:
					var tw2 = create_tween()
					tw2.tween_property(sun_ray_mat, "emission", Color(1.0, 0.5, 0.1), 0.5)
					
		var spd_mult = 0.0 if is_sun_frozen else 1.0
		sun_time += delta * spd_mult
		
		level_timer -= delta
		timer_tick.emit(level_timer)
		if level_timer <= 0.0:
			timer_running = false
			game_over = true
			is_shooting = false
			if gun_spray: gun_spray.emitting = false
			
			# Dramatic Game Over Impact
			shake(0.5, 0.08)
			if sun_mat:
				var tw = create_tween()
				tw.tween_property(sun_mat, "emission_energy_multiplier", 12.0, 0.3)
				tw.parallel().tween_property(sun_mat, "albedo_color", Color(4.0, 2.0, 1.0), 0.3)
				if sun_mesh:
					tw.parallel().tween_property(sun_mesh, "scale", Vector3(1.2, 1.2, 1.2), 0.3)
					
			timer_expired.emit()
			
		if GameState.is_survival_mode:
			GameState.survival_time += delta
			wave_timer += delta
			
			if wave_timer < 10.0:
				heat_regen_base = 2.0 # The Release
			else:
				heat_regen_base = 2.5 + (GameState.current_wave * 1.5) # The Tension
			
			if is_two_phase and phase2_triggered:
				heat_regen_base *= 1.2 # The Boss Phase is aggressive but beatable with base gun

		
	# Relocate sunspot on timer
	if sunspot_node:
		sunspot_timer -= delta
		if sunspot_timer <= 0.0:
			_relocate_sunspot()

	# Solar flare spawn & movement
	flare_spawn_timer -= delta
	if flare_spawn_timer <= 0.0:
		_spawn_solar_flare()
	_update_flares(delta)
	
	# Weather system logic
	if active_weather == "none":
		weather_blend = max(0.0, weather_blend - delta * 1.5)
		if weather_timer > 0.0 and timer_running:
			weather_timer -= delta
			if weather_timer <= 0.0:
				_start_weather_event()
	else:
		weather_blend = min(1.0, weather_blend + delta * 1.5)
		if weather_duration > 0.0 and timer_running:
			weather_duration -= delta
			if weather_duration <= 0.0:
				_end_weather_event()
				
	# Weather Mechanics
	if active_weather == "rain":
		temperature = max(0.0, temperature - 5.0 * delta)
		water_tank = min(MAX_WATER, water_tank + 25.0 * delta)
		
	# Dynamic Wind Sway on tropical foliage
	var wind_t = Time.get_ticks_msec() * 0.001
	for f_prop in foliage_props:
		if is_instance_valid(f_prop):
			var sway_z = sin(wind_t * 1.6 + f_prop.position.x * 0.1) * 0.035
			var sway_x = cos(wind_t * 1.2 + f_prop.position.z * 0.1) * 0.02
			f_prop.rotation.z = sway_z
			f_prop.rotation.x = sway_x
		
	# Increase difficulty based on level
	var regen_rate = heat_regen_base
		
	if is_measuring:
		cooldown_timer += delta

	# Sun bob and rotate
	if not is_dragging_sun:
		if is_catastrom_active:
			var high_pos = sun_base_pos + Vector3(0, 10.0, 0)
			sun.position = sun.position.lerp(high_pos, 3.0 * delta)
		elif sun_sway_amplitude > 0.0:
			var spd_mult = 0.0 if is_sun_frozen else 1.0
			sun_move_time += delta * spd_mult
			var x_offset = sin(sun_move_time * sun_sway_speed) * sun_sway_amplitude
			sun.position.x = sun_base_pos.x + x_offset
			
			if sun_figure8:
				var y_offset = sin(sun_move_time * sun_sway_speed * 2.0) * (sun_sway_amplitude * 0.5)
				sun.position.y = sun_base_pos.y + y_offset
				sun.position.z = sun_base_pos.z
			else:
				sun.position.y = sun_base_pos.y + sin(sun_time * sun_bob_speed) * sun_bob_amp
				sun.position.z = sun_base_pos.z
		else:
			sun.position.x = sun_base_pos.x
			sun.position.y = sun_base_pos.y + sin(sun_time * sun_bob_speed) * sun_bob_amp
			sun.position.z = sun_base_pos.z

	if sun_mesh:
		var spd_mult = 0.0 if is_sun_frozen else 1.0
		sun_mesh.rotation.y += 0.5 * delta * spd_mult
	if sun_rays_node:
		var spd_mult = 0.0 if is_sun_frozen else 1.0
		sun_rays_node.rotation.z += 0.3 * delta * spd_mult
	
	_sync_light_to_sun()
	# Breathing pulse & Temperature scaling
	var pulse = 1.0 + sin(sun_time * 4.0) * 0.02
	var ratio = temperature / MAX_TEMP
	var target_scale = (0.4 + 0.6 * ratio) * pulse
	
	if is_dragging_sun:
		var shrink_factor = clamp(sun.position.y / sun_base_pos.y, 0.1, 1.0)
		target_scale *= shrink_factor
		if sun_shatter_particles:
			sun_shatter_particles.global_position = sun.global_position
			if not sun_shatter_particles.emitting:
				sun_shatter_particles.emitting = true
	else:
		if sun_shatter_particles and sun_shatter_particles.emitting:
			sun_shatter_particles.emitting = false
			
	sun.scale = Vector3(target_scale, target_scale, target_scale)
	
	_update_sun_face(ratio)
	
	# Heat Regeneration
	if temperature < MAX_TEMP and not is_sun_frozen and active_weather != "eclipse":
		temperature += (heat_regen_base * (1.0 - GameState.heat_resistance)) * delta # Sun gets hotter over time
		
	_update_sky(false)
	
	if hud and hud.grab_icon:
		if is_catastrom_active:
			hud.grab_icon.visible = true
			var pos = camera.unproject_position(sun.global_position)
			hud.grab_icon.position = pos - hud.grab_icon.size / 2.0
		else:
			hud.grab_icon.visible = false

	# Solar Wind hazard
	if solar_wind_enabled and not is_title_screen:
		_process_solar_wind(delta)
	else:
		wind_strength = 0.0
		if wind_particles and wind_particles.emitting:
			wind_particles.emitting = false

	
	if seagull_layer:
		# Check if magma rocks hit seagulls
		var valid_rocks: Array[RigidBody3D] = []
		for r in active_magma_rocks:
			if is_instance_valid(r):
				valid_rocks.append(r)
				# 4.0 radius gives a nice generous scare zone
				seagull_layer.check_scare_at(r.global_position, 4.0)
		active_magma_rocks = valid_rocks
		

	# Aim gun (apply wind drift to virtual mouse position)
	var mouse_pos = virtual_mouse_pos
	if wind_state == 2 and wind_strength > 0.0:
		wind_elapsed += delta
		# Turbulent drift: base drift + sine wobble for organic feel
		var turbulence = 1.0 + sin(wind_elapsed * 5.0) * 0.35 + sin(wind_elapsed * 13.0) * 0.15
		virtual_mouse_pos.x += wind_direction * wind_strength * turbulence * wind_level_mult * delta
		var viewport_size = get_viewport().get_visible_rect().size
		virtual_mouse_pos.x = clamp(virtual_mouse_pos.x, 0, viewport_size.x)
		mouse_pos = virtual_mouse_pos
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_normal = camera.project_ray_normal(mouse_pos)
	# Project to sun's Z depth
	var dist = (sun.position.z - ray_origin.z) / ray_normal.z
	var target_pos = ray_origin + ray_normal * dist
	
	# Constrain target_pos so we can't aim too low (prevents clipping into ground)
	target_pos.y = max(target_pos.y, -2.0)
	
	# Gun follows mouse but returns to base when not shooting
	if is_shooting:
		var aim_target = target_pos
		# Constrain aim target so gun doesn't fly off screen
		aim_target.x = clamp(aim_target.x, -20.0, 20.0)
		aim_target.y = clamp(aim_target.y, -2.0, 20.0) # Restrict downward movement
	
	gun.look_at(target_pos, Vector3.UP)
	
	# Smoothly return gun to base position if not actively recoiling
	# Recoil kicks Z forward (closer to camera) and Y up
	gun.position = gun.position.lerp(gun_base_pos, 10.0 * delta)

	# Camera recoil spring back (smoothly returns to target coordinate 0,0,5 and rotation 0)
	camera.position = camera.position.lerp(Vector3(0, 0, 5), 8.0 * delta)
	camera.rotation.x = lerp(camera.rotation.x, 0.0, 8.0 * delta)
	# Solar wind camera roll (subtle tilt to sell the push)
	var target_roll = 0.0
	if wind_state == 2 and wind_strength > 0.0 and not reduce_motion:
		target_roll = wind_direction * -0.03  # ~1.7° tilt opposite to drift
	camera.rotation.z = lerp(camera.rotation.z, target_roll, 5.0 * delta)
	
	# Dynamic FOV
	var target_fov = 75.0
	if is_shooting and can_shoot:
		if GameState.current_weapon_id == "heavy":
			target_fov = 83.0 # Wide, powerful pushback
		elif GameState.current_weapon_id == "precision":
			target_fov = 70.0 # Slight zoom-in for sniping focus
		else:
			target_fov = 77.0 # Slight push
	camera.fov = lerp(camera.fov, target_fov, 8.0 * delta)
	
	
		
	# Update crosshair position to exactly match mouse pointer
	var space = get_world_3d().direct_space_state
	var aim_origin = muzzle.global_position
	var aim_dir = -muzzle.global_basis.z
	var ray_params = PhysicsRayQueryParameters3D.create(aim_origin, aim_origin + aim_dir * 200.0)
	var result = space.intersect_ray(ray_params)
	
	crosshair_moved.emit(virtual_mouse_pos, is_catastrom_active)
			
	# Prevent sputtering when empty
	if water_tank <= 0.0:
		if can_shoot and not water_empty_sfx.playing:
			water_empty_sfx.play()
		can_shoot = false
	elif water_tank >= MAX_WATER * 0.25: # Must recharge to 25% before shooting again
		can_shoot = true
	
	# Shooting mechanics
	if is_shooting and can_shoot:
		is_firing = true
		fire_stop_timer = FIRE_STOP_DELAY
		if not shoot_loop_sfx.playing:
			shoot_loop_sfx.play()
			
		water_tank -= WATER_DRAIN_RATE * delta
		gun_spray.emitting = true
		
		# Subtle accessibility-friendly recoil kick (push gun and camera back slightly)
		if not reduce_motion:
			gun.position.z += 0.06 * delta
			gun.position.y += 0.02 * delta
			camera.position.z += 0.015 * delta
			camera.rotation.x += 0.004 * delta
		
		# Spawn wet marks on environment when water spray hits it
		if result and wet_spawn_timer <= 0.0:
			var hit_pos = result.position
			var hit_normal = result.normal
			if hit_pos.distance_to(sun.position) > 4.5:
				_spawn_wet_mark(hit_pos, hit_normal)
				wet_spawn_timer = 0.08
				if randf() < 0.3:
					_spawn_splash(hit_pos)
				
		# Check Seagull Interception
		if is_instance_valid(seagull_layer):
			for bird in seagull_layer.birds:
				var state = bird.get("state", "")
				if state == "sitting" or state == "landing":
					var b_node = bird["node"] as Node3D
					if is_instance_valid(b_node):
						var b_pos = b_node.global_position
						var vec_to_bird = b_pos - aim_origin
						var proj_t = vec_to_bird.dot(aim_dir)
						if proj_t > 0.0:
							var closest_pt = aim_origin + aim_dir * proj_t
							if b_pos.distance_to(closest_pt) < 1.5:
								seagull_layer.scare_bird(bird)
		
		# Check Solar Flare Interception (Requires ~0.33s of tracking water spray)
		var intercepted_flares = []
		for flare in active_flares:
			var f_node = flare["node"] as Node3D
			if is_instance_valid(f_node):
				var flare_pos = f_node.global_position
				var vec_to_flare = flare_pos - ray_origin
				var proj_t = vec_to_flare.dot(ray_normal)
				if proj_t > 0.0:
					var closest_pt = ray_origin + ray_normal * proj_t
					var dist_to_ray = flare_pos.distance_to(closest_pt)
					if dist_to_ray < 2.8: # Focused 2.8m radius requiring tracking aim
						# Cool & shrink flare over 0.33s of sustained hit
						flare["hp"] = (flare["hp"] as float) - (3.0 * delta)
						var cur_hp = clamp(flare["hp"] as float, 0.0, 1.0)
						f_node.scale = Vector3(cur_hp, cur_hp, cur_hp)
						
						if steam_particles and randf() < 0.2:
							steam_particles.global_position = flare_pos
							steam_particles.restart()
						if randf() < 0.2:
							_spawn_splash(flare_pos)
							
						if cur_hp <= 0.0:
							intercepted_flares.append(flare)
					
		for flare in intercepted_flares:
			var f_node = flare["node"] as Node3D
			if is_instance_valid(f_node):
				var flare_pos = f_node.global_position
				steam_particles.global_position = flare_pos
				steam_particles.emitting = true
				if sizzle_sfx:
					sizzle_sfx.play()
				if flare_intercept_sfx:
					flare_intercept_sfx.play()
				shake(0.2, 0.03)
				
				_spawn_flare_explosion(flare_pos)
				
				# Reward: Instantly refill +40% Water Tank & +2% Catastrom Charge!
				water_tank = min(MAX_WATER, water_tank + MAX_WATER * 0.40)
				GameState.catastrom_charge = min(1.0, GameState.catastrom_charge + 0.02)
				water_refill_count += 1
				water_changed.emit(water_tank, MAX_WATER)

				
				if hud and hud.has_method("_on_projectile_hit"):
					hud._on_projectile_hit()
					
				f_node.queue_free()
				active_flares.erase(flare)

		# Check hit
		var aim_dist = target_pos.distance_to(sun.position)
		if aim_dist < 5.0: # Close enough to hit the larger sun
			_on_hit(delta, target_pos)
			combo_timer += delta
			if combo_timer >= 1.5:
				if not combo_active:
					combo_active = true
					if hud and hud.has_method("show_combo"): hud.show_combo(true)
				
				var current_mult = min(3.0, 1.0 + ((combo_timer - 1.5) * 0.2))
				if hud and hud.has_method("update_combo_text"):
					hud.update_combo_text(current_mult)
		else:
			combo_timer = 0.0
			if combo_active:
				combo_active = false
				if hud and hud.has_method("show_combo"): hud.show_combo(false)
	else:
		combo_timer = max(0.0, combo_timer - delta)
		if combo_timer <= 0.0 and combo_active:
			combo_active = false
			if hud and hud.has_method("show_combo"): hud.show_combo(false)
			
		gun_spray.emitting = false
		water_tank = min(MAX_WATER, water_tank + current_weapon_recharge * delta)
			
	# Audio loop timer — stop loop layer after 0.12s of no firing
	if is_firing:
		fire_stop_timer -= delta
		if fire_stop_timer <= 0.0:
			is_firing = false
			shoot_loop_sfx.stop()
		
	
	# Update UI progress bars
	hit_cooldown = max(0.0, hit_cooldown - delta)
	wet_spawn_timer = max(0.0, wet_spawn_timer - delta)
	water_changed.emit(water_tank, MAX_WATER)
		
	if water_mat and water_mat is StandardMaterial3D:
		water_mat.uv1_offset += Vector3(0.02 * delta, 0.02 * delta, 0) # Scrolling ripples

	if GameState.catastrom_charge >= 1.0:
		if not was_catastrom_charged:
			was_catastrom_charged = true
			if hud and hud.has_method("show_toast"):
				var is_kr = GameState.language == "KR"
				var title = "카타스트롬 준비됨" if is_kr else "CATASTROM READY"
				var desc = "태양을 바다로 끌어내리세요 [F]" if is_kr else "DRAG THE SUN DOWN [F]"
				hud.show_toast(title, desc, "res://assets/ui/Catastrom.png", Color(0.8, 0.4, 1.0, 1.0))
	else:
		was_catastrom_charged = false

func _input(event: InputEvent) -> void:
	if is_title_screen:
		return
	if hud and "lose_screen" in hud and hud.lose_screen != null and hud.lose_screen.visible:
		return
	if hud and (hud.settings_screen.visible or hud.credits_screen.visible or hud.pause_screen.visible):
		is_shooting = false
		return # Input guard: ignore gameplay mouse/keyboard input while menus are open

	if game_over: return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if not is_dragging_sun:
			virtual_mouse_pos += event.relative * mouse_sensitivity
			var viewport_size = get_viewport().get_visible_rect().size
			virtual_mouse_pos.x = clamp(virtual_mouse_pos.x, 0, viewport_size.x)
			virtual_mouse_pos.y = clamp(virtual_mouse_pos.y, 0, viewport_size.y)
		
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed) or \
	   (event is InputEventKey and event.keycode == KEY_R and event.pressed):
		if GameState.ice_charges_remaining > 0:
			_shoot_ice()

	if event is InputEventKey and event.keycode == KEY_F and event.pressed and not event.echo:
		if GameState.catastrom_charge >= 1.0 and not is_catastrom_active:
			is_catastrom_active = true
			is_shooting = false
			if gun: gun.visible = false
			return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if is_catastrom_active and event.pressed and not is_dragging_sun:
			is_dragging_sun = true
			is_shooting = false
			if catastrom_sfx:
				catastrom_sfx.play()
			if hud and hud.grab_icon:
				hud.grab_icon.texture = preload("res://assets/ui/grab_closed.png")
			return
					
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			is_shooting = event.pressed
			
	if is_dragging_sun and event is InputEventMouseMotion:
		# Directly modify sun position based on mouse motion
		# Mouse moving down = positive relative.y
		if event.relative.y > 0:
			sun.position.y -= event.relative.y * 0.015
		elif event.relative.y < 0:
			sun.position.y -= event.relative.y * 0.005 # Slight resistance when pushing up
			
		sun.position.y = clamp(sun.position.y, -2.0, sun_base_pos.y + 15.0)
		
		if sun.position.y <= 0.0:
			_trigger_catastrom_dunk()

# ─────────────────────────────────────────────────────────────────────────────
# Sun Face Procedural Drawing
# ─────────────────────────────────────────────────────────────────────────────
const FACE_SIZE = 128
const FACE_COLOR = Color(1.0, 1.0, 1.0, 1.0)

func _draw_face(expression: String) -> ImageTexture:
	var img = Image.create_empty(FACE_SIZE, FACE_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var cx = FACE_SIZE / 2
	var cy = FACE_SIZE / 2
	match expression:
		"angry": _draw_angry(img, cx, cy)
		"annoyed": _draw_annoyed(img, cx, cy)
		"neutral": _draw_neutral(img, cx, cy)
		"happy": _draw_happy(img, cx, cy)
		"dizzy": _draw_dizzy(img, cx, cy)
		
	# Add the dark orange outer stroke procedurally
	_add_outline_to_image(img, 4, Color(0.6, 0.2, 0.0, 1.0))
	
	return ImageTexture.create_from_image(img)

func _add_outline_to_image(img: Image, thickness: int, color: Color) -> void:
	var outline_dict = {}
	for x in range(FACE_SIZE):
		for y in range(FACE_SIZE):
			if img.get_pixel(x, y).a > 0.5:
				for dx in range(-thickness, thickness + 1):
					for dy in range(-thickness, thickness + 1):
						if dx*dx + dy*dy <= thickness*thickness:
							var nx = x + dx
							var ny = y + dy
							if nx >= 0 and nx < FACE_SIZE and ny >= 0 and ny < FACE_SIZE:
								if img.get_pixel(nx, ny).a < 0.5:
									outline_dict[Vector2(nx, ny)] = true
	for p in outline_dict:
		img.set_pixel(int(p.x), int(p.y), color)

func _draw_circle_on_image(img: Image, cx: int, cy: int, radius: int, color: Color) -> void:
	for x in range(cx - radius, cx + radius + 1):
		for y in range(cy - radius, cy + radius + 1):
			if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= radius * radius:
				img.set_pixel(x, y, color)



func _draw_line_on_image(img: Image, x1: int, y1: int, x2: int, y2: int, thickness: int, color: Color) -> void:
	var dx = abs(x2 - x1)
	var dy = abs(y2 - y1)
	var steps = max(dx, dy)
	if steps == 0: return
	var sx = float(x2 - x1) / steps
	var sy = float(y2 - y1) / steps
	for i in range(steps + 1):
		var px = int(x1 + sx * i)
		var py = int(y1 + sy * i)
		for tx in range(-thickness/2, thickness/2 + 1):
			for ty in range(-thickness/2, thickness/2 + 1):
				var fx = px + tx
				var fy = py + ty
				if fx >= 0 and fx < FACE_SIZE and fy >= 0 and fy < FACE_SIZE:
					img.set_pixel(fx, fy, color)

func _draw_pill_on_image(img: Image, cx: int, cy: int, w: int, h: int, color: Color) -> void:
	var r = w / 2
	_draw_circle_on_image(img, cx, cy - h/2 + r, r, color)
	_draw_circle_on_image(img, cx, cy + h/2 - r, r, color)
	for x in range(cx - r, cx + r + 1):
		for y in range(cy - h/2 + r, cy + h/2 - r + 1):
			if x >= 0 and x < FACE_SIZE and y >= 0 and y < FACE_SIZE:
				img.set_pixel(x, y, color)

func _draw_half_circle_bottom(img: Image, cx: int, cy: int, radius: int, color: Color) -> void:
	for x in range(cx - radius, cx + radius + 1):
		for y in range(cy, cy + radius + 1):
			if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= radius * radius:
				if x >= 0 and x < FACE_SIZE and y >= 0 and y < FACE_SIZE:
					img.set_pixel(x, y, color)

func _draw_half_circle_top(img: Image, cx: int, cy: int, radius: int, color: Color) -> void:
	for x in range(cx - radius, cx + radius + 1):
		for y in range(cy - radius, cy + 1):
			if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= radius * radius:
				if x >= 0 and x < FACE_SIZE and y >= 0 and y < FACE_SIZE:
					img.set_pixel(x, y, color)

func _draw_half_pill_top(img: Image, cx: int, cy: int, w: int, h: int, color: Color) -> void:
	var r = w / 2
	_draw_circle_on_image(img, cx, cy - h/2 + r, r, color)
	for x in range(cx - r, cx + r + 1):
		for y in range(cy - h/2 + r, cy + h/2 + 1):
			if x >= 0 and x < FACE_SIZE and y >= 0 and y < FACE_SIZE:
				img.set_pixel(x, y, color)

func _draw_angry(img: Image, cx: int, cy: int):
	# Intense pill eyes (slightly shorter and moved down)
	_draw_pill_on_image(img, cx - 24, cy - 2, 12, 20, FACE_COLOR)
	_draw_pill_on_image(img, cx + 24, cy - 2, 12, 20, FACE_COLOR)
	# Aggressive thick eyebrows (moved higher to prevent outline merging)
	_draw_line_on_image(img, cx - 38, cy - 32, cx - 12, cy - 22, 8, FACE_COLOR)
	_draw_line_on_image(img, cx + 38, cy - 32, cx + 12, cy - 22, 8, FACE_COLOR)
	# Frown (top half of a circle)
	_draw_half_circle_top(img, cx, cy + 28, 16, FACE_COLOR)

func _draw_annoyed(img: Image, cx: int, cy: int):
	# Half-closed flat-bottom eyes
	_draw_half_pill_top(img, cx - 24, cy - 8, 12, 28, FACE_COLOR)
	_draw_half_pill_top(img, cx + 24, cy - 8, 12, 28, FACE_COLOR)
	# Small flat mouth
	_draw_pill_on_image(img, cx, cy + 24, 16, 8, FACE_COLOR)

func _draw_neutral(img: Image, cx: int, cy: int):
	# Standard soft pill eyes
	_draw_pill_on_image(img, cx - 24, cy - 8, 12, 28, FACE_COLOR)
	_draw_pill_on_image(img, cx + 24, cy - 8, 12, 28, FACE_COLOR)
	# Small dot mouth
	_draw_pill_on_image(img, cx, cy + 24, 12, 8, FACE_COLOR)

func _draw_happy(img: Image, cx: int, cy: int):
	# Large soft pill eyes
	_draw_pill_on_image(img, cx - 24, cy - 8, 14, 30, FACE_COLOR)
	_draw_pill_on_image(img, cx + 24, cy - 8, 14, 30, FACE_COLOR)
	# Big D-shaped smile
	_draw_half_circle_bottom(img, cx, cy + 12, 18, FACE_COLOR)
	# Soft blush
	_draw_circle_on_image(img, cx - 36, cy + 8, 8, Color(1.0, 0.4, 0.4, 0.8))
	_draw_circle_on_image(img, cx + 36, cy + 8, 8, Color(1.0, 0.4, 0.4, 0.8))

func _draw_dizzy(img: Image, cx: int, cy: int):
	# X eyes (left)
	_draw_line_on_image(img, cx - 34, cy - 18, cx - 14, cy + 2, 6, FACE_COLOR)
	_draw_line_on_image(img, cx - 34, cy + 2, cx - 14, cy - 18, 6, FACE_COLOR)
	# X eyes (right)
	_draw_line_on_image(img, cx + 14, cy - 18, cx + 34, cy + 2, 6, FACE_COLOR)
	_draw_line_on_image(img, cx + 14, cy + 2, cx + 34, cy - 18, 6, FACE_COLOR)
	# Squiggly mouth (Zig-zag)
	_draw_line_on_image(img, cx - 16, cy + 24, cx - 8, cy + 16, 6, FACE_COLOR)
	_draw_line_on_image(img, cx - 8, cy + 16, cx, cy + 24, 6, FACE_COLOR)
	_draw_line_on_image(img, cx, cy + 24, cx + 8, cy + 16, 6, FACE_COLOR)
	_draw_line_on_image(img, cx + 8, cy + 16, cx + 16, cy + 24, 6, FACE_COLOR)

func _update_sun_face(ratio: float) -> void:
	if not is_instance_valid(sun_face): return
	var expression: String
	var target_color: Color
	
	if ratio >= 0.75: 
		expression = "angry"
	elif ratio >= 0.50: 
		expression = "annoyed"
	elif ratio >= 0.25: 
		expression = "neutral"
	else: 
		expression = "happy"
		
	target_color = Color(2.0, 2.0, 2.0, 0.7) # Bright glowing white face (semi-transparent to blend with sun)
	
	if is_sun_frozen:
		expression = "dizzy"

	if sun_face.texture != face_textures.get(expression):
		sun_face.texture = face_textures.get(expression)
	
	if is_sun_frozen:
		sun_face.modulate = Color(0.2, 0.5, 2.5) # Deep icy blue flash
	else:
		sun_face.modulate = target_color
	
	sun_face.visible = sun.visible

func shake(duration: float, strength: float) -> void:
	if reduce_motion:
		return
	is_shaking = true
	var origin = camera.position
	var elapsed = 0.0
	while elapsed < duration:
		var offset = Vector3(
			randf_range(-strength, strength),
			randf_range(-strength, strength),
			0
		)
		camera.position = origin + offset
		elapsed += get_process_delta_time()
		await get_tree().process_frame
	camera.position = origin
	is_shaking = false

func _sync_light_to_sun() -> void:
	if sun and dir_light:
		var ref_pos = gun.global_position if (gun and gun.is_inside_tree()) else gun_base_pos
		var sun_pos = sun.global_position if sun.is_inside_tree() else sun_base_pos
		var light_dir = (ref_pos - sun_pos).normalized()
		dir_light.transform.basis = Basis.looking_at(light_dir, Vector3.UP)

func _adjust_gun_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var count = node.get_surface_override_material_count()
		if count == 0 and node.mesh:
			count = node.mesh.get_surface_count()
		for i in range(count):
			var mat = node.get_surface_override_material(i)
			if not mat and node.mesh:
				mat = node.mesh.surface_get_material(i)
			if mat is StandardMaterial3D:
				var new_mat = mat.duplicate()
				if new_mat.metallic > 0.1:
					new_mat.metallic = 0.0
				node.set_surface_override_material(i, new_mat)
	for child in node.get_children():
		_adjust_gun_materials(child)

func _setup_sun_mesh_and_material(node: Node) -> MeshInstance3D:
	var first_mesh: MeshInstance3D = null
	if node is MeshInstance3D:
		first_mesh = node
		var mat = node.mesh.surface_get_material(0) if node.mesh else null
		if mat:
			sun_mat = mat.duplicate()
		else:
			sun_mat = StandardMaterial3D.new()
		sun_mat.emission_enabled = true
		sun_mat.emission = Color(1.0, 0.7, 0.2)
		sun_mat.emission_energy_multiplier = 1.8
		node.set_surface_override_material(0, sun_mat)
	for child in node.get_children():
		var found = _setup_sun_mesh_and_material(child)
		if found and not first_mesh:
			first_mesh = found
	return first_mesh

# ─────────────────────────────────────────────────────────────────────────────
# On hit
# ─────────────────────────────────────────────────────────────────────────────
func _on_hit(delta: float, target_pos: Vector3) -> void:
	if is_instance_valid(sun_hit_tween):
		sun_hit_tween.kill()
	sun_hit_tween = create_tween()
	sun_hit_tween.tween_method(func(val): sun_mat.emission_energy_multiplier = val, 1.0, 3.5, 0.06)
	sun_hit_tween.tween_method(func(val): sun_mat.emission_energy_multiplier = val, 3.5, 1.0, 0.12)
	if not is_shaking:
		var strength = 0.015
		if GameState.current_weapon_id == "heavy": strength = 0.025
		elif GameState.current_weapon_id == "precision": strength = 0.005
		shake(0.12, strength)
	var is_critical: bool = false
	if is_shooting:
		if sunspot_node:
			var spot_dist = target_pos.distance_to(sunspot_node.global_position)
			if spot_dist < 2.5:
				is_critical = true
				
		var damage_mult: float = 1.0
		if GameState.is_survival_mode and GameState.current_wave >= 5:
			damage_mult = 1.0 + (GameState.current_wave - 4) * 0.15 # +15% damage per wave past wave 4
				
		if is_critical:
			var dmg = current_weapon_power * current_weapon_crit * damage_mult * delta
			temperature = max(0.0, temperature - dmg)
			var c_mult = 1.0
			if combo_active:
				c_mult = min(3.0, 1.0 + ((combo_timer - 1.5) * 0.2))
			GameState.catastrom_charge = min(1.0, GameState.catastrom_charge + (dmg * c_mult / 1200.0))
			if sizzle_sfx and not sizzle_sfx.playing:
				sizzle_sfx.play()
			if steam_particles:
				steam_particles.global_position = sunspot_node.global_position
				steam_particles.restart()
			critical_hit.emit()
		else:
			var dmg = current_weapon_power * damage_mult * delta
			temperature = max(0.0, temperature - dmg)
			var c_mult = 1.15 if combo_active else 1.0
			GameState.catastrom_charge = min(1.0, GameState.catastrom_charge + (dmg * c_mult / 1200.0))
			projectile_hit.emit()
			
	if hit_cooldown <= 0.0:
		hit_sfx.play()
		hit_cooldown = HIT_COOLDOWN
		
		var damage_mult: float = 1.0
		if GameState.is_survival_mode and GameState.current_wave >= 5:
			damage_mult = 1.0 + (GameState.current_wave - 4) * 0.15
			
		# Spawn floating number (calculating DPS burst for the popup)
		var dmg_val = current_weapon_power * damage_mult
		if is_critical: dmg_val *= current_weapon_crit
		_spawn_damage_number(dmg_val, is_critical, target_pos)
		
	_update_sky(false)
	
	if not particles.emitting:
		particles.restart()
	if not steam_particles.emitting:
		steam_particles.restart()
	if randf() < 0.3:
		_spawn_splash(sunspot_node.global_position)
	

		
	# Game Feel: Gun Recoil (Push gun back towards camera)
	gun.position.z += 0.05 
	gun.position.y += 0.02
			
	# Game Feel: Hit Flashing (Sun flashes white/blue briefly)
	if not is_sun_frozen:
		sun_mat.emission = Color(1.5, 1.5, 2.0)
	# Force an immediate visual update override which will be reset next frame by _update_sky
	
	if temperature <= 0.0:
		if is_two_phase and not phase2_triggered:
			phase2_triggered = true
			_trigger_phase2()
		elif GameState.is_survival_mode:
			if sun_defeated_sfx: sun_defeated_sfx.play()
			GameState.current_wave += 1
			GameState.ice_charges_remaining += 1
			
			# Boss wave reward
			if (GameState.current_wave - 1) % 5 == 0:
				water_tank = MAX_WATER
				GameState.ice_charges_remaining += 1 + GameState.bonus_ice_charges
				water_changed.emit(water_tank, MAX_WATER)
				
				# Temporarily disabled shop logic per user request
				# if hud:
				# 	get_tree().paused = true
				# 	hud.show_shop()
				
			max_survival_ice_charges = max(max_survival_ice_charges, GameState.ice_charges_remaining)
			if hud:
				hud.update_ice_charges(GameState.ice_charges_remaining, max_survival_ice_charges + GameState.bonus_ice_charges)
				
				if GameState.current_wave == 2 or GameState.current_wave == 3 or GameState.current_wave == 4:
					hud.show_weapon_unlock()
				if GameState.current_wave == 2:
					hud.show_ice_unlock()
					
				if GameState.language == "KR":
					hud.level_label.text = "웨이브 %02d" % GameState.current_wave
				else:
					hud.level_label.text = "WAVE %02d" % GameState.current_wave
				
				var flash = ColorRect.new()
				flash.color = Color(0.3, 0.7, 1.0, 0.6) if (GameState.current_wave - 1) % 5 == 0 else Color(1.0, 0.9, 0.5, 0.6)
				flash.anchor_right = 1.0
				flash.anchor_bottom = 1.0
				flash.z_index = 150
				flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
				hud.add_child(flash)
				var tw = create_tween()
				tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
				tw.tween_property(flash, "modulate:a", 0.0, 0.4)
				tw.tween_callback(flash.queue_free)
				
			sun_figure8 = GameState.current_wave >= 3
			solar_wind_enabled = GameState.current_wave >= 4
			flare_spawn_timer = min(flare_spawn_timer, max(2.5, 8.0 - (GameState.current_wave * 0.5)))
			
			sun_sway_amplitude = min(8.0, GameState.current_wave * 1.5)
			sun_sway_speed = min(2.0, 0.5 + GameState.current_wave * 0.2)
			
			# Prepare next boss wave
			if GameState.current_wave % 5 == 0:
				is_two_phase = true
				phase2_triggered = false
				phase2_heat = 100.0 # Boss always starts Phase 2 at full heat (MAX_TEMP)
			else:
				is_two_phase = false
				phase2_triggered = false
			
			if solar_wind_enabled:
				wind_state = 0
				wind_timer = randf_range(4.0, 7.0)
				wind_level_mult = min(2.5, 1.0 + (GameState.current_wave - 4) * 0.15)
				wind_strength = 0.0
				if wind_warn_label:
					wind_warn_label.visible = false
					wind_warn_label.modulate.a = 0.0
				if wind_particles: wind_particles.emitting = false
				if wind_sfx: wind_sfx.stop()
			
			temperature = MAX_TEMP
			level_timer = min(120.0, 60.0 + (level_timer * 0.5)) # Bank 50% of remaining time
			wave_timer = 0.0
			is_catastrom_active = false
			var viewport_size = get_viewport().get_visible_rect().size
			virtual_mouse_pos = viewport_size * 0.5
			if gun:
				gun.visible = true
				gun.position = gun_base_pos
				gun.rotation = Vector3.ZERO
		else:
			_win()

# ─────────────────────────────────────────────────────────────────────────────
# Temp system / Middle States
# ─────────────────────────────────────────────────────────────────────────────
func _update_sky(instant: bool) -> void:
	var ratio = temperature / MAX_TEMP
	ratio = clamp(ratio, 0.0, 1.0)
	
	# Drive shader sky heat uniform — controls orange→blue sky transition
	if _sky_shader_mat:
		_sky_shader_mat.set_shader_parameter("sun_heat", ratio)
		_sky_shader_mat.set_shader_parameter("eclipse_mix", weather_blend if active_weather == "eclipse" else 0.0)
		
	# Drive heat haze screen distortion based on temperature heat ratio
	if haze_mat:
		haze_mat.set_shader_parameter("heat_ratio", ratio)
		
	# Weather Overrides (Smoothly blended)
	var base_amb = Color(0.75, 0.65, 0.6)
	var base_dir = Color(1.0, 0.75, 0.35)
	
	var target_amb = base_amb
	var target_dir = base_dir
	
	if active_weather == "rain":
		target_amb = Color(0.4, 0.45, 0.6)
		target_dir = Color(0.6, 0.65, 0.8)
	elif active_weather == "eclipse":
		target_amb = Color(0.3, 0.1, 0.4)
		target_dir = Color(0.4, 0.1, 0.3)
		
	if world_env and world_env.environment:
		var env = world_env.environment
		env.ambient_light_color = base_amb.lerp(target_amb, weather_blend)
		env.volumetric_fog_albedo = Color(0.9, 0.6, 0.3)
		
	if dir_light:
		dir_light.light_color = base_dir.lerp(target_dir, weather_blend)

	# Sun visual phases (Middle states)
	var sun_base_albedo = Color.WHITE
	var sun_base_emission = Color(1.0, 0.7, 0.2)
	var ray_base_emission = Color(0.95, 0.35, 0.1)
	var ray_base_albedo = Color(0.95, 0.35, 0.1)
	var t_bob_spd = 2.0
	var t_bob_amp = 0.8
	var emission_mult = 1.8
	
	if not is_sun_frozen:
		if temperature > 75.0:
			sun_base_emission = Color(1.0, 0.7, 0.2)
			ray_base_emission = Color(0.95, 0.35, 0.1)
			ray_base_albedo = Color(0.95, 0.35, 0.1)
			t_bob_spd = 2.0
			t_bob_amp = 0.8
		elif temperature > 40.0:
			sun_base_emission = Color(1.0, 0.85, 0.4)
			ray_base_emission = Color(0.85, 0.45, 0.2)
			ray_base_albedo = Color(0.85, 0.45, 0.2)
			t_bob_spd = 1.2
			t_bob_amp = 0.5
		else:
			sun_base_emission = Color(0.7, 0.7, 1.0)
			ray_base_emission = Color(0.35, 0.45, 0.75)
			ray_base_albedo = Color(0.35, 0.45, 0.75)
			t_bob_spd = 0.5
			t_bob_amp = 0.5
			
	if active_weather == "eclipse":
		sun_base_albedo = sun_base_albedo.lerp(Color(0.01, 0.01, 0.02), weather_blend)
		emission_mult = lerpf(1.8, 0.0, weather_blend) # Kill the sun's internal emission completely
		ray_base_emission = ray_base_emission.lerp(Color(0.8, 0.3, 1.0), weather_blend) # Bright purple corona
		ray_base_albedo = ray_base_albedo.lerp(Color(0.5, 0.1, 0.8), weather_blend)
		t_bob_spd = lerpf(t_bob_spd, 0.2, weather_blend)
		t_bob_amp = lerpf(t_bob_amp, 0.2, weather_blend)
		
	sun_mat.albedo_color = sun_base_albedo
	sun_mat.emission = sun_base_emission
	sun_mat.emission_energy_multiplier = emission_mult
	if sun_ray_mat:
		sun_ray_mat.emission = ray_base_emission
		sun_ray_mat.albedo_color = ray_base_albedo
		sun_ray_mat.emission_energy_multiplier = lerpf(1.5, 3.0, weather_blend if active_weather == "eclipse" else 0.0)
		
	sun_bob_speed = t_bob_spd
	sun_bob_amp = t_bob_amp
	heat_changed.emit(temperature, MAX_TEMP)
	
func _trigger_catastrom_dunk() -> void:
	shake(1.5, 0.5)
	
	if sun_face:
		sun_face.texture = _draw_face("dizzy")
		
	sun_mat.emission = Color(0.0, 0.2, 1.0)
	sun_mat.albedo_color = Color(0.1, 0.5, 1.0)
	
	for i in range(5):
		var splash_pos = sun.global_position + Vector3(randf_range(-6.0, 6.0), 0, randf_range(-6.0, 6.0))
		splash_pos.y = 0.0
		_spawn_splash(splash_pos)
		
	GameState.catastrom_charge = 0.0
	is_dragging_sun = false
	is_catastrom_active = false
	if hud and hud.grab_icon:
		hud.grab_icon.texture = preload("res://assets/ui/grab_open.png")
		hud.grab_icon.visible = false
		
	# Trigger wave cleared logic
	temperature = 0.0
	_on_hit(0.01, sun.global_position)
func _win() -> void:
	if defeat_triggered: return
	defeat_triggered = true
	game_over = true
	is_shooting = false # Reset shooting state to prevent auto-firing on next level
	gun_spray.emitting = false # Fix water getting stuck on when winning

	if is_measuring:
		is_measuring = false
	
	sun_defeated_sfx.play()
	var tween = create_tween()
	tween.tween_property(sun_mat, "albedo_color", Color(0.1, 0.5, 1.0), 1.0)
	tween.parallel().tween_property(sun_mat, "emission", Color(0.0, 0.2, 1.0), 1.0)
	
	if GameState.level >= 5:
		game_complete.emit()
	else:
		GameState.level += 1
		level = GameState.level
		if level == 4:
			GameState.catastrom_charge = 1.0
		sun_defeated.emit(level)
		
		# Seamless reload
		var reload = func():
			temperature = MAX_TEMP
			water_tank = MAX_WATER
			game_over = false
			defeat_triggered = false
			cooldown_timer = 0.0
			water_refill_count = 0
			is_measuring = true
			is_catastrom_active = false
			var viewport_size = get_viewport().get_visible_rect().size
			virtual_mouse_pos = viewport_size * 0.5
			if gun:
				gun.visible = true
				gun.position = gun_base_pos
				gun.rotation = Vector3.ZERO
			
			current_config = GameState.LEVEL_CONFIG[GameState.level]
			var cfg = current_config
			WATER_DRAIN_RATE = cfg.water_drain + GameState.WEAPONS[GameState.current_weapon_id].water_drain
			heat_regen_base = cfg.heat_regen_base
			sun_sway_amplitude = cfg.sun_sway_amplitude
			sun_sway_speed = cfg.sun_sway_speed
			sun_figure8 = cfg.sun_figure8
			is_two_phase = cfg.two_phase
			phase2_heat = cfg.phase2_heat
			phase2_triggered = false
			
			solar_wind_enabled = cfg.get("solar_wind", false)
			wind_state = 0
			wind_timer = randf_range(WIND_IDLE_MIN, WIND_IDLE_MAX)
			wind_strength = 0.0
			wind_elapsed = 0.0
			wind_level_mult = 1.3 if GameState.level >= 5 else 1.0
			if wind_warn_label:
				wind_warn_label.visible = false
				wind_warn_label.modulate.a = 0.0
			if wind_particles: wind_particles.emitting = false
			if wind_sfx: wind_sfx.stop()
			
			level_timer = cfg.timer
			timer_running = true
			emit_signal("level_config_loaded", cfg.timer)
			_reset_weather()
			
			GameState.ice_charges_remaining = cfg.ice_charges
			if hud:
				hud.update_ice_charges(GameState.ice_charges_remaining, cfg.ice_charges)
				if GameState.level == 2:
					hud.show_weapon_unlock()
				if GameState.level == 3:
					hud.show_weapon_unlock()
					hud.show_ice_unlock()
				if GameState.level == 4:
					hud.show_weapon_unlock()
			
			if sun_mat:
				sun_mat.albedo_color = Color(1.0, 1.0, 1.0)
				sun_mat.emission = Color(1.0, 0.7, 0.2)
				sun_mat.emission_energy_multiplier = 1.8
			if haze_mat:
				haze_mat.set_shader_parameter("heat_ratio", 1.0)
			_update_sky(true) # force update visuals back to scorching
			if hud and hud.has_method("hide_win_screen"):
				hud.hide_win_screen()
			
		await get_tree().create_timer(1.8).timeout
		reload.call()


func _create_sfx(path: String, vol: float, poly: int, bus_name: String = "SFX_WEAPON") -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	player.bus = bus_name
	player.volume_db = vol
	player.max_polyphony = poly
	add_child(player)
	return player

func _add_collision_to_prop(node: Node) -> void:
	if node is MeshInstance3D:
		node.create_trimesh_collision()
	for child in node.get_children():
		_add_collision_to_prop(child)

func _spawn_wet_mark(pos: Vector3, normal: Vector3) -> void:
	var decal = Decal.new()
	decal.size = Vector3(1.2, 1.2, 1.2)
	decal.texture_albedo = load("res://assets/ui_circle.png")
	
	# Draw dark damp wet color (soft dark brown/grey)
	decal.modulate = Color(0.12, 0.08, 0.05, 0.75)
	decal.position = pos
	
	# Point decal along collision normal to lay flat on surfaces
	if normal.is_equal_approx(Vector3.UP):
		decal.rotation.x = PI / 2.0
	elif normal.is_equal_approx(Vector3.DOWN):
		decal.rotation.x = -PI / 2.0
	else:
		decal.look_at(pos + normal, Vector3.UP)
		
	add_child(decal)
	
	# Evaporate / dry up after 1.5 seconds delay over 2.5 seconds
	var tween = create_tween()
	tween.tween_property(decal, "modulate:a", 0.0, 2.5).set_delay(1.5)
	tween.tween_callback(decal.queue_free)

# ─────────────────────────────────────────────────────────────────────────────
# Solar Wind Hazard
# ─────────────────────────────────────────────────────────────────────────────
func _process_solar_wind(delta: float) -> void:
	# Ice Burst suppresses wind entirely
	if is_sun_frozen:
		if wind_state == 2:
			wind_strength = 0.0
			if wind_particles: wind_particles.emitting = false
		return
	
	wind_timer -= delta
	
	match wind_state:
		0:  # Idle — waiting for next gust
			if wind_timer <= 0.0:
				wind_state = 1
				wind_timer = WIND_WARN_DURATION
				wind_direction = [-1.0, 1.0].pick_random()
				wind_elapsed = 0.0
				# Show warning
				if not wind_warn_label:
					_setup_solar_wind_visuals()
				if wind_warn_label:
					var is_kr = GameState.language == "KR"
					wind_warn_label.text = "⚠ 태양풍 접근!" if is_kr else "⚠ WIND INCOMING!"
					wind_warn_label.modulate = Color(1.0, 0.9, 0.3, 1.0)
					wind_warn_label.visible = true
					wind_warn_label.modulate.a = 0.0
					var tw = create_tween()
					tw.tween_property(wind_warn_label, "modulate:a", 1.0, 0.3)
				# Start wind SFX building up
				if wind_sfx and not wind_sfx.playing:
					wind_sfx.play()
				var sfx_pb = wind_sfx.get_stream_playback() as AudioStreamGeneratorPlayback if wind_sfx else null
				if sfx_pb:
					_fill_wind_warning_audio(sfx_pb)
		1:  # Warning — pulsing label buildup
			# Pulse the warning label scale
			if wind_warn_label and not reduce_motion:
				var pulse = 1.0 + sin(wind_elapsed * 12.0) * 0.08
				wind_warn_label.pixel_size = 0.01 * pulse
			wind_elapsed += delta
			if wind_timer <= 0.0:
				wind_state = 2
				wind_timer = WIND_ACTIVE_DURATION
				wind_strength = WIND_DRIFT_SPEED
				wind_elapsed = 0.0
				# Switch warning text
				if wind_warn_label:
					var is_kr = GameState.language == "KR"
					wind_warn_label.text = "태양풍!" if is_kr else "SOLAR WIND!"
					wind_warn_label.modulate = Color(1.0, 0.6, 0.1, 1.0)
					wind_warn_label.pixel_size = 0.01  # Reset pulse
				# Enable particle streaks (match wind direction)
				if wind_particles:
					var pmat = wind_particles.process_material as ParticleProcessMaterial
					if pmat:
						pmat.direction = Vector3(wind_direction, 0, 0)
					wind_particles.emitting = true
				# Fill active wind audio
				if wind_sfx:
					var sfx_pb = wind_sfx.get_stream_playback() as AudioStreamGeneratorPlayback
					if sfx_pb:
						_fill_wind_active_audio(sfx_pb)
		2:  # Active — drifting aim
			# Smooth ramp-down near end
			if wind_timer < 0.8:
				wind_strength = lerp(wind_strength, 0.0, 4.0 * delta)
			if wind_timer <= 0.0:
				wind_state = 0
				# Level 5: shorter cooldown between gusts
				var idle_min = WIND_IDLE_MIN * (0.7 if wind_level_mult > 1.0 else 1.0)
				var idle_max = WIND_IDLE_MAX * (0.7 if wind_level_mult > 1.0 else 1.0)
				wind_timer = randf_range(idle_min, idle_max)
				wind_strength = 0.0
				# Hide warning and particles
				if wind_warn_label:
					var tw = create_tween()
					tw.tween_property(wind_warn_label, "modulate:a", 0.0, 0.3)
					tw.tween_callback(func(): wind_warn_label.visible = false)
				if wind_particles:
					wind_particles.emitting = false
				if wind_sfx:
					wind_sfx.stop()

	# Update visual reactivity to wind
	var wind_factor = clamp(wind_strength / WIND_DRIFT_SPEED, 0.0, 1.0)
	if haze_mat:
		haze_mat.set_shader_parameter("wind_strength", wind_factor)
		haze_mat.set_shader_parameter("wind_dir", wind_direction)
		
	if wind_state == 2 and sun_mat:
		# Base emission is 1.0. We pulse it up to 1.8 rapidly during wind
		sun_mat.emission_energy_multiplier = 1.0 + sin(wind_elapsed * 25.0) * 0.8 * wind_factor
	elif wind_state != 2 and sun_mat:
		sun_mat.emission_energy_multiplier = lerp(sun_mat.emission_energy_multiplier, 1.0, 5.0 * delta)

func _setup_solar_wind_visuals() -> void:
	# Warning label (3D text near the sun)
	wind_warn_label = Label3D.new()
	wind_warn_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	wind_warn_label.no_depth_test = true
	var is_kr = GameState.language == "KR"
	wind_warn_label.text = "⚠ 태양풍 접근!" if is_kr else "⚠ WIND INCOMING!"
	wind_warn_label.font = preload("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	wind_warn_label.font_size = 300
	wind_warn_label.modulate = Color(1.0, 0.9, 0.3, 1.0)
	wind_warn_label.outline_size = 16
	wind_warn_label.outline_modulate = Color.BLACK
	wind_warn_label.visible = false
	wind_warn_label.global_position = Vector3(0, 8, -15)
	add_child(wind_warn_label)
	
	# GPU Particle streaks — horizontal lines rushing across the screen
	wind_particles = GPUParticles3D.new()
	var pmat = ParticleProcessMaterial.new()
	pmat.direction = Vector3(1, 0, 0)  # Will be flipped by wind_direction
	pmat.spread = 10.0
	pmat.initial_velocity_min = 15.0
	pmat.initial_velocity_max = 25.0
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.3
	pmat.scale_max = 0.8
	# Alpha curve for smooth fade in/out
	var alpha_curve_tex = CurveTexture.new()
	var acurve = Curve.new()
	acurve.add_point(Vector2(0, 0))
	acurve.add_point(Vector2(0.2, 1.0))
	acurve.add_point(Vector2(0.8, 1.0))
	acurve.add_point(Vector2(1.0, 0.0))
	alpha_curve_tex.curve = acurve
	pmat.alpha_curve = alpha_curve_tex
	
	wind_particles.process_material = pmat
	wind_particles.trail_enabled = true
	wind_particles.trail_lifetime = 0.3
	
	var mesh = RibbonTrailMesh.new()
	mesh.size = 0.2
	var width_curve = Curve.new()
	width_curve.add_point(Vector2(0, 0.1))
	width_curve.add_point(Vector2(0.2, 1.0))
	width_curve.add_point(Vector2(1.0, 0.0))
	mesh.curve = width_curve
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.85, 0.3, 0.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.7, 0.2)
	mat.emission_energy_multiplier = 2.0
	mat.use_particle_trails = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material = mat
	wind_particles.draw_pass_1 = mesh
	
	wind_particles.amount = 60
	wind_particles.lifetime = 0.8
	wind_particles.explosiveness = 0.0
	wind_particles.emitting = false
	wind_particles.global_position = Vector3(0, 3, -5)
	# Wide emission box so streaks fill the viewport
	var pmat2 = wind_particles.process_material as ParticleProcessMaterial
	if pmat2:
		pmat2.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		pmat2.emission_box_extents = Vector3(0.5, 6.0, 8.0)
	add_child(wind_particles)
	
	# Synthesized wind SFX
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 22050.0
	gen.buffer_length = 0.5
	wind_sfx = AudioStreamPlayer.new()
	wind_sfx.stream = gen
	wind_sfx.bus = "SFX_UI"
	wind_sfx.volume_db = -16.0
	add_child(wind_sfx)

func _fill_wind_warning_audio(pb: AudioStreamGeneratorPlayback) -> void:
	# Rising low hum to build tension
	var frames = 2000
	for i in range(frames):
		var t = float(i) / 22050.0
		var freq = lerp(120.0, 300.0, float(i) / float(frames))
		var envelope = float(i) / float(frames) * 0.15
		pb.push_frame(Vector2.ONE * sin(TAU * freq * t) * envelope)

func _fill_wind_active_audio(pb: AudioStreamGeneratorPlayback) -> void:
	# Sustained whoosh — noise-like sound with modulation
	var frames = 4000
	for i in range(frames):
		var t = float(i) / 22050.0
		var noise = sin(TAU * 180.0 * t) * 0.3 + sin(TAU * 340.0 * t) * 0.2 + sin(TAU * 90.0 * t) * 0.15
		var wobble = sin(TAU * 3.0 * t) * 0.5 + 0.5
		pb.push_frame(Vector2.ONE * noise * wobble * 0.2)

func _trigger_phase2() -> void:
	timer_running = false # pause timer briefly
	
	temperature = phase2_heat
	heat_changed.emit(temperature, MAX_TEMP)
	phase2_started.emit()
	
	sun_sway_speed *= 1.3
	sun_sway_amplitude *= 1.2
	
	# Visual flare — spike emission briefly
	if is_instance_valid(sun_hit_tween):
		sun_hit_tween.kill()
	var tw = create_tween()
	tw.tween_method(func(val): sun_mat.emission_energy_multiplier = val, 1.2, 4.0, 0.2)
	tw.tween_method(func(val): sun_mat.emission_energy_multiplier = val, 4.0, 2.0, 0.3)
	
	await get_tree().create_timer(0.6).timeout
	timer_running = true

func _shoot_ice() -> void:
	GameState.ice_charges_remaining -= 1
	var total = max_survival_ice_charges if GameState.is_survival_mode else current_config.ice_charges
	total += GameState.bonus_ice_charges
	hud.update_ice_charges(GameState.ice_charges_remaining, total)
	
	ice_shoot_sfx.play()
	
	var tw = create_tween()
	tw.tween_property(gun, "position:y", gun_base_pos.y - 0.2, 0.05)
	tw.tween_property(gun, "position:y", gun_base_pos.y, 0.1)
	

	
	var blast = ice_blast_scene.instantiate()
	blasts.add_child(blast)
	
	var cam_space = get_world_3d().direct_space_state
	var ray_start = camera.project_ray_origin(virtual_mouse_pos)
	var ray_end = ray_start + camera.project_ray_normal(virtual_mouse_pos) * 1000.0
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	var result = cam_space.intersect_ray(query)
	var target_pos = ray_end
	if result:
		target_pos = result.position
		
	blast.global_position = muzzle.global_position
	blast.look_at(target_pos, Vector3.UP)

func _spawn_damage_number(amount: float, is_crit: bool, pos: Vector3) -> void:
	var lbl = Label3D.new()
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.no_depth_test = true
	lbl.text = "-%d" % round(amount * 10.0)
	lbl.font = preload("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	lbl.font_size = 600 if is_crit else 350
	lbl.modulate = Color(1.0, 0.8, 0.1) if is_crit else Color(0.3, 0.8, 1.0)
	lbl.outline_size = 32
	lbl.outline_modulate = Color.BLACK
	
	var offset = Vector3(randf_range(-2.5, 2.5), randf_range(-1.5, 1.5), randf_range(-2.0, 2.0))
	add_child(lbl)
	lbl.global_position = pos + offset
	
	var tw = create_tween().set_parallel(true)
	tw.tween_property(lbl, "global_position:y", lbl.global_position.y + 5.0, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tw.chain().tween_callback(lbl.queue_free)

func _spawn_splash(pos: Vector3) -> void:
	if splash_particles_pool.is_empty(): return
	var splash = splash_particles_pool[splash_idx]
	splash.global_position = pos
	splash.restart()
	splash_idx = (splash_idx + 1) % splash_particles_pool.size()

func _spawn_flare_explosion(pos: Vector3) -> void:
	var poof = GPUParticles3D.new()
	var pmat = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 180.0
	pmat.initial_velocity_min = 5.0
	pmat.initial_velocity_max = 10.0
	pmat.gravity = Vector3(0, 2.0, 0)
	pmat.scale_min = 0.5
	pmat.scale_max = 1.5
	
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.5, 0.5, 0.5)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 1.0, 1.0, 0.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = mat
	
	poof.process_material = pmat
	poof.draw_pass_1 = mesh
	poof.emitting = true
	poof.one_shot = true
	poof.explosiveness = 1.0
	poof.amount = 15
	poof.lifetime = 0.5
	poof.global_position = pos
	
	add_child(poof)
	get_tree().create_timer(1.0).timeout.connect(poof.queue_free)
	
	# Spawn 3-5 magma rock debris
	var num_rocks = randi_range(3, 5)
	for i in range(num_rocks):
		var rock = RigidBody3D.new()
		var phys_mat = PhysicsMaterial.new()
		phys_mat.bounce = 0.0 # Heavy rock, no bounce on sand
		phys_mat.friction = 1.0
		rock.physics_material_override = phys_mat
		rock.mass = 5.0
		
		var rock_mesh_node = magma_rock_prefabs.pick_random().instantiate()
		rock_mesh_node.scale = Vector3(0.5, 0.5, 0.5)
		for c in rock_mesh_node.get_children():
			if c is MeshInstance3D:
				c.material_override = flare_mat
		rock_mesh_node.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
		
		var col = CollisionShape3D.new()
		var col_shape = SphereShape3D.new()
		col_shape.radius = 0.5
		col.shape = col_shape
		
		rock.add_child(rock_mesh_node)
		rock.add_child(col)
		rock.position = pos + Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
		add_child(rock)
		active_magma_rocks.append(rock)
		
		var push_dir = Vector3(randf_range(-0.8, 0.8), randf_range(0.2, 1.2), randf_range(0.2, 1.0)).normalized()
		rock.apply_central_impulse(push_dir * randf_range(10.0, 18.0))
		rock.apply_torque_impulse(Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5)))
		
		var tw_rock = create_tween()
		tw_rock.tween_interval(3.0)
		tw_rock.tween_property(rock_mesh_node, "scale", Vector3.ZERO, 0.5)
		tw_rock.tween_callback(rock.queue_free)

func _spawn_ice_nova() -> void:
	if not sun: return
	var nova = GPUParticles3D.new()
	var pmat = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 0, 1)
	pmat.spread = 180.0
	pmat.initial_velocity_min = 15.0
	pmat.initial_velocity_max = 25.0
	pmat.gravity = Vector3(0, 0, 0)
	pmat.scale_min = 0.5
	pmat.scale_max = 2.0
	
	var mesh = BoxMesh.new()
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.8, 1.0, 0.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.2, 0.5, 1.0)
	mesh.material = mat
	
	nova.process_material = pmat
	nova.draw_pass_1 = mesh
	nova.emitting = true
	nova.one_shot = true
	nova.explosiveness = 1.0
	nova.amount = 40
	nova.lifetime = 0.8
	nova.global_position = sun.global_position
	
	add_child(nova)
	get_tree().create_timer(1.0).timeout.connect(nova.queue_free)

func freeze_sun() -> void:
	is_sun_frozen = true
	sun_freeze_timer = 3.0
	ice_hit_sfx.play()
	
	# Hit-Stop (Juice): Microscopic pause to sell the heavy impact
	Engine.time_scale = 0.05
	var hitstop_timer = get_tree().create_timer(0.08, true, false, true)
	hitstop_timer.timeout.connect(func():
		Engine.time_scale = 1.0
		shake(0.5, 0.1) # Bigger shake when time resumes
	)
	
	_spawn_ice_nova()
	if frost_aura:
		frost_aura.emitting = true
		
	if sun_mat:
		var tw = create_tween()
		tw.tween_property(sun_mat, "albedo_color", Color(0.8, 0.9, 1.0), 0.3)
		tw.parallel().tween_property(sun_mat, "emission", Color(0.1, 0.5, 1.0), 0.3)
	if sun_ray_mat:
		var tw2 = create_tween()
		tw2.tween_property(sun_ray_mat, "emission", Color(0.2, 0.6, 1.0), 0.3)

func _on_game_paused() -> void:
	timer_running = false
	shoot_loop_sfx.stream_paused = true

func _on_game_resumed() -> void:
	timer_running = true
	shoot_loop_sfx.stream_paused = false

# ─────────────────────────────────────────────────────────────────────────────
# Weather System
# ─────────────────────────────────────────────────────────────────────────────
func _reset_weather() -> void:
	_end_weather_event()
	var wave_len = GameState.LEVEL_CONFIG[GameState.level].timer if not GameState.is_survival_mode else 60.0
	weather_timer = randf_range(wave_len * 0.4, wave_len * 0.8)

func _start_weather_event(force_type: String = "") -> void:
	if active_weather != "none": return
	
	var is_rain = randf() > 0.5
	if force_type == "rain": is_rain = true
	elif force_type == "eclipse": is_rain = false
	
	var is_kr = GameState.language == "KR"
	
	if is_rain:
		active_weather = "rain"
		weather_duration = 10.0
		weather_rain_particles.emitting = true
		if is_kr:
			hud.show_toast("기상 이변", "폭우! 물이 무한입니다.", "res://assets/ui/ui_adventure/PNG/Default/minimap_icon_exclamation_white.png", Color(0.4, 0.8, 1.0))
		else:
			hud.show_toast("Weather Event", "Rainstorm! Water is endless.", "res://assets/ui/ui_adventure/PNG/Default/minimap_icon_exclamation_white.png", Color(0.4, 0.8, 1.0))
	else:
		active_weather = "eclipse"
		weather_duration = 10.0
		if is_kr:
			hud.show_toast("기상 이변", "일식!", "res://assets/ui/ui_adventure/PNG/Default/minimap_icon_exclamation_red.png", Color(0.8, 0.2, 0.2))
		else:
			hud.show_toast("Weather Event", "Solar Eclipse!", "res://assets/ui/ui_adventure/PNG/Default/minimap_icon_exclamation_red.png", Color(0.8, 0.2, 0.2))
	
	_update_sky(false)

func _end_weather_event() -> void:
	if active_weather == "none": return
	
	if active_weather == "rain":
		weather_rain_particles.emitting = false
		
	active_weather = "none"
	_update_sky(false)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F12:
			var img = get_viewport().get_texture().get_image()
			var time_str = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
			var path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + "/SummerNights_" + time_str + ".png"
			img.save_png(path)
			print("Screenshot saved to: ", path)
			
	if GameState.is_dev_mode and event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_R:
				_end_weather_event()
				_start_weather_event("rain")
			KEY_E:
				_end_weather_event()
				_start_weather_event("eclipse")
			KEY_W:
				if level_timer > 0.0:
					level_timer = 0.1 # Skip wave
