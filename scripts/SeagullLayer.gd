extends Node3D

class_name SeagullLayer

@export var num_birds: int = 5
@export var orbit_radius_min: float = 12.0
@export var orbit_radius_max: float = 28.0
@export var min_y: float = 8.0
@export var max_y: float = 16.0
@export var center_pos := Vector3(0, 0, -18)

var birds: Array[Dictionary] = []
var body_mat: StandardMaterial3D
var beak_mat: StandardMaterial3D
var wingtip_mat: StandardMaterial3D
var last_squawk_time: float = 0.0
var current_weather: String = "none"

func _ready() -> void:
	body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.96, 0.96, 0.98) # White body
	body_mat.roughness = 0.8
	
	beak_mat = StandardMaterial3D.new()
	beak_mat.albedo_color = Color(1.0, 0.7, 0.1) # Amber beak
	beak_mat.emission_enabled = true
	beak_mat.emission = Color(0.9, 0.55, 0.1)
	beak_mat.emission_energy_multiplier = 0.5
	
	wingtip_mat = StandardMaterial3D.new()
	wingtip_mat.albedo_color = Color(0.25, 0.25, 0.3) # Dark grey wingtips
	
	_spawn_seagulls()

func _spawn_seagulls() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(num_birds):
		var bird_node = _create_seagull_mesh()
		add_child(bird_node)
		
		var radius = rng.randf_range(orbit_radius_min, orbit_radius_max)
		var angle = rng.randf_range(0.0, TAU)
		var height = rng.randf_range(min_y, max_y)
		var speed = rng.randf_range(0.25, 0.45) * (1.0 if rng.randf() > 0.3 else -1.0)
		var flap_speed = rng.randf_range(6.0, 8.5)
		
		birds.append({
			"node": bird_node,
			"left_wing": bird_node.get_node("LeftWingPivot"),
			"right_wing": bird_node.get_node("RightWingPivot"),
			"left_elbow": bird_node.get_node("LeftWingPivot/LeftElbowPivot"),
			"right_elbow": bird_node.get_node("RightWingPivot/RightElbowPivot"),
			"head": bird_node.get_node("HeadPivot"),
			"tail": bird_node.get_node("TailPivot"),
			"radius": radius,
			"angle": angle,
			"height": height,
			"speed": speed,
			"base_speed": speed,
			"flap_speed": flap_speed,
			"base_flap_speed": flap_speed,
			"time_offset": rng.randf_range(0.0, 100.0),
			"state": "orbiting",
			"target_pos": Vector3.ZERO,
			"bank_angle": 0.0,
			"next_look_time": 0.0,
			"peck_timer": 0.0,
			"head_target_yaw": 0.0,
			"head_target_pitch": 0.0
		})

