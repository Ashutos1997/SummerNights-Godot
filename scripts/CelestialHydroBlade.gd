class_name CelestialHydroBlade
extends Node3D

## CelestialHydroBlade
## Manages procedural water-sheath VFX for Kitsune Buster IX Blade Mode:
## 1. Flowing Hydro-Sheath — tight tube wrapping the katana blade during Celestial Awakening
## 2. Helical Spiral Streams — 6 water streams orbiting tightly around the blade
## 3. Sweeping Water Crescent Arc — melee slash visual
## 4. Flying Celestial Hydro-Crescent Wave — awakening projectile

const SHEATH_RINGS: int = 24          # Cross-section rings along blade length
const SHEATH_RING_VERTS: int = 10     # Vertices per ring (tube resolution)
const SPIRAL_STREAMS: int = 6         # Helical streams orbiting the blade
const SPIRAL_SEGMENTS: int = 28       # Points per spiral stream

@export var water_core_color: Color = Color(0.18, 0.88, 1.00, 0.75)
@export var water_outer_color: Color = Color(0.06, 0.45, 0.95, 0.40)
@export var water_highlight_color: Color = Color(1.00, 1.00, 1.00, 0.92)
@export var water_solar_color: Color = Color(1.00, 0.88, 0.40, 0.80)

# Mesh instances for sheath + spirals
var sheath_mesh_instance: MeshInstance3D
var sheath_immediate_mesh: ImmediateMesh
var sheath_material: StandardMaterial3D

var spiral_mesh_instance: MeshInstance3D
var spiral_immediate_mesh: ImmediateMesh

var edge_mesh_instance: MeshInstance3D
var edge_immediate_mesh: ImmediateMesh

var is_blade_awakened: bool = false
var aura_intensity: float = 0.0
var anim_time: float = 0.0

var target_gun_node: Node3D = null

