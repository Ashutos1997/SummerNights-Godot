class_name SolarConvergenceManager
extends Node3D

## Solar Convergence Manager (Regad Omega / Solar Driver Boss Encounter)
## Phase 1: Orbital Ocular Swarm ("Solar Eyes" / "Helios Drones")
## Features custom low-poly Tokusatsu GLB models, multi-axis 3D elliptical orbits,
## physical water stream interception, dynamic damage progression, and Ice Blast shatter.

signal drone_destroyed(pos: Vector3)
signal drone_shattered_by_ice(pos: Vector3)
signal convergence_triggered()

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

const DRONE_SCENE = preload("res://assets/models/solar_eye_drone.glb")

# Audio references (Bespoke Drone SFX)
var hit_players: Array[AudioStreamPlayer] = []
var hit_player_idx: int = 0
var hit_sfx_cooldown: float = 0.0

var sfx_drone_shatter: AudioStreamPlayer
var sfx_drone_ice_shatter: AudioStreamPlayer

func _ready() -> void:
	_init_audio()

func setup(sun: Node3D, cam: Camera3D) -> void:
	sun_node = sun
	camera_node = cam

func _init_audio() -> void:
	var hit_stream = load("res://assets/audio/sfx/drone_hit.wav")
	for i in range(4):
		var hp = AudioStreamPlayer.new()
		hp.stream = hit_stream
		hp.bus = "Master"
		hp.volume_db = 0.8
		add_child(hp)
		hit_players.append(hp)

	sfx_drone_shatter = AudioStreamPlayer.new()
	sfx_drone_shatter.stream = load("res://assets/audio/sfx/drone_shatter.wav")
	sfx_drone_shatter.bus = "Master"
	sfx_drone_shatter.volume_db = 2.5
	add_child(sfx_drone_shatter)

	sfx_drone_ice_shatter = AudioStreamPlayer.new()
	sfx_drone_ice_shatter.stream = load("res://assets/audio/sfx/drone_ice_shatter.wav")
	sfx_drone_ice_shatter.bus = "Master"
	sfx_drone_ice_shatter.volume_db = 3.2
	add_child(sfx_drone_ice_shatter)

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
	drone_root.scale = Vector3(1.7, 1.7, 1.7) # Enlarged for clear readability & targeting

	# Instantiate the custom low-poly Tokusatsu Solar Eye Drone model
	var model_inst = DRONE_SCENE.instantiate() as Node3D
	drone_root.add_child(model_inst)

	# Extract materials for dynamic color shifts and hit flashing
	var casing_mats: Array[StandardMaterial3D] = []
	var pupil_mat: StandardMaterial3D = null

	var mesh_instances = model_inst.find_children("", "MeshInstance3D", true)
	for mi in mesh_instances:
		var mesh_node = mi as MeshInstance3D
		if mesh_node and mesh_node.mesh:
			for s_idx in range(mesh_node.mesh.get_surface_count()):
				var orig_mat = mesh_node.get_active_material(s_idx)
				if orig_mat:
					var dup_mat = orig_mat.duplicate() as StandardMaterial3D
					mesh_node.set_surface_override_material(s_idx, dup_mat)
					var m_name = dup_mat.resource_name if dup_mat.resource_name != "" else orig_mat.resource_name
					if "Gold" in m_name:
						casing_mats.append(dup_mat)
					elif "Solar" in m_name or "Core" in m_name or dup_mat.emission_enabled:
						if not pupil_mat:
							pupil_mat = dup_mat

	# Dynamic Coronal Orbit Geometry: Smooth, stately circular rotation around the Sun
	# Tuned for tracking gameplay: 0.85 to 1.15 rad/s (~6.5s per revolution)
	var angle_fraction = float(index) / float(total)
	var orbit_speed = (0.85 + (index * 0.06)) * (1.0 if index % 2 == 0 else -1.0)
	var phase_offset = angle_fraction * TAU

	var rx = 9.4 + (index % 3) * 0.8
	var ry = 8.4 + (index % 2) * 0.8
	var rz = 2.8 + (index % 3) * 0.6 # Positioned cleanly in front of the Sun along Z

	# Ensure sun_node is resolved before positioning
	if not sun_node or not is_instance_valid(sun_node):
		var main = get_tree().current_scene if get_tree() else null
		if main and main.get("sun") and is_instance_valid(main.sun):
			sun_node = main.sun

	var sun_pos = sun_node.global_position if (sun_node and is_instance_valid(sun_node)) else Vector3(0, 10.5, -42)
	var init_t = phase_offset
	drone_root.global_position = sun_pos + Vector3(
		cos(init_t) * rx,
		sin(init_t) * ry,
		rz + sin(init_t * 2.0 + index) * 0.6
	)

	# Dynamic wave-scaled HP (Wave 1: 38.5 HP | Wave 20: 105 HP | Wave 30: 140 HP)
	var calculated_hp = 35.0 + (wave * 3.5)

	return {
		"node": drone_root,
		"casing_mats": casing_mats,
		"pupil_mat": pupil_mat,
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
# Process: Orbit Updates & Orientation
# ─────────────────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if current_state != State.ORBITAL_SWARM:
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

		# 1. Smooth Sweeping Coronal Orbit around Sun's perimeter
		var t = (orbit_time * drone["orbit_speed"]) + drone["phase_offset"]
		var local_p = Vector3(
			cos(t) * drone["radius_x"],
			sin(t) * drone["radius_y"],
			drone["radius_z"] + sin(t * 2.0 + drone["index"]) * 0.6
		)

		var world_pos = sun_pos + local_p
		node.global_position = world_pos

		# 2. Ocular Focus: Eye drone stares directly down the player's sightline
		node.look_at(cam_pos, Vector3.UP)

		# 3. Dynamic Health Color Progression & Hit Flashing
		var cur_hp = drone["hp"] as float
		var max_hp = drone["max_hp"] as float
		var hp_pct = clampf(cur_hp / max_hp, 0.0, 1.0)
		
		var casing_mats = drone["casing_mats"] as Array[StandardMaterial3D]
		var pupil_mat = drone["pupil_mat"] as StandardMaterial3D

		# Hit impact recoil recovery back to 1.7
		if node.scale.x < 1.7:
			node.scale = node.scale.lerp(Vector3(1.7, 1.7, 1.7), 10.0 * delta)

		if drone["hit_flash"] > 0.0:
			drone["hit_flash"] -= delta * 6.0
			var f = clampf(drone["hit_flash"], 0.0, 1.0)
			# Electric cyan hit flash
			for c_mat in casing_mats:
				if is_instance_valid(c_mat):
					c_mat.albedo_color = Color(0.98, 0.80, 0.18).lerp(Color(0.5, 0.95, 1.0), f)
			if pupil_mat and is_instance_valid(pupil_mat):
				pupil_mat.emission = Color(1.0, 0.45, 0.10).lerp(Color(0.3, 1.0, 1.0), f)
				pupil_mat.emission_energy_multiplier = 3.2 + (f * 5.0)
		else:
			# Visual damage states: Gold (Healthy) -> Orange (Damaged) -> Smoldering Crimson (Critical)
			var base_casing_col: Color
			var base_pupil_col: Color
			var pulse_speed = 3.2
			
			if hp_pct > 0.60:
				base_casing_col = Color(0.98, 0.78, 0.16)
				base_pupil_col = Color(1.0, 0.42, 0.08)
				pulse_speed = 3.2
			elif hp_pct > 0.30:
				base_casing_col = Color(1.0, 0.50, 0.10)
				base_pupil_col = Color(1.0, 0.25, 0.05)
				pulse_speed = 6.0
			else:
				base_casing_col = Color(0.95, 0.20, 0.12)
				base_pupil_col = Color(1.0, 0.10, 0.05)
				pulse_speed = 10.0

			for c_mat in casing_mats:
				if is_instance_valid(c_mat):
					c_mat.albedo_color = base_casing_col

			if pupil_mat and is_instance_valid(pupil_mat):
				pupil_mat.emission = base_pupil_col
				var pulse = 0.5 + 0.5 * sin(orbit_time * pulse_speed + drone["phase_offset"])
				pupil_mat.emission_energy_multiplier = 2.6 + (pulse * 1.8)

# ─────────────────────────────────────────────────────────────────────────────
# Water Stream Interception (Absorbs damage, shields Sun behind it)
# ─────────────────────────────────────────────────────────────────────────────
func check_water_stream_intercept(ray_origin: Vector3, ray_normal: Vector3, weapon_damage: float) -> Dictionary:
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
			
			# Interception radius: 1.85m matching 1.7x scaled drone dimensions
			if dist < 1.85 and dist < min_dist_to_ray:
				min_dist_to_ray = dist
				closest_drone = drone
				hit_world_pt = pt_on_ray

	if closest_drone.is_empty():
		return { "hit": false }

	# Apply water cooling damage to the intercepted drone
	var cur_hp = closest_drone["hp"] as float
	cur_hp -= weapon_damage
	closest_drone["hp"] = cur_hp
	closest_drone["hit_flash"] = 1.0

	var d_node = closest_drone["node"] as Node3D
	# Visual mechanical recoil kick on impact
	d_node.scale = Vector3(1.45, 1.45, 1.45)

	# Play crisp rhythmic hydro-metallic hit tick
	if hit_sfx_cooldown <= 0.0 and not hit_players.is_empty():
		var p = hit_players[hit_player_idx]
		hit_player_idx = (hit_player_idx + 1) % hit_players.size()
		p.pitch_scale = randf_range(0.92, 1.15)
		p.play()
		hit_sfx_cooldown = 0.065

	# Check Destruction
	if cur_hp <= 0.0:
		var pos = d_node.global_position
		_spawn_drone_destruction_fx(pos, false)
		if sfx_drone_shatter:
			sfx_drone_shatter.pitch_scale = randf_range(0.95, 1.08)
			sfx_drone_shatter.play()

		active_drones.erase(closest_drone)
		d_node.queue_free()
		drone_destroyed.emit(pos)

		return {
			"hit": true,
			"destroyed": true,
			"position": pos
		}

	return {
		"hit": true,
		"destroyed": false,
		"position": hit_world_pt
	}

# ─────────────────────────────────────────────────────────────────────────────
# Ice Blast Interception (AOE Cryo-Frost: shatters all drones within 5.5m blast radius)
# ─────────────────────────────────────────────────────────────────────────────
func check_ice_blast_intercept(blast_pos: Vector3, radius: float = 5.5) -> bool:
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

	if sfx_drone_ice_shatter:
		sfx_drone_ice_shatter.pitch_scale = randf_range(0.96, 1.06)
		sfx_drone_ice_shatter.play()

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
