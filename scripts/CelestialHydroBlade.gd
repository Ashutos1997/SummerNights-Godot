class_name CelestialHydroBlade
extends Node3D

## CelestialHydroBlade
## Manages VFX for Kitsune Buster IX Blade Mode:
## - Energy Slash Trail — glowing celestial solar arc rendered along the blade
## - Flying Celestial Solar-Crescent Wave — awakening projectile

var is_blade_awakened: bool = false
var aura_intensity: float = 0.0
var anim_time: float = 0.0

var target_gun_node: Node3D = null

func _ready() -> void:
	visible = true

func set_blade_active(active: bool, gun_node: Node3D = null) -> void:
	is_blade_awakened = active
	target_gun_node = gun_node

func _process(delta: float) -> void:
	anim_time += delta
	
	if is_blade_awakened and target_gun_node and is_instance_valid(target_gun_node):
		aura_intensity = min(1.0, aura_intensity + delta * 6.0)
	else:
		aura_intensity = max(0.0, aura_intensity - delta * 6.0)

# ══════════════════════════════════════════════════════════════════
# Blade geometry helpers — compute blade spine in world space
# ══════════════════════════════════════════════════════════════════
func _get_blade_axes() -> Dictionary:
	if not target_gun_node or not is_instance_valid(target_gun_node):
		return {}
	var gun_basis: Basis = target_gun_node.global_basis
	var gun_origin: Vector3 = target_gun_node.global_position
	var local_up: Vector3 = gun_basis.y.normalized()
	var local_forward: Vector3 = -gun_basis.z.normalized()
	var local_right: Vector3 = gun_basis.x.normalized()
	
	# Blade spine: from collar (base) to kissaki (tip)
	var blade_base: Vector3 = gun_origin + (local_up * 0.22) + (local_forward * 0.40)
	var blade_tip: Vector3 = gun_origin + (local_up * 0.30) + (local_forward * 1.55)
	var blade_vec: Vector3 = blade_tip - blade_base
	var blade_len: float = blade_vec.length()
	if blade_len < 0.1:
		return {}
	var blade_dir: Vector3 = blade_vec / blade_len
	
	# Build orthonormal frame around blade axis
	var perp_up: Vector3 = local_up
	# If blade_dir is near-parallel to local_up, fallback
	if abs(blade_dir.dot(perp_up)) > 0.95:
		perp_up = local_right
	var right_axis: Vector3 = blade_dir.cross(perp_up).normalized()
	var up_axis: Vector3 = right_axis.cross(blade_dir).normalized()
	
	return {
		"base": blade_base,
		"tip": blade_tip,
		"dir": blade_dir,
		"len": blade_len,
		"right": right_axis,
		"up": up_axis,
		"local_up": local_up,
		"local_right": local_right,
		"local_forward": local_forward,
	}

# ══════════════════════════════════════════════════════════════════
# 1. CELESTIAL FOXFIRE SLASH WAVE — aimed flame crescent with embers
# ══════════════════════════════════════════════════════════════════
func trigger_slash_arc(_camera: Camera3D, _slash_dir: float, _is_awakened: bool, _aim_target: Vector3 = Vector3.ZERO) -> void:
	pass

func spawn_flying_hydro_crescent(_origin: Vector3, _dir: Vector3, _main_scene: Node) -> void:
	pass

func spawn_foxfire_slash(origin: Vector3, dir: Vector3, slash_dir: float, is_awakened: bool, main_scene: Node) -> void:
	var wave = CelestialFoxfireWave.new(origin, dir, slash_dir, is_awakened, main_scene)
	main_scene.add_child(wave)

