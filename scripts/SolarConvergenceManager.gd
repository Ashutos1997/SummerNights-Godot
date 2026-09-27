class_name SolarConvergenceManager
extends Node3D

## Solar Convergence Manager (Regad Omega / Solar Driver Boss Encounter)
## Phase 1: Orbital Ocular Swarm ("Solar Eyes" / "Helios Drones")
## Multi-axis 3D elliptical orbits revolving around the Sun, intercepting water spray,
## blocking sunspots, with Ice Blast shatter counterplay.

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

# Materials (cached for instancing & performance)
var mat_gold_casing: StandardMaterial3D
var mat_dark_sclera: StandardMaterial3D
var mat_pupil_glow: StandardMaterial3D

# Audio references
var sfx_deflect: AudioStreamPlayer
var sfx_break: AudioStreamPlayer
var sfx_ice_hit: AudioStreamPlayer

func _ready() -> void:
	_init_materials()
	_init_audio()

func setup(sun: Node3D, cam: Camera3D) -> void:
	sun_node = sun
	camera_node = cam

func _init_materials() -> void:
	# Outer casing: Cyber-Gold metallic
	mat_gold_casing = StandardMaterial3D.new()
	mat_gold_casing.albedo_color = Color(0.98, 0.78, 0.16)
	mat_gold_casing.metallic = 0.85
	mat_gold_casing.roughness = 0.18

	# Internal eyeball housing: Dark obsidian metallic
	mat_dark_sclera = StandardMaterial3D.new()
	mat_dark_sclera.albedo_color = Color(0.10, 0.11, 0.14)
	mat_dark_sclera.metallic = 0.90
	mat_dark_sclera.roughness = 0.22

	# Central ocular pupil/lens: Radiant amber-crimson emissive lens
	mat_pupil_glow = StandardMaterial3D.new()
	mat_pupil_glow.albedo_color = Color(1.0, 0.38, 0.08)
	mat_pupil_glow.emission_enabled = true
	mat_pupil_glow.emission = Color(1.0, 0.42, 0.10)
	mat_pupil_glow.emission_energy_multiplier = 2.4

