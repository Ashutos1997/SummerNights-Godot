class_name CelestialHydroCannon
extends Node3D

## Procedural 9-Stream Converging Hydro-Cannon (Fox Nine Awakening)
## Renders 9 distinct, readable hydro-streams that emerge as a solid cohesive stream
## from the tip of the gun, separate into individual spiraling braided torrents in mid-air,
## and converge gently around the crosshair target.

const STREAM_COUNT: int = 9
const SEGMENTS_PER_STREAM: int = 30
const RING_SEGMENTS: int = 16

@export var core_color: Color = Color(0.15, 0.85, 1.00, 0.70)
@export var outer_color: Color = Color(0.05, 0.50, 1.00, 0.45)
@export var highlight_color: Color = Color(1.00, 1.00, 1.00, 0.85)
@export var solar_color: Color = Color(1.00, 0.92, 0.50, 0.75)

var immediate_mesh: ImmediateMesh
var mesh_instance: MeshInstance3D
var stream_material: StandardMaterial3D

var is_firing: bool = false
var intensity: float = 0.0
var anim_time: float = 0.0

var stream_origin: Vector3 = Vector3.ZERO
var stream_target: Vector3 = Vector3.ZERO

func _ready() -> void:
	# Additive blending for brilliant luminous water vortex
	stream_material = StandardMaterial3D.new()
	stream_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	stream_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	stream_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	stream_material.vertex_color_use_as_albedo = true
	stream_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	immediate_mesh = ImmediateMesh.new()
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "HydroVortexMesh"
	mesh_instance.mesh = immediate_mesh
	mesh_instance.material_override = stream_material
	add_child(mesh_instance)
	
	visible = false

func set_firing(firing: bool, origin: Vector3, target: Vector3) -> void:
	is_firing = firing
	stream_origin = origin
	stream_target = target

func _process(delta: float) -> void:
	if is_firing:
		intensity = min(1.0, intensity + delta * 14.0)
		visible = true
	else:
		intensity = max(0.0, intensity - delta * 14.0)
		
	if intensity <= 0.001:
		if immediate_mesh.get_surface_count() > 0:
			immediate_mesh.clear_surfaces()
		visible = false
		return
		
	anim_time += delta
	_generate_vortex()

func _generate_vortex() -> void:
	immediate_mesh.clear_surfaces()
	
	var aim_vec: Vector3 = stream_target - stream_origin
	var flight_dist: float = aim_vec.length()
	if flight_dist < 0.2:
		return
		
	var dir: Vector3 = aim_vec / flight_dist
	
	# Orthonormal basis for vortex rotation around the central aim axis
	var up_ref: Vector3 = Vector3.UP
	if abs(dir.dot(up_ref)) > 0.95:
		up_ref = Vector3.RIGHT
	var right: Vector3 = dir.cross(up_ref).normalized()
	var ortho_up: Vector3 = right.cross(dir).normalized()
	
	# Active camera position for accurate billboard facing
	var cam: Camera3D = get_viewport().get_camera_3d()
	var cam_pos: Vector3 = cam.global_position if cam else Vector3(0, 0, 5)
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, stream_material)
	
	# 1. 9 Distinct Braided Streams (Starts solid at tip of gun -> separates in mid-air -> converges slightly)
	for s_idx in range(STREAM_COUNT):
		_draw_stream(s_idx, dir, right, ortho_up, flight_dist, cam_pos)
		
	# 2. Sleek Muzzle Aperture Ring (anchors streams right at the nozzle tip)
	_draw_vortex_ring(stream_origin, right, ortho_up, 0.065, 0.02, highlight_color, 18.0)
	
	# 3. Gentle Convergence Impact Ring at Target (frames the crosshair with gentle focal feedback)
	_draw_impact_ring(stream_target, right, ortho_up)
	
	immediate_mesh.surface_end()