func _create_seagull_mesh() -> Node3D:
	var bird_root = Node3D.new()
	
	# Main Body
	var body_inst = MeshInstance3D.new()
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(0.25, 0.2, 0.55)
	body_inst.mesh = body_mesh
	body_inst.material_override = body_mat
	bird_root.add_child(body_inst)
	
	# Head Pivot (Base of neck, enables natural look-around and pecking)
	var head_pivot = Node3D.new()
	head_pivot.name = "HeadPivot"
	head_pivot.position = Vector3(0, 0.12, -0.20)
	bird_root.add_child(head_pivot)
	
	var head_inst = MeshInstance3D.new()
	var head_mesh = BoxMesh.new()
	head_mesh.size = Vector3(0.18, 0.18, 0.22)
	head_inst.mesh = head_mesh
	head_inst.material_override = body_mat
	head_inst.position = Vector3(0, 0, -0.08)
	head_pivot.add_child(head_inst)
	
	# Eyes (Attached to HeadPivot so they move together)
	for x in [-0.09, 0.09]:
		var eye = MeshInstance3D.new()
		var eye_mesh = BoxMesh.new()
		eye_mesh.size = Vector3(0.04, 0.04, 0.04)
		eye.mesh = eye_mesh
		eye.material_override = wingtip_mat
		eye.position = Vector3(x, 0.03, -0.14)
		head_pivot.add_child(eye)
	
	# Beak (Attached to HeadPivot)
	var beak_inst = MeshInstance3D.new()
	var beak_mesh = PrismMesh.new()
	beak_mesh.size = Vector3(0.08, 0.18, 0.08)
	beak_inst.mesh = beak_mesh
	beak_inst.material_override = beak_mat
	beak_inst.rotation_degrees = Vector3(-90, 0, 0)
	beak_inst.position = Vector3(0, -0.02, -0.26)
	head_pivot.add_child(beak_inst)
	
	# Tail Pivot (Enables trim pitch and ground twitches)
	var tail_pivot = Node3D.new()
	tail_pivot.name = "TailPivot"
	tail_pivot.position = Vector3(0, 0.08, 0.25)
	bird_root.add_child(tail_pivot)
	
	var tail_inst = MeshInstance3D.new()
	var tail_mesh = PrismMesh.new()
	tail_mesh.size = Vector3(0.15, 0.25, 0.04)
	tail_inst.mesh = tail_mesh
	tail_inst.material_override = wingtip_mat
	tail_inst.rotation_degrees = Vector3(110, 0, 0)
	tail_inst.position = Vector3(0, 0, 0.10)
	tail_pivot.add_child(tail_inst)
	
	# Feet
	for x in [-0.07, 0.07]:
		var foot = MeshInstance3D.new()
		var foot_mesh = BoxMesh.new()
		foot_mesh.size = Vector3(0.06, 0.04, 0.12)
		foot.mesh = foot_mesh
		foot.material_override = beak_mat
		foot.position = Vector3(x, -0.1, 0.05)
		bird_root.add_child(foot)
	
	# Left Wing (Shoulder -> Elbow -> Wingtip hierarchy)
	var left_pivot = Node3D.new()
	left_pivot.name = "LeftWingPivot"
	left_pivot.position = Vector3(-0.14, 0.05, 0.0)
	bird_root.add_child(left_pivot)
	
	var left_inner = MeshInstance3D.new()
	var l_inner_mesh = BoxMesh.new()
	l_inner_mesh.size = Vector3(0.55, 0.04, 0.35)
	left_inner.mesh = l_inner_mesh
	left_inner.material_override = body_mat
	left_inner.position = Vector3(-0.275, 0.0, 0.0)
	left_pivot.add_child(left_inner)
	
	var left_elbow = Node3D.new()
	left_elbow.name = "LeftElbowPivot"
	left_elbow.position = Vector3(-0.55, 0.0, 0.0)
	left_pivot.add_child(left_elbow)
	
	var left_outer = MeshInstance3D.new()
	var l_outer_mesh = BoxMesh.new()
	l_outer_mesh.size = Vector3(0.55, 0.038, 0.30)
	left_outer.mesh = l_outer_mesh
	left_outer.material_override = body_mat
	left_outer.position = Vector3(-0.275, 0.0, -0.02)
	left_elbow.add_child(left_outer)
	
	var left_tip = MeshInstance3D.new()
	var l_tip_mesh = BoxMesh.new()
	l_tip_mesh.size = Vector3(0.32, 0.042, 0.22)
	left_tip.mesh = l_tip_mesh
	left_tip.material_override = wingtip_mat
	left_tip.position = Vector3(-0.68, 0.0, -0.04)
	left_elbow.add_child(left_tip)

	# Right Wing (Shoulder -> Elbow -> Wingtip hierarchy)
	var right_pivot = Node3D.new()
	right_pivot.name = "RightWingPivot"
	right_pivot.position = Vector3(0.14, 0.05, 0.0)
	bird_root.add_child(right_pivot)
	
	var right_inner = MeshInstance3D.new()
	var r_inner_mesh = BoxMesh.new()
	r_inner_mesh.size = Vector3(0.55, 0.04, 0.35)
	right_inner.mesh = r_inner_mesh
	right_inner.material_override = body_mat
	right_inner.position = Vector3(0.275, 0.0, 0.0)
	right_pivot.add_child(right_inner)
	
	var right_elbow = Node3D.new()
	right_elbow.name = "RightElbowPivot"
	right_elbow.position = Vector3(0.55, 0.0, 0.0)
	right_pivot.add_child(right_elbow)
	
	var right_outer = MeshInstance3D.new()
	var r_outer_mesh = BoxMesh.new()
	r_outer_mesh.size = Vector3(0.55, 0.038, 0.30)
	right_outer.mesh = r_outer_mesh
	right_outer.material_override = body_mat
	right_outer.position = Vector3(0.275, 0.0, -0.02)
	right_elbow.add_child(right_outer)
	
	var right_tip = MeshInstance3D.new()
	var r_tip_mesh = BoxMesh.new()
	r_tip_mesh.size = Vector3(0.32, 0.042, 0.22)
	right_tip.mesh = r_tip_mesh
	right_tip.material_override = wingtip_mat
	right_tip.position = Vector3(0.68, 0.0, -0.04)
	right_elbow.add_child(right_tip)

	bird_root.scale = Vector3(1.5, 1.5, 1.5)
	
	# Squawk SFX
	var squawk_sfx = AudioStreamPlayer.new()
	squawk_sfx.stream = load("res://assets/audio/sfx/seagull.wav")
	squawk_sfx.volume_db = -4.0 # Slightly adjusted since it's a dedicated sound
	squawk_sfx.name = "SquawkSfx"
	bird_root.add_child(squawk_sfx)
	
	# Feathers Particles
	var feathers = GPUParticles3D.new()
	feathers.name = "Feathers"
	feathers.emitting = false
	feathers.one_shot = true
	feathers.explosiveness = 0.95
	feathers.amount = 8
	feathers.lifetime = 1.5
	
	var f_mat = StandardMaterial3D.new()
	f_mat.albedo_color = Color(0.9, 0.9, 0.95)
	f_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	
	var f_mesh = QuadMesh.new()
	f_mesh.size = Vector2(0.06, 0.12)
	f_mesh.material = f_mat
	feathers.draw_pass_1 = f_mesh
	
	var f_proc = ParticleProcessMaterial.new()
	f_proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	f_proc.emission_sphere_radius = 0.4
	f_proc.direction = Vector3(0, 1, 0)
	f_proc.spread = 80.0
	f_proc.initial_velocity_min = 1.0
	f_proc.initial_velocity_max = 3.0
	f_proc.gravity = Vector3(0, -0.8, 0)
	f_proc.angular_velocity_min = -180.0
	f_proc.angular_velocity_max = 180.0
	f_proc.damping_min = 1.0
	f_proc.damping_max = 2.0
	feathers.process_material = f_proc
	bird_root.add_child(feathers)

	return bird_root

