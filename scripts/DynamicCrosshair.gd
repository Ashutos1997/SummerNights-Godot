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

# ─── Weapon Style ─────────────────────────────────────────────────────────────
var weapon_style: String = "standard"
var _gatling_spin_angle: float = 0.0
var _is_firing: bool = false

func _ready() -> void:
	pivot_offset = size / 2.0
	if crosshair_image:
		crosshair_image.pivot_offset = crosshair_image.size / 2.0
		crosshair_image.modulate = current_crosshair_color
	_apply_weapon_style_visibility()

func set_weapon_style(id: String) -> void:
	weapon_style = id
	_apply_weapon_style_visibility()
	queue_redraw()

func set_firing(firing: bool) -> void:
	_is_firing = firing

func _apply_weapon_style_visibility() -> void:
	if crosshair_image:
		crosshair_image.visible = (weapon_style == "standard")

func _process(delta: float) -> void:
	if weapon_style == "tidal":
		var spin_speed = 180.0 if _is_firing else 60.0
		_gatling_spin_angle = fmod(_gatling_spin_angle + spin_speed * delta, 360.0)
		queue_redraw()

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

func _get_ring_color() -> Color:
	if is_empty: return empty_color
	if is_low_water: return current_crosshair_color
	return water_color

func _draw_water_ring(center: Vector2, radius: float, thickness: float) -> void:
	var bg_color = Color(0.0, 0.0, 0.0, 0.2)
	var fg_color = _get_ring_color()
	draw_arc(center, radius, 0, TAU, 32, bg_color, thickness, true)
	if current_water > 0 and max_water > 0:
		var fill_ratio = current_water / max_water
		var end_angle = -PI / 2.0 + (TAU * fill_ratio)
		draw_arc(center, radius, -PI / 2.0, end_angle, 32, fg_color, thickness, true)

func _draw() -> void:
	var center = size / 2.0
	var col = current_crosshair_color
	match weapon_style:
		"standard":
			_draw_water_ring(center, 28.0, 3.0)
		"precision":
			_draw_precision(center, col)
		"heavy":
			_draw_heavy(center, col)
		"scatter":
			_draw_scatter(center, col)
		"tidal":
			_draw_tidal(center, col)
		_:
			_draw_water_ring(center, 28.0, 3.0)

# ── Precision: Tight + crosshair with scanning center dot ─────────────────────
func _draw_precision(center: Vector2, col: Color) -> void:
	var gap = 6.0
	var arm = 16.0
	var thick = 1.5
	draw_line(center + Vector2(-arm - gap, 0), center + Vector2(-gap, 0), col, thick, true)
	draw_line(center + Vector2(gap, 0), center + Vector2(arm + gap, 0), col, thick, true)
	draw_line(center + Vector2(0, -arm - gap), center + Vector2(0, -gap), col, thick, true)
	draw_line(center + Vector2(0, gap), center + Vector2(0, arm + gap), col, thick, true)
	draw_circle(center, 2.0, col)
	_draw_water_ring(center, 22.0, 2.0)

# ── Heavy: Thick corner bracket corners ───────────────────────────────────────
func _draw_heavy(center: Vector2, col: Color) -> void:
	var r = 18.0
	var arm = 10.0
	var thick = 3.5
	draw_line(center + Vector2(-r - arm, -r), center + Vector2(-r, -r), col, thick, true)
	draw_line(center + Vector2(-r, -r), center + Vector2(-r, -r + arm), col, thick, true)
	draw_line(center + Vector2(r, -r), center + Vector2(r + arm, -r), col, thick, true)
	draw_line(center + Vector2(r, -r), center + Vector2(r, -r + arm), col, thick, true)
	draw_line(center + Vector2(-r - arm, r), center + Vector2(-r, r), col, thick, true)
	draw_line(center + Vector2(-r, r), center + Vector2(-r, r - arm), col, thick, true)
	draw_line(center + Vector2(r, r), center + Vector2(r + arm, r), col, thick, true)
	draw_line(center + Vector2(r, r), center + Vector2(r, r - arm), col, thick, true)
	_draw_water_ring(center, 34.0, 4.0)

# ── Scatter: 3 diverging spread lines ─────────────────────────────────────────
func _draw_scatter(center: Vector2, col: Color) -> void:
	var thick = 2.0
	for ang_deg in [-35.0, 0.0, 35.0]:
		var ang = deg_to_rad(ang_deg - 90.0)
		var s = center + Vector2(cos(ang), sin(ang)) * 10.0
		var e = center + Vector2(cos(ang), sin(ang)) * 28.0
		draw_line(s, e, col, thick, true)
	draw_line(center + Vector2(-6, 0), center + Vector2(6, 0), col, thick, true)
	_draw_water_ring(center, 36.0, 2.5)

# ── Tidal Gatling: Spinning dashed ring ───────────────────────────────────────
func _draw_tidal(center: Vector2, col: Color) -> void:
	var radius = 24.0
	var num_dashes = 8
	var dash_arc = deg_to_rad(22.0)
	var gap_arc  = (TAU / num_dashes) - dash_arc
	var offset   = deg_to_rad(_gatling_spin_angle)
	for i in range(num_dashes):
		var start_a = offset + i * (dash_arc + gap_arc)
		draw_arc(center, radius, start_a, start_a + dash_arc, 8, col, 3.0, true)
	var c_arm = 5.0
	draw_line(center + Vector2(-c_arm, 0), center + Vector2(c_arm, 0), col, 1.5, true)
	draw_line(center + Vector2(0, -c_arm), center + Vector2(0, c_arm), col, 1.5, true)
	_draw_water_ring(center, 32.0, 2.5)

