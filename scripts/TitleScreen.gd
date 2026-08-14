extends Control

@onready var color_rect = $ColorRect
@onready var title_lbl = $ColorRect/VBoxContainer/Title
@onready var title2_lbl = $ColorRect/VBoxContainer/Title2
@onready var subtitle_lbl = $ColorRect/VBoxContainer/Subtitle
@onready var normal_btn = $ColorRect/VBoxContainer/ButtonsBox/NormalBtn
@onready var survival_btn = $ColorRect/VBoxContainer/ButtonsBox/SurvivalBtn
@onready var dev_btn = $ColorRect/VBoxContainer/ButtonsBox/DevBtn
@onready var lang_btn = $LangBtn
@onready var lang_highlight = $LangBtn/ToggleHighlight
@onready var en_label = $LangBtn/Labels/ENLabel
@onready var kr_label = $LangBtn/Labels/KRLabel
@onready var high_score_lbl = $ColorRect/VBoxContainer/HighScoreLabel
@onready var credit_lbl = $CreditLine

signal start_game(is_survival: bool)

var is_starting: bool = false
var best_time_lbl: Label = null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_update_language()

	if lang_btn:
		lang_btn.pressed.connect(_on_lang_btn_pressed)

func _update_language() -> void:

	var is_kr = GameState.language == "KR"
	var font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/ui/fonts/Fonts/Kenney Future.ttf"
	var font = load(font_path)
	
	if title_lbl: title_lbl.text = "썸머" if is_kr else "SUMMER"
	if title2_lbl: title2_lbl.text = "나이츠" if is_kr else "NIGHTS"
	if subtitle_lbl: subtitle_lbl.text = "태양을 식혀라" if is_kr else "COOL DOWN THE SUN"
	if normal_btn: normal_btn.text = "일반 모드" if is_kr else "NORMAL MODE"
	if survival_btn: survival_btn.text = "무한 모드" if is_kr else "ENDLESS MODE"
	if dev_btn: dev_btn.text = "DEV"
	
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
		

		var en_font = load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
		if en_label:
			en_label.add_theme_font_override("font", en_font)
			en_label.add_theme_font_size_override("font_size", 18)
		if kr_label:
			kr_label.add_theme_font_override("font", en_font)
			kr_label.add_theme_font_size_override("font_size", 18)
		
		# Animate the language toggle
		if lang_highlight and en_label and kr_label:
			var tw = create_tween()
			tw.set_ease(Tween.EASE_OUT)
			tw.set_trans(Tween.TRANS_SINE)
			tw.set_parallel(true)
			
			if is_kr:
				tw.tween_property(lang_highlight, "position:x", 48.0, 0.25)
				tw.tween_property(en_label, "theme_override_colors/font_color", Color(1.0, 0.85, 0.2, 1.0), 0.25)
				tw.tween_property(kr_label, "theme_override_colors/font_color", Color(0.0, 0.0, 0.0, 1.0), 0.25)
			else:
				tw.tween_property(lang_highlight, "position:x", 0.0, 0.25)
				tw.tween_property(en_label, "theme_override_colors/font_color", Color(0.0, 0.0, 0.0, 1.0), 0.25)
				tw.tween_property(kr_label, "theme_override_colors/font_color", Color(1.0, 0.85, 0.2, 1.0), 0.25)
		
		# Best Time Display
		if GameState.best_survival_time > 0.0:
			if not best_time_lbl:
				best_time_lbl = Label.new()
				$ColorRect/VBoxContainer.add_child(best_time_lbl)
				$ColorRect/VBoxContainer.move_child(best_time_lbl, subtitle_lbl.get_index() + 1)
				
			var m = int(GameState.best_survival_time) / 60
			var s = int(GameState.best_survival_time) % 60
			best_time_lbl.text = "최고 기록: %02d:%02d" % [m, s] if is_kr else "BEST ENDLESS TIME: %02d:%02d" % [m, s]
			best_time_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_style_label(best_time_lbl, 16 if is_kr else 14, Color(0.4, 0.9, 0.4, 1.0), font)
			best_time_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
			best_time_lbl.add_theme_constant_override("outline_size", 4)
			
		# High Score Display
		if high_score_lbl:
			if GameState.high_score > 0:
				# Format with commas (e.g., 1,500)
				var score_str = str(GameState.high_score)
				var formatted_score = ""
				for i in range(score_str.length()):
					if i > 0 and i % 3 == 0:
						formatted_score = "," + formatted_score
					formatted_score = score_str[score_str.length() - 1 - i] + formatted_score
				
				high_score_lbl.text = "최고 점수: %s" % formatted_score if is_kr else "HIGH SCORE: %s" % formatted_score
				_style_label(high_score_lbl, 18 if is_kr else 16, Color(0.4, 0.9, 0.4, 1.0), font)
				high_score_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
				high_score_lbl.add_theme_constant_override("outline_size", 4)
			else:
				high_score_lbl.visible = false
			
		# Style buttons
		if normal_btn and survival_btn and dev_btn:
			for btn in [normal_btn, survival_btn, dev_btn, lang_btn]:
				if not btn: continue
				btn.add_theme_font_override("font", font)
				btn.add_theme_font_size_override("font_size", 20 if is_kr else 18)
				btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
				btn.add_theme_color_override("font_outline_color", Color.BLACK)
				btn.add_theme_constant_override("outline_size", 2)
				var style_normal = StyleBoxFlat.new()
				style_normal.bg_color = Color(0, 0, 0, 0.4)
				style_normal.border_color = Color(1.0, 0.85, 0.2, 0.6)
				style_normal.border_width_bottom = 2
				style_normal.border_width_top = 2
				style_normal.border_width_left = 2
				style_normal.border_width_right = 2
				style_normal.content_margin_left = 16
				style_normal.content_margin_right = 16
				style_normal.content_margin_top = 8
				style_normal.content_margin_bottom = 8
				btn.add_theme_stylebox_override("normal", style_normal)
				
				var style_hover = style_normal.duplicate()
				style_hover.bg_color = Color(1.0, 0.75, 0.15, 0.2)
				btn.add_theme_stylebox_override("hover", style_hover)
				
				var style_pressed = style_normal.duplicate()
				if btn == normal_btn:
					style_pressed.bg_color = Color(1.0, 0.8, 0.2, 0.4)
				elif btn == survival_btn:
					style_pressed.bg_color = Color(0.2, 0.8, 1.0, 0.4)
				elif btn == dev_btn:
					style_pressed.bg_color = Color(0.8, 0.2, 1.0, 0.4)
				elif btn == lang_btn:
					style_pressed.bg_color = Color(1.0, 1.0, 1.0, 0.4)
				btn.add_theme_stylebox_override("pressed", style_pressed)
				btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	color_rect.modulate.a = 0.0
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(color_rect, "modulate:a", 1.0, 0.5)

	# --- STARTUP ANIMATION PROTOTYPE ---
	var vbox = $ColorRect/VBoxContainer
	
	# Hide immediately to prevent flashing, but DO NOT touch position yet!
	# The layout engine needs a frame to compute anchored positions correctly.
	vbox.modulate.a = 0.0
	if lang_btn:
		lang_btn.modulate.a = 0.0
	if credit_lbl:
		credit_lbl.modulate.a = 0.0
		
	# Play the custom PS1 startup audio
	var startup_audio = AudioStreamPlayer.new()
	startup_audio.stream = load("res://assets/audio/sfx/ps1_startup.wav")
	# If the start is too quiet, you can skip ahead by changing 0.0 below:
	add_child(startup_audio)
	startup_audio.play(0.0)
	
	# Wait for drop (and for the UI layout to fully compute)
	await get_tree().create_timer(2.5).timeout
	
	# Now the anchors have resolved correctly, so we can grab the true Y positions
	var orig_vbox_y = vbox.position.y
	var orig_lang_y = lang_btn.position.y if lang_btn else 0
	var orig_credit_y = credit_lbl.position.y if credit_lbl else 0
	
	# Instantly drop them down by 50px
	vbox.position.y += 50
	if lang_btn: lang_btn.position.y += 50
	if credit_lbl: credit_lbl.position.y += 50
	
	# Slide-in Animation back to the original layout positions
	var slide_tw = create_tween()
	slide_tw.set_parallel(true)
	slide_tw.set_ease(Tween.EASE_OUT)
	slide_tw.set_trans(Tween.TRANS_BACK)
	
	slide_tw.tween_property(vbox, "position:y", orig_vbox_y, 0.8)
	slide_tw.tween_property(vbox, "modulate:a", 1.0, 0.6)
	
	# Smoothly fade the audio out over 3 seconds so it cuts cleanly
	slide_tw.tween_property(startup_audio, "volume_db", -80.0, 3.0)
	
	if lang_btn:
		slide_tw.tween_property(lang_btn, "position:y", orig_lang_y, 0.8)
		slide_tw.tween_property(lang_btn, "modulate:a", 1.0, 0.6)
	if credit_lbl:
		slide_tw.tween_property(credit_lbl, "position:y", orig_credit_y, 0.8)
		slide_tw.tween_property(credit_lbl, "modulate:a", 1.0, 0.6)
	# --- END STARTUP ANIMATION PROTOTYPE ---

	if normal_btn:
		normal_btn.pressed.connect(_on_normal_pressed)
	if survival_btn:
		survival_btn.pressed.connect(_on_survival_pressed)
	if dev_btn:
		dev_btn.pressed.connect(_on_dev_pressed)

func _style_label(lbl: Label, size: int, color: Color, font: Font) -> void:
	if not lbl: return
	if font:
		lbl.add_theme_font_override("font", font)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
	lbl.add_theme_constant_override("outline_size", 5)

func _on_normal_pressed() -> void:
	if is_starting: return
	_start_game(false)

func _on_survival_pressed() -> void:
	if is_starting: return
	_start_game(true)

func _on_dev_pressed() -> void:
	if is_starting: return
	_start_game(true, true)

func _start_game(is_survival: bool, is_dev: bool = false) -> void:
	is_starting = true
	GameState.reset()
	GameState.is_survival_mode = is_survival
	
	if is_dev:
		GameState.is_dev_mode = true
		GameState.current_wave = 11
		
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func(): start_game.emit(is_survival))

func _on_lang_btn_pressed() -> void:
	if is_starting: return
	
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/sfx/ui_tick.wav")
	audio.bus = "SFX"
	add_child(audio)
	audio.play()
	
	GameState.language = "KR" if GameState.language == "EN" else "EN"
	GameState.save_settings()
	_update_language()