func scare_bird(b: Dictionary) -> void:
	if b.get("state") == "sitting" or b.get("state") == "landing":
		b["state"] = "fleeing"
		var node = b["node"] as Node3D
		b["start_pos"] = node.position
		
		# Squawk with a 0.4 second global cooldown to prevent audio spam
		var current_time = Time.get_ticks_msec() * 0.001
		if current_time - last_squawk_time > 0.4:
			var sfx = node.get_node_or_null("SquawkSfx")
			if sfx:
				sfx.pitch_scale = randf_range(0.9, 1.2) # Small natural pitch variation
				sfx.play()
				last_squawk_time = current_time
			
		# Feathers!
		var feathers = node.get_node_or_null("Feathers")
		if feathers:
			feathers.restart()
			
		# Fly away faster!
		b["speed"] = (b.get("base_speed", b["speed"]) as float) * 1.5
		b["flap_speed"] = (b.get("base_flap_speed", b["flap_speed"]) as float) * 1.5
		
		var future_angle = (b["angle"] as float) + (b["speed"] as float) * 2.0
		var rad = b["radius"] as float
		var target = Vector3(center_pos.x + cos(future_angle)*rad, b["height"], center_pos.z + sin(future_angle)*rad)
		b["target_pos"] = target
		var mid = (b["start_pos"] + target) / 2.0
		b["ctrl_pos"] = Vector3(mid.x, max(target.y + 8.0, 30.0), mid.z) # Fly up higher and faster
		b["anim_t"] = 0.0

