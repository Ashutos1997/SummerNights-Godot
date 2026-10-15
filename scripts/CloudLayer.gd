extends Node3D

class_name CloudLayer

@export var num_clouds: int = 18
@export var min_speed: float = 1.2
@export var max_speed: float = 3.2
@export var bounds_x: float = 85.0
@export var min_y: float = 14.0
@export var max_y: float = 28.0
@export var min_z: float = -75.0
@export var max_z: float = -20.0

var clouds: Array[Dictionary] = []
var cloud_mat: StandardMaterial3D

func _ready() -> void:
	# Shared sunset cloud material with toon diffuse & warm sunset emission
	cloud_mat = StandardMaterial3D.new()
	cloud_mat.albedo_color = Color(1.0, 0.84, 0.58, 0.95)
	cloud_mat.roughness = 0.85
	cloud_mat.emission_enabled = true
	cloud_mat.emission = Color(0.9, 0.48, 0.15)
	cloud_mat.emission_energy_multiplier = 0.45
	
	_spawn_clouds()

var target_weather: String = "none"
var sun_heat_ratio: float = 1.0

func set_weather_blend(weather_type: String, blend: float) -> void:
	target_weather = weather_type

func set_sun_heat(ratio: float) -> void:
	sun_heat_ratio = clamp(ratio, 0.0, 1.0)

func _spawn_clouds() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(num_clouds):
		var cloud_node = _create_stylized_cloud_mesh(rng)
		add_child(cloud_node)
		
		var start_x = rng.randf_range(-bounds_x, bounds_x)
		var start_y = rng.randf_range(min_y, max_y)
		var start_z = rng.randf_range(min_z, max_z)
		
		# Depth parallax: closer clouds (higher Z, nearer -20) drift faster than distant horizon clouds (nearer -75)
		var depth_t = clamp((start_z - min_z) / (max_z - min_z), 0.0, 1.0)
		var speed = lerp(min_speed, max_speed, depth_t) * rng.randf_range(0.9, 1.1)
		
		# Varied scale range from small wispy clouds to large billowy clouds (0.8x to 4.2x)
		var scale_factor = rng.randf_range(0.8, 4.2)
		var sx = scale_factor * rng.randf_range(0.85, 1.35)
		var sy = scale_factor * rng.randf_range(0.45, 0.85)
		var sz = scale_factor * rng.randf_range(0.75, 1.25)
		
		cloud_node.position = Vector3(start_x, start_y, start_z)
		cloud_node.scale = Vector3(sx, sy, sz)
		
		clouds.append({
			"node": cloud_node,
			"speed": speed,
			"base_y": start_y,
			"bob_speed": rng.randf_range(0.4, 1.0),
			"time_offset": rng.randf_range(0.0, 100.0)
		})

func _create_stylized_cloud_mesh(rng: RandomNumberGenerator) -> Node3D:
	var cloud_root = Node3D.new()
	
	# Randomized puff cluster count and offsets for organic, varied cloud shapes
	var puff_count = rng.randi_range(4, 9)
	for p in range(puff_count):
		var mesh_inst = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = rng.randf_range(0.7, 2.2)
		sphere.height = sphere.radius * 2.0
		sphere.radial_segments = 8
		sphere.rings = 6
		mesh_inst.mesh = sphere
		mesh_inst.material_override = cloud_mat
		
		var offset = Vector3(
			rng.randf_range(-2.2, 2.2) if p > 0 else 0.0,
			rng.randf_range(-0.4, 0.6) if p > 0 else 0.0,
			rng.randf_range(-0.5, 0.5) if p > 0 else 0.0
		)
		mesh_inst.position = offset
		cloud_root.add_child(mesh_inst)
		
	return cloud_root

