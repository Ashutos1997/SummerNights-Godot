extends Node3D
## Summer Nights 3D - Water Gun vs The Sun

# ─── Game State ──────────────────────────────────────────────────────────────
var temperature: float    = 100.0
const MAX_TEMP: float     = 100.0
var water_tank: float     = 100.0
const MAX_WATER: float    = 100.0
var WATER_DRAIN_RATE: float = 8.75 # Reduced by 65% from 25.0 to make water tank last 3x longer
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
var heat_regen_base: float = 2.0
var sun_sway_amplitude: float = 0.0
var sun_sway_speed: float = 0.0
var sun_figure8: bool = false
var sun_move_time: float = 0.0
var level_timer: float = 0.0
var timer_running: bool = false
var is_two_phase: bool = false
var phase2_triggered: bool = false
var phase2_heat: float = 0.0


# ─── Sky colours at each temp threshold ──────────────────────────────────────
const SKY := [
	{"t": 100, "bg": Color(0.88, 0.14, 0.03)},
	{"t":  75, "bg": Color(1.00, 0.40, 0.00)},
	{"t":  50, "bg": Color(1.00, 0.68, 0.00)},
	{"t":  25, "bg": Color(0.38, 0.73, 0.93)},
	{"t":   0, "bg": Color(0.08, 0.53, 0.85)},
]

# ─── Node references ─────────────────────────────────────────────────────────
var world_env:   WorldEnvironment
var env_res:     Environment
var sky_mat:     ProceduralSkyMaterial
var _sky_shader_mat: ShaderMaterial
var haze_mat:    ShaderMaterial
var steam_particles: GPUParticles3D
var dir_light:   DirectionalLight3D
var camera:      Camera3D
var sun:         Node3D
var sun_mesh:    MeshInstance3D
var sun_mat:     StandardMaterial3D
var sun_ray_mat: StandardMaterial3D
var sun_rays_node: Node3D
var sun_face:    Sprite3D
var sun_face_shadow: Sprite3D
var face_textures: Dictionary = {}
var gun:         Node3D
var muzzle:      Marker3D
var virtual_mouse_pos: Vector2
var blasts:      Node3D
var particles:   GPUParticles3D

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

