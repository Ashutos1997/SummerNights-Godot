class_name SolarConvergenceManager
extends Node3D

## Solar Convergence Manager (Regad Omega / Solar Driver Boss Encounter)
## Phase 1: Orbital Ocular Swarm ("Solar Eyes" / "Helios Drones")
## Features custom low-poly Tokusatsu GLB models, multi-axis 3D elliptical orbits,
## physical water stream interception, dynamic damage progression, and Ice Blast shatter.

signal drone_destroyed(pos: Vector3)
signal drone_shattered_by_ice(pos: Vector3)
signal convergence_triggered()
signal convergence_drone_docked(drone_index: int, pos: Vector3)
signal convergence_completed()
signal solar_driver_equipped(pos: Vector3)
signal harmonic_tether_severed(pair_idx: int, pos: Vector3)
signal harmonic_matrix_collapsed()
signal interceptor_destroyed(pos: Vector3)

enum State {
	IDLE,
	ORBITAL_SWARM,
	CONVERGENCE_CHARGING,
	CONVERGENCE_IMPLODING,
	OMEGA_SUN
}

var current_state: State = State.IDLE

var sun_node: Node3D
var camera_node: Camera3D

var active_drones: Array[Dictionary] = []
var orbit_time: float = 0.0

# ── Wave 55+ Interceptor Escorts (Active Stream Interception) ───────────────
var last_water_ray_origin: Vector3 = Vector3(0, 0, 5)
var last_water_ray_normal: Vector3 = Vector3(0, 0, -1)
var water_active_timer: float = 0.0

# ── Wave 50+ Harmonic Resonance Matrix (Milestone 3) ───────────────────────
var is_harmonic_matrix: bool = false
var harmonic_pairs: Array[Dictionary] = []
var active_tethers_count: int = 0
var stun_timer: float = 0.0

# ── Solar Driver & Equatorial Belt (Milestone 2) ───────────────────────────
var driver_root: Node3D = null
var driver_buckle: Node3D = null
var belt_strap_left: Node3D = null
var belt_strap_right: Node3D = null
var driver_core_mat: StandardMaterial3D = null
var driver_conduit_mat: StandardMaterial3D = null
var driver_shockwave_particles: CPUParticles3D = null
var dock_particles_left: CPUParticles3D = null
var dock_particles_right: CPUParticles3D = null
var is_driver_equipped: bool = false
var is_convergence_active: bool = false
var docked_drone_count: int = 0
var driver_anim_time: float = 0.0


const DRONE_SCENE = preload("res://assets/models/solar_eye_drone.glb")

# Audio references (Open-Source CC0 Drone SFX by rubberduck / OpenGameArt)
var hit_streams: Array[AudioStream] = []
var hit_players: Array[AudioStreamPlayer] = []
var hit_player_idx: int = 0
var hit_sfx_cooldown: float = 0.0

var sfx_shatter_metal: AudioStreamPlayer
var sfx_shatter_glass: AudioStreamPlayer
var sfx_shatter_core: AudioStreamPlayer
var sfx_ice_shatter_glass: AudioStreamPlayer
var sfx_ice_blast: AudioStreamPlayer
var sfx_driver_lock: AudioStreamPlayer
var sfx_driver_overdrive: AudioStreamPlayer
var sfx_drone_shield_hum: AudioStreamPlayer
var drone_hum_tween: Tween = null

func _ready() -> void:
	_init_audio()

func setup(sun: Node3D, cam: Camera3D) -> void:
	sun_node = sun
	camera_node = cam
	setup_solar_driver()

func _init_audio() -> void:
	# 4 variations of CC0 metal impact recordings
	hit_streams = [
		load("res://assets/audio/sfx/drone_metal_hit_01.ogg"),
		load("res://assets/audio/sfx/drone_metal_hit_02.ogg"),
		load("res://assets/audio/sfx/drone_metal_hit_03.ogg"),
		load("res://assets/audio/sfx/drone_metal_hit_04.ogg")
	]
	for i in range(4):
		var hp = AudioStreamPlayer.new()
		hp.bus = "Master"
		hp.volume_db = -8.0
		add_child(hp)
		hit_players.append(hp)

	# Water Destruction (Mechanical Rupture + Glass Fracture + Core Blast)
	sfx_shatter_metal = AudioStreamPlayer.new()
	sfx_shatter_metal.stream = load("res://assets/audio/sfx/drone_shatter_metal.ogg")
	sfx_shatter_metal.bus = "Master"
	sfx_shatter_metal.volume_db = -2.0
	add_child(sfx_shatter_metal)

	sfx_shatter_glass = AudioStreamPlayer.new()
	sfx_shatter_glass.stream = load("res://assets/audio/sfx/drone_shatter_glass.ogg")
	sfx_shatter_glass.bus = "Master"
	sfx_shatter_glass.volume_db = -3.0
	add_child(sfx_shatter_glass)

	sfx_shatter_core = AudioStreamPlayer.new()
	sfx_shatter_core.stream = load("res://assets/audio/sfx/shield_break.ogg")
	sfx_shatter_core.bus = "Master"
	sfx_shatter_core.volume_db = -2.0
	add_child(sfx_shatter_core)

	# Ice Blast Shatter (Cryo-Frost Glacial Shatter + Glass Cascade)
	sfx_ice_shatter_glass = AudioStreamPlayer.new()
	sfx_ice_shatter_glass.stream = load("res://assets/audio/sfx/drone_ice_shatter_glass.ogg")
	sfx_ice_shatter_glass.bus = "Master"
	sfx_ice_shatter_glass.volume_db = 1.0
	add_child(sfx_ice_shatter_glass)

	sfx_ice_blast = AudioStreamPlayer.new()
	sfx_ice_blast.stream = load("res://assets/audio/sfx/ice_hit.ogg")
	sfx_ice_blast.bus = "Master"
	sfx_ice_blast.volume_db = 0.0
	add_child(sfx_ice_blast)

	# Driver Belt Clamping & Lock SFX
	sfx_driver_lock = AudioStreamPlayer.new()
	sfx_driver_lock.stream = load("res://assets/audio/sfx/driver_lock.ogg")
	sfx_driver_lock.bus = "Master"
	sfx_driver_lock.volume_db = 0.5
	add_child(sfx_driver_lock)

	# Phase 2 Overdrive Surge SFX
	sfx_driver_overdrive = AudioStreamPlayer.new()
	sfx_driver_overdrive.stream = load("res://assets/audio/sfx/driver_overdrive.ogg")
	sfx_driver_overdrive.bus = "Master"
	sfx_driver_overdrive.volume_db = 1.5
	add_child(sfx_driver_overdrive)

	# Golden Drone Shield Ambient Hum (Looping with dynamic entrance & volume ducking)
	sfx_drone_shield_hum = AudioStreamPlayer.new()
	sfx_drone_shield_hum.stream = load("res://assets/audio/sfx/drone_shield_hum.ogg")
	sfx_drone_shield_hum.bus = "Master"
	sfx_drone_shield_hum.volume_db = -18.0
	add_child(sfx_drone_shield_hum)