func _process(delta: float) -> void:
	var time = Time.get_ticks_msec() * 0.001
	for c in clouds:
		var node = c["node"] as Node3D
		if not is_instance_valid(node): continue
		
		# Move left to right
		node.position.x += c["speed"] * delta
		
		# Gentle vertical bobbing
		var bob = sin(time * c["bob_speed"] + c["time_offset"]) * 0.25
		node.position.y = c["base_y"] + bob
		
		# Seamless wrap from right boundary (+85m) to left boundary (-85m)
		if node.position.x > bounds_x:
			node.position.x = -bounds_x
			node.position.y = randf_range(min_y, max_y)
			node.position.z = randf_range(min_z, max_z)
			c["base_y"] = node.position.y
			
			# Re-calculate depth parallax speed for new depth
			var depth_t = clamp((node.position.z - min_z) / (max_z - min_z), 0.0, 1.0)
			c["speed"] = lerp(min_speed, max_speed, depth_t) * randf_range(0.9, 1.1)
			
			# Re-randomize size & aspect ratio on wrap for endless variety
			var sf = randf_range(0.8, 4.2)
			node.scale = Vector3(
				sf * randf_range(0.85, 1.35),
				sf * randf_range(0.45, 0.85),
				sf * randf_range(0.75, 1.25)
			)

	# Smooth color transitions
	var cool_t = 1.0 - sun_heat_ratio
	# Sunset: warm golden peach; Twilight/Night: deep twilight with moonlit silver-cyan rim
	var sunset_albedo = Color(1.0, 0.84, 0.58, 0.95)
	var twilight_albedo = Color(0.24, 0.32, 0.52, 0.95)
	var target_albedo = sunset_albedo.lerp(twilight_albedo, cool_t * 0.85)

	var sunset_emission = Color(0.9, 0.48, 0.15)
	var twilight_emission = Color(0.42, 0.75, 0.95) # Moonlit silver-cyan rim
	var target_emission = sunset_emission.lerp(twilight_emission, cool_t * 0.90)
	var target_emission_energy = lerpf(0.45, 0.28, cool_t)
	
	if target_weather == "rain":
		target_albedo = Color(0.3, 0.35, 0.4, 0.95) # Dark greyish blue
		target_emission = Color(0.0, 0.0, 0.0)
		target_emission_energy = 0.0
	elif target_weather == "eclipse":
		target_albedo = Color(0.1, 0.05, 0.15, 0.95) # Very dark purple
		target_emission = Color(0.2, 0.0, 0.4)
		target_emission_energy = 0.2
		
	cloud_mat.albedo_color = cloud_mat.albedo_color.lerp(target_albedo, delta * 2.0)
	cloud_mat.emission = cloud_mat.emission.lerp(target_emission, delta * 2.0)
	cloud_mat.emission_energy_multiplier = lerp(cloud_mat.emission_energy_multiplier, target_emission_energy, delta * 2.0)

	# ── Interactive Beach Clouds Process ──
	_process_beach_clouds(delta)

# ── Interactive Beach Cloud System (Multi-Cloud Soft Cover) ──────────────────
var interactive_clouds: Array[Dictionary] = []
@export var max_interactive_clouds: int = 3

func _is_wave_eligible_for_beach_cloud() -> bool:
	if GameState.is_survival_mode:
		# Regular waves only: Wave >= 2, non-boss waves
		return GameState.current_wave >= 2 and (GameState.current_wave % 5 != 0)
	else:
		# Normal levels 2 to 5 (Level 1 is calm tutorial, Level 6 is final boss)
		return GameState.level >= 2 and GameState.level <= 5

func _process_beach_clouds(delta: float) -> void:
	if not _is_wave_eligible_for_beach_cloud():
		if not interactive_clouds.is_empty():
			_despawn_all_interactive_clouds()
		return
		
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Determine wind drift direction from current game state
	var main_node = get_tree().current_scene
	var wind_dir = 1.0
	if main_node and "wind_direction" in main_node and main_node.wind_direction != 0.0:
		wind_dir = main_node.wind_direction
		
	# Initial spawn: Stagger clouds across the visible sky so the arena has immediate life
	if interactive_clouds.is_empty():
		for i in range(max_interactive_clouds):
			var frac = float(i) / float(max(1, max_interactive_clouds - 1))
			var init_x = lerpf(-52.0, 52.0, frac) + rng.randf_range(-6.0, 6.0)
			_spawn_single_interactive_cloud(rng, wind_dir, init_x, true)
		return

	var time = Time.get_ticks_msec() * 0.001
	var surge_mult = 1.35 if (main_node and "wind_state" in main_node and main_node.wind_state == 2) else 1.0
	
	# Process existing clouds
	for i in range(interactive_clouds.size() - 1, -1, -1):
		var c = interactive_clouds[i]
		var node = c.get("node") as Node3D
		if not is_instance_valid(node):
			interactive_clouds.remove_at(i)
			continue
			
		# Sync cloud drift direction with active wind direction
		c["dir"] = wind_dir
		
		# Move horizontally across the combat plane (boosted during active solar wind surge)
		node.position.x += c["speed"] * c["dir"] * surge_mult * delta
		
		# Gentle vertical bobbing
		var bob = sin(time * c["bob_speed"] + c["time_offset"]) * c["bob_amp"]
		node.position.y = c["base_y"] + bob
		
		# Despawn and wrap from the windward boundary when passing off-screen
		var off_right = (c["dir"] > 0 and node.position.x > 82.0)
		var off_left = (c["dir"] < 0 and node.position.x < -82.0)
		if off_right or off_left:
			var entry_x = -78.0 if c["dir"] > 0 else 78.0
			node.queue_free()
			interactive_clouds.remove_at(i)
			_spawn_single_interactive_cloud(rng, wind_dir, entry_x, false)