var foliage_props: Array[Node3D] = []

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
	print("[MEASURE] Level started, timer running")

	var cfg = GameState.LEVEL_CONFIG[GameState.level]
	WATER_DRAIN_RATE = cfg.water_drain
	heat_regen_base = cfg.heat_regen_base
	sun_sway_amplitude = cfg.sun_sway_amplitude
	sun_sway_speed = cfg.sun_sway_speed
	sun_figure8 = cfg.sun_figure8
	is_two_phase = cfg.two_phase
	phase2_heat = cfg.phase2_heat
	phase2_triggered = false
	
	level_timer = cfg.timer
	timer_running = true

	virtual_mouse_pos = get_viewport().get_visible_rect().size / 2.0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hud = load("res://scenes/HUD.tscn").instantiate()
	add_child(hud)
	heat_changed.connect(hud._on_heat_changed)
	water_changed.connect(hud._on_water_changed)
	sun_defeated.connect(hud._on_sun_defeated)
	game_complete.connect(hud.show_end_screen)
	hud.game_paused.connect(_on_game_paused)
	hud.game_resumed.connect(_on_game_resumed)
	
	GameState.ice_charges_remaining = cfg.ice_charges
	hud.update_ice_charges(GameState.ice_charges_remaining, cfg.ice_charges)
	if GameState.level == 3:
		hud.show_ice_unlock()
		
	projectile_hit.connect(hud._on_projectile_hit)
	timer_tick.connect(hud._on_timer_tick)
	timer_expired.connect(hud._on_timer_expired)
	phase2_started.connect(hud._on_phase2_started)
	emit_signal("level_config_loaded", cfg.timer)
	crosshair_moved.connect(hud._on_crosshair_moved)
	hud.sensitivity_changed.connect(func(val): mouse_sensitivity = val)
	hud.reduce_motion_changed.connect(func(enabled): reduce_motion = enabled)
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

	print("--- DIAGNOSTICS START ---")
	print("Audio driver: ", AudioServer.get_driver_name())
	print("Audio mix rate: ", AudioServer.get_mix_rate())
	print("Audio output latency: ", AudioServer.get_output_latency())
	print("Current water drain rate: ", WATER_DRAIN_RATE)
	if dir_light:
		print("DirLight energy: ", dir_light.light_energy)
		print("DirLight shadow enabled: ", dir_light.shadow_enabled)
	if env_res:
		print("Ambient energy: ", env_res.ambient_light_energy)
		print("Ambient color: ", env_res.ambient_light_color)
	if sun_mat:
		print("Sun emission: ", sun_mat.emission_energy_multiplier)
	for child in get_children():
		print("Main child: ", child.name, " type: ", child.get_class())
	if sun:
		for child in sun.get_children():
			print("Sun child: ", child.name, " type: ", child.get_class())
	print("--- DIAGNOSTICS END ---")

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
 
	var sun_light = OmniLight3D.new()
	sun_light.light_color = Color(1.0, 0.7, 0.3)
	sun_light.light_energy = 2.0
	sun_light.omni_range = 30.0
	sun.add_child(sun_light)
	
	var shadow_sprite = Sprite3D.new()
	shadow_sprite.name = "SunFaceShadow"
	shadow_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	shadow_sprite.pixel_size = 0.06
	shadow_sprite.position = Vector3(0.08, -0.08, 3.39) # Offset down-right
	shadow_sprite.no_depth_test = true
	shadow_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	shadow_sprite.render_priority = -1 # Render behind face
	shadow_sprite.modulate = Color(0, 0, 0, 0.9) # Dark drop shadow
	sun.add_child(shadow_sprite)
	sun_face_shadow = shadow_sprite
	
	var face_sprite = Sprite3D.new()
	face_sprite.name = "SunFace"
	face_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	face_sprite.pixel_size = 0.06
	face_sprite.position = Vector3(0, 0, 3.4)
	face_sprite.no_depth_test = true
	face_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	face_sprite.render_priority = 0
	sun.add_child(face_sprite)
	sun_face = face_sprite
	
	face_textures = {
		"angry":   _draw_face("angry"),
		"annoyed": _draw_face("annoyed"),
		"neutral": _draw_face("neutral"),
		"happy":   _draw_face("happy"),
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
 
	# ── Gun ──────────────────────────────────────────────────────────────────
	gun = Node3D.new()
	gun.position = gun_base_pos
	add_child(gun)
	
	# Load Kenney's 3D Blaster GLB
	var gun_model = load("res://assets/blaster.glb").instantiate()
	# Rotate 180 on Y because Kenney models default to facing +Z (backward relative to camera)
	gun_model.rotation_degrees = Vector3(0, 180, 0)
	gun_model.scale = Vector3(1.0, 1.0, 1.0)
	gun_model.position = Vector3(0, -0.3, -0.1) # Position comfortably in bottom-right corner
	_adjust_gun_materials(gun_model)
	gun.add_child(gun_model)
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
		sunspot_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		sunspot_tween.tween_property(sunspot_node, "scale", Vector3(1.25, 1.25, 1.25), 0.5)
		sunspot_tween.tween_property(sunspot_node, "scale", Vector3(1.0, 1.0, 1.0), 0.5)

func _spawn_solar_flare() -> void:
	flare_spawn_timer = randf_range(9.0, 12.0)
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
		mesh_inst.material_override = flare_mat
		mesh_inst.position = offset
		flare_root.add_child(mesh_inst)
		
	var flare_spin_speed = Vector3(randf_range(-2.0, 2.0), randf_range(1.0, 3.0), randf_range(-2.0, 2.0))

	# Fiery OmniLight Aura
	var f_light = OmniLight3D.new()
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
		return
	if hud and (hud.settings_screen.visible or hud.credits_screen.visible or hud.pause_screen.visible):
		if gun_spray: gun_spray.emitting = false
		is_shooting = false
		timer_running = false
		return
		
	timer_running = true

	if timer_running and not defeat_triggered:
		if is_sun_frozen:
			sun_freeze_timer -= delta
			if sun_freeze_timer <= 0.0:
				is_sun_frozen = false
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
			timer_expired.emit()

		
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
	
	# Dynamic Wind Sway on tropical foliage
	var wind_t = Time.get_ticks_msec() * 0.001
	for f_prop in foliage_props:
		if is_instance_valid(f_prop):
			var sway_z = sin(wind_t * 1.6 + f_prop.position.x * 0.1) * 0.035
			var sway_x = cos(wind_t * 1.2 + f_prop.position.z * 0.1) * 0.02
			f_prop.rotation.z = sway_z
			f_prop.rotation.x = sway_x
		
	# Increase difficulty based on level
	var regen_rate = 5.0 + (level * 1.5)
		
	if is_measuring:
		cooldown_timer += delta

	# Sun bob and rotate
	sun.position.y = sun_base_pos.y + sin(sun_time * sun_bob_speed) * sun_bob_amp
	
	if sun_sway_amplitude > 0.0:
		var spd_mult = 0.0 if is_sun_frozen else 1.0
		sun_move_time += delta * spd_mult
		var x_offset = sin(sun_move_time * sun_sway_speed) * sun_sway_amplitude
		var z_offset = 0.0
		if sun_figure8:
			z_offset = sin(sun_move_time * sun_sway_speed * 2.0) * (sun_sway_amplitude * 0.4)
		sun.position.x = sun_base_pos.x + x_offset
		sun.position.z = sun_base_pos.z + z_offset
	else:
		sun.position.x = sun_base_pos.x
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
	sun.scale = Vector3(target_scale, target_scale, target_scale)
	
	_update_sun_face(ratio)
	
	# Heat Regeneration
	if temperature < MAX_TEMP and not is_sun_frozen:
		temperature += heat_regen_base * delta # Sun gets hotter over time
		_update_sky(false)

	# Aim gun
	var mouse_pos = virtual_mouse_pos
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
		
	# Update crosshair position to exactly match mouse pointer
	var space = get_world_3d().direct_space_state
	var aim_origin = muzzle.global_position
	var aim_dir = -muzzle.global_basis.z
	var ray_params = PhysicsRayQueryParameters3D.create(aim_origin, aim_origin + aim_dir * 200.0)
	var result = space.intersect_ray(ray_params)
	
	crosshair_moved.emit(virtual_mouse_pos, false)
			
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
							
						if cur_hp <= 0.0:
							intercepted_flares.append(flare)
					
		for flare in intercepted_flares:
			var f_node = flare["node"] as Node3D
			if is_instance_valid(f_node):
				if steam_particles:
					steam_particles.global_position = f_node.global_position
					steam_particles.restart()
				if sizzle_sfx:
					sizzle_sfx.play()
				
				# Reward: Instantly refill +30% Water Tank!
				water_tank = min(MAX_WATER, water_tank + MAX_WATER * 0.30)
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
	else:
		gun_spray.emitting = false
		water_tank = min(MAX_WATER, water_tank + 15.0 * delta)
			
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

func _input(event: InputEvent) -> void:
	if hud and "lose_screen" in hud and hud.lose_screen != null and hud.lose_screen.visible:
		return
	if hud and (hud.settings_screen.visible or hud.credits_screen.visible or hud.pause_screen.visible):
		is_shooting = false
		return # Input guard: ignore gameplay mouse/keyboard input while menus are open

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P:
			_capture_screenshot()
	if game_over: return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		virtual_mouse_pos += event.relative * mouse_sensitivity
		var viewport_size = get_viewport().get_visible_rect().size
		virtual_mouse_pos.x = clamp(virtual_mouse_pos.x, 0, viewport_size.x)
		virtual_mouse_pos.y = clamp(virtual_mouse_pos.y, 0, viewport_size.y)
		
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed) or \
	   (event is InputEventKey and event.keycode == KEY_R and event.pressed):
		if GameState.ice_charges_remaining > 0:
			_shoot_ice()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			is_shooting = event.pressed

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
	return ImageTexture.create_from_image(img)

