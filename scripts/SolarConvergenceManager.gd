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

# ── Kamen Rider Apex Helmet (Milestone 3 Expansion) ─────────────────────────
var helmet_root: Node3D = null
var helmet_crown: Node3D = null
var helmet_brow: Node3D = null
var helmet_left_cheek: Node3D = null
var helmet_right_cheek: Node3D = null
var helmet_visor: Node3D = null
var helmet_steam_left: CPUParticles3D = null
var helmet_steam_right: CPUParticles3D = null
var helmet_gem_mat: StandardMaterial3D = null
var helmet_visor_mat: StandardMaterial3D = null
var is_helmet_equipped: bool = false

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

func _ready() -> void:
	_init_audio()

func setup(sun: Node3D, cam: Camera3D) -> void:
	sun_node = sun
	camera_node = cam
	setup_solar_driver()
	setup_solar_helmet()

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
		hp.volume_db = 2.0
		add_child(hp)
		hit_players.append(hp)

	# Water Destruction (Mechanical Rupture + Glass Fracture + Core Blast)
	sfx_shatter_metal = AudioStreamPlayer.new()
	sfx_shatter_metal.stream = load("res://assets/audio/sfx/drone_shatter_metal.ogg")
	sfx_shatter_metal.bus = "Master"
	sfx_shatter_metal.volume_db = 3.0
	add_child(sfx_shatter_metal)

	sfx_shatter_glass = AudioStreamPlayer.new()
	sfx_shatter_glass.stream = load("res://assets/audio/sfx/drone_shatter_glass.ogg")
	sfx_shatter_glass.bus = "Master"
	sfx_shatter_glass.volume_db = 2.5
	add_child(sfx_shatter_glass)

	sfx_shatter_core = AudioStreamPlayer.new()
	sfx_shatter_core.stream = load("res://assets/audio/sfx/shield_break.ogg")
	sfx_shatter_core.bus = "Master"
	sfx_shatter_core.volume_db = 1.0
	add_child(sfx_shatter_core)

	# Ice Blast Shatter (Cryo-Frost Glacial Shatter + Glass Cascade)
	sfx_ice_shatter_glass = AudioStreamPlayer.new()
	sfx_ice_shatter_glass.stream = load("res://assets/audio/sfx/drone_ice_shatter_glass.ogg")
	sfx_ice_shatter_glass.bus = "Master"
	sfx_ice_shatter_glass.volume_db = 3.5
	add_child(sfx_ice_shatter_glass)

	sfx_ice_blast = AudioStreamPlayer.new()
	sfx_ice_blast.stream = load("res://assets/audio/sfx/ice_hit.ogg")
	sfx_ice_blast.bus = "Master"
	sfx_ice_blast.volume_db = 2.5
	add_child(sfx_ice_blast)

# ─────────────────────────────────────────────────────────────────────────────
# Phase 1: Orbital Swarm Spawning
# ─────────────────────────────────────────────────────────────────────────────
func start_orbital_swarm(count: int = 6, wave: int = 1) -> void:
	clear_drones()
	current_state = State.ORBITAL_SWARM
	orbit_time = 0.0

	for i in range(count):
		var drone_data = _create_drone(i, count, wave)
		active_drones.append(drone_data)
		add_child(drone_data["node"])