func _ready() -> void:
	# Shared additive material for all blade VFX
	sheath_material = StandardMaterial3D.new()
	sheath_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sheath_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sheath_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	sheath_material.vertex_color_use_as_albedo = true
	sheath_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	# Inner tube sheath
	sheath_immediate_mesh = ImmediateMesh.new()
	sheath_mesh_instance = MeshInstance3D.new()
	sheath_mesh_instance.name = "BladeSheath"
	sheath_mesh_instance.mesh = sheath_immediate_mesh
	sheath_mesh_instance.material_override = sheath_material
	add_child(sheath_mesh_instance)
	
	# Helical spiral streams
	spiral_immediate_mesh = ImmediateMesh.new()
	spiral_mesh_instance = MeshInstance3D.new()
	spiral_mesh_instance.name = "BladeSpiralStreams"
	spiral_mesh_instance.mesh = spiral_immediate_mesh
	spiral_mesh_instance.material_override = sheath_material
	add_child(spiral_mesh_instance)
	
	# Cutting edge glow ribbon
	edge_immediate_mesh = ImmediateMesh.new()
	edge_mesh_instance = MeshInstance3D.new()
	edge_mesh_instance.name = "BladeEdgeGlow"
	edge_mesh_instance.mesh = edge_immediate_mesh
	edge_mesh_instance.material_override = sheath_material
	add_child(edge_mesh_instance)
	
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
	
	if aura_intensity > 0.005:
		_render_blade_sheath()
		_render_spiral_streams()
		_render_edge_glow()
	else:
		if sheath_immediate_mesh.get_surface_count() > 0:
			sheath_immediate_mesh.clear_surfaces()
		if spiral_immediate_mesh.get_surface_count() > 0:
			spiral_immediate_mesh.clear_surfaces()
		if edge_immediate_mesh.get_surface_count() > 0:
			edge_immediate_mesh.clear_surfaces()

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
# 1. FLOWING HYDRO-SHEATH — translucent tube hugging the blade
# ══════════════════════════════════════════════════════════════════
func _render_blade_sheath() -> void:
	sheath_immediate_mesh.clear_surfaces()
	var axes = _get_blade_axes()
	if axes.is_empty():
		return
	
	var blade_base: Vector3 = axes["base"]
	var blade_dir: Vector3 = axes["dir"]
	var blade_len: float = axes["len"]
	var right_ax: Vector3 = axes["right"]
	var up_ax: Vector3 = axes["up"]
	
	sheath_immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, sheath_material)
	
	# Build ring cross-sections along blade spine and connect with quads
	var prev_ring: Array[Vector3] = []
	var prev_colors: Array[Color] = []
	
	for ring_idx in range(SHEATH_RINGS + 1):
		var t: float = float(ring_idx) / float(SHEATH_RINGS)  # 0.0 = collar, 1.0 = tip
		
		# Sori curvature: blade curves upward slightly
		var sori_offset: Vector3 = up_ax * (0.04 * pow(t, 1.8))
		var center: Vector3 = blade_base + (blade_dir * (blade_len * t)) + sori_offset
		
		# Radius envelope: starts snug at habaki, swells mid-blade, tapers to tip
		var base_radius: float = 0.032 + sin(t * PI) * 0.048
		# Animated breathing pulse
		var pulse: float = sin(anim_time * 10.0 - t * 8.0) * 0.008 + 1.0
		var radius: float = base_radius * pulse * aura_intensity
		
		# Taper to zero at tip
		if t > 0.85:
			radius *= (1.0 - t) / 0.15
		# Taper slightly at collar
		if t < 0.08:
			radius *= t / 0.08
		
		# Slow rotation of the tube cross-section for flowing water feel
		var ring_twist: float = anim_time * 4.0 + t * 3.0
		
		var cur_ring: Array[Vector3] = []
		var cur_colors: Array[Color] = []
		
		for v_idx in range(SHEATH_RING_VERTS + 1):
			var theta: float = (float(v_idx) / float(SHEATH_RING_VERTS)) * TAU + ring_twist
			var offset: Vector3 = (right_ax * cos(theta) + up_ax * sin(theta)) * radius
			var vert: Vector3 = center + offset
			cur_ring.append(vert)
			
			# Color: flowing gradient with animated wave crests
			var wave: float = sin(anim_time * 18.0 - t * 12.0 + theta * 2.0) * 0.15 + 0.85
			var col: Color = water_outer_color.lerp(water_core_color, sin(t * PI) * 0.7)
			# Highlight crests
			col = col.lerp(water_highlight_color, max(0.0, sin(anim_time * 14.0 - t * 10.0 + theta * 3.0)) * 0.35)
			col.a = (0.25 + sin(t * PI) * 0.20) * aura_intensity * wave
			# Softer at edges for volumetric feel
			col.a *= 0.7
			cur_colors.append(col)
		
		# Connect this ring to previous ring with quads
		if ring_idx > 0 and prev_ring.size() == cur_ring.size():
			for v_idx in range(SHEATH_RING_VERTS):
				var v0: Vector3 = prev_ring[v_idx]
				var v1: Vector3 = prev_ring[v_idx + 1]
				var v2: Vector3 = cur_ring[v_idx]
				var v3: Vector3 = cur_ring[v_idx + 1]
				var c0: Color = prev_colors[v_idx]
				var c1: Color = prev_colors[v_idx + 1]
				var c2: Color = cur_colors[v_idx]
				var c3: Color = cur_colors[v_idx + 1]
				
				# Triangle 1: v0, v2, v1
				sheath_immediate_mesh.surface_set_color(c0)
				sheath_immediate_mesh.surface_add_vertex(v0)
				sheath_immediate_mesh.surface_set_color(c2)
				sheath_immediate_mesh.surface_add_vertex(v2)
				sheath_immediate_mesh.surface_set_color(c1)
				sheath_immediate_mesh.surface_add_vertex(v1)
				
				# Triangle 2: v1, v2, v3
				sheath_immediate_mesh.surface_set_color(c1)
				sheath_immediate_mesh.surface_add_vertex(v1)
				sheath_immediate_mesh.surface_set_color(c2)
				sheath_immediate_mesh.surface_add_vertex(v2)
				sheath_immediate_mesh.surface_set_color(c3)
				sheath_immediate_mesh.surface_add_vertex(v3)
		
		prev_ring = cur_ring
		prev_colors = cur_colors
	
	sheath_immediate_mesh.surface_end()