func check_scare_at(pos: Vector3, radius: float) -> void:
	for b in birds:
		var state = b.get("state")
		if state == "sitting" or state == "landing":
			var node = b["node"] as Node3D
			if node and node.global_position.distance_to(pos) <= radius:
				scare_bird(b)

func _process(delta: float) -> void:
	var time = Time.get_ticks_msec() * 0.001
	
	# Weather overrides
	if current_weather == "eclipse":
		for b in birds:
			var state = b.get("state")
			if state == "sitting" or state == "landing":
				scare_bird(b)

	for b in birds:
		var node = b["node"] as Node3D
		if not is_instance_valid(node): continue
		
		var state = b.get("state", "orbiting") as String
		
		var l_wing = b.get("left_wing") as Node3D
		var r_wing = b.get("right_wing") as Node3D
		var l_elbow = b.get("left_elbow") as Node3D
		var r_elbow = b.get("right_elbow") as Node3D
		var head = b.get("head") as Node3D
		var tail = b.get("tail") as Node3D
		
		var t_offset = b["time_offset"] as float
		
		if state == "orbiting":
			# Update orbital angle
			b["angle"] += (b["speed"] as float) * delta
			var angle = b["angle"] as float
			var rad = b["radius"] as float
			
			var cycle = fmod(time + t_offset, 6.5)
			var shoulder_z: float = 0.0
			var elbow_z: float = 0.0
			var elbow_sweep: float = 0.0
			var elbow_tuck: float = 0.0
			var body_bob: float = 0.0
			var pitch_bob: float = 0.0
			var turbulence_roll: float = 0.0
			
			if cycle < 4.0:
				# Flap phase: multi-joint wingbeat with aerodynamic upstroke fold
				var flap_phase = (time + t_offset) * (b["flap_speed"] as float)
				shoulder_z = sin(flap_phase) * 0.36
				elbow_z = sin(flap_phase - 0.42) * 0.28
				
				# On upstroke, outer wing sweeps backward and tucks slightly
				var upstroke = max(0.0, sin(flap_phase))
				elbow_sweep = upstroke * 0.32
				elbow_tuck = upstroke * -0.12
				
				# Vertical body bobbing & pitch response to wing downstroke
				body_bob = -sin(flap_phase) * 0.12
				pitch_bob = -cos(flap_phase) * 0.04
			else:
				# Glide phase: aerodynamic dihedral V-wings with gentle thermal drift
				var glide_t = clamp((cycle - 4.0) / 0.5, 0.0, 1.0)
				shoulder_z = lerp(0.0, 0.08, glide_t) # Subtle dihedral V-angle
				elbow_z = lerp(0.0, -0.04, glide_t)
				body_bob = sin(time * 2.0 + t_offset) * 0.04
				pitch_bob = sin(time * 1.5 + t_offset) * 0.02
				turbulence_roll = sin(time * 2.5 + t_offset) * 0.04
			
			var pos_x = center_pos.x + cos(angle) * rad
			var pos_z = center_pos.z + sin(angle) * rad
			node.position = Vector3(pos_x, (b["height"] as float) + body_bob, pos_z)
			
			var tangent = Vector3(-sin(angle), 0, cos(angle)) * (1.0 if (b["speed"] as float) > 0 else -1.0)
			var look_basis = Transform3D.IDENTITY.looking_at(tangent, Vector3.UP).basis
			
			# Dynamic bank into turn + turbulence
			var target_bank = -0.20 * (1.0 if (b["speed"] as float) > 0 else -1.0) + turbulence_roll
			b["bank_angle"] = lerp(b.get("bank_angle", 0.0) as float, target_bank, 6.0 * delta)
			var bank_q = Quaternion(Vector3(0, 0, 1), b["bank_angle"] as float)
			var pitch_q = Quaternion(Vector3(1, 0, 0), pitch_bob)
			node.transform.basis = (look_basis * Basis(bank_q * pitch_q)).scaled(Vector3(1.5, 1.5, 1.5))
			
			# Head levels with horizon / forward flight path
			if head:
				head.rotation.x = lerp(head.rotation.x, -pitch_bob * 0.8, 8.0 * delta)
				head.rotation.y = lerp(head.rotation.y, 0.0, 8.0 * delta)
				head.rotation.z = lerp(head.rotation.z, -(b["bank_angle"] as float) * 0.5, 8.0 * delta)
			if tail:
				tail.rotation.x = lerp(tail.rotation.x, pitch_bob * 1.2, 8.0 * delta)
				tail.rotation.y = lerp(tail.rotation.y, 0.0, 8.0 * delta)
			
			# Apply wing rotations
			if l_wing:
				l_wing.rotation.x = lerp(l_wing.rotation.x, 0.0, 12.0 * delta)
				l_wing.rotation.y = lerp(l_wing.rotation.y, 0.0, 12.0 * delta)
				l_wing.rotation.z = shoulder_z
			if r_wing:
				r_wing.rotation.x = lerp(r_wing.rotation.x, 0.0, 12.0 * delta)
				r_wing.rotation.y = lerp(r_wing.rotation.y, 0.0, 12.0 * delta)
				r_wing.rotation.z = -shoulder_z
			if l_elbow:
				l_elbow.rotation.x = 0.0
				l_elbow.rotation.y = -elbow_sweep
				l_elbow.rotation.z = elbow_z + elbow_tuck
			if r_elbow:
				r_elbow.rotation.x = 0.0
				r_elbow.rotation.y = elbow_sweep
				r_elbow.rotation.z = -elbow_z - elbow_tuck
				
			# Randomly decide to land
			var landing_chance = 0.001
			if current_weather == "rain":
				landing_chance = 0.05 # Seek shelter quickly
			elif current_weather == "eclipse":
				landing_chance = 0.0 # Don't land during eclipse
				
			if randf() < landing_chance: 
				b["state"] = "landing"
				b["start_pos"] = node.position
				# Narrowed X range (-6 to 6) to keep them strictly on the central beach, avoiding trees
				var target = Vector3(randf_range(-6.0, 6.0), -1.95, randf_range(-8.0, 1.0))
				b["target_pos"] = target
				var mid = (b["start_pos"] + target) / 2.0
				b["ctrl_pos"] = Vector3(mid.x, max(b["start_pos"].y + 5.0, 30.0), mid.z)
				b["anim_t"] = 0.0
				
		elif state == "landing":
			var t = b.get("anim_t", 0.0) as float
			t += delta / 2.5 # 2.5 seconds to land
			b["anim_t"] = t
			
			if t >= 1.0:
				b["state"] = "sitting"
				node.position.y = -1.95 # lock perfectly to ground height
				b["next_look_time"] = time + randf_range(1.0, 2.5)
			else:
				var ease_t = t * t * (3.0 - 2.0 * t)
				var p0 = b["start_pos"] as Vector3
				var p1 = b["ctrl_pos"] as Vector3
				var p2 = b["target_pos"] as Vector3
				var new_pos = p0.lerp(p1, ease_t).lerp(p1.lerp(p2, ease_t), ease_t)
				var vel = new_pos - node.position
				node.position = new_pos
				if vel.length_squared() > 0.001:
					var cur_q = node.transform.basis.orthonormalized().get_rotation_quaternion()
					var tgt_q = Transform3D.IDENTITY.looking_at(vel, Vector3.UP).basis.get_rotation_quaternion()
					node.transform.basis = Basis(cur_q.slerp(tgt_q, 6.0 * delta)).scaled(Vector3(1.5, 1.5, 1.5))
				
				# Active flapping during descent with flare-out before touchdown
				var flap_phase = (time + t_offset) * (b["flap_speed"] as float) * 1.15
				var shoulder_z = sin(flap_phase) * 0.36
				var elbow_z = sin(flap_phase - 0.4) * 0.28
				var elbow_sweep = max(0.0, sin(flap_phase)) * 0.25
				
				# Final landing flare (wings extend wide and pitch slightly back)
				if t > 0.8:
					var flare = (t - 0.8) / 0.2
					shoulder_z = lerp(shoulder_z, 0.15, flare)
					elbow_z = lerp(elbow_z, 0.20, flare)
					elbow_sweep = lerp(elbow_sweep, 0.0, flare)
				
				if l_wing:
					l_wing.rotation.x = lerp(l_wing.rotation.x, 0.0, 10.0 * delta)
					l_wing.rotation.y = lerp(l_wing.rotation.y, 0.0, 10.0 * delta)
					l_wing.rotation.z = shoulder_z
				if r_wing:
					r_wing.rotation.x = lerp(r_wing.rotation.x, 0.0, 10.0 * delta)
					r_wing.rotation.y = lerp(r_wing.rotation.y, 0.0, 10.0 * delta)
					r_wing.rotation.z = -shoulder_z
				if l_elbow:
					l_elbow.rotation.x = 0.0
					l_elbow.rotation.y = -elbow_sweep
					l_elbow.rotation.z = elbow_z
				if r_elbow:
					r_elbow.rotation.x = 0.0
					r_elbow.rotation.y = elbow_sweep
					r_elbow.rotation.z = -elbow_z
				if head:
					head.rotation = Vector3.ZERO
				if tail:
					tail.rotation = Vector3.ZERO
				
		elif state == "sitting":
			# Sit idle on the beach, lock rotation purely horizontal
			var target_y = -PI/2.0 if node.position.x > 0 else PI/2.0
			var cur_rot_y = node.rotation.y
			var new_y = lerp_angle(cur_rot_y, target_y, 2.0 * delta)
			node.transform.basis = Basis(Quaternion(Vector3.UP, new_y)).scaled(Vector3(1.5, 1.5, 1.5))
			
			# Subtle breathing idle bob
			node.position.y = -1.95 + sin(time * 2.5 + t_offset) * 0.012
			
			# Neatly tuck wings against body
			if l_wing:
				l_wing.rotation.x = lerp(l_wing.rotation.x, -0.05, 8.0 * delta)
				l_wing.rotation.y = lerp(l_wing.rotation.y, -0.75, 8.0 * delta)
				l_wing.rotation.z = lerp(l_wing.rotation.z, 0.35, 8.0 * delta)
			if r_wing:
				r_wing.rotation.x = lerp(r_wing.rotation.x, -0.05, 8.0 * delta)
				r_wing.rotation.y = lerp(r_wing.rotation.y, 0.75, 8.0 * delta)
				r_wing.rotation.z = lerp(r_wing.rotation.z, -0.35, 8.0 * delta)
			if l_elbow:
				l_elbow.rotation.x = lerp(l_elbow.rotation.x, 0.0, 8.0 * delta)
				l_elbow.rotation.y = lerp(l_elbow.rotation.y, -0.45, 8.0 * delta)
				l_elbow.rotation.z = lerp(l_elbow.rotation.z, -0.15, 8.0 * delta)
			if r_elbow:
				r_elbow.rotation.x = lerp(r_elbow.rotation.x, 0.0, 8.0 * delta)
				r_elbow.rotation.y = lerp(r_elbow.rotation.y, 0.45, 8.0 * delta)
				r_elbow.rotation.z = lerp(r_elbow.rotation.z, 0.15, 8.0 * delta)
				
			# Idle behaviors: Looking around left/right, curious tilt, pecking the sand
			if time >= (b.get("next_look_time", 0.0) as float):
				b["next_look_time"] = time + randf_range(1.8, 3.8)
				var pick = randf()
				if pick < 0.40:
					# Turn head left or right with slight tilt
					b["head_target_yaw"] = randf_range(-0.7, 0.7)
					b["head_target_pitch"] = randf_range(-0.15, 0.15)
				elif pick < 0.75:
					# Peck at the sand
					b["peck_timer"] = 0.45
					b["head_target_yaw"] = randf_range(-0.2, 0.2)
				else:
					# Look straight
					b["head_target_yaw"] = 0.0
					b["head_target_pitch"] = 0.0
			
			var peck_t = b.get("peck_timer", 0.0) as float
			if peck_t > 0.0:
				b["peck_timer"] = peck_t - delta
				var peck_progress = 1.0 - (peck_t / 0.45)
				var dip = sin(peck_progress * PI)
				if head:
					head.rotation.x = lerp(head.rotation.x, -dip * 0.75, 22.0 * delta)
					head.rotation.y = lerp(head.rotation.y, b.get("head_target_yaw", 0.0) as float, 12.0 * delta)
					head.rotation.z = 0.0
				if tail:
					tail.rotation.x = lerp(tail.rotation.x, dip * 0.3, 20.0 * delta)
			else:
				if head:
					head.rotation.x = lerp(head.rotation.x, b.get("head_target_pitch", 0.0) as float, 6.0 * delta)
					head.rotation.y = lerp(head.rotation.y, b.get("head_target_yaw", 0.0) as float, 6.0 * delta)
					head.rotation.z = lerp(head.rotation.z, (b.get("head_target_yaw", 0.0) as float) * 0.2, 6.0 * delta)
				if tail:
					tail.rotation.x = lerp(tail.rotation.x, sin(time * 3.0 + t_offset) * 0.06, 6.0 * delta)
					tail.rotation.y = 0.0
			
		elif state == "fleeing":
			var t = b.get("anim_t", 0.0) as float
			t += delta / 1.2 # 1.2 seconds to flee back to orbit (much faster than landing)
			b["anim_t"] = t
			
			if t >= 1.0:
				b["state"] = "orbiting"
				# Restore original cruise speeds
				b["speed"] = b.get("base_speed", b["speed"])
				b["flap_speed"] = b.get("base_flap_speed", b["flap_speed"])
			else:
				b["angle"] += (b["speed"] as float) * delta
				var ease_t = t * t * (3.0 - 2.0 * t)
				var p0 = b["start_pos"] as Vector3
				var p1 = b["ctrl_pos"] as Vector3
				var p2 = b["target_pos"] as Vector3
				var new_pos = p0.lerp(p1, ease_t).lerp(p1.lerp(p2, ease_t), ease_t)
				var vel = new_pos - node.position
				node.position = new_pos
				if vel.length_squared() > 0.001:
					var cur_q = node.transform.basis.orthonormalized().get_rotation_quaternion()
					var tgt_q = Transform3D.IDENTITY.looking_at(vel, Vector3.UP).basis.get_rotation_quaternion()
					var pitch_q = Quaternion(Vector3(1, 0, 0), 0.2) # pitch up into climb
					tgt_q = tgt_q * pitch_q
					node.transform.basis = Basis(cur_q.slerp(tgt_q, 6.0 * delta)).scaled(Vector3(1.5, 1.5, 1.5))
				
				# Panicked rapid wingbeats with exaggerated sweep
				var flap_phase = (time + t_offset) * (b["flap_speed"] as float) * 1.6
				var shoulder_z = sin(flap_phase) * 0.52
				var elbow_z = sin(flap_phase - 0.45) * 0.40
				var elbow_sweep = max(0.0, sin(flap_phase)) * 0.38
				
				if l_wing:
					l_wing.rotation.x = lerp(l_wing.rotation.x, 0.0, 15.0 * delta)
					l_wing.rotation.y = lerp(l_wing.rotation.y, 0.0, 15.0 * delta)
					l_wing.rotation.z = shoulder_z
				if r_wing:
					r_wing.rotation.x = lerp(r_wing.rotation.x, 0.0, 15.0 * delta)
					r_wing.rotation.y = lerp(r_wing.rotation.y, 0.0, 15.0 * delta)
					r_wing.rotation.z = -shoulder_z
				if l_elbow:
					l_elbow.rotation.x = 0.0
					l_elbow.rotation.y = -elbow_sweep
					l_elbow.rotation.z = elbow_z
				if r_elbow:
					r_elbow.rotation.x = 0.0
					r_elbow.rotation.y = elbow_sweep
					r_elbow.rotation.z = -elbow_z
				
				if head:
					head.rotation.x = lerp(head.rotation.x, 0.2, 10.0 * delta) # look up into escape climb
					head.rotation.y = 0.0
					head.rotation.z = 0.0
				if tail:
					tail.rotation.x = lerp(tail.rotation.x, -0.25, 10.0 * delta)