func _spawn_single_interactive_cloud(rng: RandomNumberGenerator, wind_dir: float, x_pos: float, is_initial: bool) -> void:
	var base_y = rng.randf_range(11.5, 16.0) # Sky altitude passing directly over the Sun at Y=13.5
	var z_depth = rng.randf_range(-37.0, -39.5) # Subtly layered in front of Sun at -42, far behind trees
	var speed = rng.randf_range(3.8, 6.2) # Base drift speed
	var main_node = get_tree().current_scene
	if main_node and "current_wind_knots" in main_node and main_node.current_wind_knots > 0.0:
		speed = lerpf(3.0, 7.5, main_node.current_wind_knots / 50.0) * rng.randf_range(0.9, 1.1)
	var scale_factor = rng.randf_range(0.85, 1.35)
	var radius = 5.6 * scale_factor
	
	var cloud_root = Node3D.new()
	cloud_root.name = "BeachCloud"
	cloud_root.position = Vector3(x_pos, base_y, z_depth)
	
	# Organic randomized puff clusters (5 to 8 overlapping spheres)
	var puff_count = rng.randi_range(5, 8)
	for p in range(puff_count):
		var mi = MeshInstance3D.new()
		var sp = SphereMesh.new()
		var r = rng.randf_range(2.4, 3.8) * scale_factor if p == 0 else rng.randf_range(1.8, 3.0) * scale_factor
		sp.radius = r
		sp.height = r * 2.0
		sp.radial_segments = 10
		sp.rings = 6
		mi.mesh = sp
		# Share the global cloud_mat so all interactive clouds share 1:1 sky lighting & sunset tinting
		mi.material_override = cloud_mat
		
		var offset = Vector3.ZERO
		if p > 0:
			offset = Vector3(
				rng.randf_range(-3.8, 3.8) * scale_factor,
				rng.randf_range(-0.8, 1.2) * scale_factor,
				rng.randf_range(-0.6, 0.6) * scale_factor
			)
		mi.position = offset
		cloud_root.add_child(mi)
		
	add_child(cloud_root)
	
	if not is_initial:
		cloud_root.scale = Vector3(0.1, 0.1, 0.1)
		var tw = create_tween()
		tw.tween_property(cloud_root, "scale", Vector3.ONE, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
	interactive_clouds.append({
		"node": cloud_root,
		"speed": speed,
		"dir": wind_dir,
		"base_y": base_y,
		"radius": radius,
		"bob_speed": rng.randf_range(0.5, 0.9),
		"bob_amp": rng.randf_range(0.2, 0.45),
		"time_offset": rng.randf_range(0.0, 100.0)
	})

func _despawn_all_interactive_clouds() -> void:
	for c in interactive_clouds:
		var node = c.get("node") as Node3D
		if is_instance_valid(node):
			node.queue_free()
	interactive_clouds.clear()

func has_active_beach_cloud() -> bool:
	return not interactive_clouds.is_empty()

func check_water_spray(aim_origin: Vector3, aim_dir: Vector3) -> Dictionary:
	var closest_hit: Dictionary = {"hit": false}
	var closest_t: float = 999999.0
	
	for c in interactive_clouds:
		var node = c.get("node") as Node3D
		if not is_instance_valid(node):
			continue
			
		var c_pos = node.global_position
		var vec_to_cloud = c_pos - aim_origin
		var proj_t = vec_to_cloud.dot(aim_dir)
		if proj_t <= 0.0 or proj_t >= closest_t:
			continue
			
		var closest_pt = aim_origin + aim_dir * proj_t
		var dist = c_pos.distance_to(closest_pt)
		var rad = c.get("radius", 6.0) as float
		if dist <= rad:
			closest_t = proj_t
			closest_hit = {
				"hit": true,
				"hit_pos": closest_pt,
				"cloud_pos": c_pos,
				"cloud_node": node
			}
			
	return closest_hit
