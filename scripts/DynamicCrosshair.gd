extends Control

@onready var crosshair_image: TextureRect = $CrosshairImage

var is_empty: bool = false
var is_low_water: bool = false
var empty_color: Color = Color(1.0, 0.2, 0.2, 0.9)
var warning_color: Color = Color(1.0, 0.5, 0.0, 0.9)
var water_color: Color = Color(0.2, 0.8, 1.0, 0.7)
var base_color: Color = Color(0.6, 0.9, 1.0, 0.9)

var current_crosshair_color: Color = base_color:
	set(val):
		current_crosshair_color = val
		if crosshair_image:
			crosshair_image.modulate = val
		queue_redraw()

var pulse_tween: Tween
var current_water: float = 100.0
var max_water: float = 100.0

func _ready() -> void:
	# Center pivots so it scales from the middle
	pivot_offset = size / 2.0
	if crosshair_image:
		crosshair_image.pivot_offset = crosshair_image.size / 2.0
		crosshair_image.modulate = current_crosshair_color

func update_water(current: float, max_val: float) -> void:
	current_water = current
	max_water = max_val
	queue_redraw()
	
	var ratio = 0.0
	if max_val > 0.0:
		ratio = current / max_val
		
	if current <= 0.0:
		if not is_empty:
			is_empty = true
			is_low_water = false
			if is_instance_valid(pulse_tween): pulse_tween.kill()
			current_crosshair_color = empty_color
	elif ratio <= 0.25:
		if not is_low_water or is_empty:
			is_empty = false
			is_low_water = true
			if is_instance_valid(pulse_tween): pulse_tween.kill()
			
			if GameState.reduce_motion:
				current_crosshair_color = warning_color
			else:
				pulse_tween = create_tween()
				pulse_tween.set_loops()
				pulse_tween.tween_property(self, "current_crosshair_color", warning_color, 0.6).set_trans(Tween.TRANS_SINE)
				pulse_tween.tween_property(self, "current_crosshair_color", base_color, 0.6).set_trans(Tween.TRANS_SINE)
	else:
		if is_empty or is_low_water:
			is_empty = false
			is_low_water = false
			if is_instance_valid(pulse_tween): pulse_tween.kill()
			current_crosshair_color = base_color

func _draw() -> void:
	var center = size / 2.0
	var radius = 28.0 # Thin ring slightly outside the crosshair image
	var thickness = 3.0
	var bg_color = Color(0.0, 0.0, 0.0, 0.2)
	
	var fg_color = water_color
	if is_empty:
		fg_color = empty_color
	elif is_low_water:
		fg_color = current_crosshair_color
	
	# Draw background track
	draw_arc(center, radius, 0, TAU, 32, bg_color, thickness, true)
	
	# Draw progress arc
	if current_water > 0 and max_water > 0:
		var fill_ratio = current_water / max_water
		var end_angle = -PI/2 + (TAU * fill_ratio)
		draw_arc(center, radius, -PI/2, end_angle, 32, fg_color, thickness, true)