func _init_audio() -> void:
	sfx_deflect = AudioStreamPlayer.new()
	sfx_deflect.stream = load("res://assets/audio/sfx/shield_deflect.wav")
	sfx_deflect.bus = "Master"
	sfx_deflect.volume_db = -4.0
	add_child(sfx_deflect)

	sfx_break = AudioStreamPlayer.new()
	sfx_break.stream = load("res://assets/audio/sfx/shield_break.ogg")
	sfx_break.bus = "Master"
	sfx_break.volume_db = -1.0
	add_child(sfx_break)

	sfx_ice_hit = AudioStreamPlayer.new()
	sfx_ice_hit.stream = load("res://assets/audio/sfx/ice_hit.ogg")
	sfx_ice_hit.bus = "Master"
	sfx_ice_hit.volume_db = 0.0
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

	# 1. Outer Gold Chassis Ring (Torus)
	var ring_mesh = TorusMesh.new()
	ring_mesh.inner_radius = 0.32
	ring_mesh.outer_radius = 0.46
	ring_mesh.rings = 14
	ring_mesh.ring_segments = 8
	var ring_inst = MeshInstance3D.new()
	ring_inst.name = "GoldRing"
	ring_inst.mesh = ring_mesh
	ring_inst.material_override = mat_gold_casing
	drone_root.add_child(ring_inst)

	# 2. Central Sclera Dome (Sphere)
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.30
	sphere_mesh.height = 0.50
	sphere_mesh.radial_segments = 14
	sphere_mesh.rings = 8
	var sphere_inst = MeshInstance3D.new()
	sphere_inst.name = "EyeBall"
	sphere_inst.mesh = sphere_mesh
	sphere_inst.material_override = mat_dark_sclera
	drone_root.add_child(sphere_inst)

	# 3. Ocular Pupil Lens (Emissive Cylinder Disk)
	var pupil_mesh = CylinderMesh.new()
	pupil_mesh.top_radius = 0.16
	pupil_mesh.bottom_radius = 0.16
	pupil_mesh.height = 0.06
	pupil_mesh.radial_segments = 14
	var pupil_inst = MeshInstance3D.new()
	pupil_inst.name = "PupilLens"
	pupil_inst.mesh = pupil_mesh
	pupil_inst.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	pupil_inst.position = Vector3(0.0, 0.0, 0.24)
	
	# Unique material instance per drone for independent hit flashing
	var pupil_mat = mat_pupil_glow.duplicate() as StandardMaterial3D
	pupil_inst.material_override = pupil_mat
	drone_root.add_child(pupil_inst)

	# 4. Angled Eyebrow Fins (Audience Glare / Regad aesthetic)
	for sign_x in [-1.0, 1.0]:
		var fin_mesh = PrismMesh.new()
		fin_mesh.size = Vector3(0.12, 0.38, 0.08)
		var fin_inst = MeshInstance3D.new()
		fin_inst.mesh = fin_mesh
		fin_inst.material_override = mat_gold_casing
		fin_inst.position = Vector3(sign_x * 0.44, 0.18, 0.02)
		fin_inst.rotation_degrees = Vector3(0.0, 0.0, -sign_x * 35.0)
		drone_root.add_child(fin_inst)

	# Multi-axis Elliptical Orbit Geometry
	# Spread inclinations across multi-angle 3D planes to form a spherical orbital cage
	var angle_fraction = float(index) / float(total)
	var inclination_deg = -35.0 + (angle_fraction * 70.0) # -35° to +35° vertical tilt
	var yaw_deg = angle_fraction * 180.0                  # Cross-crossing orbital planes
	var roll_deg = (index % 2) * 25.0 - 12.5

	var orbit_basis = Basis.from_euler(Vector3(
		deg_to_rad(inclination_deg),
		deg_to_rad(yaw_deg),
		deg_to_rad(roll_deg)
	))

	# Direction alternating: every other drone orbits counter-clockwise for dramatic crossing paths
	var orbit_speed = (1.4 + (index * 0.12)) * (1.0 if index % 2 == 0 else -1.0)
	var phase_offset = angle_fraction * TAU

	# Elliptical radii around the Sun
	var rx = 5.2 + (index % 3) * 0.5
	var ry = 2.6 + (index % 2) * 0.6
	var rz = 4.2 + (index % 3) * 0.4

	return {
		"node": drone_root,
		"pupil_inst": pupil_inst,
		"pupil_mat": pupil_mat,
		"orbit_basis": orbit_basis,
		"orbit_speed": orbit_speed,
		"phase_offset": phase_offset,
		"radius_x": rx,
		"radius_y": ry,
		"radius_z": rz,
		"hp": 35.0,
		"max_hp": 35.0,
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
			sin(t * 2.0) * (drone["radius_y"] * 0.45),
			sin(t) * drone["radius_z"]
		)

		var world_pos = sun_pos + (drone["orbit_basis"] as Basis) * local_p
		node.global_position = world_pos

		# 2. Ocular Focus: Eye drone always stares directly down the player's sightline
		node.look_at(cam_pos, Vector3.UP)

		# 3. Dynamic Pupil Breathing Pulse
		var pupil_mat = drone["pupil_mat"] as StandardMaterial3D
		if pupil_mat:
			if drone["hit_flash"] > 0.0:
				drone["hit_flash"] -= delta * 5.0
				var f = clampf(drone["hit_flash"], 0.0, 1.0)
				pupil_mat.emission = Color(1.0, 0.42, 0.10).lerp(Color(0.2, 0.9, 1.0), f)
				pupil_mat.emission_energy_multiplier = 2.4 + (f * 3.5)
			else:
				var pulse = 0.5 + 0.5 * sin(orbit_time * 3.2 + drone["phase_offset"])
				pupil_mat.emission = Color(1.0, 0.42, 0.10)
				pupil_mat.emission_energy_multiplier = 2.0 + (pulse * 1.0)

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
			
			# Interception radius: 1.15m (generous enough to shield sunspots behind it)
			if dist < 1.15 and dist < min_dist_to_ray:
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
	# Play metal deflection sound occasionally
	if sfx_deflect and not sfx_deflect.playing and randf() < 0.25:
		sfx_deflect.pitch_scale = randf_range(1.1, 1.3)
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
func check_ice_blast_intercept(blast_pos: Vector3, radius: float = 2.4) -> bool:
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
	particles.amount = 28
	particles.lifetime = 0.8
	particles.global_position = pos

	# Direction & Velocity
	particles.direction = Vector3.UP
	particles.spread = 180.0
	particles.initial_velocity_min = 6.0
	particles.initial_velocity_max = 14.0
	particles.gravity = Vector3(0.0, -12.0, 0.0)

	var p_mat = StandardMaterial3D.new()
	p_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	p_mat.vertex_color_use_as_albedo = true

	if is_ice_shatter:
		# Radiant cyan-frost ice shards
		p_mat.albedo_color = Color(0.35, 0.95, 1.0, 0.9)
		particles.color = Color(0.65, 0.98, 1.0, 1.0)
	else:
		# Molten gold electrical sparks
		p_mat.albedo_color = Color(1.0, 0.75, 0.15, 0.9)
		particles.color = Color(1.0, 0.85, 0.3, 1.0)

	var p_mesh = BoxMesh.new()
	p_mesh.size = Vector3(0.14, 0.14, 0.14)
	p_mesh.material = p_mat
	particles.mesh = p_mesh

	add_child(particles)
	particles.emitting = true

	# Auto cleanup after lifetime
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
