class_name CelestialTails
extends Node3D

## Procedural 9-Tail Celestial Hydro-Ribbons (Fox Nine Awakening)
## Generates 9 glowing, ethereal hydro-silk ribbons cascading gracefully from the
## overhead celestial canopy, framing the upper sky without obstructing the beach or reticle.
## Features staggered henshin bloom, multi-frequency traveling waves, aim inertia, and ribbon twist.

const TAIL_COUNT: int = 9
const SEGMENTS_PER_TAIL: int = 32

@export var base_color: Color = Color(0.12, 0.70, 1.00, 0.45)
@export var mid_color: Color = Color(0.35, 0.92, 1.00, 0.78)
@export var tip_color: Color = Color(1.00, 1.00, 1.00, 0.95)
@export var solar_tip_color: Color = Color(1.00, 0.96, 0.82, 0.95)

var immediate_mesh: ImmediateMesh
var mesh_instance: MeshInstance3D
var ribbon_material: StandardMaterial3D

var is_active: bool = false
var anim_time: float = 0.0

# Per-tail bloom transition progress (0.0 to 1.0+)
var tail_progress: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var bloom_tween: Tween

# Aim inertia & sway
var target_aim: Vector2 = Vector2.ZERO
var current_aim: Vector2 = Vector2.ZERO
var aim_drag: Vector2 = Vector2.ZERO

func _ready() -> void:
	# 1. Setup Material with Additive Blending
	ribbon_material = StandardMaterial3D.new()
	ribbon_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ribbon_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ribbon_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	ribbon_material.vertex_color_use_as_albedo = true
	ribbon_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	# 2. Setup ImmediateMesh and MeshInstance3D
	immediate_mesh = ImmediateMesh.new()
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "TailRibbons"
	mesh_instance.mesh = immediate_mesh
	mesh_instance.material_override = ribbon_material
	add_child(mesh_instance)
	
	# Initial state: inactive & hidden
	visible = false
	for i in range(TAIL_COUNT):
		tail_progress[i] = 0.0

func activate_awakening() -> void:
	is_active = true
	visible = true
	
	if bloom_tween and bloom_tween.is_valid():
		bloom_tween.kill()
		
	bloom_tween = create_tween().set_parallel(true)
	
	# Henshin bloom ripple: center crest tail (4) erupts first, rippling outward to wingtips (0, 8)
	for i in range(TAIL_COUNT):
		var dist_from_center: int = abs(i - 4)
		var delay: float = float(dist_from_center) * 0.05
		var idx: int = i
		
		# Spring overshoot gives an energetic whip-bloom before settling
		bloom_tween.tween_method(
			func(val: float): tail_progress[idx] = val,
			tail_progress[idx],
			1.0,
			0.65
		).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func deactivate_awakening() -> void:
	is_active = false
	
	if bloom_tween and bloom_tween.is_valid():
		bloom_tween.kill()
		
	bloom_tween = create_tween().set_parallel(true)
	
	# Retraction sequence: outer wingtips fold inward first, cascading back to heaven
	for i in range(TAIL_COUNT):
		var dist_from_center: int = abs(i - 4)
		var delay: float = float(4 - dist_from_center) * 0.035
		var idx: int = i
		
		bloom_tween.tween_method(
			func(val: float): tail_progress[idx] = val,
			tail_progress[idx],
			0.0,
			0.45
		).set_delay(delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		
	bloom_tween.chain().tween_callback(func():
		if not is_active:
			visible = false
			if immediate_mesh.get_surface_count() > 0:
				immediate_mesh.clear_surfaces()
	)

func update_aim(norm_aim: Vector2, delta: float) -> void:
	target_aim = norm_aim
	current_aim = current_aim.lerp(target_aim, clamp(6.0 * delta, 0.0, 1.0))
	aim_drag = target_aim - current_aim

func _process(delta: float) -> void:
	var any_visible: bool = false
	for p in tail_progress:
		if p > 0.001:
			any_visible = true
			break
			
	if not any_visible:
		if immediate_mesh.get_surface_count() > 0:
			immediate_mesh.clear_surfaces()
		return
		
	anim_time += delta
	_generate_ribbons()

func _generate_ribbons() -> void:
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, ribbon_material)
	
	for i in range(TAIL_COUNT):
		_draw_single_tail(i)
		
	immediate_mesh.surface_end()