func _draw_circle_on_image(img: Image, cx: int, cy: int, radius: int, color: Color) -> void:
	for x in range(cx - radius, cx + radius + 1):
		for y in range(cy - radius, cy + radius + 1):
			if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= radius * radius:
				if x >= 0 and x < FACE_SIZE and y >= 0 and y < FACE_SIZE:
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
	# Intense pill eyes
	_draw_pill_on_image(img, cx - 24, cy - 4, 12, 24, FACE_COLOR)
	_draw_pill_on_image(img, cx + 24, cy - 4, 12, 24, FACE_COLOR)
	# Aggressive thick eyebrows intersecting eyes
	_draw_line_on_image(img, cx - 40, cy - 24, cx - 12, cy - 12, 10, FACE_COLOR)
	_draw_line_on_image(img, cx + 40, cy - 24, cx + 12, cy - 12, 10, FACE_COLOR)
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

func _update_sun_face(ratio: float) -> void:
	if not is_instance_valid(sun_face): return
	var expression: String
	var target_color: Color
	
	if ratio >= 0.75: 
		expression = "angry"
		target_color = Color(3.0, 0.2, 0.0) # Intense fiery red/orange glow
	elif ratio >= 0.50: 
		expression = "annoyed"
		target_color = Color(2.0, 0.8, 0.1) # Bright warm golden glow
	elif ratio >= 0.25: 
		expression = "neutral"
		target_color = Color(1.2, 1.0, 0.8) # Soft warm white glow
	else: 
		expression = "happy"
		target_color = Color(0.5, 2.0, 3.0) # Vibrant cyan/blue watery glow
	
	if sun_face.texture != face_textures.get(expression):
		sun_face.texture = face_textures.get(expression)
		if is_instance_valid(sun_face_shadow):
			sun_face_shadow.texture = face_textures.get(expression)
	
	if is_sun_frozen:
		sun_face.modulate = Color(0.2, 0.5, 2.5) # Deep icy blue flash
	else:
		sun_face.modulate = target_color
	
	sun_face.visible = sun.visible
	if is_instance_valid(sun_face_shadow):
		sun_face_shadow.visible = sun.visible

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

