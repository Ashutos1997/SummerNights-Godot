extends Node2D

# ── State ──────────────────────────────────────────────────────────────────
var temperature: float = 100.0
var max_temperature: float = 100.0
var is_game_over: bool = false

# ── Sky gradient colors ────────────────────────────────────────────────────
# Each entry: [temperature_threshold, sky_top_color, sky_bottom_color]
const SKY_STOPS = [
	[100, Color(0.9, 0.16, 0.05),  Color(1.0, 0.75, 0.2)],   # scorching red/orange
	[75,  Color(1.0, 0.4,  0.0),   Color(1.0, 0.82, 0.31)],   # orange
	[50,  Color(1.0, 0.7,  0.0),   Color(1.0, 0.93, 0.5)],    # yellow
	[25,  Color(0.4, 0.75, 0.95),  Color(0.75, 0.94, 1.0)],   # light blue
	[0,   Color(0.1, 0.55, 0.85),  Color(0.5, 0.87, 1.0)],    # cool blue
]

# ── Node refs ──────────────────────────────────────────────────────────────
@onready var background: ColorRect = $Background
@onready var sun: Node2D = $Sun
@onready var gun: Node2D = $WaterGun
@onready var temp_bar: TextureProgressBar = $UI/TempBar
@onready var title_label: Label = $UI/TitleLabel
@onready var water_blast_pool: Node2D = $WaterBlasts
@onready var heat_shimmer: ColorRect = $HeatShimmer

# Preload the WaterBlast scene
var WaterBlast = preload("res://scenes/WaterBlast.tscn")

func _ready() -> void:
	_update_environment()

func _process(delta: float) -> void:
	if is_game_over:
		return

	# Animate heat shimmer opacity
	var shimmer_alpha = (temperature / max_temperature) * 0.25
	heat_shimmer.color = Color(1, 0.8, 0.4, shimmer_alpha)

func _input(event: InputEvent) -> void:
	if is_game_over:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_shoot(event.position)

func _shoot(target_pos: Vector2) -> void:
	var blast = WaterBlast.instantiate()
	water_blast_pool.add_child(blast)
	# Gun barrel offset — tip of the rifle
	var barrel_pos = gun.global_position + Vector2(0, -60).rotated(gun.rotation)
	blast.launch(barrel_pos, target_pos)
	blast.hit_sun.connect(_on_blast_hit_sun)
	# Trigger recoil
	gun.fire_recoil()

func _on_blast_hit_sun() -> void:
	if temperature <= 0:
		return

	temperature = max(0.0, temperature - 5.0)
	_update_environment()

	# Trigger visual hit on the sun
	$Sun.get_hit()

	# Camera shake
	var tween = create_tween()
	tween.tween_property($Camera2D, "offset", Vector2(8, 5), 0.05)
	tween.tween_property($Camera2D, "offset", Vector2(-6, -4), 0.05)
	tween.tween_property($Camera2D, "offset", Vector2(4, -3), 0.05)
	tween.tween_property($Camera2D, "offset", Vector2.ZERO, 0.05)

	if temperature <= 0:
		_trigger_win()

func _update_environment() -> void:
	# Update temperature bar
	temp_bar.value = temperature / max_temperature * 100.0

	# Update bar color
	if temperature > 50:
		temp_bar.tint_progress = Color(0.95, 0.25, 0.1)
	else:
		temp_bar.tint_progress = Color(0.1, 0.65, 0.95)

	# Find the right sky color stop
	var top_color: Color = SKY_STOPS[0][1]
	var bot_color: Color = SKY_STOPS[0][2]
	for stop in SKY_STOPS:
		if temperature <= stop[0]:
			top_color = stop[1]
			bot_color = stop[2]

	# Tween the background gradient
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(background, "material:shader_parameter/top_color", top_color, 0.5)
	tween.tween_property(background, "material:shader_parameter/bottom_color", bot_color, 0.5)

func _trigger_win() -> void:
	is_game_over = true
	title_label.text = "SUN COOLED DOWN! 🌊"
	title_label.add_theme_color_override("font_color", Color(0.2, 0.8, 1.0))
	# Freeze + tint the sun
	$Sun.set_cooled()