func _start_drone_hum() -> void:
	if not sfx_drone_shield_hum:
		return
	if drone_hum_tween and drone_hum_tween.is_valid():
		drone_hum_tween.kill()

	sfx_drone_shield_hum.volume_db = -18.0
	if not sfx_drone_shield_hum.playing:
		sfx_drone_shield_hum.play()

	# Start soft and gracefully duck down to a very subtle ambient background level
	drone_hum_tween = create_tween()
	drone_hum_tween.tween_interval(1.5)
	drone_hum_tween.tween_property(sfx_drone_shield_hum, "volume_db", -28.0, 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _stop_drone_hum() -> void:
	if drone_hum_tween and drone_hum_tween.is_valid():
		drone_hum_tween.kill()
	if sfx_drone_shield_hum and sfx_drone_shield_hum.playing:
		drone_hum_tween = create_tween()
		drone_hum_tween.tween_property(sfx_drone_shield_hum, "volume_db", -45.0, 0.35)
		drone_hum_tween.tween_callback(func():
			if sfx_drone_shield_hum:
				sfx_drone_shield_hum.stop()
				sfx_drone_shield_hum.volume_db = -18.0
		)

# ─────────────────────────────────────────────────────────────────────────────
# Phase 1: Orbital Swarm Spawning
# ─────────────────────────────────────────────────────────────────────────────
func start_orbital_swarm(count: int = 6, wave: int = 1, is_phase2: bool = false) -> void:
	clear_drones()
	current_state = State.ORBITAL_SWARM
	orbit_time = 0.0

	# When drones appear, ensure the driver is equipped!
	if not is_driver_equipped:
		materialize_solar_driver(true)
	else:
		if driver_root and is_instance_valid(driver_root):
			driver_root.visible = true
		if driver_buckle and is_instance_valid(driver_buckle):
			driver_buckle.scale = Vector3.ONE
			driver_buckle.position = Vector3.ZERO
		if belt_strap_left and is_instance_valid(belt_strap_left):
			belt_strap_left.scale = Vector3.ONE
			belt_strap_left.rotation.y = 0.0
		if belt_strap_right and is_instance_valid(belt_strap_right):
			belt_strap_right.scale = Vector3.ONE
			belt_strap_right.rotation.y = 0.0

	if is_phase2:
		# Overdrive re-ignition
		if sfx_driver_overdrive:
			sfx_driver_overdrive.play()
		if driver_core_mat:
			driver_core_mat.emission = Color(1.0, 0.35, 0.10)
			driver_core_mat.emission_energy_multiplier = 14.0
			var c_tw = create_tween()
			c_tw.tween_property(driver_core_mat, "emission_energy_multiplier", 4.5, 1.0).set_trans(Tween.TRANS_QUAD)
		if driver_conduit_mat:
			driver_conduit_mat.emission = Color(1.0, 0.45, 0.15)
			driver_conduit_mat.emission_energy_multiplier = 6.0
			var cn_tw = create_tween()
			cn_tw.tween_property(driver_conduit_mat, "emission_energy_multiplier", 3.0, 1.0).set_trans(Tween.TRANS_QUAD)

	_start_drone_hum()

	for i in range(count):
		var drone_data = _create_drone(i, count, wave, is_phase2)
		active_drones.append(drone_data)
		add_child(drone_data["node"])

		# Launch drones from belt waist with staggered pop
		var d_node = drone_data["node"] as Node3D
		d_node.scale = Vector3.ZERO
		var tw = create_tween()
		tw.tween_interval(0.20 + i * 0.05)
		tw.tween_property(d_node, "scale", Vector3(2.3, 2.3, 2.3), 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if wave >= 50 and not is_phase2:
		_setup_harmonic_matrix()
	else:
		_clear_harmonic_matrix()

	# Deploy Interceptor Escorts on Wave 55+ (1 on Wave 55, 2 on Wave 60+)
	var num_interceptors = 0
	if wave >= 60:
		num_interceptors = 2
	elif wave >= 55:
		num_interceptors = 1

	for j in range(num_interceptors):
		var interceptor_data = _create_interceptor_drone(j, num_interceptors, wave)
		active_drones.append(interceptor_data)
		add_child(interceptor_data["node"])

		var d_node = interceptor_data["node"] as Node3D
		d_node.scale = Vector3.ZERO
		var tw = create_tween()
		tw.tween_interval(0.35 + j * 0.15)
		tw.tween_property(d_node, "scale", Vector3(1.7, 1.7, 1.7), 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _create_interceptor_drone(index: int, total: int, wave: int) -> Dictionary:
	var drone_root = Node3D.new()
	drone_root.name = "InterceptorDrone_%d" % index
	drone_root.scale = Vector3(1.7, 1.7, 1.7)

	var model_inst = DRONE_SCENE.instantiate() as Node3D
	drone_root.add_child(model_inst)

	var casing_mats: Array[StandardMaterial3D] = []
	var pearl_mats: Array[StandardMaterial3D] = []
	var pupil_mat: StandardMaterial3D = null

	var mesh_instances = model_inst.find_children("", "MeshInstance3D", true)
	for mi in mesh_instances:
		var mesh_node = mi as MeshInstance3D
		if mesh_node and mesh_node.mesh:
			for s_idx in range(mesh_node.mesh.get_surface_count()):
				var orig_mat = mesh_node.get_active_material(s_idx)
				if orig_mat:
					var dup_mat = orig_mat.duplicate() as StandardMaterial3D
					dup_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
					dup_mat.specular_mode = BaseMaterial3D.SPECULAR_TOON
					dup_mat.rim_enabled = true
					dup_mat.rim = 0.90
					dup_mat.rim_tint = 0.60
					dup_mat.backlight_enabled = true
					dup_mat.backlight = Color(0.15, 0.45, 0.65)
					mesh_node.set_surface_override_material(s_idx, dup_mat)

					var m_name = dup_mat.resource_name if dup_mat.resource_name != "" else orig_mat.resource_name
					if "Gold" in m_name:
						casing_mats.append(dup_mat)
					elif "Pearl" in m_name:
						pearl_mats.append(dup_mat)
					elif "Solar" in m_name or "Pupil" in m_name or "Core" in m_name or dup_mat.emission_enabled:
						if not pupil_mat:
							pupil_mat = dup_mat

	# Plasma thrusters on the back of the interceptor
	var thrusters = CPUParticles3D.new()
	thrusters.name = "ThrusterExhaust"
	thrusters.amount = 16
	thrusters.lifetime = 0.22
	thrusters.explosiveness = 0.05
	thrusters.direction = Vector3(0, 0, 1)
	thrusters.spread = 15.0
	thrusters.initial_velocity_min = 4.0
	thrusters.initial_velocity_max = 8.0
	thrusters.gravity = Vector3.ZERO
	thrusters.color = Color(0.2, 0.90, 1.0, 0.85)

	var p_mesh = BoxMesh.new()
	p_mesh.size = Vector3(0.06, 0.06, 0.12)
	var p_mat = StandardMaterial3D.new()
	p_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	p_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	p_mat.albedo_color = Color(0.3, 0.95, 1.0)
	p_mat.emission_enabled = true
	p_mat.emission = Color(0.2, 0.9, 1.0)
	p_mat.emission_energy_multiplier = 6.0
	p_mesh.material = p_mat
	thrusters.mesh = p_mesh
	thrusters.position = Vector3(0, 0, 0.20)
	drone_root.add_child(thrusters)

	# Radiant camera-facing cyan lens flare on the eye
	var eye_flare = MeshInstance3D.new()
	eye_flare.name = "InterceptorEyeFlare"
	var sphere = SphereMesh.new()
	sphere.radius = 0.32
	sphere.height = 0.64
	eye_flare.mesh = sphere
	var mat_ef = StandardMaterial3D.new()
	mat_ef.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_ef.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_ef.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat_ef.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat_ef.albedo_color = Color(0.25, 0.92, 1.0, 0.95)
	mat_ef.emission_enabled = true
	mat_ef.emission = Color(0.2, 0.90, 1.0)
	mat_ef.emission_energy_multiplier = 9.0
	eye_flare.material_override = mat_ef
	drone_root.add_child(eye_flare)

	# Dynamic Crack Fracture Overlay Meshes
	var mesh_minor = _build_crack_mesh(index + 20, false)
	var crack_minor = MeshInstance3D.new()
	crack_minor.name = "CrackMinor"
	crack_minor.mesh = mesh_minor
	crack_minor.visible = false
	var mat_minor = StandardMaterial3D.new()
	mat_minor.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_minor.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_minor.render_priority = 2
	mat_minor.albedo_color = Color(0.4, 0.95, 1.0, 0.95)
	mat_minor.emission_enabled = true
	mat_minor.emission = Color(0.2, 0.9, 1.0)
	mat_minor.emission_energy_multiplier = 3.5
	crack_minor.material_override = mat_minor
	drone_root.add_child(crack_minor)

	var mesh_major = _build_crack_mesh(index + 20, true)
	var crack_major = MeshInstance3D.new()
	crack_major.name = "CrackMajor"
	crack_major.mesh = mesh_major
	crack_major.visible = false
	var mat_major = StandardMaterial3D.new()
	mat_major.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_major.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_major.render_priority = 3
	mat_major.albedo_color = Color(0.6, 0.95, 1.0, 0.95)
	mat_major.emission_enabled = true
	mat_major.emission = Color(0.3, 0.95, 1.0)
	mat_major.emission_energy_multiplier = 4.5
	crack_major.material_override = mat_major
	drone_root.add_child(crack_major)

	# Coolant steam vent
	var vent_fx = CPUParticles3D.new()
	vent_fx.name = "VentFX"
	vent_fx.emitting = false
	vent_fx.amount = 6
	vent_fx.lifetime = 0.5
	vent_fx.direction = Vector3(0, 1, -0.3)
	vent_fx.spread = 35.0
	vent_fx.initial_velocity_min = 1.0
	vent_fx.initial_velocity_max = 2.2
	vent_fx.gravity = Vector3(0, 3.5, 0)
	var v_mat = StandardMaterial3D.new()
	v_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	v_mat.albedo_color = Color(0.4, 0.9, 1.0, 0.7)
	var v_mesh = BoxMesh.new()
	v_mesh.size = Vector3(0.05, 0.05, 0.05)
	v_mesh.material = v_mat
	vent_fx.mesh = v_mesh
	vent_fx.position = Vector3(0, 0, -0.36)
	drone_root.add_child(vent_fx)

	var sun_pos = sun_node.global_position if (sun_node and is_instance_valid(sun_node)) else Vector3(0, 13.5, -42)
	var start_pos = sun_pos + Vector3(-6.0 if index == 0 else 6.0, 8.0, 20.0)
	drone_root.global_position = start_pos

	var max_hp = 120.0 + minf(60.0, (wave - 55) * 2.5)

	return {
		"node": drone_root,
		"index": 100 + index,
		"hp": max_hp,
		"max_hp": max_hp,
		"hit_flash": 0.0,
		"casing_mats": casing_mats,
		"pearl_mats": pearl_mats,
		"pupil_mat": pupil_mat,
		"crack_minor": crack_minor,
		"crack_major": crack_major,
		"crack_mat_minor": mat_minor,
		"crack_mat_major": mat_major,
		"vent_fx": vent_fx,
		"thrusters": thrusters,
		"is_interceptor": true,
		"interceptor_idx": index,
		"total_interceptors": total,
		"patrol_offset": index * PI,
		"phase_offset": index * PI,
		"orbit_speed": 1.0,
		"radius_x": 0.0,
		"radius_y": 0.0,
		"radius_z": 0.0,
		"tilt_angle": 0.0,
		"prev_x": start_pos.x
	}

func _create_drone(index: int, total: int, wave: int = 1, is_phase2: bool = false) -> Dictionary:
	var drone_root = Node3D.new()
	drone_root.name = "SolarEyeDrone_%d" % index
	drone_root.scale = Vector3(2.3, 2.3, 2.3) # Scaled for crisp silhouette readability & arcade presence from beach

	# Instantiate the custom low-poly Tokusatsu Solar Eye Drone model
	var model_inst = DRONE_SCENE.instantiate() as Node3D
	drone_root.add_child(model_inst)

	# Extract materials for dynamic color shifts and hit flashing
	var casing_mats: Array[StandardMaterial3D] = []
	var pearl_mats: Array[StandardMaterial3D] = []
	var pupil_mat: StandardMaterial3D = null

	var mesh_instances = model_inst.find_children("", "MeshInstance3D", true)
	for mi in mesh_instances:
		var mesh_node = mi as MeshInstance3D
		if mesh_node and mesh_node.mesh:
			for s_idx in range(mesh_node.mesh.get_surface_count()):
				var orig_mat = mesh_node.get_active_material(s_idx)
				if orig_mat:
					var dup_mat = orig_mat.duplicate() as StandardMaterial3D
					# Apply stylized Summer Nights toon shading and golden sunset rim lighting
					dup_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
					dup_mat.specular_mode = BaseMaterial3D.SPECULAR_TOON
					dup_mat.rim_enabled = true
					dup_mat.rim = 0.85
					dup_mat.rim_tint = 0.45
					dup_mat.backlight_enabled = true
					dup_mat.backlight = Color(0.38, 0.28, 0.16)
					mesh_node.set_surface_override_material(s_idx, dup_mat)

					var m_name = dup_mat.resource_name if dup_mat.resource_name != "" else orig_mat.resource_name
					if "Gold" in m_name:
						casing_mats.append(dup_mat)
					elif "Pearl" in m_name:
						pearl_mats.append(dup_mat)
					elif "Solar" in m_name or "Pupil" in m_name or "Core" in m_name or dup_mat.emission_enabled:
						if not pupil_mat:
							pupil_mat = dup_mat

	# Dynamic Coronal Orbit Geometry:
	# Wave 30-39: Smooth circular rotation around the Sun's perimeter
	# Wave 40+: "Infinity Lattice" (Counter-rotating double tilted planes +/-33 deg)
	var is_infinity_lattice: bool = (wave >= 40)
	var ring_id: int = 0
	var tilt_angle: float = 0.0
	var orbit_speed: float = 0.0
	var phase_offset: float = 0.0
	var rx: float = 0.0
	var ry: float = 0.0
	var rz: float = 0.0
	var base_pupil_col: Color = Color(1.0, 0.78, 0.18)

	# Ensure sun_node is resolved before positioning
	if not sun_node or not is_instance_valid(sun_node):
		var main = get_tree().current_scene if get_tree() else null
		if main and main.get("sun") and is_instance_valid(main.sun):
			sun_node = main.sun

	var sun_pos = sun_node.global_position if (sun_node and is_instance_valid(sun_node)) else Vector3(0, 13.5, -42)

	if is_infinity_lattice:
		ring_id = index % 2 # 0: Ring A (Ascending Gold), 1: Ring B (Descending Violet)
		var ring_total: int = int(ceil(float(total) / 2.0)) if ring_id == 0 else int(floor(float(total) / 2.0))
		var ring_idx: int = int(index / 2)
		phase_offset = (float(ring_idx) / maxf(1.0, float(ring_total))) * TAU

		# Ring A tilts +38 deg, Ring B tilts -38 deg
		tilt_angle = deg_to_rad(38.0) if ring_id == 0 else deg_to_rad(-38.0)

		# Counter-rotating speeds: Ring A clockwise (+), Ring B counter-clockwise (-)
		var speed_mult = 1.35 if is_phase2 else 1.0
		orbit_speed = (0.88 * speed_mult) if ring_id == 0 else (-0.88 * speed_mult)

		# Pronounced elliptical aspect ratio (~2.3:1) so tilted rings form a clear 3D "X" / Infinity Lattice
		rx = 16.6 + (ring_idx % 2) * 0.5
		ry = 7.2 + (ring_idx % 2) * 0.4
		# Ring A orbits slightly ahead along Z to avoid z-fighting at intersection nodes
		rz = 5.2 if ring_id == 0 else 3.8

		if is_phase2:
			base_pupil_col = Color(1.0, 0.35, 0.10) if ring_id == 0 else Color(1.0, 0.18, 0.48)
		else:
			base_pupil_col = Color(1.0, 0.82, 0.25) if ring_id == 0 else Color(0.95, 0.38, 1.0)

		# Initial position on tilted plane with guaranteed shield clearance
		var unrot_x = cos(phase_offset) * rx
		var unrot_y = sin(phase_offset) * ry
		var px = unrot_x * cos(tilt_angle) - unrot_y * sin(tilt_angle)
		var py = unrot_x * sin(tilt_angle) + unrot_y * cos(tilt_angle)
		var dist_sq = px * px + py * py
		var shield_front_z = sqrt(maxf(0.0, 10.6 * 10.6 - dist_sq))
		var pz = maxf(4.5, shield_front_z + 2.5) + (1.4 if ring_id == 0 else 0.0)
		drone_root.global_position = sun_pos + Vector3(px, py, pz)
	else:
		var angle_fraction = float(index) / float(total)
		orbit_speed = (0.85 + (index * 0.06)) * (1.0 if index % 2 == 0 else -1.0)
		phase_offset = angle_fraction * TAU
		var base_r = 14.6 + (index % 3) * 0.7
		rx = base_r
		ry = base_r * 0.90
		rz = 4.4 + (index % 3) * 0.6
		base_pupil_col = Color(1.0, 0.25, 0.10) if is_phase2 else Color(1.0, 0.78, 0.18)

		var init_t = phase_offset
		drone_root.global_position = sun_pos + Vector3(
			cos(init_t) * rx,
			sin(init_t) * ry,
			rz + sin(init_t * 1.6 + index) * 0.4
		)

	if pupil_mat:
		pupil_mat.emission = base_pupil_col
		pupil_mat.emission_energy_multiplier = 4.5 if is_infinity_lattice else (4.0 if is_phase2 else 3.2)

	# Dynamic wave-scaled HP (Wave 1: 26.3 HP | Wave 20: 51 HP | Wave 30: 64 HP | Wave 40: 77 HP | Phase 2 discount)
	var calculated_hp = 25.0 + (wave * 1.3)
	if is_phase2:
		calculated_hp *= 0.70 # Fast, brittle Overdrive escort

	# Dynamic Crack Fracture Overlay Meshes
	var mesh_minor = _build_crack_mesh(index, false)
	var crack_minor = MeshInstance3D.new()
	crack_minor.name = "CrackMinor"
	crack_minor.mesh = mesh_minor
	crack_minor.visible = false
	var mat_minor = StandardMaterial3D.new()
	mat_minor.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_minor.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_minor.render_priority = 2
	mat_minor.albedo_color = Color(1.0, 0.88, 0.45, 0.95)
	mat_minor.emission_enabled = true
	mat_minor.emission = Color(1.0, 0.84, 0.35)
	mat_minor.emission_energy_multiplier = 2.8
	crack_minor.material_override = mat_minor
	drone_root.add_child(crack_minor)

	var mesh_major = _build_crack_mesh(index, true)
	var crack_major = MeshInstance3D.new()
	crack_major.name = "CrackMajor"
	crack_major.mesh = mesh_major
	crack_major.visible = false
	var mat_major = StandardMaterial3D.new()
	mat_major.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_major.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_major.render_priority = 3
	mat_major.albedo_color = Color(1.0, 0.70, 0.24, 0.95)
	mat_major.emission_enabled = true
	mat_major.emission = Color(1.0, 0.68, 0.22)
	mat_major.emission_energy_multiplier = 3.8
	crack_major.material_override = mat_major
	drone_root.add_child(crack_major)

	# Trapped Coolant Steam Wisps (leaking coolant vapor when heavily fractured)
	var vent_fx = CPUParticles3D.new()
	vent_fx.name = "VentFX"
	vent_fx.emitting = false
	vent_fx.amount = 6
	vent_fx.lifetime = 0.6
	vent_fx.direction = Vector3(0, 1, -0.3)
	vent_fx.spread = 35.0
	vent_fx.initial_velocity_min = 1.0
	vent_fx.initial_velocity_max = 2.2
	vent_fx.gravity = Vector3(0, 3.5, 0)
	var v_mat = StandardMaterial3D.new()
	v_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	v_mat.albedo_color = Color(0.55, 0.92, 1.0, 0.65)
	var v_mesh = BoxMesh.new()
	v_mesh.size = Vector3(0.05, 0.05, 0.05)
	v_mesh.material = v_mat
	vent_fx.mesh = v_mesh
	vent_fx.position = Vector3(0, 0, -0.36)
	drone_root.add_child(vent_fx)

	return {
		"node": drone_root,
		"casing_mats": casing_mats,
		"pearl_mats": pearl_mats,
		"pupil_mat": pupil_mat,
		"crack_minor": crack_minor,
		"crack_major": crack_major,
		"crack_mat_minor": mat_minor,
		"crack_mat_major": mat_major,
		"vent_fx": vent_fx,
		"orbit_speed": orbit_speed,
		"phase_offset": phase_offset,
		"radius_x": rx,
		"radius_y": ry,
		"radius_z": rz,
		"hp": calculated_hp,
		"max_hp": calculated_hp,
		"hit_flash": 0.0,
		"index": index,
		"is_infinity_lattice": is_infinity_lattice,
		"ring_id": ring_id,
		"tilt_angle": tilt_angle,
		"base_pupil_color": base_pupil_col,
		"is_harmonic_anchor": false,
		"harmonic_pair_idx": -1
	}

# ─────────────────────────────────────────────────────────────────────────────
# Procedural 3D Crack Fracture Mesh Generator
# ─────────────────────────────────────────────────────────────────────────────
func _build_crack_mesh(seed_val: int, is_major: bool) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var branch_count = 5 if is_major else 3
	var max_radius = 0.58 if is_major else 0.32
	var half_w = 0.016 if is_major else 0.010

	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val * 100 + (99 if is_major else 33)

	var main_branch_points: Array[Array] = []

	for b in range(branch_count):
		var base_angle = (float(b) / float(branch_count)) * TAU + rng.randf_range(-0.25, 0.25)
		var num_segs = 4 if is_major else 3
		var seg_pts: Array[Vector3] = []

		# Start near center aperture ring
		var r_start = 0.05
		var cur_x = cos(base_angle) * r_start
		var cur_y = sin(base_angle) * r_start
		var cur_z = -0.40 + sqrt(cur_x * cur_x + cur_y * cur_y) * 0.22
		seg_pts.append(Vector3(cur_x, cur_y, cur_z))

		for s in range(1, num_segs + 1):
			var t = float(s) / float(num_segs)
			var r = lerpf(r_start, max_radius, t)
			var ang = base_angle + rng.randf_range(-0.35, 0.35)
			var px = cos(ang) * r
			var py = sin(ang) * r
			var pz = -0.40 + sqrt(px * px + py * py) * 0.22
			seg_pts.append(Vector3(px, py, pz))

		main_branch_points.append(seg_pts)

		# Build ribbon quads for this branch
		for i in range(seg_pts.size() - 1):
			var p0 = seg_pts[i]
			var p1 = seg_pts[i + 1]
			var dir2d = Vector2(p1.x - p0.x, p1.y - p0.y)
			if dir2d.length_squared() < 0.0001:
				continue
			var norm2d = Vector2(-dir2d.y, dir2d.x).normalized() * half_w

			var v0_l = p0 + Vector3(norm2d.x, norm2d.y, 0)
			var v0_r = p0 - Vector3(norm2d.x, norm2d.y, 0)
			var v1_l = p1 + Vector3(norm2d.x, norm2d.y, 0)
			var v1_r = p1 - Vector3(norm2d.x, norm2d.y, 0)

			st.set_normal(Vector3(0, 0, -1))
			st.add_vertex(v0_l)
			st.add_vertex(v0_r)
			st.add_vertex(v1_l)

			st.add_vertex(v1_l)
			st.add_vertex(v0_r)
			st.add_vertex(v1_r)

	# Subtle hairline connecting fractures for major damage
	if is_major and main_branch_points.size() >= 3:
		var cross_half_w = half_w * 0.75
		for c in range(2):
			var idx_a = (c * 2) % main_branch_points.size()
			var idx_b = (idx_a + 1) % main_branch_points.size()
			var b1 = main_branch_points[idx_a]
			var b2 = main_branch_points[idx_b]
			if b1.size() > 2 and b2.size() > 2:
				var p0 = b1[1]
				var p1 = b2[1]
				var dir2d = Vector2(p1.x - p0.x, p1.y - p0.y)
				if dir2d.length_squared() >= 0.0001:
					var norm2d = Vector2(-dir2d.y, dir2d.x).normalized() * cross_half_w
					var v0_l = p0 + Vector3(norm2d.x, norm2d.y, 0)
					var v0_r = p0 - Vector3(norm2d.x, norm2d.y, 0)
					var v1_l = p1 + Vector3(norm2d.x, norm2d.y, 0)
					var v1_r = p1 - Vector3(norm2d.x, norm2d.y, 0)
					st.set_normal(Vector3(0, 0, -1))
					st.add_vertex(v0_l)
					st.add_vertex(v0_r)
					st.add_vertex(v1_l)
					st.add_vertex(v1_l)
					st.add_vertex(v0_r)
					st.add_vertex(v1_r)

	return st.commit()

# ─────────────────────────────────────────────────────────────────────────────
# Process: Orbit Updates & Orientation
# ─────────────────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	# Animate Equatorial Solar Driver Core and Conduits
	if is_driver_equipped:
		driver_anim_time += delta
		if driver_core_mat and is_instance_valid(driver_core_mat):
			var core_pulse = 0.5 + 0.5 * sin(driver_anim_time * 3.5)
			driver_core_mat.emission_energy_multiplier = 3.4 + core_pulse * 1.4
		if driver_conduit_mat and is_instance_valid(driver_conduit_mat):
			var conduit_pulse = 0.5 + 0.5 * sin(driver_anim_time * 2.8)
			driver_conduit_mat.emission_energy_multiplier = 2.6 + conduit_pulse * 0.9

	if current_state != State.ORBITAL_SWARM and current_state != State.CONVERGENCE_CHARGING:
		return

	if not sun_node or not is_instance_valid(sun_node):
		var main = get_tree().current_scene if get_tree() else null
		if main and main.get("sun") and is_instance_valid(main.sun):
			sun_node = main.sun
		elif get_parent() and get_parent().get("sun") and is_instance_valid(get_parent().sun):
			sun_node = get_parent().sun
		else:
			return

	if not camera_node or not is_instance_valid(camera_node):
		camera_node = get_viewport().get_camera_3d()

	hit_sfx_cooldown = max(0.0, hit_sfx_cooldown - delta)
	water_active_timer = maxf(0.0, water_active_timer - delta)
	if stun_timer > 0.0:
		stun_timer -= delta
	var delta_orbit = delta * (0.20 if stun_timer > 0.0 else 1.0)
	orbit_time += delta_orbit
	var sun_pos = sun_node.global_position
	var cam_pos = camera_node.global_position if (camera_node and is_instance_valid(camera_node)) else Vector3(0, 0, 5)

	for drone in active_drones:
		var node = drone["node"] as Node3D
		if not is_instance_valid(node):
			continue

		var is_interceptor = drone.get("is_interceptor", false)
		var world_pos: Vector3

		if is_interceptor:
			var idx = drone.get("interceptor_idx", 0)
			var total_i = drone.get("total_interceptors", 1)
			var spread_x = 0.0
			var spread_y = 0.0
			if total_i > 1:
				spread_x = -1.2 if idx == 0 else 1.2
				spread_y = 0.4 if idx == 0 else -0.4

			var target_pos: Vector3
			if water_active_timer > 0.0 and abs(last_water_ray_normal.z) > 0.001:
				# 1. Bodyguard Priority: Check if player is aiming towards any other drone!
				var targeted_drone_pos = Vector3.ZERO
				var min_ray_dist = 5.5
				for other_drone in active_drones:
					if other_drone.get("is_interceptor", false):
						continue
					var o_node = other_drone.get("node") as Node3D
					if is_instance_valid(o_node):
						var d_pos = o_node.global_position
						var to_d = d_pos - last_water_ray_origin
						var proj_t = to_d.dot(last_water_ray_normal)
						if proj_t > 0.0:
							var ray_pt = last_water_ray_origin + last_water_ray_normal * proj_t
							var dist = d_pos.distance_to(ray_pt)
							if dist < min_ray_dist:
								min_ray_dist = dist
								targeted_drone_pos = d_pos

				if targeted_drone_pos != Vector3.ZERO:
					# Player is firing at an orbital drone! Rapidly surge forward between player camera and the drone
					var dir_to_cam = (cam_pos - targeted_drone_pos).normalized()
					var forward_dist = 6.5
					target_pos = targeted_drone_pos + (dir_to_cam * forward_dist) + Vector3(spread_x, spread_y, 0.0)
				else:
					# Player is firing at the Sun! Intercept along forward defensive plane Z = -22.0
					var t_ray = (-22.0 - last_water_ray_origin.z) / last_water_ray_normal.z
					if t_ray > 0.0:
						var hit_pt = last_water_ray_origin + last_water_ray_normal * t_ray
						var clamped_x = clampf(hit_pt.x + spread_x, -18.0, 18.0)
						var clamped_y = clampf(hit_pt.y + spread_y, 3.0, 24.0)
						target_pos = Vector3(clamped_x, clamped_y, -22.0)
					else:
						target_pos = sun_pos + Vector3(spread_x * 4.0, 2.0, 20.0)
			else:
				# Evasive defensive hover in front of Sun
				var t_hov = (orbit_time * 2.5) + drone.get("patrol_offset", 0.0)
				var h_x = sin(t_hov) * 7.5 + spread_x * 3.0
				var h_y = (sun_pos.y - 1.0) + cos(t_hov * 1.5) * 3.5
				target_pos = Vector3(h_x, h_y, -22.0)

			var cur_p = node.global_position
			var move_speed = 12.0 if water_active_timer > 0.0 else 3.5
			if stun_timer > 0.0:
				move_speed = 1.0
			world_pos = cur_p.lerp(target_pos, delta * move_speed)
			if stun_timer > 0.0:
				world_pos += Vector3(randf_range(-0.16, 0.16), randf_range(-0.16, 0.16), 0.0)
			node.global_position = world_pos

			var thrusters = drone.get("thrusters") as CPUParticles3D
			if thrusters and is_instance_valid(thrusters):
				thrusters.initial_velocity_max = 14.0 if water_active_timer > 0.0 else 8.0

			node.look_at(cam_pos, Vector3.UP)
			var vel_x = (world_pos.x - drone.get("prev_x", world_pos.x)) / maxf(0.001, delta)
			drone["prev_x"] = world_pos.x
			node.rotate_z(clampf(-vel_x * 0.035, -0.65, 0.65))
		else:
			# If convergence vortex is active, smoothly pull into high-speed equatorial ring
			if drone.get("vortex_active", false):
				drone["radius_x"] = lerpf(drone["radius_x"], drone.get("target_radius_x", 14.0), delta * 4.5)
				drone["radius_y"] = lerpf(drone["radius_y"], drone.get("target_radius_y", 1.0), delta * 4.5)
				drone["radius_z"] = lerpf(drone["radius_z"], drone.get("target_radius_z", 5.0), delta * 4.5)

			# 1. Coronal Orbit Calculation
			var local_p: Vector3
			if drone.get("is_infinity_lattice", false) and not drone.get("vortex_active", false):
				var t = (orbit_time * drone["orbit_speed"]) + drone["phase_offset"]
				var unrot_x = cos(t) * drone["radius_x"]
				var unrot_y = sin(t) * drone["radius_y"]
				var tilt = drone["tilt_angle"]
				var px = unrot_x * cos(tilt) - unrot_y * sin(tilt)
				var py = unrot_x * sin(tilt) + unrot_y * cos(tilt)
				var dist_sq = px * px + py * py
				var shield_front_z = sqrt(maxf(0.0, 10.6 * 10.6 - dist_sq))
				var pz = maxf(4.5, shield_front_z + 2.5) + (1.4 if drone.get("ring_id", 0) == 0 else 0.0)
				local_p = Vector3(px, py, pz)
			else:
				# Standard equatorial orbit
				var t = (orbit_time * drone["orbit_speed"]) + drone["phase_offset"]
				local_p = Vector3(
					cos(t) * drone["radius_x"],
					sin(t) * drone["radius_y"],
					drone["radius_z"] + sin(t * 1.6 + drone["index"]) * 0.4
				)

			world_pos = sun_pos + local_p
			if stun_timer > 0.0:
				world_pos += Vector3(randf_range(-0.16, 0.16), randf_range(-0.16, 0.16), 0.0)
			node.global_position = world_pos

			# 2. Ocular Focus: Eye drone stares directly down the player's sightline
			node.look_at(cam_pos, Vector3.UP)

		# 3. Dynamic Health Color Progression & Crack Damage Progression
		var cur_hp = drone["hp"] as float
		var max_hp = drone["max_hp"] as float
		var hp_pct = clampf(cur_hp / max_hp, 0.0, 1.0)

		var casing_mats = drone["casing_mats"] as Array[StandardMaterial3D]
		var pearl_mats = drone.get("pearl_mats", []) as Array[StandardMaterial3D]
		var pupil_mat = drone["pupil_mat"] as StandardMaterial3D
		var crack_minor = drone.get("crack_minor") as MeshInstance3D
		var crack_major = drone.get("crack_major") as MeshInstance3D
		var mat_minor = drone.get("crack_mat_minor") as StandardMaterial3D
		var mat_major = drone.get("crack_mat_major") as StandardMaterial3D
		var vent_fx = drone.get("vent_fx") as CPUParticles3D

		# Hit impact recoil recovery back to base scale
		var target_scale = 1.7 if is_interceptor else 2.3
		if node.scale.x < target_scale:
			node.scale = node.scale.lerp(Vector3(target_scale, target_scale, target_scale), 10.0 * delta)

		# Crack stage updates
		if hp_pct > 0.65:
			# Pristine condition
			if crack_minor and crack_minor.visible: crack_minor.visible = false
			if crack_major and crack_major.visible: crack_major.visible = false
			if vent_fx and vent_fx.emitting: vent_fx.emitting = false
		elif hp_pct > 0.35:
			# Stage 1: Minor fractures across lens and inner aperture
			if crack_minor and not crack_minor.visible: crack_minor.visible = true
			if crack_major and crack_major.visible: crack_major.visible = false
			if vent_fx and vent_fx.emitting: vent_fx.emitting = false
			if mat_minor and is_instance_valid(mat_minor):
				var pulse = 0.5 + 0.5 * sin(orbit_time * 5.0 + drone.get("phase_offset", 0.0))
				mat_minor.emission_energy_multiplier = 2.8 + (pulse * 1.4)
		else:
			# Stage 2: Critical hairline fissures across lens and aperture & imminent shatter
			if crack_minor and not crack_minor.visible: crack_minor.visible = true
			if crack_major and not crack_major.visible: crack_major.visible = true
			if vent_fx and not vent_fx.emitting: vent_fx.emitting = true

			# Impending shatter warning: erratic strobe or high-frequency pulse
			if hp_pct <= 0.18:
				# Imminent core failure (< 18% HP): structural shudder + high-voltage flash
				var jitter_amt = (1.0 - (hp_pct / 0.18)) * 0.05
				node.global_position += Vector3(randf_range(-jitter_amt, jitter_amt), randf_range(-jitter_amt, jitter_amt), 0.0)
				if mat_major and is_instance_valid(mat_major):
					var strobe = 1.0 if sin(orbit_time * 20.0) > 0.0 else 0.4
					mat_major.emission_energy_multiplier = 3.8 + (strobe * 2.2)
			else:
				var pulse = 0.5 + 0.5 * sin(orbit_time * 10.0 + drone.get("phase_offset", 0.0))
				if mat_major and is_instance_valid(mat_major):
					mat_major.emission_energy_multiplier = 3.2 + (pulse * 1.8)
				# Subtle instability tremor
				node.global_position += Vector3(randf_range(-0.015, 0.015), randf_range(-0.015, 0.015), 0.0)

		if drone["hit_flash"] > 0.0:
			drone["hit_flash"] -= delta * 6.0
			var f = clampf(drone["hit_flash"], 0.0, 1.0)
			var hit_tint = Color(0.5, 0.95, 1.0) if drone.get("ring_id", 0) == 0 else Color(0.85, 0.70, 1.0)
			for c_mat in casing_mats:
				if is_instance_valid(c_mat):
					c_mat.albedo_color = Color(1.0, 0.86, 0.22).lerp(hit_tint, f)
			for p_mat in pearl_mats:
				if is_instance_valid(p_mat):
					p_mat.albedo_color = Color(0.97, 0.96, 0.93).lerp(hit_tint, f)
			if pupil_mat and is_instance_valid(pupil_mat):
				var base_col = drone.get("base_pupil_color", Color(1.0, 0.78, 0.18))
				pupil_mat.emission = base_col.lerp(hit_tint, f)
				pupil_mat.emission_energy_multiplier = 3.5 + (f * 5.0)
			if mat_minor and is_instance_valid(mat_minor):
				mat_minor.emission = Color(1.0, 0.84, 0.35).lerp(hit_tint, f)
			if mat_major and is_instance_valid(mat_major):
				mat_major.emission = Color(1.0, 0.68, 0.22).lerp(hit_tint, f)
		else:
			var base_casing_col: Color
			var base_pearl_col: Color
			var base_pupil_col: Color = drone.get("base_pupil_color", Color(1.0, 0.78, 0.18))
			var pulse_speed = 3.2
			var base_energy = 3.2

			if drone.get("is_interceptor", false):
				# Sleek Arc Cyan / Electric Plasma palette
				base_casing_col = Color(0.78, 0.92, 1.0)
				base_pearl_col = Color(0.92, 0.96, 1.0)
				base_pupil_col = Color(0.15, 0.92, 1.0) # Electric Plasma Cyan
				base_energy = 8.5
				pulse_speed = 6.0
			elif is_harmonic_matrix and drone.get("is_harmonic_anchor", false):
				var p_idx = drone.get("harmonic_pair_idx", 0)
				var pair_active = false
				if p_idx >= 0 and p_idx < harmonic_pairs.size():
					pair_active = harmonic_pairs[p_idx].get("active", false)

				if pair_active:
					if p_idx == 0:
						# Solar Gold Anchor Drone (Pair 0: Drones 0 & 4)
						base_pupil_col = Color(1.0, 0.95, 0.15)
						base_casing_col = Color(1.0, 0.88, 0.22)
						base_pearl_col = Color(1.0, 0.96, 0.88)
						base_energy = 8.0
						pulse_speed = 5.0
					else:
						# Coronal Violet Anchor Drone (Pair 1: Drones 1 & 5)
						base_pupil_col = Color(0.96, 0.20, 1.0)
						base_casing_col = Color(0.88, 0.35, 1.0)
						base_pearl_col = Color(0.96, 0.88, 1.0)
						base_energy = 8.5
						pulse_speed = 5.0
				else:
					# Severed Anchor circuit: dimmed down
					base_pupil_col = Color(0.45, 0.40, 0.35)
					base_casing_col = Color(0.60, 0.58, 0.55)
					base_pearl_col = Color(0.70, 0.68, 0.65)
					base_energy = 1.2
					pulse_speed = 1.0
			elif drone.get("is_infinity_lattice", false):
				var is_ring_b = (drone.get("ring_id", 0) == 1)
				if hp_pct > 0.60:
					base_casing_col = Color(1.0, 0.86, 0.22) if not is_ring_b else Color(0.92, 0.80, 0.95)
					base_pearl_col = Color(0.97, 0.96, 0.93) if not is_ring_b else Color(0.95, 0.92, 0.98)
					base_pupil_col = drone.get("base_pupil_color", Color(1.0, 0.82, 0.25))
					pulse_speed = 3.2
					base_energy = 4.2
				elif hp_pct > 0.30:
					base_casing_col = Color(1.0, 0.80, 0.20) if not is_ring_b else Color(0.88, 0.72, 0.92)
					base_pearl_col = Color(0.96, 0.95, 0.92) if not is_ring_b else Color(0.93, 0.88, 0.96)
					base_pupil_col = drone.get("base_pupil_color", Color(1.0, 0.62, 0.15)).lerp(Color(1.0, 0.25, 0.15), 0.35)
					pulse_speed = 5.0
					base_energy = 5.0
				else:
					base_casing_col = Color(0.96, 0.70, 0.18) if not is_ring_b else Color(0.82, 0.62, 0.88)
					base_pearl_col = Color(0.94, 0.93, 0.90) if not is_ring_b else Color(0.90, 0.84, 0.94)
					base_pupil_col = Color(1.0, 0.25, 0.15) if not is_ring_b else Color(1.0, 0.15, 0.60)
					pulse_speed = 8.0
					base_energy = 5.8
			else:
				if hp_pct > 0.60:
					base_casing_col = Color(1.0, 0.86, 0.22)
					base_pearl_col = Color(0.97, 0.96, 0.93)
					base_pupil_col = Color(1.0, 0.78, 0.18)
					pulse_speed = 3.2
					base_energy = 3.2
				elif hp_pct > 0.30:
					base_casing_col = Color(1.0, 0.80, 0.20)
					base_pearl_col = Color(0.96, 0.95, 0.92)
					base_pupil_col = Color(1.0, 0.62, 0.15)
					pulse_speed = 5.0
					base_energy = 4.0
				else:
					base_casing_col = Color(0.96, 0.70, 0.18)
					base_pearl_col = Color(0.94, 0.93, 0.90)
					base_pupil_col = Color(1.0, 0.48, 0.12)
					pulse_speed = 8.0
					base_energy = 4.8

			for c_mat in casing_mats:
				if is_instance_valid(c_mat):
					c_mat.albedo_color = base_casing_col

			for p_mat in pearl_mats:
				if is_instance_valid(p_mat):
					p_mat.albedo_color = base_pearl_col

			if pupil_mat and is_instance_valid(pupil_mat):
				pupil_mat.emission = base_pupil_col
				var pulse = 0.5 + 0.5 * sin(orbit_time * pulse_speed + drone.get("phase_offset", 0.0))
				pupil_mat.emission_energy_multiplier = base_energy + (pulse * 2.0)

			if mat_minor and is_instance_valid(mat_minor):
				mat_minor.emission = Color(0.2, 0.9, 1.0) if is_interceptor else Color(1.0, 0.84, 0.35)
			if mat_major and is_instance_valid(mat_major):
				mat_major.emission = Color(0.3, 0.95, 1.0) if is_interceptor else Color(1.0, 0.68, 0.22)

	_update_harmonic_tethers(delta)

# ─────────────────────────────────────────────────────────────────────────────
# Water Stream Interception (Absorbs damage, shields Sun behind it)
# ─────────────────────────────────────────────────────────────────────────────
func check_water_stream_intercept(ray_origin: Vector3, ray_normal: Vector3, weapon_damage: float, intercept_radius: float = 2.4) -> Dictionary:
	if current_state != State.ORBITAL_SWARM or active_drones.is_empty():
		return { "hit": false }

	last_water_ray_origin = ray_origin
	last_water_ray_normal = ray_normal
	water_active_timer = 0.35

	var closest_drone: Dictionary = {}
	var min_dist_to_ray = 999.0
	var hit_world_pt = Vector3.ZERO

	for drone in active_drones:
		var node = drone["node"] as Node3D
		if not is_instance_valid(node):
			continue

		var drone_pos = node.global_position
		var to_drone = drone_pos - ray_origin
		var proj_t = to_drone.dot(ray_normal)

		if proj_t > 0.0:
			var pt_on_ray = ray_origin + ray_normal * proj_t
			var dist = drone_pos.distance_to(pt_on_ray)
			
			# Interception radius (default 2.4m, wider for blade slashes)
			if dist < intercept_radius and dist < min_dist_to_ray:
				min_dist_to_ray = dist
				closest_drone = drone
				hit_world_pt = pt_on_ray

	if closest_drone.is_empty():
		return { "hit": false }

	var is_core_crit: bool = (min_dist_to_ray < 1.0)
	var final_damage = weapon_damage * (1.5 if is_core_crit else 1.0)

	# Apply water cooling damage to the intercepted drone
	var cur_hp = closest_drone["hp"] as float
	cur_hp -= final_damage
	closest_drone["hp"] = cur_hp
	closest_drone["hit_flash"] = 1.0

	var d_node = closest_drone["node"] as Node3D
	# Visual mechanical recoil kick on impact
	d_node.scale = Vector3(2.0, 2.0, 2.0)

	# Play dynamic, randomized CC0 metal impact tick
	if hit_sfx_cooldown <= 0.0 and not hit_players.is_empty() and not hit_streams.is_empty():
		var p = hit_players[hit_player_idx]
		hit_player_idx = (hit_player_idx + 1) % hit_players.size()
		p.stream = hit_streams.pick_random()
		p.pitch_scale = randf_range(1.15, 1.35) if is_core_crit else randf_range(0.94, 1.18)
		p.play()
		hit_sfx_cooldown = 0.065

	# Check Destruction
	if cur_hp <= 0.0:
		var pos = d_node.global_position
		_spawn_drone_destruction_fx(pos, false)
		
		# Multi-layered mechanical core rupture
		if sfx_shatter_metal:
			sfx_shatter_metal.pitch_scale = randf_range(0.95, 1.05)
			sfx_shatter_metal.play()
		if sfx_shatter_glass:
			sfx_shatter_glass.pitch_scale = randf_range(1.05, 1.20)
			sfx_shatter_glass.play()
		if sfx_shatter_core:
			sfx_shatter_core.pitch_scale = 1.15
			sfx_shatter_core.play()

		active_drones.erase(closest_drone)
		d_node.queue_free()
		drone_destroyed.emit(pos)
		if closest_drone.get("is_interceptor", false):
			interceptor_destroyed.emit(pos)
		_check_harmonic_pair_sever(closest_drone, pos)

		if active_drones.is_empty():
			trigger_driver_overload()

		return {
			"hit": true,
			"destroyed": true,
			"position": pos,
			"is_crit": is_core_crit
		}

	return {
		"hit": true,
		"destroyed": false,
		"position": hit_world_pt,
		"is_crit": is_core_crit
	}

# ─────────────────────────────────────────────────────────────────────────────
# Ice Blast Interception (AOE Cryo-Frost: shatters all drones within 6.5m blast radius)
# ─────────────────────────────────────────────────────────────────────────────
func check_ice_blast_intercept(blast_pos: Vector3, radius: float = 6.5) -> bool:
	if current_state != State.ORBITAL_SWARM or active_drones.is_empty():
		return false

	var to_shatter: Array[Dictionary] = []
	for drone in active_drones:
		var node = drone["node"] as Node3D
		if is_instance_valid(node):
			if node.global_position.distance_to(blast_pos) <= radius:
				to_shatter.append(drone)

	if to_shatter.is_empty():
		return false

	for drone in to_shatter:
		var d_node = drone["node"] as Node3D
		var pos = d_node.global_position
		_spawn_drone_destruction_fx(pos, true)
		active_drones.erase(drone)
		d_node.queue_free()
		drone_shattered_by_ice.emit(pos)
		if drone.get("is_interceptor", false):
			interceptor_destroyed.emit(pos)
		_check_harmonic_pair_sever(drone, pos)

	if active_drones.is_empty():
		trigger_driver_overload()

	# Multi-layered cryogenic glass avalanche
	if sfx_ice_shatter_glass:
		sfx_ice_shatter_glass.pitch_scale = randf_range(0.98, 1.10)
		sfx_ice_shatter_glass.play()
	if sfx_ice_blast:
		sfx_ice_blast.pitch_scale = 1.15
		sfx_ice_blast.play()
	if sfx_shatter_metal:
		sfx_shatter_metal.pitch_scale = 1.25
		sfx_shatter_metal.play()

	return true

# ─────────────────────────────────────────────────────────────────────────────
# Destruction Particle Effects
# ─────────────────────────────────────────────────────────────────────────────
func _spawn_drone_destruction_fx(pos: Vector3, is_ice_shatter: bool) -> void:
	var particles = CPUParticles3D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.amount = 36
	particles.lifetime = 0.9
	particles.global_position = pos

	particles.direction = Vector3.UP
	particles.spread = 180.0
	particles.initial_velocity_min = 8.0
	particles.initial_velocity_max = 16.0
	particles.gravity = Vector3(0.0, -14.0, 0.0)

	var p_mat = StandardMaterial3D.new()
	p_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	p_mat.vertex_color_use_as_albedo = true

	if is_ice_shatter:
		p_mat.albedo_color = Color(0.35, 0.95, 1.0, 0.95)
		particles.color = Color(0.65, 0.98, 1.0, 1.0)
	else:
		p_mat.albedo_color = Color(1.0, 0.75, 0.15, 0.95)
		particles.color = Color(1.0, 0.85, 0.3, 1.0)

	var p_mesh = BoxMesh.new()
	p_mesh.size = Vector3(0.18, 0.18, 0.18)
	p_mesh.material = p_mat
	particles.mesh = p_mesh

	add_child(particles)
	particles.emitting = true

	var timer = get_tree().create_timer(1.2)
	timer.timeout.connect(func(): if is_instance_valid(particles): particles.queue_free())

# ─────────────────────────────────────────────────────────────────────────────
# Utility & State Accessors
# ─────────────────────────────────────────────────────────────────────────────
func get_active_drone_count() -> int:
	return active_drones.size()

func clear_drones() -> void:
	_stop_drone_hum()
	_clear_harmonic_matrix()
	for d in active_drones:
		var node = d.get("node") as Node3D
		if is_instance_valid(node):
			node.queue_free()
	active_drones.clear()
	current_state = State.IDLE

# ─────────────────────────────────────────────────────────────────────────────
# Wave 50+ Harmonic Resonance Matrix Mechanics (Shield-Surface Frequency Resonance)
# ─────────────────────────────────────────────────────────────────────────────
func is_harmonic_shield_active() -> bool:
	if not is_harmonic_matrix:
		return active_drones.size() > 0
	return active_tethers_count > 0

func get_harmonic_shield_tint() -> Color:
	if not is_harmonic_matrix or active_tethers_count <= 0:
		return Color(1.0, 0.82, 0.18, 0.95)

	var p0_active: bool = false
	var p1_active: bool = false
	for p in harmonic_pairs:
		if p.get("active", false):
			if p.get("pair_idx") == 0: p0_active = true
			elif p.get("pair_idx") == 1: p1_active = true

	if p0_active and p1_active:
		# Both frequencies locked: dual-tone rhythmic harmonic wave
		var t = 0.5 + 0.5 * sin(orbit_time * 4.5)
		return Color(1.0, 0.82, 0.18, 0.95).lerp(Color(0.95, 0.35, 1.0, 0.95), t)
	elif p0_active:
		return Color(1.0, 0.82, 0.18, 0.95) # Pure Solar Gold
	elif p1_active:
		return Color(0.95, 0.35, 1.0, 0.95) # Pure Coronal Violet

	return Color(1.0, 0.82, 0.18, 0.95)

func _setup_harmonic_matrix() -> void:
	_clear_harmonic_matrix()
	is_harmonic_matrix = true
	active_tethers_count = 0
	if active_drones.size() < 6:
		return

	# Pair 0: Drone 0 and Drone 4 (Ring A, Solar Gold)
	# Pair 1: Drone 1 and Drone 5 (Ring B, Coronal Violet)
	var pair_configs = [
		{ "idx_a": 0, "idx_b": 4, "color": Color(1.0, 0.82, 0.15), "name": "Solar Gold" },
		{ "idx_a": 1, "idx_b": 5, "color": Color(0.95, 0.30, 1.00), "name": "Coronal Violet" }
	]

	for p_idx in range(pair_configs.size()):
		var cfg = pair_configs[p_idx]
		var d_a: Dictionary = {}
		var d_b: Dictionary = {}
		for d in active_drones:
			if d["index"] == cfg["idx_a"]: d_a = d
			elif d["index"] == cfg["idx_b"]: d_b = d

		if d_a.is_empty() or d_b.is_empty():
			continue

		d_a["is_harmonic_anchor"] = true
		d_b["is_harmonic_anchor"] = true
		d_a["harmonic_pair_idx"] = p_idx
		d_b["harmonic_pair_idx"] = p_idx

		_attach_harmonic_halo(d_a.get("node"), cfg["color"])
		_attach_harmonic_halo(d_b.get("node"), cfg["color"])

		harmonic_pairs.append({
			"pair_idx": p_idx,
			"drone_a": d_a,
			"drone_b": d_b,
			"color": cfg["color"],
			"active": true
		})
		active_tethers_count += 1

func _attach_harmonic_halo(drone_node: Node3D, color: Color) -> void:
	if not is_instance_valid(drone_node): return
	var halo_root = Node3D.new()
	halo_root.name = "HarmonicHaloRoot"
	drone_node.add_child(halo_root)

	# Radiant, Camera-Facing Lens Flare Core (Directly at the drone pupil, always facing player)
	var lens_flare = MeshInstance3D.new()
	lens_flare.name = "AnchorLensGlow"
	var sphere = SphereMesh.new()
	sphere.radius = 0.36
	sphere.height = 0.72
	lens_flare.mesh = sphere
	var mat_g = StandardMaterial3D.new()
	mat_g.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_g.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_g.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat_g.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat_g.albedo_color = Color(color.r, color.g, color.b, 0.95)
	mat_g.emission_enabled = true
	mat_g.emission = color
	mat_g.emission_energy_multiplier = 9.5
	lens_flare.material_override = mat_g
	halo_root.add_child(lens_flare)

	# Subtle outer aura ring around the lens (facing player)
	var reticle = MeshInstance3D.new()
	reticle.name = "AnchorReticle"
	var torus = TorusMesh.new()
	torus.inner_radius = 0.48
	torus.outer_radius = 0.56
	reticle.mesh = torus
	var mat_r = StandardMaterial3D.new()
	mat_r.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_r.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_r.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat_r.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_r.albedo_color = Color(color.r, color.g, color.b, 0.85)
	mat_r.emission_enabled = true
	mat_r.emission = color
	mat_r.emission_energy_multiplier = 6.5
	reticle.material_override = mat_r
	halo_root.add_child(reticle)

func _update_harmonic_tethers(delta: float) -> void:
	if not is_harmonic_matrix:
		return

	for pair in harmonic_pairs:
		if not pair.get("active", false):
			continue
		var d_a = pair.get("drone_a", {})
		var d_b = pair.get("drone_b", {})
		var node_a = d_a.get("node") as Node3D
		var node_b = d_b.get("node") as Node3D

		if not is_instance_valid(node_a) or not is_instance_valid(node_b) or not active_drones.has(d_a) or not active_drones.has(d_b):
			_sever_harmonic_pair(pair, sun_node.global_position if is_instance_valid(sun_node) else global_position)
			continue

		# Gently spin the thin optic reticle on both anchor drones
		for n in [node_a, node_b]:
			var reticle = n.find_child("AnchorReticle", true, false) as MeshInstance3D
			if is_instance_valid(reticle):
				reticle.rotate_z(delta * 2.0)

func _check_harmonic_pair_sever(drone: Dictionary, pos: Vector3) -> void:
	if not is_harmonic_matrix:
		return
	var p_idx = drone.get("harmonic_pair_idx", -1)
	if p_idx >= 0 and p_idx < harmonic_pairs.size():
		var pair = harmonic_pairs[p_idx]
		if pair.get("active", false):
			_sever_harmonic_pair(pair, pos, false)

func _sever_harmonic_pair(pair: Dictionary, burst_pos: Vector3, shatter_drones: bool = false) -> void:
	if not pair.get("active", false):
		return
	pair["active"] = false
	active_tethers_count = max(0, active_tethers_count - 1)

	_spawn_tether_sever_fx(burst_pos, pair["color"])

	# Hide the glowing eye flare on the surviving partner drone so it visually powers down
	for d in [pair["drone_a"], pair["drone_b"]]:
		var dn = d.get("node") as Node3D
		if is_instance_valid(dn):
			var hr = dn.find_child("HarmonicHaloRoot", false, false)
			if is_instance_valid(hr):
				hr.visible = false

	if shatter_drones:
		for d in [pair["drone_a"], pair["drone_b"]]:
			var dn = d.get("node") as Node3D
			if is_instance_valid(dn) and active_drones.has(d):
				var pos = dn.global_position
				_spawn_drone_destruction_fx(pos, true)
				active_drones.erase(d)
				dn.queue_free()
				drone_shattered_by_ice.emit(pos)

	harmonic_tether_severed.emit(pair["pair_idx"], burst_pos)

	if active_tethers_count <= 0:
		harmonic_matrix_collapsed.emit()
		_trigger_matrix_collapse_fx()

func _spawn_tether_sever_fx(pos: Vector3, color: Color) -> void:
	var particles = CPUParticles3D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.amount = 32
	particles.lifetime = 0.75
	particles.global_position = pos
	particles.direction = Vector3.UP
	particles.spread = 180.0
	particles.initial_velocity_min = 10.0
	particles.initial_velocity_max = 22.0
	particles.gravity = Vector3(0.0, -8.0, 0.0)

	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 5.0

	var p_mesh = BoxMesh.new()
	p_mesh.size = Vector3(0.18, 0.18, 0.18)
	p_mesh.material = mat
	particles.mesh = p_mesh

	add_child(particles)
	particles.emitting = true

	var tw = create_tween()
	tw.tween_interval(1.0)
	tw.tween_callback(particles.queue_free)

	if sfx_shatter_metal:
		sfx_shatter_metal.pitch_scale = randf_range(1.2, 1.4)
		sfx_shatter_metal.play()

func _trigger_matrix_collapse_fx() -> void:
	stun_timer = 3.5
	if sfx_driver_overdrive:
		sfx_driver_overdrive.pitch_scale = 1.3
		sfx_driver_overdrive.play()
	if sfx_ice_shatter_glass:
		sfx_ice_shatter_glass.pitch_scale = 0.95
		sfx_ice_shatter_glass.play()

	for d in active_drones:
		var vfx = d.get("vent_fx") as CPUParticles3D
		if is_instance_valid(vfx):
			vfx.emitting = true

func _clear_harmonic_matrix() -> void:
	is_harmonic_matrix = false
	active_tethers_count = 0
	stun_timer = 0.0
	for p in harmonic_pairs:
		var t = p.get("tether_node") as Node3D
		if is_instance_valid(t):
			t.queue_free()
	harmonic_pairs.clear()

# ─────────────────────────────────────────────────────────────────────────────
# Milestone 2: Equatorial Solar Driver & Planetary Belt
# ─────────────────────────────────────────────────────────────────────────────
func setup_solar_driver() -> void:
	if driver_root and is_instance_valid(driver_root):
		return
	if not sun_node or not is_instance_valid(sun_node):
		return

	driver_root = Node3D.new()
	driver_root.name = "SolarDriverRoot"
	driver_root.visible = false
	# Sit at Sun's lower waist/belly (Y = -3.85m), tilted 14 degrees up towards beach camera
	# This keeps the Sun's face (eyes, eyebrows, mouth) completely unobstructed above the belt
	driver_root.position = Vector3(0.0, -3.85, 0.0)
	driver_root.rotation.x = deg_to_rad(14.0)
	sun_node.add_child(driver_root)

	var driver_scene = load("res://assets/models/solar_driver.glb")
	if not driver_scene:
		push_error("[SolarConvergence] Failed to load res://assets/models/solar_driver.glb")
		return

	var driver_inst = driver_scene.instantiate()
	driver_root.add_child(driver_inst)

	# Locate named nodes from GLB
	driver_buckle = driver_inst.find_child("DriverBuckle", true, false) as Node3D
	belt_strap_left = driver_inst.find_child("BeltStrap_Left", true, false) as Node3D
	belt_strap_right = driver_inst.find_child("BeltStrap_Right", true, false) as Node3D

	# Setup Toon materials and extract emissive mats for pulsation
	_setup_driver_materials(driver_inst)

	# Shockwave Particle Emitter on Buckle Latch
	if driver_buckle:
		driver_shockwave_particles = CPUParticles3D.new()
		driver_shockwave_particles.emitting = false
		driver_shockwave_particles.one_shot = true
		driver_shockwave_particles.explosiveness = 0.95
		driver_shockwave_particles.amount = 45
		driver_shockwave_particles.lifetime = 0.75
		driver_shockwave_particles.direction = Vector3.BACK
		driver_shockwave_particles.spread = 75.0
		driver_shockwave_particles.initial_velocity_min = 8.0
		driver_shockwave_particles.initial_velocity_max = 18.0
		driver_shockwave_particles.gravity = Vector3.ZERO
		driver_shockwave_particles.color = Color(1.0, 0.85, 0.28, 0.95)

		var sp_mat = StandardMaterial3D.new()
		sp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sp_mat.albedo_color = Color(1.0, 0.88, 0.32, 0.95)
		var sp_mesh = BoxMesh.new()
		sp_mesh.size = Vector3(0.24, 0.24, 0.24)
		sp_mesh.material = sp_mat
		driver_shockwave_particles.mesh = sp_mesh
		driver_shockwave_particles.position = Vector3(0.0, 0.0, 8.20)
		driver_buckle.add_child(driver_shockwave_particles)

		# Lateral Docking Bay Spark Particle Emitters
		dock_particles_left = _create_dock_particles(Vector3(-1.95, 0.0, 7.55))
		dock_particles_right = _create_dock_particles(Vector3(1.95, 0.0, 7.55))
		driver_buckle.add_child(dock_particles_left)
		driver_buckle.add_child(dock_particles_right)

func _create_dock_particles(pos: Vector3) -> CPUParticles3D:
	var cp = CPUParticles3D.new()
	cp.emitting = false
	cp.one_shot = true
	cp.explosiveness = 0.95
	cp.amount = 30
	cp.lifetime = 0.50
	cp.direction = Vector3.BACK
	cp.spread = 65.0
	cp.initial_velocity_min = 6.0
	cp.initial_velocity_max = 14.0
	cp.gravity = Vector3.ZERO
	cp.color = Color(0.35, 0.95, 1.0, 0.95)
	var sp_mat = StandardMaterial3D.new()
	sp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sp_mat.albedo_color = Color(0.35, 0.95, 1.0, 0.95)
	var sp_mesh = BoxMesh.new()
	sp_mesh.size = Vector3(0.18, 0.18, 0.18)
	sp_mesh.material = sp_mat
	cp.mesh = sp_mesh
	cp.position = pos
	return cp

func _setup_driver_materials(node: Node) -> void:
	if node is MeshInstance3D and node.mesh:
		for s_idx in range(node.mesh.get_surface_count()):
			var orig_mat = node.mesh.surface_get_material(s_idx)
			if orig_mat is StandardMaterial3D:
				var dup_mat = orig_mat.duplicate() as StandardMaterial3D
				dup_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
				dup_mat.specular_mode = BaseMaterial3D.SPECULAR_TOON
				dup_mat.rim_enabled = true
				dup_mat.rim = 0.70
				dup_mat.rim_tint = 0.45
				node.set_surface_override_material(s_idx, dup_mat)

				var m_name = dup_mat.resource_name if dup_mat.resource_name != "" else orig_mat.resource_name
				if "Core" in m_name or "Pupil" in m_name:
					driver_core_mat = dup_mat
					dup_mat.emission_enabled = true
					dup_mat.emission = Color(1.0, 0.65, 0.15)
					dup_mat.emission_energy_multiplier = 4.0
				elif "Conduit" in m_name or "Amber" in m_name:
					driver_conduit_mat = dup_mat
					dup_mat.emission_enabled = true
					dup_mat.emission = Color(1.0, 0.70, 0.20)
					dup_mat.emission_energy_multiplier = 3.0
				elif "Cyan" in m_name or "LED" in m_name:
					dup_mat.emission_enabled = true
					dup_mat.emission = Color(0.18, 0.90, 1.0)
					dup_mat.emission_energy_multiplier = 2.5
	for child in node.get_children():
		_setup_driver_materials(child)

func materialize_solar_driver(animated: bool = true) -> void:
	if is_driver_equipped:
		return
	is_driver_equipped = true

	if not driver_root or not is_instance_valid(driver_root):
		setup_solar_driver()

	if not driver_root:
		return

	driver_root.visible = true

	if animated and driver_buckle and belt_strap_left and belt_strap_right:
		# 1. Belt straps start completely hidden / collapsed
		belt_strap_left.scale = Vector3.ZERO
		belt_strap_left.rotation.y = deg_to_rad(25.0)
		belt_strap_right.scale = Vector3.ZERO
		belt_strap_right.rotation.y = deg_to_rad(-25.0)

		# 2. Buckle rushes in laterally from the side flank
		driver_buckle.scale = Vector3(0.35, 0.35, 0.35)
		driver_buckle.position = Vector3(18.0, 0.0, 4.5)

		# Energy conduit surge
		if driver_conduit_mat:
			driver_conduit_mat.emission_energy_multiplier = 8.0

		var tw = create_tween()

		# Phase 1: Driver Buckle rushes in from side and slams onto center waist (0.36s)
		tw.set_parallel(true)
		tw.tween_property(driver_buckle, "position", Vector3.ZERO, 0.36).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(driver_buckle, "scale", Vector3.ONE, 0.36).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		# Phase 2: On Buckle Impact -> SFX, shockwave, core flash, THEN belt appears!
		tw.chain().tween_callback(func():
			if sfx_driver_lock:
				sfx_driver_lock.play()
			if sfx_shatter_core:
				sfx_shatter_core.pitch_scale = 1.30
				sfx_shatter_core.play()
			if driver_shockwave_particles:
				driver_shockwave_particles.restart()
			if driver_core_mat:
				driver_core_mat.emission_energy_multiplier = 14.0
				var f_tw = create_tween()
				f_tw.tween_property(driver_core_mat, "emission_energy_multiplier", 4.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

			var main = get_tree().current_scene if get_tree() else null
			if main and main.has_method("shake"):
				main.shake(0.20, 0.03)

			solar_driver_equipped.emit(driver_buckle.global_position)
		)

		# Phase 3: Belt sweeps out from the sides of the buckle around the waist!
		tw.chain().set_parallel(true)
		tw.tween_property(belt_strap_left, "scale", Vector3.ONE, 0.36).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(belt_strap_left, "rotation:y", 0.0, 0.36).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(belt_strap_right, "scale", Vector3.ONE, 0.36).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(belt_strap_right, "rotation:y", 0.0, 0.36).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		if belt_strap_left:
			belt_strap_left.scale = Vector3.ONE
			belt_strap_left.rotation.y = 0.0
		if belt_strap_right:
			belt_strap_right.scale = Vector3.ONE
			belt_strap_right.rotation.y = 0.0
		if driver_buckle:
			driver_buckle.scale = Vector3.ONE
			driver_buckle.position = Vector3.ZERO
			solar_driver_equipped.emit(driver_buckle.global_position)

func remove_solar_driver(animated: bool = true) -> void:
	if not is_driver_equipped or not driver_root:
		return
	is_driver_equipped = false

	if animated and driver_buckle and belt_strap_left and belt_strap_right:
		# Unlatch mechanical sound
		if sfx_shatter_metal:
			sfx_shatter_metal.pitch_scale = 1.45
			sfx_shatter_metal.play()

		# Core emission power down
		if driver_core_mat:
			driver_core_mat.emission_energy_multiplier = 0.3

		var tw = create_tween().set_parallel(true)
		# Phase 1: Buckle pops forward with elastic spring
		tw.tween_property(driver_buckle, "scale", Vector3(0.01, 0.01, 0.01), 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.tween_property(driver_buckle, "position", Vector3(0.0, 1.8, 5.0), 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

		# Phase 2: Belt Straps retract and peel outward
		tw.tween_property(belt_strap_left, "scale", Vector3(0.01, 1.0, 0.01), 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tw.tween_property(belt_strap_left, "rotation:y", deg_to_rad(35.0), 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tw.tween_property(belt_strap_right, "scale", Vector3(0.01, 1.0, 0.01), 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tw.tween_property(belt_strap_right, "rotation:y", deg_to_rad(-35.0), 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

		tw.chain().tween_callback(func():
			if driver_root and is_instance_valid(driver_root):
				driver_root.visible = false
				driver_buckle.scale = Vector3.ONE
				driver_buckle.position = Vector3.ZERO
				belt_strap_left.scale = Vector3.ONE
				belt_strap_left.rotation.y = 0.0
				belt_strap_right.scale = Vector3.ONE
				belt_strap_right.rotation.y = 0.0
		)
	else:
		if driver_root and is_instance_valid(driver_root):
			driver_root.visible = false
			if driver_buckle:
				driver_buckle.scale = Vector3.ONE
				driver_buckle.position = Vector3.ZERO
			if belt_strap_left:
				belt_strap_left.scale = Vector3.ONE
				belt_strap_left.rotation.y = 0.0
			if belt_strap_right:
				belt_strap_right.scale = Vector3.ONE
				belt_strap_right.rotation.y = 0.0

func toggle_solar_driver() -> void:
	if is_driver_equipped:
		remove_solar_driver(true)
	else:
		materialize_solar_driver(true)

func is_driver_active() -> bool:
	return is_driver_equipped

func get_driver_buckle_position() -> Vector3:
	if driver_buckle and is_instance_valid(driver_buckle):
		return driver_buckle.global_position
	return sun_node.global_position if (sun_node and is_instance_valid(sun_node)) else Vector3.ZERO

func get_docking_bay_position(is_left: bool) -> Vector3:
	var bay_offset = Vector3(-1.95 if is_left else 1.95, 0.0, 7.55)
	if driver_buckle and is_instance_valid(driver_buckle):
		return driver_buckle.to_global(bay_offset)
	if driver_root and is_instance_valid(driver_root):
		return driver_root.to_global(bay_offset)
	return sun_node.global_position if (sun_node and is_instance_valid(sun_node)) else Vector3.ZERO

func is_convergence_in_progress() -> bool:
	return is_convergence_active or current_state == State.CONVERGENCE_CHARGING or current_state == State.CONVERGENCE_IMPLODING

# ─────────────────────────────────────────────────────────────────────────────
# Driver Overload Climax (Triggered when all orbital drones are destroyed)
# ─────────────────────────────────────────────────────────────────────────────
func trigger_driver_overload() -> void:
	_stop_drone_hum()
	current_state = State.IDLE
	convergence_completed.emit()

	# 1. SFX: Heavy metallic rupture and shield burst
	if sfx_shatter_metal:
		sfx_shatter_metal.pitch_scale = 0.70
		sfx_shatter_metal.play()
	if sfx_shatter_core:
		sfx_shatter_core.pitch_scale = 1.05
		sfx_shatter_core.play()

	# 2. Camera trauma shake & Sun shock wince
	var main = get_tree().current_scene if get_tree() else null
	if main:
		if main.has_method("shake"):
			main.shake(0.40, 0.038)
		if main.has_method("on_solar_convergence_sun_powerup"):
			main.on_solar_convergence_sun_powerup()

	# 3. Driver Buckle Overload: Sparks erupt, core flares unstable crimson, conduit flickers
	if driver_shockwave_particles:
		driver_shockwave_particles.amount = 70
		driver_shockwave_particles.restart()

	if driver_core_mat:
		driver_core_mat.emission = Color(1.0, 0.20, 0.10)
		driver_core_mat.emission_energy_multiplier = 18.0
		var c_tw = create_tween()
		c_tw.tween_property(driver_core_mat, "emission_energy_multiplier", 3.2, 1.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if driver_conduit_mat:
		var cn_tw = create_tween()
		cn_tw.tween_property(driver_conduit_mat, "emission_energy_multiplier", 1.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 4. Bilingual HUD Toast
	if main and main.get("hud") and is_instance_valid(main.hud) and main.hud.has_method("show_toast"):
		var gs = get_node_or_null("/root/GameState")
		var is_kr = (gs.language == "KR") if gs else false
		var title = "드론 군체 무력화 완료!" if is_kr else "DRONE SWARM NEUTRALIZED!"
		var desc = "솔라 드라이버 과열 — 태양 직접 냉각 가능!" if is_kr else "Solar Driver Overheated — Sun Vulnerable!"
		main.hud.show_toast(title, desc, "res://assets/ui/icons/delivery-drone.svg", Color(1.0, 0.80, 0.20))
