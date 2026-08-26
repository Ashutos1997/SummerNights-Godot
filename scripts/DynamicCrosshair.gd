extends Control

@onready var crosshair_image: TextureRect = $CrosshairImage

var is_empty: bool = false
var empty_color: Color = Color(1.0, 0.2, 0.2, 0.9)
var water_color: Color = Color(0.2, 0.8, 1.0, 0.7)
var base_color: Color = Color(0.6, 0.9, 1.0, 0.9)

var current_water: float = 100.0
var max_water: float = 100.0

func _ready() -> void:
	# Center pivots so it scales from the middle
	pivot_offset = size / 2.0
	if crosshair_image:
		crosshair_image.pivot_offset = crosshair_image.size / 2.0

func update_water(current: float, max_val: float) -> void:
	current_water = current
	max_water = max_val
	queue_redraw()
	
	if current <= 0.0 and not is_empty:
		is_empty = true
		crosshair_image.modulate = empty_color
	elif current > 0.0 and is_empty:
		is_empty = false
		crosshair_image.modulate = base_color

func _draw() -> void:
	var center = size / 2.0
	var radius = 28.0 # Thin ring slightly outside the crosshair image
	var thickness = 3.0
	var bg_color = Color(0.0, 0.0, 0.0, 0.2)
	var fg_color = empty_color if is_empty else water_color
	
	# Draw background track
	draw_arc(center, radius, 0, TAU, 32, bg_color, thickness, true)
	
	# Draw progress arc
	if current_water > 0 and max_water > 0:
		var fill_ratio = current_water / max_water
		var end_angle = -PI/2 + (TAU * fill_ratio)
		draw_arc(center, radius, -PI/2, end_angle, 32, fg_color, thickness, true)
