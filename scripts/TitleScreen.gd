extends Control

@onready var color_rect = $ColorRect
@onready var title_lbl = $ColorRect/VBoxContainer/Title
@onready var title2_lbl = $ColorRect/VBoxContainer/Title2
@onready var subtitle_lbl = $ColorRect/VBoxContainer/Subtitle
@onready var prompt_lbl = $ColorRect/VBoxContainer/Prompt
@onready var credit_lbl = $CreditLine

signal start_game

var is_starting: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var is_kr = GameState.language == "KR"
	var font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/ui/fonts/Fonts/Kenney Future.ttf"
	var font = load(font_path)
	
	if title_lbl: title_lbl.text = "썸머" if is_kr else "SUMMER"
	if title2_lbl: title2_lbl.text = "나이츠" if is_kr else "NIGHTS"
	if subtitle_lbl: subtitle_lbl.text = "태양을 식혀라" if is_kr else "COOL DOWN THE SUN"
	if prompt_lbl: prompt_lbl.text = "클릭 또는 스페이스바로 시작" if is_kr else "PRESS SPACE OR CLICK TO START"
	
	if font:
		var title_color = Color(1.0, 0.75, 0.15, 1.0)
		_style_label(title_lbl, 72, title_color, font)
		_style_label(title2_lbl, 72, title_color, font)
		
		# Add title shadow overrides — applied identically for EN and KR
		for lbl in [title_lbl, title2_lbl]:
			if lbl:
				lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
				lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
				lbl.add_theme_constant_override("shadow_offset_x", 4)
				lbl.add_theme_constant_override("shadow_offset_y", 4)
				lbl.add_theme_constant_override("shadow_outline_size", 12)
				lbl.add_theme_constant_override("outline_size", 8)
				
		_style_label(subtitle_lbl, 20 if is_kr else 18, Color(1.0, 0.75, 0.15, 1.0), font)
		# Subtitle also gets a subtle outline for legibility against the 3D background
		if subtitle_lbl:
			subtitle_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
			subtitle_lbl.add_theme_constant_override("outline_size", 4)
		_style_label(prompt_lbl, 16 if is_kr else 14, Color(1.0, 1.0, 1.0, 1.0), font)
		if prompt_lbl:
			prompt_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
			prompt_lbl.add_theme_constant_override("outline_size", 3)
		_style_label(credit_lbl, 14 if is_kr else 12, Color(1.0, 1.0, 1.0, 0.7), font)

	color_rect.modulate.a = 0.0
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(color_rect, "modulate:a", 1.0, 0.5)

	# Pulse animation on prompt label — respects Reduce Motion setting (WCAG 2.2.2)
	var reduce_motion = GameState.reduce_motion
	if prompt_lbl and not reduce_motion:
		var pulse_tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		pulse_tw.tween_property(prompt_lbl, "modulate:a", 0.7, 1.2)
		pulse_tw.tween_property(prompt_lbl, "modulate:a", 1.0, 1.2)
	elif prompt_lbl:
		prompt_lbl.modulate.a = 1.0

func _style_label(lbl: Label, size: int, color: Color, font: Font) -> void:
	if not lbl: return
	if font:
		lbl.add_theme_font_override("font", font)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
	lbl.add_theme_constant_override("outline_size", 5)

func _input(event: InputEvent) -> void:
	if is_starting: return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			_start_game()
	elif event is InputEventMouseButton and event.pressed:
		_start_game()

func _start_game() -> void:
	if is_starting: return
	is_starting = true
	GameState.reset()
	start_game.emit()