func _capture_screenshot() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var image = get_viewport().get_texture().get_image()
	if image:
		image.save_png("res://debug_endscreen.png")
		print("Screenshot saved to debug_endscreen.png")
	get_tree().quit()

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
		shake(0.12, 0.015)
	if hit_cooldown <= 0.0:
		hit_sfx.play()
		hit_cooldown = HIT_COOLDOWN
	var regen_rate = 5.0 + (level * 1.5)
	if not is_shooting:
		temperature = min(MAX_TEMP, temperature + regen_rate * delta)
	else:
		# Check if hitting active Sunspot / Critical Heat Vent
		var is_critical: bool = false
		if sunspot_node:
			var spot_dist = target_pos.distance_to(sunspot_node.global_position)
			if spot_dist < 2.5:
				is_critical = true
				
		if is_critical:
			temperature = max(0.0, temperature - 24.0 * delta) # 2.4x Critical Cooling Boost!
			if sizzle_sfx and not sizzle_sfx.playing:
				sizzle_sfx.play()
			if steam_particles:
				steam_particles.global_position = sunspot_node.global_position
				steam_particles.restart()
			critical_hit.emit()
		else:
			temperature = max(0.0, temperature - 10.0 * delta) # Balanced standard cooling
			projectile_hit.emit()
		
	_update_sky(false)
	
	if not particles.emitting:
		particles.restart()
	if not steam_particles.emitting:
		steam_particles.restart()
	

		
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
		
	# Drive heat haze screen distortion based on temperature heat ratio
	if haze_mat:
		haze_mat.set_shader_parameter("heat_ratio", ratio)

	# Sun visual phases (Middle states)
	if not is_sun_frozen:
		if temperature > 75.0:
			# Scorching
			sun_mat.emission = Color(1.0, 0.7, 0.2)
			if sun_ray_mat:
				sun_ray_mat.emission = Color(0.95, 0.35, 0.1)
				sun_ray_mat.albedo_color = Color(0.95, 0.35, 0.1)
			sun_bob_speed = 2.0
			sun_bob_amp = 0.8
		elif temperature > 40.0:
			# Neutralizing
			sun_mat.emission = Color(1.0, 0.85, 0.4)
			if sun_ray_mat:
				sun_ray_mat.emission = Color(0.85, 0.45, 0.2)
				sun_ray_mat.albedo_color = Color(0.85, 0.45, 0.2)
			sun_bob_speed = 1.2
			sun_bob_amp = 0.5
		else:
			# Weakened
			sun_mat.emission = Color(0.7, 0.7, 1.0)
			if sun_ray_mat:
				sun_ray_mat.emission = Color(0.35, 0.45, 0.75)
				sun_ray_mat.albedo_color = Color(0.35, 0.45, 0.75)
			sun_bob_speed = 0.5
	heat_changed.emit(temperature, MAX_TEMP)
	