func _create_drone(index: int, total: int, wave: int = 1) -> Dictionary:
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
					dup_mat.rim_color = Color(1.0, 0.88, 0.35)
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

	# Dynamic Coronal Orbit Geometry: Smooth, stately circular rotation around the Sun's perimeter
	# Orbit radius (11.8m - 12.8m) providing generous clearance from Sun's body (~8m radius) and beach horizon
	var angle_fraction = float(index) / float(total)
	var orbit_speed = (0.85 + (index * 0.06)) * (1.0 if index % 2 == 0 else -1.0)
	var phase_offset = angle_fraction * TAU

	var base_r = 11.8 + (index % 3) * 0.5
	var rx = base_r
	var ry = base_r * 0.92 # Subtle celestial inclination framing the Sun cleanly above beach horizon
	var rz = 3.6 + (index % 3) * 0.6 # Positioned cleanly in front of the Sun along Z

	# Ensure sun_node is resolved before positioning
	if not sun_node or not is_instance_valid(sun_node):
		var main = get_tree().current_scene if get_tree() else null
		if main and main.get("sun") and is_instance_valid(main.sun):
			sun_node = main.sun

	var sun_pos = sun_node.global_position if (sun_node and is_instance_valid(sun_node)) else Vector3(0, 13.5, -42)
	var init_t = phase_offset
	drone_root.global_position = sun_pos + Vector3(
		cos(init_t) * rx,
		sin(init_t) * ry,
		rz + sin(init_t * 1.6 + index) * 0.4
	)

	# Dynamic wave-scaled HP (Wave 1: 38.5 HP | Wave 20: 105 HP | Wave 30: 140 HP)
	var calculated_hp = 35.0 + (wave * 3.5)

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
		"index": index
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

	# Animate Helmet Gem and Visor LEDs
	if is_helmet_equipped:
		if helmet_gem_mat and is_instance_valid(helmet_gem_mat):
			var gem_pulse = 0.5 + 0.5 * sin(driver_anim_time * 4.0)
			helmet_gem_mat.emission_energy_multiplier = 3.2 + gem_pulse * 1.6
		if helmet_visor_mat and is_instance_valid(helmet_visor_mat):
			var visor_pulse = 0.5 + 0.5 * sin(driver_anim_time * 3.2)
			helmet_visor_mat.emission_energy_multiplier = 3.5 + visor_pulse * 1.5

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
	orbit_time += delta
	var sun_pos = sun_node.global_position
	var cam_pos = camera_node.global_position if (camera_node and is_instance_valid(camera_node)) else Vector3(0, 0, 5)

	for drone in active_drones:
		var node = drone["node"] as Node3D
		if not is_instance_valid(node):
			continue

		# If convergence vortex is active, smoothly pull into high-speed equatorial ring
		if drone.get("vortex_active", false):
			drone["radius_x"] = lerpf(drone["radius_x"], drone.get("target_radius_x", 10.2), delta * 4.5)
			drone["radius_y"] = lerpf(drone["radius_y"], drone.get("target_radius_y", 0.6), delta * 4.5)
			drone["radius_z"] = lerpf(drone["radius_z"], drone.get("target_radius_z", 4.2), delta * 4.5)

		# 1. Smooth Sweeping Coronal Orbit around Sun's perimeter
		var t = (orbit_time * drone["orbit_speed"]) + drone["phase_offset"]
		var local_p = Vector3(
			cos(t) * drone["radius_x"],
			sin(t) * drone["radius_y"],
			drone["radius_z"] + sin(t * 1.6 + drone["index"]) * 0.4
		)

		var world_pos = sun_pos + local_p
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

		# Hit impact recoil recovery back to 2.3
		if node.scale.x < 2.3:
			node.scale = node.scale.lerp(Vector3(2.3, 2.3, 2.3), 10.0 * delta)

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
				var pulse = 0.5 + 0.5 * sin(orbit_time * 5.0 + drone["phase_offset"])
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
				var pulse = 0.5 + 0.5 * sin(orbit_time * 10.0 + drone["phase_offset"])
				if mat_major and is_instance_valid(mat_major):
					mat_major.emission_energy_multiplier = 3.2 + (pulse * 1.8)
				# Subtle instability tremor
				node.global_position += Vector3(randf_range(-0.015, 0.015), randf_range(-0.015, 0.015), 0.0)

		if drone["hit_flash"] > 0.0:
			drone["hit_flash"] -= delta * 6.0
			var f = clampf(drone["hit_flash"], 0.0, 1.0)
			# Electric cyan hit flash
			for c_mat in casing_mats:
				if is_instance_valid(c_mat):
					c_mat.albedo_color = Color(1.0, 0.86, 0.22).lerp(Color(0.5, 0.95, 1.0), f)
			for p_mat in pearl_mats:
				if is_instance_valid(p_mat):
					p_mat.albedo_color = Color(0.97, 0.96, 0.93).lerp(Color(0.5, 0.95, 1.0), f)
			if pupil_mat and is_instance_valid(pupil_mat):
				pupil_mat.emission = Color(1.0, 0.78, 0.18).lerp(Color(0.3, 1.0, 1.0), f)
				pupil_mat.emission_energy_multiplier = 3.5 + (f * 5.0)
			if mat_minor and is_instance_valid(mat_minor):
				mat_minor.emission = Color(1.0, 0.84, 0.35).lerp(Color(0.4, 1.0, 1.0), f)
			if mat_major and is_instance_valid(mat_major):
				mat_major.emission = Color(1.0, 0.68, 0.22).lerp(Color(0.4, 1.0, 1.0), f)
		else:
			# Visual damage states: Preserves dignified Sun-Gold & Pearl Ivory armor; pupil heats up with warm solar amber
			var base_casing_col: Color
			var base_pearl_col: Color
			var base_pupil_col: Color
			var pulse_speed = 3.2
			var base_energy = 3.2

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
				var pulse = 0.5 + 0.5 * sin(orbit_time * pulse_speed + drone["phase_offset"])
				pupil_mat.emission_energy_multiplier = base_energy + (pulse * 2.0)

			if mat_minor and is_instance_valid(mat_minor):
				mat_minor.emission = Color(1.0, 0.84, 0.35)
			if mat_major and is_instance_valid(mat_major):
				mat_major.emission = Color(1.0, 0.68, 0.22)