func _draw_stream(idx: int, dir: Vector3, right: Vector3, ortho_up: Vector3, flight_dist: float, cam_pos: Vector3) -> void:
	var base_angle: float = (float(idx) * TAU) / float(STREAM_COUNT)
	var pts: Array[Vector3] = []
	var t_steps: Array[float] = []
	var widths: Array[float] = []
	var alphas: Array[float] = []
	
	var is_solar_accent: bool = (idx % 3 == 0)
	var stream_col: Color = solar_color if is_solar_accent else core_color
	
	for seg in range(SEGMENTS_PER_STREAM + 1):
		var t: float = float(seg) / float(SEGMENTS_PER_STREAM) # 0.0 at muzzle -> 1.0 at target
		
		# Swirl angle
		var swirl: float = base_angle + anim_time * 14.0 + t * 6.5
		
		# Radius profile:
		# Starts tight at 0.035m (forming a solid unified stream at muzzle tip)
		# Expands in mid-flight to 0.48m (clearly separated into 9 distinct streams)
		# Converges slightly to 0.18m at target (gentle convergence without collapsing into a blob)
		var radius: float
		if t < 0.12:
			# Solid unified beam at muzzle
			var u: float = t / 0.12
			radius = (0.035 * (1.0 - u) + 0.14 * u) * intensity
		elif t < 0.65:
			# Distinct separated streams with clean negative space between them
			var u: float = (t - 0.12) / 0.53
			radius = (0.14 + 0.34 * sin(u * PI)) * intensity
		else:
			# Converge slightly towards target
			var u: float = (t - 0.65) / 0.35
			radius = (0.48 * (1.0 - u) + 0.18 * u) * intensity
			
		var offset: Vector3 = (right * cos(swirl) + ortho_up * sin(swirl)) * radius
		var pt: Vector3 = stream_origin + (dir * (flight_dist * t)) + offset
		pts.append(pt)
		t_steps.append(t)
		
		# Sleek ribbon width: keeps streams distinct and prevents overexposure
		var w: float = (0.045 * (1.0 - t * 0.4) + 0.02 * sin(t * PI)) * intensity
		widths.append(w)
		
		# Translucent alpha: allows overlapping streams to blend cleanly
		var a: float = (0.75 - t * 0.20) * intensity
		alphas.append(a)
		
	var prev_left: Vector3 = Vector3.ZERO
	var prev_right: Vector3 = Vector3.ZERO
	var prev_color: Color = Color.TRANSPARENT
	
	for seg in range(SEGMENTS_PER_STREAM + 1):
		var pt: Vector3 = pts[seg]
		var width: float = widths[seg]
		var alpha: float = alphas[seg]
		var t: float = t_steps[seg]
		
		var tangent: Vector3
		if seg < SEGMENTS_PER_STREAM:
			tangent = (pts[seg + 1] - pt).normalized()
		else:
			tangent = (pt - pts[seg - 1]).normalized()
			
		# Camera-facing billboard vector
		var v_cam: Vector3 = (pt - cam_pos).normalized()
		var norm: Vector3 = tangent.cross(v_cam).normalized()
		if norm.length_squared() < 1e-4:
			norm = right
			
		var half_w: Vector3 = norm * (width * 0.5)
		var v_left: Vector3 = pt + half_w
		var v_right: Vector3 = pt - half_w
		
		var pulse: float = sin(anim_time * 20.0 - t * 16.0 + idx * 0.7) * 0.12 + 0.88
		
		var col: Color
		if t < 0.20:
			col = highlight_color.lerp(stream_col, t / 0.20)
		elif t < 0.80:
			col = stream_col.lerp(highlight_color, (t - 0.20) / 0.60 * 0.5)
		else:
			col = highlight_color.lerp(solar_color, (t - 0.80) / 0.20)
		col.a = alpha * pulse
		
		if seg > 0:
			_add_quad(prev_left, v_left, prev_right, v_right, prev_color, col)
			
		prev_left = v_left
		prev_right = v_right
		prev_color = col

