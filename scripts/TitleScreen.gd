extends Control

@onready var color_rect = $ColorRect
@onready var title_lbl = $ColorRect/VBoxContainer/Title
@onready var title2_lbl = $ColorRect/VBoxContainer/Title2
@onready var subtitle_lbl = $ColorRect/VBoxContainer/Subtitle
@onready var normal_btn = $ColorRect/VBoxContainer/ButtonsBox/NormalBtn
@onready var survival_btn = $ColorRect/VBoxContainer/ButtonsBox/SurvivalBtn
@onready var credit_lbl = $CreditLine

signal start_game(is_survival: bool)

var is_starting: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var is_kr = GameState.language == "KR"
	var font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/ui/fonts/Fonts/Kenney Future.ttf"
	var font = load(font_path)
	
	if title_lbl: title_lbl.text = "썸머" if is_kr else "SUMMER"
	if title2_lbl: title2_lbl.text = "나이츠" if is_kr else "NIGHTS"
	if subtitle_lbl: subtitle_lbl.text = "태양을 식혀라" if is_kr else "COOL DOWN THE SUN"
	if normal_btn: normal_btn.text = "일반 모드" if is_kr else "NORMAL MODE"
	if survival_btn: survival_btn.text = "무한 모드" if is_kr else "ENDLESS MODE"
	
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
		_style_label(credit_lbl, 14 if is_kr else 12, Color(1.0, 1.0, 1.0, 0.7), font)
		
		# Style buttons
		if normal_btn and survival_btn:
			for btn in [normal_btn, survival_btn]:
				btn.add_theme_font_override("font", font)
				btn.add_theme_font_size_override("font_size", 20 if is_kr else 18)
				btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
				btn.add_theme_color_override("font_outline_color", Color.BLACK)
				btn.add_theme_constant_override("outline_size", 2)
				var style_normal = StyleBoxFlat.new()
				style_normal.bg_color = Color(0, 0, 0, 0.4)
				style_normal.border_color = Color(1.0, 0.85, 0.2, 0.6)
				style_normal.set_border_width_all(1)
				style_normal.set_corner_radius_all(4)
				style_normal.content_margin_left = 24.0
				style_normal.content_margin_right = 24.0
				var style_hover = style_normal.duplicate()
				style_hover.bg_color = Color(1.0, 0.85, 0.2, 0.2)
				style_hover.border_color = Color(1.0, 0.85, 0.2, 1.0)
				btn.add_theme_stylebox_override("normal", style_normal)
				btn.add_theme_stylebox_override("hover", style_hover)
				btn.add_theme_stylebox_override("pressed", style_hover)
				btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	color_rect.modulate.a = 0.0
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(color_rect, "modulate:a", 1.0, 0.5)

	if normal_btn:
		normal_btn.pressed.connect(func(): _start_game(false))
	if survival_btn:
		survival_btn.pressed.connect(func(): _start_game(true))

func _style_label(lbl: Label, size: int, color: Color, font: Font) -> void:
	if not lbl: return
	if font:
		lbl.add_theme_font_override("font", font)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
	lbl.add_theme_constant_override("outline_size", 5)

func _start_game(is_survival: bool) -> void:
	if is_starting: return
	is_starting = true
	GameState.reset()
	GameState.is_survival_mode = is_survival
	start_game.emit(is_survival)