# ==============================================================================
# Helper Class: CelestialFoxfireWave (Aimed Slash Wave with Spark Embers)
# ==============================================================================
class CelestialFoxfireWave extends Node3D:
	var flight_dir: Vector3
	var flight_speed: float = 85.0
	var lifetime: float = 0.45
	var elapsed: float = 0.0
	var is_awakened: bool = false
	var slash_tilt: float = 1.0
	
	var main_ref: Node
	var material_ref: StandardMaterial3D
	
	var imm_mesh: ImmediateMesh
	var mesh_inst: MeshInstance3D
	var ember_particles: GPUParticles3D
	
	func _init(p_origin: Vector3, p_dir: Vector3, p_slash_dir: float, p_awakened: bool, p_main: Node) -> void:
		flight_dir = p_dir.normalized()
		is_awakened = p_awakened
		slash_tilt = p_slash_dir
		main_ref = p_main
		global_position = p_origin + flight_dir * 1.0
		
	func _ready() -> void:
		var up_v: Vector3 = Vector3.UP
		if abs(flight_dir.dot(up_v)) > 0.95:
			up_v = Vector3.RIGHT
		look_at(global_position + flight_dir, up_v)
		rotate_object_local(Vector3.FORWARD, deg_to_rad(32.0 * slash_tilt))
		
		imm_mesh = ImmediateMesh.new()
		mesh_inst = MeshInstance3D.new()
		mesh_inst.mesh = imm_mesh
		
		material_ref = StandardMaterial3D.new()
		material_ref.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material_ref.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material_ref.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		material_ref.vertex_color_use_as_albedo = true
		material_ref.cull_mode = BaseMaterial3D.CULL_DISABLED
		mesh_inst.material_override = material_ref
		add_child(mesh_inst)
		
		_build_foxfire_crescent_geometry()
		_setup_ember_trail()
		
	func _build_foxfire_crescent_geometry() -> void:
		imm_mesh.clear_surfaces()
		imm_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material_ref)
		
		var segments: int = 18
		var half_span: float = 1.5 if not is_awakened else 2.1
		var arc_depth: float = 0.55 if not is_awakened else 0.75
		var thickness: float = 0.28 if not is_awakened else 0.38
		
		var prev_lead: Vector3 = Vector3.ZERO
		var prev_trail: Vector3 = Vector3.ZERO
		var prev_c: Color = Color.TRANSPARENT
		
		for i in range(segments + 1):
			var t: float = (float(i) / float(segments)) * 2.0 - 1.0
			var profile: float = 1.0 - (t * t)
			
			var x: float = t * half_span
			var z_lead: float = (1.0 - profile) * arc_depth
			var z_trail: float = z_lead + (profile * thickness + 0.06)
			var y: float = sin(t * PI) * 0.08
			
			var v_lead = Vector3(x, y, -z_lead)
			var v_trail = Vector3(x * 0.94, y * 0.4, -z_trail)
			
			var c_apex = Color(1.0, 1.0, 1.0, 0.98)
			var c_core = Color(1.0, 0.82, 0.22, 0.90)
			var c_wing = Color(1.0, 0.48, 0.12, 0.65)
			
			if is_awakened:
				c_core = Color(1.0, 0.92, 0.50, 0.96)
				c_wing = Color(1.0, 0.70, 0.25, 0.85)
			
			var col: Color = c_wing.lerp(c_core, profile)
			if profile > 0.65:
				col = col.lerp(c_apex, (profile - 0.65) / 0.35 * 0.85)
			col.a = profile * 0.92 + 0.08
			
			if i > 0:
				_add_mesh_quad(prev_lead, v_lead, prev_trail, v_trail, prev_c, col)
				_add_mesh_quad(v_lead, prev_lead, v_trail, prev_trail, col, prev_c)
				
			prev_lead = v_lead
			prev_trail = v_trail
			prev_c = col
			
		imm_mesh.surface_end()
		
	func _setup_ember_trail() -> void:
		ember_particles = GPUParticles3D.new()
		var p_mat = ParticleProcessMaterial.new()
		p_mat.direction = -Vector3.FORWARD
		p_mat.spread = 25.0
		p_mat.initial_velocity_min = 2.0
		p_mat.initial_velocity_max = 5.0
		p_mat.gravity = Vector3(0, 1.5, 0)
		p_mat.scale_min = 0.25
		p_mat.scale_max = 0.55
		
		var q_mesh = QuadMesh.new()
		q_mesh.size = Vector2(0.10, 0.10)
		var q_mat = StandardMaterial3D.new()
		q_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		q_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		q_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		q_mat.albedo_color = Color(1.0, 0.85, 0.30, 0.85)
		q_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		q_mesh.material = q_mat
		
		ember_particles.process_material = p_mat
		ember_particles.draw_pass_1 = q_mesh
		ember_particles.amount = 16
		ember_particles.lifetime = 0.30
		ember_particles.emitting = true
		add_child(ember_particles)
		
	func _add_mesh_quad(v0: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, c0: Color, c1: Color) -> void:
		imm_mesh.surface_set_color(c0)
		imm_mesh.surface_add_vertex(v0)
		imm_mesh.surface_set_color(c1)
		imm_mesh.surface_add_vertex(v1)
		imm_mesh.surface_set_color(c0)
		imm_mesh.surface_add_vertex(v2)
		
		imm_mesh.surface_set_color(c1)
		imm_mesh.surface_add_vertex(v1)
		imm_mesh.surface_set_color(c1)
		imm_mesh.surface_add_vertex(v3)
		imm_mesh.surface_set_color(c0)
		imm_mesh.surface_add_vertex(v2)
		
	func _process(delta: float) -> void:
		elapsed += delta
		global_position += flight_dir * (flight_speed * delta)
		
		var remain: float = lifetime - elapsed
		if remain < 0.15:
			mesh_inst.transparency = 1.0 - (remain / 0.15)
			
		if elapsed >= lifetime:
			queue_free()
			return
			
		# Impact check with Sun
		if main_ref and is_instance_valid(main_ref):
			var sun = main_ref.get("sun") as Node3D
			if is_instance_valid(sun):
				if global_position.distance_to(sun.global_position) < 5.0:
					_trigger_impact()
					queue_free()
					
	func _trigger_impact() -> void:
		if not main_ref or not is_instance_valid(main_ref):
			return
		var burst = GPUParticles3D.new()
		var b_mat = ParticleProcessMaterial.new()
		b_mat.direction = Vector3.UP
		b_mat.spread = 180.0
		b_mat.initial_velocity_min = 4.0
		b_mat.initial_velocity_max = 8.0
		b_mat.gravity = Vector3(0, -2.0, 0)
		b_mat.scale_min = 0.2
		b_mat.scale_max = 0.5
		
		var q_mesh = QuadMesh.new()
		q_mesh.size = Vector2(0.08, 0.08)
		var q_mat = StandardMaterial3D.new()
		q_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		q_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		q_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		q_mat.albedo_color = Color(1.0, 0.88, 0.40, 0.9)
		q_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		q_mesh.material = q_mat
		
		burst.process_material = b_mat
		burst.draw_pass_1 = q_mesh
		burst.amount = 12
		burst.lifetime = 0.25
		burst.one_shot = true
		burst.explosiveness = 0.9
		burst.global_position = global_position
		main_ref.add_child(burst)
		main_ref.get_tree().create_timer(0.3).timeout.connect(burst.queue_free)
