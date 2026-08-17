extends Control

@export var color: Color = Color(1.0, 0.85, 0.2, 0.8)
@export var glow_color: Color = Color(1.0, 0.6, 0.0, 0.2)
@export var line_width: float = 6.0
@export var radius: float = 140.0
@export var rotation_speed: float = 0.4 # Radians per second

var ray_rotation: float = 0.0
var time_passed: float = 0.0

func _ready():
	resized.connect(queue_redraw)

func _process(delta: float):
	ray_rotation += rotation_speed * delta
	time_passed += delta
	queue_redraw()

func _draw_sun_elements(base_color: Color, width: float, center: Vector2):
	# Draw the FULL main sun circle
	draw_arc(center, radius, 0, TAU, 128, base_color, width, true)
	
	# Face elements (Stationary)
	var eye_offset_x = 40.0
	var eye_offset_y = -30.0
	var eye_length = 40.0
	
	# Left Eye
	draw_line(center + Vector2(-eye_offset_x, eye_offset_y), center + Vector2(-eye_offset_x, eye_offset_y + eye_length), base_color, width, true)
	# Right Eye
	draw_line(center + Vector2(eye_offset_x, eye_offset_y), center + Vector2(eye_offset_x, eye_offset_y + eye_length), base_color, width, true)
	
	# Left Eyebrow (Slightly thicker/angrier if width allows)
	draw_line(center + Vector2(-eye_offset_x - 30, eye_offset_y - 40), center + Vector2(-eye_offset_x + 10, eye_offset_y - 15), base_color, width, true)
	# Right Eyebrow
	draw_line(center + Vector2(eye_offset_x + 30, eye_offset_y - 40), center + Vector2(eye_offset_x - 10, eye_offset_y - 15), base_color, width, true)
	
	# Mouth (Stylized jagged line)
	var mouth_y = 60.0
	var mouth_w = 25.0
	var mouth_h = 20.0
	var mouth_pts = PackedVector2Array([
		center + Vector2(-mouth_w, mouth_y + mouth_h),
		center + Vector2(-mouth_w * 0.3, mouth_y + 5.0),
		center + Vector2(0, mouth_y + mouth_h * 0.8),
		center + Vector2(mouth_w * 0.3, mouth_y + 5.0),
		center + Vector2(mouth_w, mouth_y + mouth_h)
	])
	draw_polyline(mouth_pts, base_color, width, true)
	
	# Rays (Triangles, Rotating & Detached)
	var ray_count = 10
	var ray_base_spread = 0.12 # radians (slightly thinner)
	var ray_gap = 15.0 # Detach from the main circle
	var ray_length = 45.0
	
	for i in range(ray_count):
		var angle = (i * TAU / ray_count) + ray_rotation
		var base_left_angle = angle - ray_base_spread
		var base_right_angle = angle + ray_base_spread
		
		var tip = center + Vector2(cos(angle), sin(angle)) * (radius + ray_gap + ray_length)
		var base_left = center + Vector2(cos(base_left_angle), sin(base_left_angle)) * (radius + ray_gap)
		var base_right = center + Vector2(cos(base_right_angle), sin(base_right_angle)) * (radius + ray_gap)
		
		var ray_pts = PackedVector2Array([base_left, tip, base_right])
		draw_polyline(ray_pts, base_color, width, true)

func _draw():
	var center = Vector2(size.x - 80, size.y - 80) 
	
	# Pulsing Glow Effect
	var pulse = (sin(time_passed * 3.0) + 1.0) * 0.5 # 0.0 to 1.0
	var current_glow = glow_color
	current_glow.a = lerp(0.1, 0.4, pulse)
	
	# Draw Glow Pass (Thick, low alpha)
	_draw_sun_elements(current_glow, line_width * 4.0, center)
	
	# Draw Core Pass (Crisp, high alpha)
	_draw_sun_elements(color, line_width, center)