# ─────────────────────────────────────────────────────────────────────────────
# Water Stream Interception (Absorbs damage, shields Sun behind it)
# ─────────────────────────────────────────────────────────────────────────────
func check_water_stream_intercept(ray_origin: Vector3, ray_normal: Vector3, weapon_damage: float, intercept_radius: float = 2.4) -> Dictionary:
	if current_state != State.ORBITAL_SWARM or active_drones.is_empty():
		return { "hit": false }

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
	for d in active_drones:
		var node = d.get("node") as Node3D
		if is_instance_valid(node):
			node.queue_free()
	active_drones.clear()
	current_state = State.IDLE

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
				dup_mat.rim_color = Color(1.0, 0.88, 0.35)
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
		# Initial retracted & pre-deployed state
		belt_strap_left.scale = Vector3(0.01, 1.0, 0.01)
		belt_strap_left.rotation.y = deg_to_rad(35.0)
		belt_strap_right.scale = Vector3(0.01, 1.0, 0.01)
		belt_strap_right.rotation.y = deg_to_rad(-35.0)

		# Buckle floats down from front-above
		driver_buckle.scale = Vector3(0.15, 0.15, 0.15)
		driver_buckle.position = Vector3(0.0, 2.8, 9.5)

		# Energy conduit surge
		if driver_conduit_mat:
			driver_conduit_mat.emission_energy_multiplier = 8.0

		var tw = create_tween()
		tw.set_parallel(true)

		# Phase 1: Dual Belt Ribbon Sweep (Holographic energy wrap around waist)
		tw.tween_property(belt_strap_left, "scale", Vector3.ONE, 0.48).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(belt_strap_left, "rotation:y", 0.0, 0.48).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(belt_strap_right, "scale", Vector3.ONE, 0.48).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(belt_strap_right, "rotation:y", 0.0, 0.48).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		# Phase 2: Driver Buckle Magnetic Acceleration & Slam into Waist
		tw.chain().tween_property(driver_buckle, "position", Vector3.ZERO, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(driver_buckle, "scale", Vector3.ONE, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		# Phase 3: Impact Lock-On ("CLANK-CHUNK!"), Shockwave, Core Flash
		tw.chain().tween_callback(func():
			if sfx_shatter_metal:
				sfx_shatter_metal.pitch_scale = 0.80
				sfx_shatter_metal.play()
			if sfx_shatter_core:
				sfx_shatter_core.pitch_scale = 1.30
				sfx_shatter_core.play()
			if driver_shockwave_particles:
				driver_shockwave_particles.restart()
			if driver_core_mat:
				driver_core_mat.emission_energy_multiplier = 14.0
				var f_tw = create_tween()
				f_tw.tween_property(driver_core_mat, "emission_energy_multiplier", 4.0, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			if driver_conduit_mat:
				var c_tw = create_tween()
				c_tw.tween_property(driver_conduit_mat, "emission_energy_multiplier", 3.0, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

			var main = get_tree().current_scene if get_tree() else null
			if main and main.has_method("shake"):
				main.shake(0.22, 0.035)

			solar_driver_equipped.emit(driver_buckle.global_position)
		)
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
# Kamen Rider Apex Helmet (Model & Materials Setup)
# ─────────────────────────────────────────────────────────────────────────────
func setup_solar_helmet() -> void:
	if helmet_root and is_instance_valid(helmet_root):
		return
	if not sun_node or not is_instance_valid(sun_node):
		return

	helmet_root = Node3D.new()
	helmet_root.name = "SolarHelmetRoot"
	helmet_root.visible = false
	# Sit at Sun's center, tilted 14 degrees up towards the beach camera
	helmet_root.position = Vector3(0.0, 0.0, 0.0)
	helmet_root.rotation.x = deg_to_rad(14.0)
	sun_node.add_child(helmet_root)

	var helmet_scene = load("res://assets/models/solar_helmet.glb")
	if not helmet_scene:
		push_error("[SolarConvergence] Failed to load res://assets/models/solar_helmet.glb")
		return

	var helmet_inst = helmet_scene.instantiate()
	helmet_root.add_child(helmet_inst)

	# Locate named sub-assemblies from GLB
	helmet_crown = helmet_inst.find_child("Helmet_Crown", true, false) as Node3D
	helmet_brow = helmet_inst.find_child("Helmet_Brow", true, false) as Node3D
	helmet_left_cheek = helmet_inst.find_child("Helmet_LeftCheek", true, false) as Node3D
	helmet_right_cheek = helmet_inst.find_child("Helmet_RightCheek", true, false) as Node3D
	helmet_visor = helmet_inst.find_child("Helmet_VisorFrame", true, false) as Node3D

	# Setup Toon materials and extract emissive mats
	_setup_helmet_materials(helmet_inst)

	# Steam Exhaust Particle Systems on Cheek Cowls
	if helmet_left_cheek:
		helmet_steam_left = _create_steam_vent_particles(Vector3(-7.10, 1.20, 2.80), Vector3(-1.0, 0.2, -0.4))
		helmet_left_cheek.add_child(helmet_steam_left)
	if helmet_right_cheek:
		helmet_steam_right = _create_steam_vent_particles(Vector3(7.10, 1.20, 2.80), Vector3(1.0, 0.2, -0.4))
		helmet_right_cheek.add_child(helmet_steam_right)

func _create_steam_vent_particles(pos: Vector3, dir: Vector3) -> CPUParticles3D:
	var cp = CPUParticles3D.new()
	cp.emitting = false
	cp.one_shot = true
	cp.explosiveness = 0.90
	cp.amount = 35
	cp.lifetime = 0.85
	cp.direction = dir.normalized()
	cp.spread = 45.0
	cp.initial_velocity_min = 12.0
	cp.initial_velocity_max = 24.0
	cp.gravity = Vector3(0, 4.0, 0)
	cp.scale_amount_min = 0.8
	cp.scale_amount_max = 2.4
	cp.color = Color(1.0, 0.95, 0.90, 0.80)

	var sp_mat = StandardMaterial3D.new()
	sp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sp_mat.albedo_color = Color(1.0, 0.95, 0.90, 0.75)
	var sp_mesh = SphereMesh.new()
	sp_mesh.radius = 0.35
	sp_mesh.height = 0.70
	sp_mesh.material = sp_mat
	cp.mesh = sp_mesh
	cp.position = pos
	return cp

func _setup_helmet_materials(node: Node) -> void:
	if node is MeshInstance3D and node.mesh:
		for s_idx in range(node.mesh.get_surface_count()):
			var orig_mat = node.mesh.surface_get_material(s_idx)
			if orig_mat is StandardMaterial3D:
				var dup_mat = orig_mat.duplicate() as StandardMaterial3D
				dup_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
				dup_mat.specular_mode = BaseMaterial3D.SPECULAR_TOON
				dup_mat.rim_enabled = true
				dup_mat.rim = 0.65
				dup_mat.rim_tint = 0.40
				dup_mat.rim_color = Color(1.0, 0.88, 0.35)
				node.set_surface_override_material(s_idx, dup_mat)

				var m_name = dup_mat.resource_name if dup_mat.resource_name != "" else orig_mat.resource_name
				if "Crimson" in m_name:
					helmet_gem_mat = dup_mat
					dup_mat.emission_enabled = true
					dup_mat.emission = Color(0.95, 0.15, 0.15)
					dup_mat.emission_energy_multiplier = 3.5
				elif "Cyan" in m_name:
					helmet_visor_mat = dup_mat
					dup_mat.emission_enabled = true
					dup_mat.emission = Color(0.20, 0.92, 1.0)
					dup_mat.emission_energy_multiplier = 4.0
				elif "Amber" in m_name:
					dup_mat.emission_enabled = true
					dup_mat.emission = Color(1.0, 0.70, 0.20)
					dup_mat.emission_energy_multiplier = 3.0
	for child in node.get_children():
		_setup_helmet_materials(child)

func materialize_solar_helmet(animated: bool = true) -> void:
	if is_helmet_equipped:
		return
	is_helmet_equipped = true
	if not helmet_root or not is_instance_valid(helmet_root):
		setup_solar_helmet()
	if not helmet_root:
		return
	helmet_root.visible = true

	if animated:
		_assemble_kamen_rider_helmet()
	else:
		if helmet_crown: helmet_crown.position = Vector3.ZERO; helmet_crown.scale = Vector3.ONE
		if helmet_brow: helmet_brow.position = Vector3.ZERO; helmet_brow.scale = Vector3.ONE
		if helmet_left_cheek: helmet_left_cheek.position = Vector3.ZERO; helmet_left_cheek.rotation.y = 0.0
		if helmet_right_cheek: helmet_right_cheek.position = Vector3.ZERO; helmet_right_cheek.rotation.y = 0.0
		if helmet_visor: helmet_visor.position = Vector3.ZERO; helmet_visor.scale = Vector3.ONE

func remove_solar_helmet(animated: bool = true) -> void:
	if not is_helmet_equipped or not helmet_root:
		return
	is_helmet_equipped = false

	if animated:
		if sfx_shatter_metal:
			sfx_shatter_metal.pitch_scale = 1.35
			sfx_shatter_metal.play()
		var tw = create_tween().set_parallel(true)
		if helmet_crown:
			tw.tween_property(helmet_crown, "position:y", 15.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			tw.tween_property(helmet_crown, "scale", Vector3(0.01, 0.01, 0.01), 0.35)
		if helmet_left_cheek:
			tw.tween_property(helmet_left_cheek, "position:x", -15.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		if helmet_right_cheek:
			tw.tween_property(helmet_right_cheek, "position:x", 15.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		if helmet_visor:
			tw.tween_property(helmet_visor, "scale", Vector3(0.01, 0.01, 0.01), 0.30)
		tw.chain().tween_callback(func():
			if helmet_root and is_instance_valid(helmet_root):
				helmet_root.visible = false
				if helmet_crown: helmet_crown.position = Vector3.ZERO; helmet_crown.scale = Vector3.ONE
				if helmet_brow: helmet_brow.position = Vector3.ZERO; helmet_brow.scale = Vector3.ONE
				if helmet_left_cheek: helmet_left_cheek.position = Vector3.ZERO; helmet_left_cheek.rotation.y = 0.0
				if helmet_right_cheek: helmet_right_cheek.position = Vector3.ZERO; helmet_right_cheek.rotation.y = 0.0
				if helmet_visor: helmet_visor.position = Vector3.ZERO; helmet_visor.scale = Vector3.ONE
		)
	else:
		if helmet_root and is_instance_valid(helmet_root):
			helmet_root.visible = false

func toggle_solar_helmet() -> void:
	if is_helmet_equipped:
		remove_solar_helmet(true)
	else:
		materialize_solar_helmet(true)

func is_helmet_active() -> bool:
	return is_helmet_equipped

# ─────────────────────────────────────────────────────────────────────────────
# Milestone 3: The Convergence Choreography (Vortex Acceleration & Helmet Lock)
# ─────────────────────────────────────────────────────────────────────────────
func trigger_convergence_event() -> void:
	if is_convergence_active:
		return
	is_convergence_active = true
	current_state = State.CONVERGENCE_CHARGING
	convergence_triggered.emit()

	# 1. Ensure Solar Driver is equipped
	if not is_driver_equipped:
		materialize_solar_driver(true)

	# 2. Ensure helmet is loaded and ready
	if not helmet_root:
		setup_solar_helmet()

	# 3. Ensure active drones exist (spawn 6 if none currently in orbit)
	if active_drones.is_empty():
		start_orbital_swarm(6, 25)

	# 4. Time Dilation: Cinematic slow-mo drop
	Engine.time_scale = 0.32

	# 5. Audio & Cinematic Impact
	if sfx_ice_blast:
		sfx_ice_blast.pitch_scale = 0.55
		sfx_ice_blast.play()
	if sfx_shatter_metal:
		sfx_shatter_metal.pitch_scale = 0.55
		sfx_shatter_metal.play()

	var main = get_tree().current_scene if get_tree() else null
	if main:
		if main.has_method("shake"):
			main.shake(0.35, 0.025)
		if main.get("hud") and is_instance_valid(main.hud) and main.hud.has_method("show_convergence_banner"):
			main.hud.show_convergence_banner()
		# Sun reaction: furious charging face & heat scale expansion!
		if main.has_method("on_solar_convergence_sun_powerup"):
			main.on_solar_convergence_sun_powerup()

	# 6. Overcharge pupil glow on all drones
	for drone in active_drones:
		var pupil_mat = drone.get("pupil_mat") as StandardMaterial3D
		if pupil_mat:
			pupil_mat.emission_energy_multiplier = 12.0

	# 7. Drone Vortex Acceleration (0.0s – 1.0s)
	# Align drones into an accelerated equatorial vortex ring around the Sun
	for d in active_drones:
		d["target_radius_x"] = 10.2
		d["target_radius_y"] = 0.6
		d["target_radius_z"] = 4.2
		d["vortex_active"] = true

	# Smoothly accelerate orbit angular velocity
	var speed_tw = create_tween()
	speed_tw.tween_method(func(mult: float):
		for d in active_drones:
			d["orbit_speed"] = 2.0 * mult
	, 1.0, 4.2, 0.95).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	# 8. Trigger Sequential Inward Merge after Vortex Reaches Max RPM
	speed_tw.chain().tween_callback(func():
		current_state = State.CONVERGENCE_IMPLODING
		_start_sequential_drone_absorption()
	)

func _start_sequential_drone_absorption() -> void:
	var drones_to_absorb = active_drones.duplicate()
	var total = drones_to_absorb.size()
	docked_drone_count = 0

	for i in range(total):
		var d_data = drones_to_absorb[i]
		var d_node = d_data.get("node") as Node3D
		if not is_instance_valid(d_node):
			continue
		var delay = i * 0.16
		_animate_drone_vortex_merge(d_node, i, total, delay)

func _animate_drone_vortex_merge(drone_node: Node3D, index: int, total: int, delay: float) -> void:
	var tw = create_tween()
	tw.tween_interval(delay)

	var sun_p = sun_node.global_position if (sun_node and is_instance_valid(sun_node)) else Vector3(0, 13.5, -42)
	var buckle_p = get_driver_buckle_position()
	var target_p = buckle_p.lerp(sun_p, 0.30)

	# Spiral curve directly into the center of the Sun / Driver buckle
	tw.chain().tween_property(drone_node, "global_position", target_p, 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(drone_node, "scale", Vector3(0.01, 0.01, 0.01), 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tw.chain().tween_callback(func():
		# Sound of absorption with escalating pitch
		if sfx_shatter_metal:
			sfx_shatter_metal.pitch_scale = 1.0 + (index * 0.14)
			sfx_shatter_metal.play()

		# Dock spark / flash
		var is_left = (index % 2 == 0)
		if is_left and dock_particles_left:
			dock_particles_left.restart()
		elif not is_left and dock_particles_right:
			dock_particles_right.restart()

		var main = get_tree().current_scene if get_tree() else null
		if main and main.has_method("shake"):
			main.shake(0.08, 0.015)

		if is_instance_valid(drone_node):
			drone_node.visible = false
			drone_node.queue_free()

		docked_drone_count += 1
		convergence_drone_docked.emit(index, target_p)

		# When all drones are absorbed, trigger Kamen Rider Helmet Assembly!
		if docked_drone_count >= total:
			_assemble_kamen_rider_helmet()
	)

func _assemble_kamen_rider_helmet() -> void:
	active_drones.clear()
	is_helmet_equipped = true

	if not helmet_root or not is_instance_valid(helmet_root):
		setup_solar_helmet()
	if not helmet_root:
		_finish_convergence_event()
		return

	helmet_root.visible = true

	# Set initial detached offsets
	if helmet_crown:
		helmet_crown.position = Vector3(0.0, 15.0, 0.0) # Drops from high above
		helmet_crown.scale = Vector3(1.25, 1.25, 1.25)
	if helmet_left_cheek:
		helmet_left_cheek.position = Vector3(-16.0, 0.0, 0.0) # Sweeps in from left
		helmet_left_cheek.rotation.y = deg_to_rad(45.0)
	if helmet_right_cheek:
		helmet_right_cheek.position = Vector3(16.0, 0.0, 0.0) # Sweeps in from right
		helmet_right_cheek.rotation.y = deg_to_rad(-45.0)
	if helmet_brow:
		helmet_brow.position = Vector3(0.0, 6.0, 4.0)
		helmet_brow.scale = Vector3(0.3, 0.3, 0.3)
	if helmet_visor:
		helmet_visor.position = Vector3(0.0, 0.0, 9.0)
		helmet_visor.scale = Vector3(0.15, 0.15, 0.15)

	# Charge swell audio before helmet slam
	if sfx_ice_blast:
		sfx_ice_blast.pitch_scale = 1.35
		sfx_ice_blast.play()

	var tw = create_tween()
	tw.set_parallel(true)

	# Parallel slam lock-on (0.52s, TRANS_BACK, EASE_OUT)
	if helmet_crown:
		tw.tween_property(helmet_crown, "position", Vector3.ZERO, 0.52).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(helmet_crown, "scale", Vector3.ONE, 0.52).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if helmet_left_cheek:
		tw.tween_property(helmet_left_cheek, "position", Vector3.ZERO, 0.48).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(helmet_left_cheek, "rotation:y", 0.0, 0.48).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if helmet_right_cheek:
		tw.tween_property(helmet_right_cheek, "position", Vector3.ZERO, 0.48).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(helmet_right_cheek, "rotation:y", 0.0, 0.48).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if helmet_brow:
		tw.tween_property(helmet_brow, "position", Vector3.ZERO, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(helmet_brow, "scale", Vector3.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if helmet_visor:
		tw.tween_property(helmet_visor, "position", Vector3.ZERO, 0.50).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(helmet_visor, "scale", Vector3.ONE, 0.50).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# On impact: Hydraulic Clamp Lock & Grand Shockwave
	tw.chain().tween_callback(func():
		_finish_convergence_event()
	)

func _finish_convergence_event() -> void:
	# 1. Lock SFX: Heavy metallic clamp
	if sfx_shatter_metal:
		sfx_shatter_metal.pitch_scale = 0.72
		sfx_shatter_metal.play()
	if sfx_shatter_core:
		sfx_shatter_core.pitch_scale = 1.10
		sfx_shatter_core.play()
	if sfx_ice_shatter_glass:
		sfx_ice_shatter_glass.pitch_scale = 0.80
		sfx_ice_shatter_glass.play()

	# 2. Steam exhausts blast outward!
	if helmet_steam_left:
		helmet_steam_left.restart()
	if helmet_steam_right:
		helmet_steam_right.restart()

	# 3. Blinding ignition on forehead gem, visor, and belt
	if helmet_gem_mat:
		helmet_gem_mat.emission_energy_multiplier = 14.0
		var g_tw = create_tween()
		g_tw.tween_property(helmet_gem_mat, "emission_energy_multiplier", 3.5, 0.60).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if helmet_visor_mat:
		helmet_visor_mat.emission_energy_multiplier = 16.0
		var v_tw = create_tween()
		v_tw.tween_property(helmet_visor_mat, "emission_energy_multiplier", 4.0, 0.60).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if driver_shockwave_particles:
		driver_shockwave_particles.amount = 80
		driver_shockwave_particles.restart()

	if driver_core_mat:
		driver_core_mat.emission_energy_multiplier = 18.0
		var c_tw = create_tween()
		c_tw.tween_property(driver_core_mat, "emission_energy_multiplier", 4.5, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if driver_conduit_mat:
		driver_conduit_mat.emission_energy_multiplier = 9.0
		var b_tw = create_tween()
		b_tw.tween_property(driver_conduit_mat, "emission_energy_multiplier", 3.2, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 4. Heavy camera trauma shake & Sun state restoration
	var main = get_tree().current_scene if get_tree() else null
	if main:
		if main.has_method("shake"):
			main.shake(0.52, 0.055)
		if main.has_method("on_solar_convergence_completed"):
			main.on_solar_convergence_completed()

	# 5. Restore time scale back to 1.0x
	var t_tw = create_tween()
	t_tw.tween_property(Engine, "time_scale", 1.0, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	current_state = State.OMEGA_SUN
	is_convergence_active = false
	convergence_completed.emit()

	if main and main.get("hud") and is_instance_valid(main.hud) and main.hud.has_method("show_toast"):
		var is_kr = GameState.language == "KR"
		var title = "오메가 솔라 각성 완료!" if is_kr else "OMEGA SOLAR AWAKENED!"
		var desc = "가면라이더 헬멧 & 드라이버 수렴 완성" if is_kr else "Kamen Rider Helmet & Driver Convergence Complete"
		main.hud.show_toast(title, desc, "res://assets/ui/ui_adventure/PNG/Default/minimap_icon_star_yellow.png", Color(1.0, 0.75, 0.15))