func _draw_vortex_ring(center_pos: Vector3, right: Vector3, ortho_up: Vector3, r_out: float, r_in: float, ring_color: Color, rot_speed: float) -> void:
	var r_outer: float = r_out * intensity
	var r_inner: float = r_in * intensity
	var ring_rot: float = anim_time * rot_speed
	
	var prev_inner: Vector3 = Vector3.ZERO
	var prev_outer: Vector3 = Vector3.ZERO
	var prev_col: Color = Color.TRANSPARENT
	
	for i in range(RING_SEGMENTS + 1):
		var theta: float = (float(i) * TAU) / float(RING_SEGMENTS) + ring_rot
		var c: float = cos(theta)
		var s: float = sin(theta)
		var radial_dir: Vector3 = right * c + ortho_up * s
		
		var v_inner: Vector3 = center_pos + radial_dir * r_inner
		var v_outer: Vector3 = center_pos + radial_dir * r_outer
		
		var pulse: float = sin(anim_time * 20.0 + theta * 3.0) * 0.15 + 0.85
		var col_inner: Color = highlight_color
		col_inner.a = 0.85 * intensity * pulse
		var col_outer: Color = ring_color
		col_outer.a = 0.0
		
		if i > 0:
			_add_ring_quad(prev_inner, v_inner, prev_outer, v_outer, prev_col, col_inner, col_outer)
			
		prev_inner = v_inner
		prev_outer = v_outer
		prev_col = col_inner

func _draw_impact_ring(target_pos: Vector3, right: Vector3, ortho_up: Vector3) -> void:
	var r_outer: float = (0.35 + sin(anim_time * 16.0) * 0.05) * intensity
	var r_inner: float = (0.12 + sin(anim_time * 16.0) * 0.02) * intensity
	var ring_rot: float = anim_time * 12.0
	
	var prev_inner: Vector3 = Vector3.ZERO
	var prev_outer: Vector3 = Vector3.ZERO
	var prev_col: Color = Color.TRANSPARENT
	
	for i in range(RING_SEGMENTS + 1):
		var theta: float = (float(i) * TAU) / float(RING_SEGMENTS) + ring_rot
		var c: float = cos(theta)
		var s: float = sin(theta)
		var radial_dir: Vector3 = right * c + ortho_up * s
		
		var v_inner: Vector3 = target_pos + radial_dir * r_inner
		var v_outer: Vector3 = target_pos + radial_dir * r_outer
		
		var pulse: float = sin(anim_time * 22.0 + theta * 2.0) * 0.15 + 0.85
		var col_inner: Color = highlight_color
		col_inner.a = 0.85 * intensity * pulse
		var col_outer: Color = core_color
		col_outer.a = 0.0
		
		if i > 0:
			_add_ring_quad(prev_inner, v_inner, prev_outer, v_outer, prev_col, col_inner, col_outer)
			
		prev_inner = v_inner
		prev_outer = v_outer
		prev_col = col_inner

func _add_ring_quad(prev_in: Vector3, cur_in: Vector3, prev_out: Vector3, cur_out: Vector3, col_prev: Color, col_in: Color, col_out: Color) -> void:
	immediate_mesh.surface_set_color(col_prev)
	immediate_mesh.surface_add_vertex(prev_in)
	immediate_mesh.surface_set_color(col_in)
	immediate_mesh.surface_add_vertex(cur_in)
	immediate_mesh.surface_set_color(col_prev)
	immediate_mesh.surface_add_vertex(prev_out)
	
	immediate_mesh.surface_set_color(col_prev)
	immediate_mesh.surface_add_vertex(prev_out)
	immediate_mesh.surface_set_color(col_in)
	immediate_mesh.surface_add_vertex(cur_in)
	immediate_mesh.surface_set_color(col_out)
	immediate_mesh.surface_add_vertex(cur_out)

func _add_quad(prev_l: Vector3, cur_l: Vector3, prev_r: Vector3, cur_r: Vector3, col_prev: Color, col_cur: Color) -> void:
	immediate_mesh.surface_set_color(col_prev)
	immediate_mesh.surface_add_vertex(prev_l)
	immediate_mesh.surface_set_color(col_cur)
	immediate_mesh.surface_add_vertex(cur_l)
	immediate_mesh.surface_set_color(col_prev)
	immediate_mesh.surface_add_vertex(prev_r)
	
	immediate_mesh.surface_set_color(col_prev)
	immediate_mesh.surface_add_vertex(prev_r)
	immediate_mesh.surface_set_color(col_cur)
	immediate_mesh.surface_add_vertex(cur_l)
	immediate_mesh.surface_set_color(col_cur)
	immediate_mesh.surface_add_vertex(cur_r)