# ══════════════════════════════════════════════════════════════════
# 2. HELICAL SPIRAL STREAMS — orbiting water torrents around blade
# ══════════════════════════════════════════════════════════════════
func _render_spiral_streams() -> void:
	spiral_immediate_mesh.clear_surfaces()
	var axes = _get_blade_axes()
	if axes.is_empty():
		return
	
	var blade_base: Vector3 = axes["base"]
	var blade_dir: Vector3 = axes["dir"]
	var blade_len: float = axes["len"]
	var right_ax: Vector3 = axes["right"]
	var up_ax: Vector3 = axes["up"]
	
	var cam: Camera3D = get_viewport().get_camera_3d()
	var cam_pos: Vector3 = cam.global_position if cam else Vector3.ZERO
	
	spiral_immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, sheath_material)
	
	for s_idx in range(SPIRAL_STREAMS):
		var base_phase: float = (float(s_idx) * TAU) / float(SPIRAL_STREAMS)
		var is_solar: bool = (s_idx % 3 == 0)
		var stream_col: Color = water_solar_color if is_solar else water_core_color
		
		var pts: Array[Vector3] = []
		var widths: Array[float] = []
		var colors: Array[Color] = []
		
		for seg in range(SPIRAL_SEGMENTS + 1):
			var t: float = float(seg) / float(SPIRAL_SEGMENTS)
			
			# Sori curvature
			var sori_offset: Vector3 = up_ax * (0.04 * pow(t, 1.8))
			var spine_pt: Vector3 = blade_base + (blade_dir * (blade_len * t)) + sori_offset
			
			# Spiral orbit angle — fast rotation creates the vortex-wrap look
			var swirl_speed: float = 12.0
			var helix_turns: float = 5.0  # number of full turns along blade length
			var angle: float = base_phase + (anim_time * swirl_speed) + (t * helix_turns * TAU)
			
			# Orbit radius: tight near collar, expands mid-blade, tapers at tip
			var orbit_r: float = 0.055 + sin(t * PI) * 0.06
			orbit_r *= aura_intensity
			# Taper at tip
			if t > 0.85:
				orbit_r *= (1.0 - t) / 0.15
			if t < 0.06:
				orbit_r *= t / 0.06
			
			var offset: Vector3 = (right_ax * cos(angle) + up_ax * sin(angle)) * orbit_r
			var pt: Vector3 = spine_pt + offset
			pts.append(pt)
			
			# Ribbon width
			var w: float = (0.028 + sin(t * PI) * 0.020) * aura_intensity
			if t > 0.88:
				w *= (1.0 - t) / 0.12
			widths.append(w)
			
			# Color
			var pulse: float = sin(anim_time * 20.0 - t * 14.0 + s_idx * 1.1) * 0.15 + 0.85
			var col: Color = water_highlight_color.lerp(stream_col, 0.4 + 0.4 * sin(t * PI))
			col.a = (0.65 - t * 0.15) * aura_intensity * pulse
			colors.append(col)
		
		# Build camera-facing ribbon strip
		var prev_l: Vector3 = Vector3.ZERO
		var prev_r: Vector3 = Vector3.ZERO
		var prev_c: Color = Color.TRANSPARENT
		
		for seg in range(SPIRAL_SEGMENTS + 1):
			var pt: Vector3 = pts[seg]
			var w: float = widths[seg]
			var col: Color = colors[seg]
			
			var tangent: Vector3
			if seg < SPIRAL_SEGMENTS:
				tangent = (pts[seg + 1] - pt).normalized()
			else:
				tangent = (pt - pts[seg - 1]).normalized()
			
			var to_cam: Vector3 = (pt - cam_pos).normalized()
			var norm: Vector3 = tangent.cross(to_cam).normalized()
			if norm.length_squared() < 1e-4:
				norm = right_ax
			
			var v_l: Vector3 = pt + norm * (w * 0.5)
			var v_r: Vector3 = pt - norm * (w * 0.5)
			
			if seg > 0:
				_add_quad_to(spiral_immediate_mesh, prev_l, v_l, prev_r, v_r, prev_c, col)
			
			prev_l = v_l
			prev_r = v_r
			prev_c = col
	
	spiral_immediate_mesh.surface_end()

# ══════════════════════════════════════════════════════════════════
# 3. CUTTING EDGE GLOW — bright ribbon along the blade's sharp edge
# ══════════════════════════════════════════════════════════════════
func _render_edge_glow() -> void:
	edge_immediate_mesh.clear_surfaces()
	var axes = _get_blade_axes()
	if axes.is_empty():
		return
	
	var blade_base: Vector3 = axes["base"]
	var blade_dir: Vector3 = axes["dir"]
	var blade_len: float = axes["len"]
	var right_ax: Vector3 = axes["right"]
	var up_ax: Vector3 = axes["up"]
	
	var cam: Camera3D = get_viewport().get_camera_3d()
	var cam_pos: Vector3 = cam.global_position if cam else Vector3.ZERO
	
	edge_immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, sheath_material)
	
	var edge_segments: int = 20
	var prev_l: Vector3 = Vector3.ZERO
	var prev_r: Vector3 = Vector3.ZERO
	var prev_c: Color = Color.TRANSPARENT
	
	for seg in range(edge_segments + 1):
		var t: float = float(seg) / float(edge_segments)
		
		# Sori curvature
		var sori_offset: Vector3 = up_ax * (0.04 * pow(t, 1.8))
		var spine_pt: Vector3 = blade_base + (blade_dir * (blade_len * t)) + sori_offset
		
		# Edge is on the cutting side (right side of the blade when held)
		var edge_offset: Vector3 = right_ax * 0.015
		var pt: Vector3 = spine_pt + edge_offset
		
		# Ribbon width — thin bright line along the edge
		var w: float = 0.018 * aura_intensity
		# Taper at ends
		if t < 0.05:
			w *= t / 0.05
		if t > 0.92:
			w *= (1.0 - t) / 0.08
		
		var tangent: Vector3 = blade_dir
		var to_cam: Vector3 = (pt - cam_pos).normalized()
		var norm: Vector3 = tangent.cross(to_cam).normalized()
		if norm.length_squared() < 1e-4:
			norm = up_ax
		
		var v_l: Vector3 = pt + norm * (w * 0.5)
		var v_r: Vector3 = pt - norm * (w * 0.5)
		
		# Bright white-cyan with flowing pulse
		var pulse: float = sin(anim_time * 24.0 - t * 16.0) * 0.2 + 0.8
		var col: Color = water_highlight_color.lerp(water_core_color, 0.25)
		col.a = (0.7 + sin(t * PI) * 0.25) * aura_intensity * pulse
		
		if seg > 0:
			_add_quad_to(edge_immediate_mesh, prev_l, v_l, prev_r, v_r, prev_c, col)
		
		prev_l = v_l
		prev_r = v_r
		prev_c = col
	
	edge_immediate_mesh.surface_end()