func _win() -> void:
	if defeat_triggered: return
	defeat_triggered = true
	game_over = true
	is_shooting = false # Reset shooting state to prevent auto-firing on next level
	gun_spray.emitting = false # Fix water getting stuck on when winning

	if is_measuring:
		is_measuring = false
		print("[MEASURE] Sun cooled in: ", snapped(cooldown_timer, 0.01), " seconds")
		print("[MEASURE] Water refills used: ", water_refill_count)
	
	sun_defeated_sfx.play()
	var tween = create_tween()
	tween.tween_property(sun_mat, "albedo_color", Color(0.1, 0.5, 1.0), 1.0)
	tween.parallel().tween_property(sun_mat, "emission", Color(0.0, 0.2, 1.0), 1.0)
	
	if GameState.level >= 5:
		game_complete.emit()
	else:
		GameState.level += 1
		level = GameState.level
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
			
			var cfg = GameState.LEVEL_CONFIG[GameState.level]
			WATER_DRAIN_RATE = cfg.water_drain
			heat_regen_base = cfg.heat_regen_base
			sun_sway_amplitude = cfg.sun_sway_amplitude
			sun_sway_speed = cfg.sun_sway_speed
			sun_figure8 = cfg.sun_figure8
			is_two_phase = cfg.two_phase
			phase2_heat = cfg.phase2_heat
			phase2_triggered = false
			
			level_timer = cfg.timer
			timer_running = true
			emit_signal("level_config_loaded", cfg.timer)
			
			GameState.ice_charges_remaining = cfg.ice_charges
			if hud:
				hud.update_ice_charges(GameState.ice_charges_remaining, cfg.ice_charges)
				if GameState.level == 3:
					hud.show_ice_unlock()
			
			print("[MEASURE] Level started, timer running")
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
	var cfg = GameState.LEVEL_CONFIG[GameState.level]
	hud.update_ice_charges(GameState.ice_charges_remaining, cfg.ice_charges)
	
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

func freeze_sun() -> void:
	is_sun_frozen = true
	sun_freeze_timer = 3.0
	ice_hit_sfx.play()
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