func _draw_single_tail(tail_idx: int) -> void:
	var p: float = tail_progress[tail_idx]
	if p <= 0.001:
		return
		
	var t_norm: float = (float(tail_idx) - 4.0) / 4.0 # Range: -1.0 (leftmost) to +1.0 (rightmost)
	var abs_t: float = abs(t_norm)
	
	var fan_spread: float = t_norm * deg_to_rad(45.0)
	var base_y: float = 0.85 + (1.0 - abs_t) * 0.25
	
	# 1. Generate Spine Points along the path
	var spine_pts: Array[Vector3] = []
	var spine_s: Array[float] = []
	
	# During bloom, tail unfurls forward along its path
	var eff_length: float = min(p, 1.0)
	var stretch_factor: float = max(1.0, p) # Elastic overshoot stretch
	
	for seg in range(SEGMENTS_PER_TAIL + 1):
		var u: float = float(seg) / float(SEGMENTS_PER_TAIL)
		var s: float = u * eff_length
		
		# Procedural overhead celestial canopy path
		var forward_reach: float = 0.15 - s * 1.35 # Z goes from +0.15 to -1.20
		var y_descent: float = pow(s, 1.3) * (0.35 + abs_t * 0.45)
		var tip_curl: float = 0.0
		if s > 0.75:
			tip_curl = pow((s - 0.75) / 0.25, 1.8) * 0.12
		var y_pos: float = base_y - y_descent + tip_curl
		
		var x_pos: float = t_norm * 0.25 + sin(fan_spread) * (s * 1.55 + pow(s, 1.5) * 0.35)
		var z_pos: float = forward_reach
		
		# Multi-frequency traveling hydro-waves coursing down the silk
		var wave_phase1: float = anim_time * 3.8 - s * 4.6 + tail_idx * 0.72
		var wave_phase2: float = anim_time * 7.5 - s * 9.2 + tail_idx * 1.15
		var wave_phase3: float = anim_time * 2.6 - s * 3.6 + tail_idx * 0.85
		
		var wave_x: float = (sin(wave_phase1) * 0.045 + sin(wave_phase2) * 0.016) * (s * s)
		var wave_y: float = (cos(wave_phase3) * 0.035 + cos(wave_phase1 * 1.4) * 0.012) * (s * s)
		var wave_z: float = sin(anim_time * 2.2 + tail_idx * 0.55) * (0.035 * s)
		
		# Organic living breath
		var breathe: float = sin(anim_time * 1.8 + tail_idx * 0.35) * (0.035 * s)
		
		# Aim inertia sway (trailing dynamic drag behind player movement)
		var sway_x: float = -aim_drag.x * (s * 0.12 + s * s * 0.18) + target_aim.x * 0.05 * s
		var sway_y: float = -aim_drag.y * (s * 0.08 + s * s * 0.12) - target_aim.y * 0.04 * s
		
		var pt: Vector3 = Vector3(
			(x_pos + wave_x + sway_x) * stretch_factor,
			(y_pos + wave_y + breathe + sway_y) * stretch_factor,
			(z_pos + wave_z)
		)
		spine_pts.append(pt)
		spine_s.append(s)
		
	# 2. Build 3D Calligraphic Ribbon Triangles
	var prev_left: Vector3 = Vector3.ZERO
	var prev_right: Vector3 = Vector3.ZERO
	var prev_color: Color = Color.TRANSPARENT
	
	var global_alpha_mult: float = clamp(p * 2.0, 0.0, 1.0)
	
	for seg in range(SEGMENTS_PER_TAIL + 1):
		var pt: Vector3 = spine_pts[seg]
		var s: float = spine_s[seg]
		
		# Tangent direction along spine
		var tangent: Vector3
		if seg < SEGMENTS_PER_TAIL:
			tangent = (spine_pts[seg + 1] - pt).normalized()
		else:
			tangent = (pt - spine_pts[seg - 1]).normalized()
			
		# Binormal facing the camera
		var view_dir: Vector3 = pt.normalized()
		var binormal: Vector3 = tangent.cross(view_dir)
		if binormal.length_squared() < 1e-4:
			binormal = tangent.cross(Vector3.UP)
			if binormal.length_squared() < 1e-4:
				binormal = Vector3.RIGHT
		binormal = binormal.normalized()
		
		# Organic ribbon twist (flowing silk roll in 3D)
		var roll_angle: float = sin(anim_time * 2.2 - s * 4.0 + tail_idx * 0.6) * (0.28 * s)
		var ribbon_dir: Vector3 = (Basis(tangent, roll_angle) * binormal).normalized()
		
		# Calligraphic ribbon width
		var base_w: float = (pow(sin(s * PI), 0.85) * 0.075 + 0.012)
		if s > 0.85:
			base_w *= pow((1.0 - s) / 0.15, 0.8)
		var width: float = base_w * clamp(p * 1.5, 0.0, 1.0)
		
		var half_w: Vector3 = ribbon_dir * (width * 0.5)
		var v_left: Vector3 = pt + half_w
		var v_right: Vector3 = pt - half_w
		
		# Glowing energy pulse racing down the hydro-ribbon
		var energy_pulse: float = sin(anim_time * 6.0 - s * 10.0 + tail_idx * 0.75) * 0.12 + 0.88
		var alpha: float = global_alpha_mult * energy_pulse
		
		# Soft glowing gradient along spine with subtle solar wisp accent at the tip
		var seg_color: Color
		if s < 0.28:
			var m: float = s / 0.28
			seg_color = base_color.lerp(mid_color, m)
			seg_color.a = (0.25 + m * 0.45) * alpha
		elif s < 0.80:
			var m: float = (s - 0.28) / 0.52
			seg_color = mid_color.lerp(tip_color, m)
			seg_color.a = 0.78 * alpha
		else:
			var m: float = (s - 0.80) / 0.20
			seg_color = tip_color.lerp(solar_tip_color, m * 0.5)
			seg_color.a = (1.0 - m * 0.35) * 0.95 * alpha
			
		# Emit Triangles
		if seg > 0:
			# Triangle 1
			immediate_mesh.surface_set_color(prev_color)
			immediate_mesh.surface_add_vertex(prev_left)
			immediate_mesh.surface_set_color(seg_color)
			immediate_mesh.surface_add_vertex(v_left)
			immediate_mesh.surface_set_color(prev_color)
			immediate_mesh.surface_add_vertex(prev_right)
			
			# Triangle 2
			immediate_mesh.surface_set_color(prev_color)
			immediate_mesh.surface_add_vertex(prev_right)
			immediate_mesh.surface_set_color(seg_color)
			immediate_mesh.surface_add_vertex(v_left)
			immediate_mesh.surface_set_color(seg_color)
			immediate_mesh.surface_add_vertex(v_right)
			
		prev_left = v_left
		prev_right = v_right
		prev_color = seg_color
