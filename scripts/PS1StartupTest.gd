extends Node3D

@onready var env = $WorldEnvironment
@onready var dir_light = $DirectionalLight3D
@onready var sun_mesh = $Sun
@onready var flash_rect = $CanvasLayer/FlashRect
@onready var title_label = $CanvasLayer/TitleLabel
@onready var audio_player = $AudioStreamPlayer

var sun_mat : StandardMaterial3D

func _ready():
	# Initial Cold Boot State
	if sun_mesh.material_override:
		sun_mat = sun_mesh.material_override as StandardMaterial3D
		sun_mat.emission_enabled = true
		sun_mat.emission = Color.BLACK
	
	env.environment.background_energy_multiplier = 0.0
	env.environment.ambient_light_energy = 0.0
	dir_light.light_energy = 0.0
	
	flash_rect.color = Color.WHITE
	flash_rect.modulate.a = 0.0
	title_label.modulate.a = 0.0
	
	# Deep pitch shift for prototype drone sound
	audio_player.pitch_scale = 0.2
	audio_player.volume_db = 10.0
	
	# Choreograph Sequence
	await get_tree().create_timer(1.0).timeout
	audio_player.play()
	
	await get_tree().create_timer(3.0).timeout
	_the_drop()

func _the_drop():
	# The Drop (Instant snap to bright daylight)
	env.environment.background_energy_multiplier = 1.0
	env.environment.ambient_light_energy = 1.0
	dir_light.light_energy = 1.0
	
	if sun_mat:
		sun_mat.emission = Color(1.0, 0.7, 0.2)
		sun_mat.emission_energy_multiplier = 1.8
		
	# Instantly flash white and show text
	flash_rect.modulate.a = 1.0
	title_label.modulate.a = 1.0
	
	# The Fade
	var tw = create_tween()
	tw.tween_property(flash_rect, "modulate:a", 0.0, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