# ══════════════════════════════════════════════════════════════════
# 4. SWEEPING WATER CRESCENT ARC (melee slash visual)
# ══════════════════════════════════════════════════════════════════
func trigger_slash_arc(camera: Camera3D, slash_dir: float, is_awakened: bool) -> void:
	if not camera:
		return
		
	var slash_node = Node3D.new()
	slash_node.name = "WaterSlashArc"
	add_child(slash_node)
	
	var cam_pos: Vector3 = camera.global_position
	var cam_forward: Vector3 = -camera.global_basis.z.normalized()
	var cam_right: Vector3 = camera.global_basis.x.normalized()
	var cam_up: Vector3 = camera.global_basis.y.normalized()
	
	# Center arc in front of camera
	slash_node.global_position = cam_pos + cam_forward * 1.6 + cam_up * -0.1
	
	# Slash plane orientation (tilted diagonally following sword strike)
	var swing_tilt: float = deg_to_rad(28.0 * slash_dir)
	var swing_normal: Vector3 = (cam_up * cos(swing_tilt) + cam_right * sin(swing_tilt)).normalized()
	var swing_tangent: Vector3 = swing_normal.cross(cam_forward).normalized()
	
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
	slash_node.add_child(mesh_inst)
	
	var arc_radius_in: float = 1.1 if not is_awakened else 1.4
	var arc_radius_out: float = 2.4 if not is_awakened else 3.4
	var span_angle: float = deg_to_rad(120.0)
	var arc_segs: int = 24
	
	imm_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, slash_mat)
	
	var prev_in: Vector3 = Vector3.ZERO
	var prev_out: Vector3 = Vector3.ZERO
	var prev_col: Color = Color.TRANSPARENT
	
	for i in range(arc_segs + 1):
		var u: float = float(i) / float(arc_segs)
		var cur_angle: float = (u - 0.5) * span_angle * slash_dir
		
		var cos_a: float = cos(cur_angle)
		var sin_a: float = sin(cur_angle)
		
		var radial_dir: Vector3 = (swing_tangent * cos_a + cam_forward * sin_a * 0.4).normalized()
		
		var thick_profile: float = sin(u * PI)
		var r_in: float = arc_radius_in + (1.0 - thick_profile) * 0.25
		var r_out: float = arc_radius_out + thick_profile * 0.4
		
		var v_inner: Vector3 = radial_dir * r_in + swing_normal * ((u - 0.5) * 0.3 * slash_dir)
		var v_outer: Vector3 = radial_dir * r_out + swing_normal * ((u - 0.5) * 0.5 * slash_dir)
		
		var col_lead: Color = water_highlight_color if is_awakened else Color(0.85, 0.96, 1.0, 0.95)
		var col_trail: Color = water_solar_color if (is_awakened and thick_profile > 0.6) else water_core_color
		var col: Color = col_trail.lerp(col_lead, thick_profile)
		col.a = thick_profile * (0.95 if is_awakened else 0.80)
		
		if i > 0:
			_add_quad_to(imm_mesh, prev_in, v_inner, prev_out, v_outer, prev_col, col)
			
		prev_in = v_inner
		prev_out = v_outer
		prev_col = col
		
	imm_mesh.surface_end()
	
	# Animate crescent expansion and dissipate
	var tw = create_tween().set_parallel(true)
	tw.tween_property(slash_node, "scale", Vector3(1.22, 1.22, 1.22), 0.26).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(mesh_inst, "transparency", 1.0, 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(slash_node.queue_free)

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
			var c_wing = Color(0.20, 0.90, 1.0, 0.85)
			var c_solar = Color(1.0, 0.88, 0.40, 0.90)
			
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
