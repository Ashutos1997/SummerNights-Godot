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

# Audio references
var sfx_deflect: AudioStreamPlayer
var sfx_break: AudioStreamPlayer
var sfx_ice_hit: AudioStreamPlayer

func _ready() -> void:
	_init_audio()

func setup(sun: Node3D, cam: Camera3D) -> void:
	sun_node = sun
	camera_node = cam

func _init_audio() -> void:
	sfx_deflect = AudioStreamPlayer.new()
	sfx_deflect.stream = load("res://assets/audio/sfx/shield_deflect.wav")
	sfx_deflect.bus = "Master"
	sfx_deflect.volume_db = -2.0
	add_child(sfx_deflect)

	sfx_break = AudioStreamPlayer.new()
	sfx_break.stream = load("res://assets/audio/sfx/shield_break.ogg")
	sfx_break.bus = "Master"
	sfx_break.volume_db = 1.0
	add_child(sfx_break)

	sfx_ice_hit = AudioStreamPlayer.new()
	sfx_ice_hit.stream = load("res://assets/audio/sfx/ice_hit.ogg")
	sfx_ice_hit.bus = "Master"
	sfx_ice_hit.volume_db = 1.5
	add_child(sfx_ice_hit)

# ─────────────────────────────────────────────────────────────────────────────
# Phase 1: Orbital Swarm Spawning
# ─────────────────────────────────────────────────────────────────────────────
func start_orbital_swarm(count: int = 6) -> void:
	clear_drones()
	current_state = State.ORBITAL_SWARM
	orbit_time = 0.0

	for i in range(count):
		var drone_data = _create_drone(i, count)
		active_drones.append(drone_data)
		add_child(drone_data["node"])

func _create_drone(index: int, total: int) -> Dictionary:
	var drone_root = Node3D.new()
	drone_root.name = "SolarEyeDrone_%d" % index
	drone_root.scale = Vector3(1.35, 1.35, 1.35)

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

	# Multi-axis Elliptical Orbit Geometry
	var angle_fraction = float(index) / float(total)
	var inclination_deg = -28.0 + (angle_fraction * 56.0)
	var yaw_deg = angle_fraction * 180.0
	var roll_deg = (index % 2) * 20.0 - 10.0

	var orbit_basis = Basis.from_euler(Vector3(
		deg_to_rad(inclination_deg),
		deg_to_rad(yaw_deg),
		deg_to_rad(roll_deg)
	))

	# Direction alternating: every other drone orbits counter-clockwise for crossing paths
	var orbit_speed = (1.25 + (index * 0.08)) * (1.0 if index % 2 == 0 else -1.0)
	var phase_offset = angle_fraction * TAU

	# Wide sweeping radii keeping drones clearly visible around the Sun
	var rx = 6.4 + (index % 3) * 0.6
	var ry = 4.6 + (index % 2) * 0.6
	var rz = 2.4 + (index % 3) * 0.5

	return {
		"node": drone_root,
		"casing_mats": casing_mats,
		"pupil_mat": pupil_mat,
		"orbit_basis": orbit_basis,
		"orbit_speed": orbit_speed,
		"phase_offset": phase_offset,
		"radius_x": rx,
		"radius_y": ry,
		"radius_z": rz,
		"hp": 40.0,
		"max_hp": 40.0,
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
		return

	orbit_time += delta
	var sun_pos = sun_node.global_position
	var cam_pos = camera_node.global_position if (camera_node and is_instance_valid(camera_node)) else Vector3(0, 0, 5)

	for drone in active_drones:
		var node = drone["node"] as Node3D
		if not is_instance_valid(node):
			continue

		# 1. Multi-axis 3D Elliptical Orbit Math
		var t = (orbit_time * drone["orbit_speed"]) + drone["phase_offset"]
		var local_p = Vector3(
			cos(t) * drone["radius_x"],
			sin(t) * drone["radius_y"],
			sin(t * 1.5) * (drone["radius_z"] * 0.45)
		)

		var world_pos = sun_pos + (drone["orbit_basis"] as Basis) * local_p
		node.global_position = world_pos

		# 2. Ocular Focus: Eye drone stares directly down the player's sightline
		node.look_at(cam_pos, Vector3.UP)

		# 3. Dynamic Health Color Progression & Hit Flashing
		var cur_hp = drone["hp"] as float
		var max_hp = drone["max_hp"] as float
		var hp_pct = clampf(cur_hp / max_hp, 0.0, 1.0)
		
		var casing_mats = drone["casing_mats"] as Array[StandardMaterial3D]
		var pupil_mat = drone["pupil_mat"] as StandardMaterial3D

		# Hit impact recoil recovery
		if node.scale.x < 1.35:
			node.scale = node.scale.lerp(Vector3(1.35, 1.35, 1.35), 10.0 * delta)

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
func check_water_stream_intercept(ray_origin: Vector3, ray_normal: Vector3, weapon_power: float, delta: float) -> Dictionary:
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
			
			# Interception radius: 1.4m matching the 1.4m drone wingspan
			if dist < 1.4 and dist < min_dist_to_ray:
				min_dist_to_ray = dist
				closest_drone = drone
				hit_world_pt = pt_on_ray

	if closest_drone.is_empty():
		return { "hit": false }

	# Apply water cooling damage to the intercepted drone
	var cur_hp = closest_drone["hp"] as float
	cur_hp -= weapon_power * delta
	closest_drone["hp"] = cur_hp
	closest_drone["hit_flash"] = 1.0

	var d_node = closest_drone["node"] as Node3D
	# Visual mechanical recoil kick on impact
	d_node.scale = Vector3(1.20, 1.20, 1.20)

	# Play metal deflection sound occasionally
	if sfx_deflect and not sfx_deflect.playing and randf() < 0.3:
		sfx_deflect.pitch_scale = randf_range(1.1, 1.35)
		sfx_deflect.play()

	# Check Destruction
	if cur_hp <= 0.0:
		var pos = d_node.global_position
		_spawn_drone_destruction_fx(pos, false)
		if sfx_break:
			sfx_break.pitch_scale = randf_range(1.05, 1.25)
			sfx_break.play()

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
# Ice Blast Interception (Instantly shatters drone into frost chunks)
# ─────────────────────────────────────────────────────────────────────────────
func check_ice_blast_intercept(blast_pos: Vector3, radius: float = 2.6) -> bool:
	if current_state != State.ORBITAL_SWARM or active_drones.is_empty():
		return false

	var shattered_drone: Dictionary = {}
	for drone in active_drones:
		var node = drone["node"] as Node3D
		if is_instance_valid(node):
			if node.global_position.distance_to(blast_pos) <= radius:
				shattered_drone = drone
				break

	if shattered_drone.is_empty():
		return false

	var d_node = shattered_drone["node"] as Node3D
	var pos = d_node.global_position

	# Ice Shatter VFX & SFX
	_spawn_drone_destruction_fx(pos, true)
	if sfx_ice_hit:
		sfx_ice_hit.pitch_scale = randf_range(1.2, 1.4)
		sfx_ice_hit.play()
	if sfx_break:
		sfx_break.pitch_scale = 1.4
		sfx_break.play()

	active_drones.erase(shattered_drone)
	d_node.queue_free()
	drone_shattered_by_ice.emit(pos)

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
