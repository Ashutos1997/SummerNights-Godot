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
# 1. CELESTIAL ENERGY SLASH TRAIL — glowing arc rendered along the blade
# ══════════════════════════════════════════════════════════════════
func trigger_slash_arc(camera: Camera3D, slash_dir: float, is_awakened: bool, _aim_target: Vector3 = Vector3.ZERO) -> void:
	if not camera:
		return
	
	var axes = _get_blade_axes()
	if axes.is_empty():
		return
	
	# Build the trail geometry anchored to the blade tip — no world-space projection
	var blade_tip: Vector3 = axes["tip"]
	var blade_base: Vector3 = axes["base"]
	var blade_dir: Vector3 = axes["dir"]
	var right_ax: Vector3 = axes["right"]
	var up_ax: Vector3 = axes["up"]
	var local_up: Vector3 = axes["local_up"]
	
	var trail_node = Node3D.new()
	trail_node.name = "EnergySlashTrail"
	add_child(trail_node)
	
	var slash_mat = StandardMaterial3D.new()
	slash_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	slash_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	slash_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	slash_mat.vertex_color_use_as_albedo = true
	slash_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	var imm_mesh = ImmediateMesh.new()
	var mesh_inst = MeshInstance3D.new()
	mesh_inst.mesh = imm_mesh
	mesh_inst.material_override = slash_mat
	trail_node.add_child(mesh_inst)
	
	# Arc parameters — trail fans out from the blade tip
	var arc_segs: int = 20
	var sweep_angle: float = deg_to_rad(140.0)  # Total arc sweep
	var trail_radius_min: float = 0.15 if not is_awakened else 0.20
	var trail_radius_max: float = 1.2 if not is_awakened else 1.8
	var trail_width: float = 0.08 if not is_awakened else 0.14
	
	# Sweep plane: the arc fans around the blade forward axis
	# Slash direction determines which way the arc curves
	var sweep_axis: Vector3 = blade_dir  # Rotation axis for the arc
	var start_vec: Vector3 = (right_ax * slash_dir + up_ax * 0.3).normalized()
	
	# Color palette: Solar celestial energy (warm golden amber + brilliant white)
	var col_core: Color = Color(1.00, 0.98, 0.90, 0.96) if not is_awakened else Color(1.0, 1.0, 1.0, 0.98)
	var col_edge: Color = Color(1.00, 0.72, 0.18, 0.60) if not is_awakened else Color(1.00, 0.85, 0.35, 0.85)
	var col_tip: Color = Color(1.00, 0.82, 0.35, 0.25)
	
	imm_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, slash_mat)
	
	var cam_pos: Vector3 = camera.global_position
	
	var prev_inner: Vector3 = Vector3.ZERO
	var prev_outer: Vector3 = Vector3.ZERO
	var prev_col: Color = Color.TRANSPARENT
	
	for i in range(arc_segs + 1):
		var u: float = float(i) / float(arc_segs)
		var angle: float = (u - 0.5) * sweep_angle * slash_dir
		
		# Rotate the start vector around the blade axis
		var rotated: Vector3 = start_vec.rotated(sweep_axis, angle)
		
		# Radius grows from blade tip outward, peaks in the middle
		var profile: float = sin(u * PI)
		var radius: float = trail_radius_min + (trail_radius_max - trail_radius_min) * profile
		
		# Inner and outer edges of the ribbon
		var center: Vector3 = blade_tip + rotated * radius
		var width: float = trail_width * (0.3 + profile * 0.7)
		
		# Camera-facing normal for ribbon width
		var tangent: Vector3
		if i < arc_segs:
			var next_angle: float = (float(i + 1) / float(arc_segs) - 0.5) * sweep_angle * slash_dir
			var next_rot: Vector3 = start_vec.rotated(sweep_axis, next_angle)
			var next_r: float = trail_radius_min + (trail_radius_max - trail_radius_min) * sin(float(i + 1) / float(arc_segs) * PI)
			tangent = ((blade_tip + next_rot * next_r) - center).normalized()
		else:
			var prev_angle: float = (float(i - 1) / float(arc_segs) - 0.5) * sweep_angle * slash_dir
			var prev_rot: Vector3 = start_vec.rotated(sweep_axis, prev_angle)
			var prev_r: float = trail_radius_min + (trail_radius_max - trail_radius_min) * sin(float(i - 1) / float(arc_segs) * PI)
			tangent = (center - (blade_tip + prev_rot * prev_r)).normalized()
		
		var to_cam: Vector3 = (center - cam_pos).normalized()
		var norm: Vector3 = tangent.cross(to_cam).normalized()
		if norm.length_squared() < 1e-4:
			norm = up_ax
		
		var v_in: Vector3 = center - norm * (width * 0.5)
		var v_out: Vector3 = center + norm * (width * 0.5)
		
		# Color: bright core in center, fading to edges
		var col: Color = col_edge.lerp(col_core, profile)
		if is_awakened and profile > 0.5:
			col = col.lerp(Color(1.0, 0.95, 0.65, 0.95), (profile - 0.5) * 0.8)
		# Fade tips
		var tip_fade: float = 1.0
		if u < 0.1:
			tip_fade = u / 0.1
		elif u > 0.9:
			tip_fade = (1.0 - u) / 0.1
		col.a *= tip_fade
		
		if i > 0:
			_add_quad_to(imm_mesh, prev_inner, v_in, prev_outer, v_out, prev_col, col)
		
		prev_inner = v_in
		prev_outer = v_out
		prev_col = col
	
	# Second layer: thinner bright core ribbon for intensity
	var prev_l2: Vector3 = Vector3.ZERO
	var prev_r2: Vector3 = Vector3.ZERO
	var prev_c2: Color = Color.TRANSPARENT
	var core_width: float = trail_width * 0.35
	
	for i in range(arc_segs + 1):
		var u: float = float(i) / float(arc_segs)
		var angle: float = (u - 0.5) * sweep_angle * slash_dir
		var rotated: Vector3 = start_vec.rotated(sweep_axis, angle)
		var profile: float = sin(u * PI)
		var radius: float = trail_radius_min + (trail_radius_max - trail_radius_min) * profile
		var center: Vector3 = blade_tip + rotated * radius
		var w: float = core_width * (0.4 + profile * 0.6)
		
		# Simple up-axis offset for the core ribbon
		var v_l: Vector3 = center + up_ax * (w * 0.5)
		var v_r: Vector3 = center - up_ax * (w * 0.5)
		
		var col: Color = Color(1.0, 1.0, 1.0, 0.9 * profile)
		if is_awakened:
			col = col.lerp(Color(1.0, 0.95, 0.70, 0.95), profile * 0.5)
		# Fade tips
		if u < 0.08:
			col.a *= u / 0.08
		elif u > 0.92:
			col.a *= (1.0 - u) / 0.08
		
		if i > 0:
			_add_quad_to(imm_mesh, prev_l2, v_l, prev_r2, v_r, prev_c2, col)
		
		prev_l2 = v_l
		prev_r2 = v_r
		prev_c2 = col
	
	imm_mesh.surface_end()
	
	# Animate: expand slightly then fade out
	var tw = create_tween().set_parallel(true)
	tw.tween_property(trail_node, "scale", Vector3(1.15, 1.15, 1.15), 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(mesh_inst, "transparency", 1.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(trail_node.queue_free)
# ══════════════════════════════════════════════════════════════════
# 5. FLYING CELESTIAL HYDRO-CRESCENT (Awakening Projectile)
# ══════════════════════════════════════════════════════════════════
func spawn_flying_hydro_crescent(origin: Vector3, dir: Vector3, main_scene: Node) -> void:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.vertex_color_use_as_albedo = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var proj = FlyingHydroCrescent.new(origin, dir, main_scene, mat)
	main_scene.add_child(proj)

func _add_quad_to(imm: ImmediateMesh, v0: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, c0: Color, c1: Color) -> void:
	# Triangle 1
	imm.surface_set_color(c0)
	imm.surface_add_vertex(v0)
	imm.surface_set_color(c1)
	imm.surface_add_vertex(v1)
	imm.surface_set_color(c0)
	imm.surface_add_vertex(v2)
	
	# Triangle 2
	imm.surface_set_color(c1)
	imm.surface_add_vertex(v1)
	imm.surface_set_color(c1)
	imm.surface_add_vertex(v3)
	imm.surface_set_color(c0)
	imm.surface_add_vertex(v2)

# ==============================================================================
# Helper Class: FlyingHydroCrescent Projectile
# ==============================================================================
class FlyingHydroCrescent extends Node3D:
	var flight_dir: Vector3
	var flight_speed: float = 78.0
	var lifetime: float = 0.65
	var elapsed: float = 0.0
	
	var main_ref: Node
	var material_ref: StandardMaterial3D
	
	var imm_mesh: ImmediateMesh
	var mesh_inst: MeshInstance3D
	
	var cleaved_flares: Array = []
	
	func _init(p_origin: Vector3, p_dir: Vector3, p_main: Node, p_mat: StandardMaterial3D) -> void:
		global_position = p_origin + p_dir * 1.5
		flight_dir = p_dir.normalized()
		main_ref = p_main
		material_ref = p_mat
		
	func _ready() -> void:
		var up_v: Vector3 = Vector3.UP
		if abs(flight_dir.dot(up_v)) > 0.95:
			up_v = Vector3.RIGHT
		look_at(global_position + flight_dir, up_v)
		
		imm_mesh = ImmediateMesh.new()
		mesh_inst = MeshInstance3D.new()
		mesh_inst.mesh = imm_mesh
		mesh_inst.material_override = material_ref
		add_child(mesh_inst)
		
		_build_crescent_geometry()
		
	func _build_crescent_geometry() -> void:
		imm_mesh.clear_surfaces()
		imm_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material_ref)
		
		var segments: int = 24
		var half_span: float = 3.2
		var arc_depth: float = 1.35
		
		var prev_lead: Vector3 = Vector3.ZERO
		var prev_trail: Vector3 = Vector3.ZERO
		var prev_c: Color = Color.TRANSPARENT
		
		for i in range(segments + 1):
			var t: float = (float(i) / float(segments)) * 2.0 - 1.0
			var profile: float = 1.0 - (t * t)
			
			var x: float = t * half_span
			var z_lead: float = (1.0 - profile) * arc_depth
			var z_trail: float = z_lead + (profile * 0.75 + 0.15)
			var y: float = sin(t * PI) * 0.15
			
			var v_lead = Vector3(x, y, -z_lead)
			var v_trail = Vector3(x * 0.92, y * 0.5, -z_trail)
			
			var c_apex = Color(1.0, 1.0, 1.0, 0.95)
			var c_wing = Color(1.00, 0.75, 0.20, 0.85)
			var c_solar = Color(1.00, 0.90, 0.45, 0.90)
			
			var col: Color = c_wing.lerp(c_apex, profile)
			if profile > 0.75:
				col = col.lerp(c_solar, (profile - 0.75) / 0.25 * 0.6)
			col.a = profile * 0.92 + 0.08
			
			if i > 0:
				_add_mesh_quad(prev_lead, v_lead, prev_trail, v_trail, prev_c, col)
				_add_mesh_quad(v_lead, prev_lead, v_trail, prev_trail, col, prev_c)
				
			prev_lead = v_lead
			prev_trail = v_trail
			prev_c = col
			
		imm_mesh.surface_end()
		
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
		var move_step: Vector3 = flight_dir * (flight_speed * delta)
		global_position += move_step
		
		rotate_object_local(Vector3.FORWARD, delta * 3.5)
		
		var remain: float = lifetime - elapsed
		if remain < 0.2:
			mesh_inst.transparency = 1.0 - (remain / 0.2)
			
		if elapsed >= lifetime:
			queue_free()
			return
			
		if main_ref and is_instance_valid(main_ref):
			var flares: Array = main_ref.get("active_flares") if main_ref.get("active_flares") else []
			for flare in flares:
				if flare in cleaved_flares:
					continue
				var f_node = flare.get("node") as Node3D
				if is_instance_valid(f_node):
					var dist: float = global_position.distance_to(f_node.global_position)
					if dist < 4.2:
						cleaved_flares.append(flare)
						flare["hp"] = 0.0
						GameState.flares_intercepted += 1
						if main_ref.get("shield_deflect_sfx") and is_instance_valid(main_ref.get("shield_deflect_sfx")):
							main_ref.shield_deflect_sfx.play()
						if main_ref.has_method("_spawn_deflected_number"):
							main_ref._spawn_deflected_number(f_node.global_position)
						if main_ref.has_method("_spawn_flare_explosion"):
							main_ref._spawn_flare_explosion(f_node.global_position)
							
			# Check Sun impact
			var sun = main_ref.get("sun") as Node3D
			if is_instance_valid(sun):
				var dist_sun: float = global_position.distance_to(sun.global_position)
				if dist_sun < 6.0:
					_trigger_sun_impact(sun.global_position)
					queue_free()
				
	func _trigger_sun_impact(sun_pos: Vector3) -> void:
		if not main_ref or not is_instance_valid(main_ref):
			return
		var ring = MeshInstance3D.new()
		var p_torus = TorusMesh.new()
		p_torus.inner_radius = 5.0
		p_torus.outer_radius = 6.2
		p_torus.rings = 24
		p_torus.ring_segments = 3
		ring.mesh = p_torus
		ring.material_override = material_ref
		
		main_ref.add_child(ring)
		ring.global_position = sun_pos
		ring.look_at(ring.global_position + flight_dir, Vector3.UP)
		
		var tw = main_ref.create_tween().set_parallel(true)
		tw.tween_property(ring, "scale", Vector3(2.4, 2.4, 2.4), 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(ring, "transparency", 1.0, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.chain().tween_callback(ring.queue_free)
		
		if main_ref.has_method("shake"):
			main_ref.shake(0.25, 0.04)
