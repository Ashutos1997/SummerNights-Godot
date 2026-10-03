extends Control

@onready var color_rect = $ColorRect
@onready var title_lbl = $ColorRect/HBoxContainer/LeftColumn/Title
@onready var title2_lbl = $ColorRect/HBoxContainer/LeftColumn/Title2
@onready var subtitle_lbl = $ColorRect/HBoxContainer/LeftColumn/Subtitle
@onready var normal_btn = $ColorRect/HBoxContainer/RightColumn/ButtonsBox/NormalBtn
@onready var survival_btn = $ColorRect/HBoxContainer/RightColumn/ButtonsBox/SurvivalBtn
@onready var dev_btn = $ColorRect/HBoxContainer/RightColumn/ButtonsBox/DevBtn
@onready var lang_btn = $LangBtn
@onready var lang_highlight = $LangBtn/ToggleHighlight
@onready var en_label = $LangBtn/Labels/ENLabel
@onready var kr_label = $LangBtn/Labels/KRLabel
@onready var high_score_lbl = $ColorRect/HBoxContainer/LeftColumn/HighScoreLabel
@onready var credit_lbl = $CreditLine
@onready var splash_container = get_node_or_null("SplashContainer")
@onready var splash_center = get_node_or_null("SplashContainer/SplashCenter")
@onready var splash_border_drawer = get_node_or_null("SplashContainer/SplashBorderDrawer")
@onready var radial_glow = get_node_or_null("SplashContainer/RadialGlow")
@onready var made_with_lbl = get_node_or_null("SplashContainer/SplashCenter/MadeWithRow/MadeWithLabel") if has_node("SplashContainer/SplashCenter/MadeWithRow/MadeWithLabel") else get_node_or_null("SplashContainer/SplashCenter/MadeWithLabel")
@onready var godot_logo = get_node_or_null("SplashContainer/SplashCenter/GodotLogo")

signal start_game(is_survival: bool)
signal show_achievements()

var is_starting: bool = false
var is_splash_active: bool = false
var splash_tween: Tween = null
var splash_logo_tween: Tween = null
var startup_audio: AudioStreamPlayer = null
var orig_vbox_y: float = 0.0
var orig_lang_y: float = 0.0
var orig_credit_y: float = 0.0
var best_time_lbl: Label = null
var ach_btn: Button
var stats_btn: Button
var settings_btn: Button
var mode_divider: CenterContainer = null
var quit_prompt_btn: Button = null

var achievements_screen: Control
var stats_screen: Control
var settings_screen: Control
var quit_popup: Control
var achievement_list: VBoxContainer

var setting_sfx_slider: HSlider
var setting_sfx_val_lbl: Label
var setting_sens_slider: HSlider
var setting_sens_val_lbl: Label
var setting_motion_check: Button
var setting_vibration_check: Button
var setting_fullscreen_check: Button
var setting_gold_skin_check: Button
var setting_gold_skin_row: HBoxContainer
var setting_lang_btn_en: Button
var setting_lang_btn_kr: Button
var settings_title_lbl: Label
var settings_prompt_lbl: Label
var achievements_prompt_lbl: Label
var stats_prompt_lbl: Label
var settings_back_btn: Button
var setting_cat_audio_lbl: Label
var setting_cat_gameplay_lbl: Label
var setting_cat_system_lbl: Label
var setting_row_labels: Dictionary = {}
var border_progress: float = -1.0:
	set(value):
		border_progress = value
		if splash_border_drawer and is_instance_valid(splash_border_drawer):
			splash_border_drawer.queue_redraw()
		queue_redraw()

func generate_rounded_rect_points(rect: Rect2, radius: float, resolution: int = 8) -> PackedVector2Array:
	var pts = PackedVector2Array()
	# Top-Left corner
	for i in range(resolution + 1):
		var angle = PI + (PI / 2.0) * (float(i) / resolution)
		pts.append(Vector2(rect.position.x + radius + cos(angle) * radius, rect.position.y + radius + sin(angle) * radius))
	# Top-Right corner
	for i in range(resolution + 1):
		var angle = PI * 1.5 + (PI / 2.0) * (float(i) / resolution)
		pts.append(Vector2(rect.position.x + rect.size.x - radius + cos(angle) * radius, rect.position.y + radius + sin(angle) * radius))
	# Bottom-Right corner
	for i in range(resolution + 1):
		var angle = 0.0 + (PI / 2.0) * (float(i) / resolution)
		pts.append(Vector2(rect.position.x + rect.size.x - radius + cos(angle) * radius, rect.position.y + rect.size.y - radius + sin(angle) * radius))
	# Bottom-Left corner
	for i in range(resolution + 1):
		var angle = PI / 2.0 + (PI / 2.0) * (float(i) / resolution)
		pts.append(Vector2(rect.position.x + radius + cos(angle) * radius, rect.position.y + rect.size.y - radius + sin(angle) * radius))
	
	pts.append(pts[0]) # Close loop
	return pts

func _draw() -> void:
	if border_progress >= 0.0 and border_progress < 1.0:
		var rect = Rect2(24, 24, size.x - 48, size.y - 48)
		# Match the HUD's border thickness (2.0) and corner radius (8.0)
		var pts = generate_rounded_rect_points(rect, 8.0, 8)
		
		var total_len = 0.0
		var segment_lens = []
		for i in range(pts.size() - 1):
			var dist = pts[i].distance_to(pts[i+1])
			segment_lens.append(dist)
			total_len += dist
			
		var draw_len = total_len * border_progress
		var draw_pts = PackedVector2Array()
		draw_pts.append(pts[0])
		
		var current_len = 0.0
		for i in range(pts.size() - 1):
			if current_len + segment_lens[i] <= draw_len:
				draw_pts.append(pts[i+1])
				current_len += segment_lens[i]
			else:
				var remain = draw_len - current_len
				var dir = (pts[i+1] - pts[i]).normalized()
				draw_pts.append(pts[i] + dir * remain)
				break
				
		if draw_pts.size() >= 2:
			# Match exact color and thickness of SubResource("StyleBoxFlat_border")
			draw_polyline(draw_pts, Color(1.0, 0.85, 0.2, 0.4), 2.0, true)

func _on_splash_border_draw() -> void:
	if border_progress >= 0.0 and border_progress <= 1.0 and splash_border_drawer:
		var rect = Rect2(24, 24, size.x - 48, size.y - 48)
		var pts = generate_rounded_rect_points(rect, 8.0, 8)
		
		var total_len = 0.0
		var segment_lens = []
		for i in range(pts.size() - 1):
			var dist = pts[i].distance_to(pts[i+1])
			segment_lens.append(dist)
			total_len += dist
			
		var draw_len = total_len * border_progress
		var draw_pts = PackedVector2Array()
		draw_pts.append(pts[0])
		
		var current_len = 0.0
		for i in range(pts.size() - 1):
			if current_len + segment_lens[i] <= draw_len:
				draw_pts.append(pts[i+1])
				current_len += segment_lens[i]
			else:
				var remain = draw_len - current_len
				var dir = (pts[i+1] - pts[i]).normalized()
				draw_pts.append(pts[i] + dir * remain)
				break
				
		if draw_pts.size() >= 2:
			splash_border_drawer.draw_polyline(draw_pts, Color(1.0, 0.85, 0.2, 0.4), 2.0, true)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if splash_border_drawer:
		splash_border_drawer.draw.connect(_on_splash_border_draw)

	if lang_btn:
		lang_btn.pressed.connect(_on_lang_btn_pressed)
		
	if dev_btn: dev_btn.visible = false
	
	# Add subtle hairline divider between Game Modes and Meta Menus
	mode_divider = CenterContainer.new()
	mode_divider.name = "ModeDivider"
	mode_divider.custom_minimum_size = Vector2(240, 1)
	var div_line = ColorRect.new()
	div_line.custom_minimum_size = Vector2(60, 1)
	div_line.color = Color(1.0, 0.75, 0.15, 0.25)
	mode_divider.add_child(div_line)
	dev_btn.get_parent().add_child(mode_divider)
	
	# Dynamically add Achievements button
	ach_btn = dev_btn.duplicate()
	ach_btn.name = "AchievementsBtn"
	ach_btn.custom_minimum_size = Vector2(240, 44)
	ach_btn.visible = true
	dev_btn.get_parent().add_child(ach_btn)
	ach_btn.pressed.connect(_show_achievements)
	
	# Dynamically add Stats button
	stats_btn = dev_btn.duplicate()
	stats_btn.name = "StatsBtn"
	stats_btn.custom_minimum_size = Vector2(240, 44)
	stats_btn.visible = true
	dev_btn.get_parent().add_child(stats_btn)
	stats_btn.pressed.connect(_show_stats)
	
	# Dynamically add Settings button
	settings_btn = dev_btn.duplicate()
	settings_btn.name = "SettingsBtn"
	settings_btn.custom_minimum_size = Vector2(240, 44)
	settings_btn.visible = true
	dev_btn.get_parent().add_child(settings_btn)
	settings_btn.pressed.connect(_show_settings)
	
	# Desktop ESC Quit guidance prompt
	quit_prompt_btn = Button.new()
	quit_prompt_btn.name = "QuitPromptBtn"
	quit_prompt_btn.flat = true
	quit_prompt_btn.focus_mode = Control.FOCUS_NONE
	quit_prompt_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	dev_btn.get_parent().add_child(quit_prompt_btn)
	quit_prompt_btn.pressed.connect(_show_quit_popup)
	
	_build_achievements_screen()
	_build_stats_screen()
	_build_settings_screen()
	_build_quit_popup()
	_update_language()

func _update_language() -> void:
	_apply_settings_language()

	var is_kr = GameState.language == "KR"
	var font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/ui/fonts/Fonts/Kenney Future.ttf"
	var font = load(font_path)
	
	if title_lbl: title_lbl.text = "썸머" if is_kr else "SUMMER"
	if title2_lbl: title2_lbl.text = "나이츠" if is_kr else "NIGHTS"
	if subtitle_lbl: subtitle_lbl.text = "태양을 식혀라" if is_kr else "COOL DOWN THE SUN"
	if normal_btn: normal_btn.text = "일반 모드" if is_kr else "NORMAL MODE"
	if survival_btn:
		var has_dawn_breaks = "dawn_breaks" in GameState.unlocked_achievements
		survival_btn.disabled = not has_dawn_breaks
		if not has_dawn_breaks:
			survival_btn.text = "무한 모드 [잠김]" if is_kr else "ENDLESS MODE [LOCKED]"
		else:
			survival_btn.text = "무한 모드" if is_kr else "ENDLESS MODE"
	if dev_btn: dev_btn.text = "DEV"
	if ach_btn: ach_btn.text = "업적" if is_kr else "ACHIEVEMENTS"
	if stats_btn: stats_btn.text = "기록" if is_kr else "STATS"
	if settings_btn: settings_btn.text = "설정" if is_kr else "SETTINGS"
	if quit_prompt_btn: quit_prompt_btn.text = "[ESC] 게임 종료" if is_kr else "[ESC] QUIT GAME"
	
	if font:
		var title_color = Color(1.0, 0.75, 0.15, 1.0)
		var title_size = 78 if is_kr else 64
		_style_label(title_lbl, title_size, title_color, font)
		_style_label(title2_lbl, title_size, title_color, font)
		
		# Add title shadow overrides — applied identically for EN and KR
		for lbl in [title_lbl, title2_lbl]:
			if lbl:
				lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
				lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
				lbl.add_theme_constant_override("shadow_offset_x", 4)
				lbl.add_theme_constant_override("shadow_offset_y", 4)
				lbl.add_theme_constant_override("shadow_outline_size", 12)
				lbl.add_theme_constant_override("outline_size", 8)
				lbl.add_theme_constant_override("letter_spacing", 4 if is_kr else 0)
				lbl.scale = Vector2.ONE
				lbl.modulate = Color.WHITE
				
		_style_label(subtitle_lbl, 20 if is_kr else 18, Color(1.0, 0.75, 0.15, 1.0), font)
		# Subtitle also gets a subtle outline for legibility against the 3D background
		if subtitle_lbl:
			subtitle_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
			subtitle_lbl.add_theme_constant_override("outline_size", 4)
		if credit_lbl:
			credit_lbl.text = "SUMMER NIGHTS v1.7 · GODOT 4 · GDSCRIPT · FORWARD+"
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
		
		# Best Time & Wave Display
		var left_col = $ColorRect/HBoxContainer/LeftColumn
		var spacer_stats = left_col.get_node_or_null("SpacerStats")
		var has_stats = (GameState.high_score > 0) or (GameState.best_survival_time > 0.0 or GameState.best_wave > 0)
		if spacer_stats:
			spacer_stats.visible = has_stats
			
		if GameState.best_survival_time > 0.0 or GameState.best_wave > 0:
			if not best_time_lbl:
				best_time_lbl = Label.new()
				left_col.add_child(best_time_lbl)
				var insert_pos = (spacer_stats.get_index() + 1) if spacer_stats else (subtitle_lbl.get_index() + 1)
				left_col.move_child(best_time_lbl, insert_pos)
				
			var m = int(GameState.best_survival_time) / 60
			var s = int(GameState.best_survival_time) % 60
			var time_str = "%02d:%02d" % [m, s]
			if GameState.best_wave > 0 and GameState.best_survival_time > 0.0:
				best_time_lbl.text = "최고 기록: %d 웨이브 (%s)" % [GameState.best_wave, time_str] if is_kr else "BEST ENDLESS: WAVE %d (%s)" % [GameState.best_wave, time_str]
			elif GameState.best_wave > 0:
				best_time_lbl.text = "최고 웨이브: %d" % GameState.best_wave if is_kr else "BEST ENDLESS: WAVE %d" % GameState.best_wave
			else:
				best_time_lbl.text = "최고 기록: %s" % time_str if is_kr else "BEST ENDLESS TIME: %s" % time_str
			best_time_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			_style_label(best_time_lbl, 16 if is_kr else 14, Color(0.4, 0.9, 0.4, 1.0), font)
			best_time_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
			best_time_lbl.add_theme_constant_override("outline_size", 4)
			# Breathing room above best time line
			var best_time_style = StyleBoxEmpty.new()
			best_time_style.content_margin_top = 2
			best_time_lbl.add_theme_stylebox_override("normal", best_time_style)
			
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
				_style_label(high_score_lbl, 16 if is_kr else 14, Color(1.0, 0.85, 0.2, 1.0), font)
				high_score_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
				high_score_lbl.add_theme_constant_override("outline_size", 4)
				# Breathing room above high score line
				var hs_style = StyleBoxEmpty.new()
				hs_style.content_margin_top = 2
				high_score_lbl.add_theme_stylebox_override("normal", hs_style)
			else:
				high_score_lbl.visible = false
			
		# Style buttons
		if normal_btn and survival_btn and dev_btn:
			for btn in [normal_btn, survival_btn, dev_btn, lang_btn, ach_btn, stats_btn, settings_btn]:
				if not btn: continue
				if btn != lang_btn and btn != dev_btn:
					btn.custom_minimum_size = Vector2(240, 44)
				btn.add_theme_font_override("font", font)
				btn.add_theme_font_size_override("font_size", 20 if is_kr else 18)
				btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
				btn.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.2, 1.0))
				btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.85, 0.2, 1.0))
				btn.add_theme_color_override("font_focus_color", Color(1.0, 0.85, 0.2, 1.0))
				btn.add_theme_color_override("font_disabled_color", Color(0.55, 0.55, 0.55, 0.6))
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
				style_hover.border_color = Color(1.0, 0.9, 0.3, 1.0)
				btn.add_theme_stylebox_override("hover", style_hover)
				
				var style_pressed = style_normal.duplicate()
				style_pressed.bg_color = Color(1.0, 0.85, 0.2, 0.4)
				style_pressed.border_color = Color(1.0, 0.9, 0.3, 1.0)
				btn.add_theme_stylebox_override("pressed", style_pressed)
				
				var style_disabled = style_normal.duplicate()
				style_disabled.bg_color = Color(0, 0, 0, 0.25)
				style_disabled.border_color = Color(0.4, 0.4, 0.4, 0.35)
				btn.add_theme_stylebox_override("disabled", style_disabled)
				
				btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
				
			# Style quit prompt guidance button
			if quit_prompt_btn:
				quit_prompt_btn.add_theme_font_override("font", font)
				quit_prompt_btn.add_theme_font_size_override("font_size", 13 if is_kr else 12)
				quit_prompt_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 0.55))
				quit_prompt_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.9, 0.3, 0.95))
				quit_prompt_btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))
				quit_prompt_btn.add_theme_color_override("font_outline_color", Color.BLACK)
				quit_prompt_btn.add_theme_constant_override("outline_size", 2)
				
				var empty_style = StyleBoxEmpty.new()
				empty_style.content_margin_top = 4
				empty_style.content_margin_bottom = 2
				quit_prompt_btn.add_theme_stylebox_override("normal", empty_style)
				quit_prompt_btn.add_theme_stylebox_override("hover", empty_style)
				quit_prompt_btn.add_theme_stylebox_override("pressed", empty_style)
				quit_prompt_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	color_rect.modulate.a = 0.0
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(color_rect, "modulate:a", 1.0, 0.5)

	# --- STARTUP ANIMATION / MADE WITH GODOT SPLASH ---
	var vbox = $ColorRect/HBoxContainer
	
	if not GameState.has_shown_splash:
		GameState.has_shown_splash = true
		is_splash_active = true
		
		# Hide menu content immediately to prevent flashing while anchors resolve
		vbox.modulate.a = 0.0
		if lang_btn: lang_btn.modulate.a = 0.0
		if credit_lbl: credit_lbl.modulate.a = 0.0
		$BorderPanel.visible = false
		
		# Style splash elements with clean design system rules
		if made_with_lbl:
			var title_font_size = 32 if is_kr else 36
			_style_label(made_with_lbl, title_font_size, Color(1.0, 0.85, 0.2, 0.95), font)
			made_with_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
			made_with_lbl.add_theme_constant_override("shadow_offset_x", 2)
			made_with_lbl.add_theme_constant_override("shadow_offset_y", 2)
			made_with_lbl.add_theme_constant_override("outline_size", 4)
			made_with_lbl.text = "제 작   엔 진" if is_kr else "M A D E   W I T H"
		
		if splash_container:
			splash_container.visible = true
			splash_container.modulate.a = 1.0
			
		if radial_glow:
			radial_glow.modulate.a = 0.0
			radial_glow.scale = Vector2(0.92, 0.92)
			
		if splash_center:
			splash_center.modulate.a = 0.0
			splash_center.scale = Vector2(0.96, 0.96)
			splash_center.pivot_offset = Vector2(250, 120)
		
		# Play the custom PS1 startup audio
		startup_audio = AudioStreamPlayer.new()
		startup_audio.stream = load("res://assets/audio/sfx/ps1_startup.wav")
		startup_audio.bus = "SFX"
		add_child(startup_audio)
		startup_audio.play(1.5)
		
		# Start drawing the golden border around the screen with smooth quad deceleration
		border_progress = 0.0
		splash_tween = create_tween()
		splash_tween.tween_property(self, "border_progress", 1.0, 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		# Smoothly fade in and scale up the Godot logo and subtle ambient glow
		splash_logo_tween = create_tween().set_parallel(true)
		if radial_glow:
			splash_logo_tween.tween_property(radial_glow, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			splash_logo_tween.tween_property(radial_glow, "scale", Vector2(1.05, 1.05), 2.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		if splash_center:
			splash_logo_tween.tween_property(splash_center, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			splash_logo_tween.tween_property(splash_center, "scale", Vector2(1.015, 1.015), 2.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		# Allow the layout engine one frame to compute true anchored positions for menu elements
		await get_tree().process_frame
		if not is_splash_active:
			return
		orig_vbox_y = vbox.position.y
		orig_lang_y = lang_btn.position.y if lang_btn else 0.0
		orig_credit_y = credit_lbl.position.y if credit_lbl else 0.0
		
		# Hold Godot logo until 2.1s, then smoothly fade out logo & glow with soft sine ease into dark void
		var logo_fade_tw = create_tween().set_parallel(true)
		if splash_center:
			logo_fade_tw.tween_property(splash_center, "modulate:a", 0.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(2.1)
		if radial_glow:
			logo_fade_tw.tween_property(radial_glow, "modulate:a", 0.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(2.1)
		
		# When border progress hits 1.0 at 3.0s, seamlessly transition to title screen
		splash_tween.tween_callback(func():
			_finish_splash_and_reveal_menu(vbox)
		)
	else:
		# Return-to-title flow: immediately reveal without splash
		if splash_container:
			splash_container.visible = false
		border_progress = -1.0
		$BorderPanel.visible = true
		vbox.modulate.a = 1.0
		if lang_btn: lang_btn.modulate.a = 1.0
		if credit_lbl: credit_lbl.modulate.a = 1.0
	# --- END STARTUP ANIMATION / MADE WITH GODOT SPLASH ---

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
	if is_survival and GameState.best_wave < 1:
		GameState.best_wave = 1
		GameState.save_settings()
	
	if is_dev:
		GameState.is_dev_mode = true
		GameState.current_wave = 11
		
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func(): start_game.emit(is_survival))

func _on_lang_btn_pressed() -> void:
	if is_starting: return
	
	UIJuice.play_tick()
	
	GameState.language = "KR" if GameState.language == "EN" else "EN"
	GameState.save_settings()
	get_tree().reload_current_scene()

func _build_achievements_screen() -> void:
	achievements_screen = Control.new()
	achievements_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	achievements_screen.visible = false
	achievements_screen.z_index = 50 # ensure it draws over everything
	add_child(achievements_screen)
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.96)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	achievements_screen.add_child(bg)
	
	var border = Panel.new()
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	border.offset_left = 24
	border.offset_top = 24
	border.offset_right = -24
	border.offset_bottom = -24
	
	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color(0, 0, 0, 0)
	border_style.border_width_left = 2
	border_style.border_width_top = 2
	border_style.border_width_right = 2
	border_style.border_width_bottom = 2
	border_style.border_color = Color(1.0, 0.85, 0.2, 0.4)
	border_style.corner_radius_top_left = 8
	border_style.corner_radius_top_right = 8
	border_style.corner_radius_bottom_left = 8
	border_style.corner_radius_bottom_right = 8
	border.add_theme_stylebox_override("panel", border_style)
	achievements_screen.add_child(border)
	
	var center = CenterContainer.new()
	center.name = "CenterContainer"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	achievements_screen.add_child(center)
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)
	
	var title_row = HBoxContainer.new()
	title_row.name = "TitleRow"
	title_row.add_theme_constant_override("separation", 12)
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(title_row)
	
	var title_icon = TextureRect.new()
	title_icon.name = "TitleIcon"
	title_icon.custom_minimum_size = Vector2(40, 40)
	title_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_icon.texture = load("res://assets/ui/menu_icons/achievements.png")
	title_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_icon.modulate = Color(1.0, 0.85, 0.2, 1.0)
	title_row.add_child(title_icon)
	
	var title = Label.new()
	title.name = "Title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_row.add_child(title)
	
	var divider = HSeparator.new()
	divider.name = "Divider"
	var div_style = StyleBoxLine.new()
	div_style.color = Color(1.0, 0.88, 0.3, 0.35)
	div_style.grow_begin = 0
	div_style.grow_end = 0
	div_style.thickness = 2
	div_style.content_margin_top = 0
	div_style.content_margin_bottom = 0
	divider.add_theme_stylebox_override("separator", div_style)
	vbox.add_child(divider)
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(700, 380)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	vbox.add_child(scroll)
	
	var list_margin = MarginContainer.new()
	list_margin.add_theme_constant_override("margin_right", 16)
	scroll.add_child(list_margin)
	
	achievement_list = VBoxContainer.new()
	achievement_list.add_theme_constant_override("separation", 16)
	list_margin.add_child(achievement_list)
	
	var divider2 = HSeparator.new()
	divider2.name = "Divider2"
	var div2_style = StyleBoxLine.new()
	div2_style.color = Color(1.0, 0.88, 0.3, 0.35)
	div2_style.grow_begin = 0
	div2_style.grow_end = 0
	div2_style.thickness = 2
	div2_style.content_margin_top = 0
	div2_style.content_margin_bottom = 0
	divider2.add_theme_stylebox_override("separator", div2_style)
	vbox.add_child(divider2)
	
	var back_btn = Button.new()
	back_btn.name = "BackBtn"
	back_btn.text = "BACK"
	back_btn.custom_minimum_size = Vector2(280, 44)
	
	var btn_center = CenterContainer.new()
	btn_center.name = "CenterContainer"
	btn_center.add_child(back_btn)
	vbox.add_child(btn_center)
	
	achievements_prompt_lbl = Label.new()
	achievements_prompt_lbl.name = "ClosePrompt"
	achievements_prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	achievements_prompt_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	achievements_prompt_lbl.text = "PRESS ESC TO CLOSE"
	_style_label(achievements_prompt_lbl, 14, Color(1.0, 0.88, 0.3, 0.85), null)
	achievements_prompt_lbl.add_theme_constant_override("outline_size", 1)
	achievements_prompt_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	if not GameState.reduce_motion:
		var sp_tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		sp_tw.tween_property(achievements_prompt_lbl, "modulate:a", 0.7, 1.2)
		sp_tw.tween_property(achievements_prompt_lbl, "modulate:a", 1.0, 1.2)
	vbox.add_child(achievements_prompt_lbl)
	
	back_btn.pressed.connect(_hide_achievements)

func _show_achievements() -> void:
	if is_starting or not achievements_screen: return
	
	for child in achievement_list.get_children():
		child.queue_free()
		
	var is_kr = GameState.language == "KR"
	var font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/ui/fonts/Fonts/Kenney Future.ttf"
	var body_font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/fonts/Inter-Medium.ttf"
	var font = load(font_path)
	var body_font = load(body_font_path)
	
	var title = achievements_screen.get_node("CenterContainer/VBoxContainer/TitleRow/Title")
	title.text = "업적" if is_kr else "ACHIEVEMENTS"
	_style_label(title, 32, Color(1.0, 0.85, 0.2, 1.0), font)
	title.add_theme_constant_override("outline_size", 4)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	
	var title_icon = achievements_screen.get_node_or_null("CenterContainer/VBoxContainer/TitleRow/TitleIcon")
	if title_icon:
		var icon_style = StyleBoxFlat.new()
		icon_style.bg_color = Color(0, 0, 0, 0)
		icon_style.border_color = Color(1.0, 0.85, 0.2, 0.4)
		icon_style.set_border_width_all(2)
		title_icon.add_theme_stylebox_override("panel", icon_style)
	
	var back_btn = achievements_screen.get_node("CenterContainer/VBoxContainer/CenterContainer/BackBtn")
	back_btn.text = "돌아가기" if is_kr else "BACK"
	if font: back_btn.add_theme_font_override("font", font)
	if achievements_prompt_lbl:
		achievements_prompt_lbl.text = "닫으려면 ESC를 누르세요" if is_kr else "PRESS ESC TO CLOSE"
		if font: achievements_prompt_lbl.add_theme_font_override("font", font)
		achievements_prompt_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 0.85))
		achievements_prompt_lbl.add_theme_constant_override("outline_size", 1)
		achievements_prompt_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	back_btn.add_theme_font_size_override("font_size", 22)
	back_btn.add_theme_constant_override("letter_spacing", 1)
	back_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	back_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.2, 1.0))
	back_btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.85, 0.2, 1.0))
	back_btn.add_theme_color_override("font_focus_color", Color(1.0, 0.85, 0.2, 1.0))
	back_btn.add_theme_color_override("font_disabled_color", Color(1.0, 0.85, 0.2, 1.0))
	back_btn.add_theme_constant_override("outline_size", 2)
	back_btn.add_theme_color_override("font_outline_color", Color.BLACK)
	
	var style_menu_btn = StyleBoxFlat.new()
	style_menu_btn.bg_color = Color(0, 0, 0, 0.4)
	style_menu_btn.border_color = Color(1.0, 0.85, 0.2, 0.6)
	style_menu_btn.set_border_width_all(2)
	style_menu_btn.set_corner_radius_all(0)
	style_menu_btn.content_margin_left = 16
	style_menu_btn.content_margin_right = 16
	style_menu_btn.content_margin_top = 8
	style_menu_btn.content_margin_bottom = 8

	var style_menu_btn_hover = style_menu_btn.duplicate()
	style_menu_btn_hover.bg_color = Color(1.0, 0.75, 0.15, 0.2)
	
	var style_menu_btn_pressed = style_menu_btn.duplicate()
	style_menu_btn_pressed.bg_color = Color(1.0, 0.85, 0.2, 0.4)
	style_menu_btn_pressed.border_color = Color(1.0, 0.9, 0.3, 1.0)
	
	var style_menu_btn_disabled = style_menu_btn.duplicate()
	style_menu_btn_disabled.bg_color = Color(0, 0, 0, 0.2)
	style_menu_btn_disabled.border_color = Color(0.5, 0.5, 0.5, 0.5)
	
	var style_focus = StyleBoxFlat.new()
	style_focus.bg_color = Color(0, 0, 0, 0)
	style_focus.border_color = Color(1.0, 0.85, 0.2, 1.0)
	style_focus.set_border_width_all(2)
	style_focus.set_corner_radius_all(6)
	style_focus.content_margin_left = 6
	style_focus.content_margin_right = 6
	style_focus.content_margin_top = 4
	style_focus.content_margin_bottom = 4
	
	back_btn.add_theme_stylebox_override("normal", style_menu_btn)
	back_btn.add_theme_stylebox_override("hover", style_menu_btn_hover)
	back_btn.add_theme_stylebox_override("pressed", style_menu_btn_pressed)
	back_btn.add_theme_stylebox_override("disabled", style_menu_btn_disabled)
	back_btn.add_theme_stylebox_override("focus", style_focus)
	
	for ach_id in GameState.ACHIEVEMENTS.keys():
		var ach = GameState.ACHIEVEMENTS[ach_id]
		var unlocked = ach_id in GameState.unlocked_achievements
		
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(700, 100)
		panel.mouse_filter = Control.MOUSE_FILTER_PASS
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.15, 0.8) if unlocked else Color(0.05, 0.05, 0.08, 0.8)
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.border_color = Color(1.0, 0.85, 0.2, 0.5) if unlocked else Color(0.3, 0.3, 0.3, 0.5)
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_left = 6
		style.corner_radius_bottom_right = 6
		panel.add_theme_stylebox_override("panel", style)
		var margin = MarginContainer.new()
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		margin.add_theme_constant_override("margin_left", 16)
		margin.add_theme_constant_override("margin_right", 16)
		panel.add_child(margin)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 16)
		margin.add_child(hbox)
		
		# Retro Flat Plate (Option A: 64x64 plate with 4px radii, gold border unlocked, steel border locked)
		var plate = PanelContainer.new()
		plate.custom_minimum_size = Vector2(64, 64)
		plate.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var plate_style = StyleBoxFlat.new()
		plate_style.bg_color = Color(0.08, 0.05, 0.12, 0.85) if unlocked else Color(0.04, 0.03, 0.06, 0.8)
		plate_style.border_color = Color(1.0, 0.85, 0.2, 0.6) if unlocked else Color(0.3, 0.3, 0.35, 0.4)
		plate_style.set_border_width_all(1)
		plate_style.set_corner_radius_all(4)
		plate.add_theme_stylebox_override("panel", plate_style)
		
		var icon_rect = TextureRect.new()
		icon_rect.texture = load(ach["icon"])
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.custom_minimum_size = Vector2(44, 44)
		icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_rect.modulate = Color(1.0, 0.85, 0.2, 1.0) if unlocked else Color(0.35, 0.35, 0.4, 0.45)
		plate.add_child(icon_rect)
		hbox.add_child(plate)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 2)
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)
		
		var ach_title = Label.new()
		ach_title.text = (ach["title_kr"] if is_kr else ach["title_en"])
		_style_label(ach_title, 24, Color(1.0, 0.85, 0.2, 1.0) if unlocked else Color(0.6, 0.6, 0.6, 1.0), font)
		ach_title.add_theme_constant_override("outline_size", 2)
		ach_title.add_theme_color_override("font_outline_color", Color.BLACK)
		vbox.add_child(ach_title)
		
		var ach_desc = Label.new()
		ach_desc.text = (ach["desc_kr"] if is_kr else ach["desc_en"])
		ach_desc.custom_minimum_size = Vector2(360, 0)
		ach_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
		_style_label(ach_desc, 15, Color(1.0, 1.0, 1.0, 0.85) if unlocked else Color(0.45, 0.45, 0.45, 0.8), body_font)
		ach_desc.add_theme_constant_override("outline_size", 1)
		ach_desc.add_theme_color_override("font_outline_color", Color.BLACK)
		vbox.add_child(ach_desc)
		
		var pdata = GameState.get_achievement_progress_data(ach_id)
		var status_col = VBoxContainer.new()
		status_col.custom_minimum_size = Vector2(150, 0)
		status_col.alignment = BoxContainer.ALIGNMENT_CENTER
		status_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		status_col.add_theme_constant_override("separation", 6)
		hbox.add_child(status_col)
		
		if unlocked:
			var badge = Label.new()
			badge.text = "[ ✔ 완료 ]" if is_kr else "[ ✔ DONE ]"
			_style_label(badge, 13, Color(1.0, 0.85, 0.2, 1.0), font)
			badge.add_theme_constant_override("outline_size", 2)
			badge.add_theme_color_override("font_outline_color", Color.BLACK)
			badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			status_col.add_child(badge)
		else:
			var count_lbl = Label.new()
			count_lbl.text = pdata.text
			_style_label(count_lbl, 13, Color(0.85, 0.85, 0.9, 0.8), font)
			count_lbl.add_theme_constant_override("outline_size", 2)
			count_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
			count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			status_col.add_child(count_lbl)
			
			var pbar = ProgressBar.new()
			pbar.custom_minimum_size = Vector2(140, 8)
			pbar.show_percentage = false
			pbar.min_value = 0.0
			pbar.max_value = 100.0
			pbar.step = 0.1
			pbar.value = pdata.ratio * 100.0
			
			var pbar_bg = StyleBoxFlat.new()
			pbar_bg.bg_color = Color(0.04, 0.03, 0.07, 0.9)
			pbar_bg.border_width_left = 1
			pbar_bg.border_width_right = 1
			pbar_bg.border_width_top = 1
			pbar_bg.border_width_bottom = 1
			pbar_bg.border_color = Color(0.3, 0.3, 0.35, 0.5)
			pbar_bg.set_corner_radius_all(4)
			
			var pbar_fill = StyleBoxFlat.new()
			pbar_fill.bg_color = Color(1.0, 0.85, 0.2, 0.9)
			pbar_fill.set_corner_radius_all(4)
			
			pbar.add_theme_stylebox_override("background", pbar_bg)
			pbar.add_theme_stylebox_override("fill", pbar_fill)
			status_col.add_child(pbar)
		
		achievement_list.add_child(panel)

	achievements_screen.visible = true
	achievements_screen.modulate.a = 0.0
	achievements_screen.set_meta("is_hiding", false)
	var tw = create_tween()
	tw.tween_property(achievements_screen, "modulate:a", 1.0, 0.25)
	
	var back_node = achievements_screen.get_node_or_null("CenterContainer/VBoxContainer/CenterContainer/BackBtn")
	if back_node: back_node.grab_focus()
	
	UIJuice.play_tick()

func _hide_achievements() -> void:
	if not achievements_screen or not achievements_screen.visible: return
	if achievements_screen.get_meta("is_hiding", false): return
	achievements_screen.set_meta("is_hiding", true)
	
	UIJuice.play_tick()
	
	var tw = create_tween()
	tw.tween_property(achievements_screen, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func(): 
		achievements_screen.visible = false
		achievements_screen.set_meta("is_hiding", false)
		if ach_btn: ach_btn.grab_focus()
	)

func _finish_splash_and_reveal_menu(vbox: Control) -> void:
	if not is_splash_active:
		return
	is_splash_active = false
	border_progress = -1.0
	$BorderPanel.visible = true
	if splash_border_drawer and is_instance_valid(splash_border_drawer):
		splash_border_drawer.queue_redraw()
	
	# Smoothly dissolve the dark curtain (SplashContainer) over 0.85s with film-grade sine easing,
	# revealing the 3D beach world and sun face in a cinematic bloom
	var curtain_tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if is_instance_valid(splash_container):
		curtain_tw.tween_property(splash_container, "modulate:a", 0.0, 0.85)
		curtain_tw.chain().tween_callback(func():
			if is_instance_valid(splash_container):
				splash_container.visible = false
		)
	if is_instance_valid(startup_audio):
		curtain_tw.tween_property(startup_audio, "volume_db", -80.0, 3.5)
	
	# Smoothly glide in menu elements with subtle stagger as the beach emerges
	var slide_tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if is_instance_valid(vbox):
		vbox.position.y = orig_vbox_y + 35
		slide_tw.tween_property(vbox, "position:y", orig_vbox_y, 0.9).set_delay(0.12)
		slide_tw.tween_property(vbox, "modulate:a", 1.0, 0.75).set_delay(0.12)
	if lang_btn:
		lang_btn.position.y = orig_lang_y + 35
		slide_tw.tween_property(lang_btn, "position:y", orig_lang_y, 0.9).set_delay(0.15)
		slide_tw.tween_property(lang_btn, "modulate:a", 1.0, 0.75).set_delay(0.15)
	if credit_lbl:
		credit_lbl.position.y = orig_credit_y + 25
		slide_tw.tween_property(credit_lbl, "position:y", orig_credit_y, 0.9).set_delay(0.18)
		slide_tw.tween_property(credit_lbl, "modulate:a", 1.0, 0.75).set_delay(0.18)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause") and not event.is_echo():
		if achievements_screen and achievements_screen.visible:
			_hide_achievements()
			get_viewport().set_input_as_handled()
			return
			
		if stats_screen and stats_screen.visible:
			_hide_stats()
			get_viewport().set_input_as_handled()
			return
		
		if settings_screen and settings_screen.visible:
			_hide_settings()
			get_viewport().set_input_as_handled()
			return
		
		if quit_popup and quit_popup.visible:
			_hide_quit_popup()
			get_viewport().set_input_as_handled()
		elif not is_starting:
			_show_quit_popup()
			get_viewport().set_input_as_handled()

func _build_quit_popup() -> void:
	quit_popup = Control.new()
	quit_popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	quit_popup.visible = false
	quit_popup.z_index = 60 # Above achievements
	add_child(quit_popup)
	
	var overlay = ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0, 0, 0, 0.90)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	quit_popup.add_child(overlay)
	
	var center = CenterContainer.new()
	center.name = "CenterContainer"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	quit_popup.add_child(center)
	
	var panel = Panel.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(400, 180)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.96)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(1.0, 0.85, 0.2, 0.8)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.name = "MarginContainer"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 32)
	margin.add_child(vbox)
	
	var lbl = Label.new()
	lbl.name = "Message"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl)
	
	var hbox = HBoxContainer.new()
	hbox.name = "HBoxContainer"
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 24)
	vbox.add_child(hbox)
	
	var yes_btn = Button.new()
	yes_btn.name = "YesBtn"
	yes_btn.custom_minimum_size = Vector2(140, 48)
	hbox.add_child(yes_btn)
	
	var no_btn = Button.new()
	no_btn.name = "NoBtn"
	no_btn.custom_minimum_size = Vector2(140, 48)
	hbox.add_child(no_btn)
	
	yes_btn.pressed.connect(_quit_game)
	no_btn.pressed.connect(_hide_quit_popup)

func _show_quit_popup() -> void:
	if is_starting or not quit_popup: return
	
	var is_kr = GameState.language == "KR"
	var font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/ui/fonts/Fonts/Kenney Future.ttf"
	var font = load(font_path)
	
	var lbl = quit_popup.get_node("CenterContainer/Panel/MarginContainer/VBoxContainer/Message")
	lbl.text = "게임을 종료하시겠습니까?" if is_kr else "DO YOU WANT TO QUIT?"
	_style_label(lbl, 22 if is_kr else 20, Color(1.0, 1.0, 1.0, 1.0), font)
	lbl.add_theme_constant_override("outline_size", 2)
	
	var yes_btn = quit_popup.get_node("CenterContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/YesBtn")
	var no_btn = quit_popup.get_node("CenterContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/NoBtn")
	
	yes_btn.text = "예 (YES)" if is_kr else "YES"
	no_btn.text = "아니요 (NO)" if is_kr else "NO"
	
	# Apply standard button styles (Primary - NO)
	var style_menu_btn = StyleBoxFlat.new()
	style_menu_btn.bg_color = Color(0, 0, 0, 0.4)
	style_menu_btn.border_color = Color(1.0, 0.85, 0.2, 0.6)
	style_menu_btn.set_border_width_all(2)
	style_menu_btn.set_corner_radius_all(0)
	
	var style_hover = style_menu_btn.duplicate()
	style_hover.bg_color = Color(1.0, 0.75, 0.15, 0.2)
	
	var style_pressed = style_menu_btn.duplicate()
	style_pressed.bg_color = Color(1.0, 0.85, 0.2, 0.4)
	style_pressed.border_color = Color(1.0, 0.9, 0.3, 1.0)
	
	var style_focus = StyleBoxFlat.new()
	style_focus.bg_color = Color(0, 0, 0, 0)
	style_focus.border_color = Color(1.0, 0.85, 0.2, 1.0)
	style_focus.set_border_width_all(2)
	style_focus.set_corner_radius_all(6)
	
	# Apply secondary button styles (Secondary - YES)
	var style_sec_btn = StyleBoxFlat.new()
	style_sec_btn.bg_color = Color(0, 0, 0, 0.3)
	style_sec_btn.border_color = Color(0.6, 0.6, 0.6, 0.4)
	style_sec_btn.set_border_width_all(2)
	style_sec_btn.set_corner_radius_all(0)
	
	var style_sec_hover = style_sec_btn.duplicate()
	style_sec_hover.bg_color = Color(0.4, 0.4, 0.4, 0.2)
	style_sec_hover.border_color = Color(0.8, 0.8, 0.8, 0.6)
	
	var style_sec_pressed = style_sec_btn.duplicate()
	style_sec_pressed.bg_color = Color(0.2, 0.2, 0.2, 0.4)
	style_sec_pressed.border_color = Color(0.5, 0.5, 0.5, 0.8)
	
	var style_sec_focus = StyleBoxFlat.new()
	style_sec_focus.bg_color = Color(0, 0, 0, 0)
	style_sec_focus.border_color = Color(0.6, 0.6, 0.6, 1.0)
	style_sec_focus.set_border_width_all(2)
	style_sec_focus.set_corner_radius_all(6)
	
	for btn in [yes_btn, no_btn]:
		var is_primary = (btn == no_btn)
		
		if font: btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 18 if is_kr else 16)
		
		var txt_color = Color(1.0, 0.85, 0.2, 1.0) if is_primary else Color(0.7, 0.7, 0.7, 1.0)
		var txt_hover = Color(1.0, 0.85, 0.2, 1.0) if is_primary else Color(0.9, 0.9, 0.9, 1.0)
		
		btn.add_theme_color_override("font_color", txt_color)
		btn.add_theme_color_override("font_hover_color", txt_hover)
		btn.add_theme_color_override("font_pressed_color", txt_color)
		btn.add_theme_color_override("font_focus_color", txt_color)
		btn.add_theme_constant_override("outline_size", 2)
		btn.add_theme_color_override("font_outline_color", Color.BLACK)
		
		btn.add_theme_stylebox_override("normal", style_menu_btn if is_primary else style_sec_btn)
		btn.add_theme_stylebox_override("hover", style_hover if is_primary else style_sec_hover)
		btn.add_theme_stylebox_override("pressed", style_pressed if is_primary else style_sec_pressed)
		btn.add_theme_stylebox_override("focus", style_focus if is_primary else style_sec_focus)
	
	quit_popup.visible = true
	quit_popup.modulate.a = 0.0
	quit_popup.set_meta("is_hiding", false)
	
	var tw = create_tween()
	tw.tween_property(quit_popup, "modulate:a", 1.0, 0.2)
	
	no_btn.grab_focus()
	
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/sfx/ui_tick.wav")
	audio.bus = "SFX"
	add_child(audio)
	audio.play()
	audio.finished.connect(audio.queue_free)

func _hide_quit_popup() -> void:
	if not quit_popup or not quit_popup.visible: return
	if quit_popup.get_meta("is_hiding", false): return
	quit_popup.set_meta("is_hiding", true)
	
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/sfx/ui_tick.wav")
	audio.bus = "SFX"
	add_child(audio)
	audio.play()
	audio.finished.connect(audio.queue_free)
	
	var tw = create_tween()
	tw.tween_property(quit_popup, "modulate:a", 0.0, 0.15)
	tw.tween_callback(func(): 
		quit_popup.visible = false
		quit_popup.set_meta("is_hiding", false)
	)

func _quit_game() -> void:
	get_tree().quit()

func _build_stats_screen() -> void:
	stats_screen = Control.new()
	stats_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stats_screen.visible = false
	stats_screen.z_index = 50
	add_child(stats_screen)
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.96)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stats_screen.add_child(bg)
	
	var border = Panel.new()
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	border.offset_left = 24
	border.offset_top = 24
	border.offset_right = -24
	border.offset_bottom = -24
	
	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color(0, 0, 0, 0)
	border_style.border_width_left = 2
	border_style.border_width_top = 2
	border_style.border_width_right = 2
	border_style.border_width_bottom = 2
	border_style.border_color = Color(1.0, 0.85, 0.2, 0.4)
	border_style.corner_radius_top_left = 8
	border_style.corner_radius_top_right = 8
	border_style.corner_radius_bottom_left = 8
	border_style.corner_radius_bottom_right = 8
	border.add_theme_stylebox_override("panel", border_style)
	stats_screen.add_child(border)
	
	var center = CenterContainer.new()
	center.name = "CenterContainer"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stats_screen.add_child(center)
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)
	
	var title_row = HBoxContainer.new()
	title_row.name = "TitleRow"
	title_row.add_theme_constant_override("separation", 12)
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(title_row)
	
	var title_icon = TextureRect.new()
	title_icon.name = "TitleIcon"
	title_icon.custom_minimum_size = Vector2(40, 40)
	title_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_icon.texture = load("res://assets/ui/menu_icons/achievements.png")
	title_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_icon.modulate = Color(1.0, 0.85, 0.2, 1.0)
	title_row.add_child(title_icon)
	
	var title = Label.new()
	title.name = "Title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_row.add_child(title)
	
	var divider = HSeparator.new()
	divider.name = "Divider"
	var div_style = StyleBoxLine.new()
	div_style.color = Color(1.0, 0.88, 0.3, 0.35)
	div_style.grow_begin = 0
	div_style.grow_end = 0
	div_style.thickness = 2
	div_style.content_margin_top = 0
	div_style.content_margin_bottom = 0
	divider.add_theme_stylebox_override("separator", div_style)
	vbox.add_child(divider)
	
	var stats_list = VBoxContainer.new()
	stats_list.name = "StatsList"
	stats_list.custom_minimum_size = Vector2(560, 0)
	stats_list.add_theme_constant_override("separation", 10)
	vbox.add_child(stats_list)
	
	var divider2 = HSeparator.new()
	divider2.name = "Divider2"
	var div2_style = StyleBoxLine.new()
	div2_style.color = Color(1.0, 0.88, 0.3, 0.35)
	div2_style.grow_begin = 0
	div2_style.grow_end = 0
	div2_style.thickness = 2
	div2_style.content_margin_top = 0
	div2_style.content_margin_bottom = 0
	divider2.add_theme_stylebox_override("separator", div2_style)
	vbox.add_child(divider2)
	
	var back_btn = Button.new()
	back_btn.name = "BackBtn"
	back_btn.text = "BACK"
	back_btn.custom_minimum_size = Vector2(280, 44)
	
	var btn_center = CenterContainer.new()
	btn_center.name = "CenterContainer"
	btn_center.add_child(back_btn)
	vbox.add_child(btn_center)
	
	stats_prompt_lbl = Label.new()
	stats_prompt_lbl.name = "ClosePrompt"
	stats_prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_prompt_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stats_prompt_lbl.text = "PRESS ESC TO CLOSE"
	_style_label(stats_prompt_lbl, 14, Color(1.0, 0.88, 0.3, 0.85), null)
	stats_prompt_lbl.add_theme_constant_override("outline_size", 1)
	stats_prompt_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	if not GameState.reduce_motion:
		var sp_tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		sp_tw.tween_property(stats_prompt_lbl, "modulate:a", 0.7, 1.2)
		sp_tw.tween_property(stats_prompt_lbl, "modulate:a", 1.0, 1.2)
	vbox.add_child(stats_prompt_lbl)
	
	back_btn.pressed.connect(_hide_stats)

func _show_stats() -> void:
	if is_starting or not stats_screen: return
	
	var list = stats_screen.get_node("CenterContainer/VBoxContainer/StatsList")
	for child in list.get_children():
		child.queue_free()
		
	var is_kr = GameState.language == "KR"
	var font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/ui/fonts/Fonts/Kenney Future.ttf"
	var font = load(font_path)
	
	var title = stats_screen.get_node("CenterContainer/VBoxContainer/TitleRow/Title")
	title.text = "기록" if is_kr else "LIFETIME STATS"
	_style_label(title, 32, Color(1.0, 0.85, 0.2, 1.0), font)
	title.add_theme_constant_override("outline_size", 4)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	
	var back_btn = stats_screen.get_node("CenterContainer/VBoxContainer/CenterContainer/BackBtn")
	back_btn.text = "돌아가기" if is_kr else "BACK"
	if font: back_btn.add_theme_font_override("font", font)
	if stats_prompt_lbl:
		stats_prompt_lbl.text = "닫으려면 ESC를 누르세요" if is_kr else "PRESS ESC TO CLOSE"
		if font: stats_prompt_lbl.add_theme_font_override("font", font)
		stats_prompt_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 0.85))
		stats_prompt_lbl.add_theme_constant_override("outline_size", 1)
		stats_prompt_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	back_btn.add_theme_font_size_override("font_size", 22)
	back_btn.add_theme_constant_override("letter_spacing", 1)
	back_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	back_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.2, 1.0))
	back_btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.85, 0.2, 1.0))
	back_btn.add_theme_color_override("font_focus_color", Color(1.0, 0.85, 0.2, 1.0))
	back_btn.add_theme_color_override("font_disabled_color", Color(1.0, 0.85, 0.2, 1.0))
	back_btn.add_theme_constant_override("outline_size", 2)
	back_btn.add_theme_color_override("font_outline_color", Color.BLACK)
	
	var style_menu_btn = StyleBoxFlat.new()
	style_menu_btn.bg_color = Color(0, 0, 0, 0.4)
	style_menu_btn.border_color = Color(1.0, 0.85, 0.2, 0.6)
	style_menu_btn.set_border_width_all(2)
	style_menu_btn.set_corner_radius_all(0)
	style_menu_btn.content_margin_left = 16
	style_menu_btn.content_margin_right = 16
	style_menu_btn.content_margin_top = 8
	style_menu_btn.content_margin_bottom = 8

	var style_menu_btn_hover = style_menu_btn.duplicate()
	style_menu_btn_hover.bg_color = Color(1.0, 0.75, 0.15, 0.2)
	
	var style_menu_btn_pressed = style_menu_btn.duplicate()
	style_menu_btn_pressed.bg_color = Color(1.0, 0.85, 0.2, 0.4)
	style_menu_btn_pressed.border_color = Color(1.0, 0.9, 0.3, 1.0)
	
	var style_menu_btn_disabled = style_menu_btn.duplicate()
	style_menu_btn_disabled.bg_color = Color(0, 0, 0, 0.2)
	style_menu_btn_disabled.border_color = Color(0.5, 0.5, 0.5, 0.5)
	
	var style_focus = StyleBoxFlat.new()
	style_focus.bg_color = Color(0, 0, 0, 0)
	style_focus.border_color = Color(1.0, 0.85, 0.2, 1.0)
	style_focus.set_border_width_all(2)
	style_focus.set_corner_radius_all(6)
	style_focus.content_margin_left = 6
	style_focus.content_margin_right = 6
	style_focus.content_margin_top = 4
	style_focus.content_margin_bottom = 4
	
	back_btn.add_theme_stylebox_override("normal", style_menu_btn)
	back_btn.add_theme_stylebox_override("hover", style_menu_btn_hover)
	back_btn.add_theme_stylebox_override("pressed", style_menu_btn_pressed)
	back_btn.add_theme_stylebox_override("disabled", style_menu_btn_disabled)
	back_btn.add_theme_stylebox_override("focus", style_focus)

	var format_int = func(num: int) -> String:
		var num_str = str(num)
		var res = ""
		for i in range(num_str.length()):
			if i > 0 and i % 3 == 0:
				res = "," + res
			res = num_str[num_str.length() - 1 - i] + res
		return res
		
	var stats_data = [
		{
			"label_en": "WATER SPRAYED",
			"label_kr": "분사한 물의 양",
			"value": format_int.call(int(GameState.total_water_sprayed)) + (" L" if is_kr else " L"),
			"icon": "res://assets/ui/hud_elements/meter_water.svg"
		},
		{
			"label_en": "FLARES INTERCEPTED",
			"label_kr": "요격한 태양 플레어",
			"value": format_int.call(GameState.flares_intercepted),
			"icon": "res://assets/ui/achievements/fireball.png"
		},
		{
			"label_en": "SEAGULLS SHOOED",
			"label_kr": "쫓아낸 갈매기 수",
			"value": format_int.call(GameState.seagulls_shooed),
			"icon": "res://assets/ui/achievements/seagull.png"
		},
		{
			"label_en": "ICE BLASTS USED",
			"label_kr": "사용한 얼음 폭발",
			"value": format_int.call(GameState.total_ice_blasts),
			"icon": "res://assets/ui/hud_elements/meter_ice.svg"
		},
		{
			"label_en": "BEST ENDLESS WAVE",
			"label_kr": "엔들리스 최고 웨이브",
			"value": ("%d 웨이브" % GameState.best_wave) if is_kr else ("WAVE %d" % GameState.best_wave),
			"icon": "res://assets/ui/achievements/sunset.png"
		},
		{
			"label_en": "SUPERNOVAS",
			"label_kr": "초신성 폭발 (사망)",
			"value": format_int.call(GameState.total_deaths),
			"icon": "res://assets/ui/achievements/ball-glow.png"
		},
		{
			"label_en": "HIGHEST SCORE",
			"label_kr": "최고 점수",
			"value": format_int.call(GameState.high_score),
			"icon": "res://assets/ui/achievements/trophy.png"
		},
		{
			"label_en": "ACHIEVEMENTS",
			"label_kr": "달성한 업적",
			"value": str(GameState.unlocked_achievements.size()) + " / " + str(GameState.ACHIEVEMENTS.keys().size()),
			"icon": "res://assets/ui/menu_icons/achievements.png"
		}
	]
	
	for s_data in stats_data:
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 14)
		list.add_child(hbox)
		
		# Retro Flat Plate with Gold Accent Border (Option B: Unified Gold Monochrome)
		var plate = PanelContainer.new()
		plate.custom_minimum_size = Vector2(32, 32)
		plate.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var plate_style = StyleBoxFlat.new()
		plate_style.bg_color = Color(0.08, 0.05, 0.12, 0.75)
		plate_style.border_color = Color(1.0, 0.85, 0.2, 0.5)
		plate_style.set_border_width_all(1)
		plate_style.set_corner_radius_all(4)
		plate.add_theme_stylebox_override("panel", plate_style)
		
		var icon_rect = TextureRect.new()
		icon_rect.texture = load(s_data["icon"])
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.custom_minimum_size = Vector2(20, 20)
		icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_rect.modulate = Color(1.0, 0.85, 0.2, 1.0)
		plate.add_child(icon_rect)
		hbox.add_child(plate)
		
		var name_lbl = Label.new()
		name_lbl.text = s_data["label_kr"] if is_kr else s_data["label_en"]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		name_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_style_label(name_lbl, 20, Color(1.0, 1.0, 1.0, 0.85), font)
		name_lbl.add_theme_constant_override("outline_size", 2)
		hbox.add_child(name_lbl)
		
		var spacer = Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(spacer)
		
		var val_lbl = Label.new()
		val_lbl.text = s_data["value"]
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		val_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_style_label(val_lbl, 22, Color(1.0, 0.85, 0.2, 1.0), font)
		val_lbl.add_theme_constant_override("outline_size", 2)
		hbox.add_child(val_lbl)

	stats_screen.visible = true
	stats_screen.modulate.a = 0.0
	stats_screen.set_meta("is_hiding", false)
	var tw = create_tween()
	tw.tween_property(stats_screen, "modulate:a", 1.0, 0.25)
	
	if back_btn: back_btn.grab_focus()
	
	UIJuice.play_tick()

func _hide_stats() -> void:
	if not stats_screen or not stats_screen.visible: return
	if stats_screen.get_meta("is_hiding", false): return
	stats_screen.set_meta("is_hiding", true)
	
	UIJuice.play_tick()
	
	var tw = create_tween()
	tw.tween_property(stats_screen, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func(): 
		stats_screen.visible = false
		stats_screen.set_meta("is_hiding", false)
		if stats_btn: stats_btn.grab_focus()
	)

func _update_toggle_btn(btn: Button, enabled: bool) -> void:
	if not btn: return
	btn.button_pressed = enabled
	if enabled:
		btn.text = "ON"
		btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.6, 1.0))
	else:
		btn.text = "OFF"
		btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 0.85))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))

func _update_setting_lang_toggle(is_kr: bool) -> void:
	if not setting_lang_btn_en or not setting_lang_btn_kr: return
	if is_kr:
		setting_lang_btn_kr.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 1.0))
		setting_lang_btn_kr.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.6, 1.0))
		setting_lang_btn_en.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 0.5))
		setting_lang_btn_en.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 0.8))
	else:
		setting_lang_btn_en.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 1.0))
		setting_lang_btn_en.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.6, 1.0))
		setting_lang_btn_kr.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 0.5))
		setting_lang_btn_kr.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 0.8))

func _apply_settings_language() -> void:
	var is_kr = GameState.language == "KR"
	var font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/ui/fonts/Fonts/Kenney Future.ttf"
	var font = load(font_path)
	var body_font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/fonts/Inter-Medium.ttf"
	var body_font = load(body_font_path)
	
	if title_lbl: title_lbl.text = "썸머" if is_kr else "SUMMER"
	if title2_lbl: title2_lbl.text = "나이츠" if is_kr else "NIGHTS"
	if subtitle_lbl: subtitle_lbl.text = "태양을 식혀라" if is_kr else "COOL DOWN THE SUN"
	if normal_btn: normal_btn.text = "일반 모드" if is_kr else "NORMAL MODE"
	if survival_btn:
		var has_dawn_breaks = "dawn_breaks" in GameState.unlocked_achievements
		survival_btn.disabled = not has_dawn_breaks
		if not has_dawn_breaks:
			survival_btn.text = "무한 모드 [잠김]" if is_kr else "ENDLESS MODE [LOCKED]"
		else:
			survival_btn.text = "무한 모드" if is_kr else "ENDLESS MODE"
	if dev_btn: dev_btn.text = "DEV"
	if ach_btn: ach_btn.text = "업적" if is_kr else "ACHIEVEMENTS"
	if stats_btn: stats_btn.text = "기록" if is_kr else "STATS"
	if settings_btn: settings_btn.text = "설정" if is_kr else "SETTINGS"
	if quit_prompt_btn: quit_prompt_btn.text = "[ESC] 게임 종료" if is_kr else "[ESC] QUIT GAME"

	if font:
		for btn in [normal_btn, survival_btn, dev_btn, ach_btn, stats_btn, settings_btn]:
			if btn:
				btn.add_theme_font_override("font", font)
				btn.add_theme_font_size_override("font_size", 20 if is_kr else 18)

		for lbl in [title_lbl, title2_lbl]:
			if lbl:
				lbl.scale = Vector2.ONE
				lbl.modulate = Color.WHITE

		if subtitle_lbl:
			_style_label(subtitle_lbl, 20 if is_kr else 18, Color(1.0, 0.75, 0.15, 1.0), font)
		if credit_lbl:
			credit_lbl.text = "SUMMER NIGHTS v1.7 · GODOT 4 · GDSCRIPT · FORWARD+"
			_style_label(credit_lbl, 14 if is_kr else 12, Color(1.0, 1.0, 1.0, 0.7), font)

		if best_time_lbl and (GameState.best_survival_time > 0.0 or GameState.best_wave > 0):
			var m = int(GameState.best_survival_time) / 60
			var s = int(GameState.best_survival_time) % 60
			var time_str = "%02d:%02d" % [m, s]
			if GameState.best_wave > 0 and GameState.best_survival_time > 0.0:
				best_time_lbl.text = "최고 기록: %d 웨이브 (%s)" % [GameState.best_wave, time_str] if is_kr else "BEST ENDLESS: WAVE %d (%s)" % [GameState.best_wave, time_str]
			elif GameState.best_wave > 0:
				best_time_lbl.text = "최고 웨이브: %d" % GameState.best_wave if is_kr else "BEST ENDLESS: WAVE %d" % GameState.best_wave
			else:
				best_time_lbl.text = "최고 기록: %s" % time_str if is_kr else "BEST ENDLESS TIME: %s" % time_str
			_style_label(best_time_lbl, 16 if is_kr else 14, Color(0.4, 0.9, 0.4, 1.0), font)

		if high_score_lbl and GameState.high_score > 0:
			var score_str = str(GameState.high_score)
			var formatted_score = ""
			for i in range(score_str.length()):
				if i > 0 and i % 3 == 0:
					formatted_score = "," + formatted_score
				formatted_score = score_str[score_str.length() - 1 - i] + formatted_score
			high_score_lbl.text = "최고 점수: %s" % formatted_score if is_kr else "HIGH SCORE: %s" % formatted_score
			_style_label(high_score_lbl, 16 if is_kr else 14, Color(1.0, 0.85, 0.2, 1.0), font)

	# Update top-right LangBtn highlight
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

	# Update Settings Screen modal
	if settings_screen:
		if settings_title_lbl:
			settings_title_lbl.text = "설정" if is_kr else "SETTINGS"
			_style_label(settings_title_lbl, 40, Color(1.0, 0.85, 0.2, 1.0), font)
			settings_title_lbl.add_theme_constant_override("outline_size", 4)
			settings_title_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
		if setting_cat_audio_lbl:
			setting_cat_audio_lbl.text = "오디오" if is_kr else "AUDIO"
			if font: setting_cat_audio_lbl.add_theme_font_override("font", font)
		if setting_cat_gameplay_lbl:
			setting_cat_gameplay_lbl.text = "조작 및 편의" if is_kr else "GAMEPLAY & CONTROLS"
			if font: setting_cat_gameplay_lbl.add_theme_font_override("font", font)
		if setting_cat_system_lbl:
			setting_cat_system_lbl.text = "화면 및 시스템" if is_kr else "DISPLAY & SYSTEM"
			if font: setting_cat_system_lbl.add_theme_font_override("font", font)

		var row_names = {
			"RowSFX": "전체 볼륨" if is_kr else "Master Volume",
			"RowSens": "마우스 감도" if is_kr else "Sensitivity",
			"RowMotion": "화면 흔들림 감소" if is_kr else "Reduce Motion",
			"RowVibration": "진동" if is_kr else "Vibration",
			"RowFullscreen": "전체 화면" if is_kr else "Fullscreen",
			"RowLanguage": "언어" if is_kr else "Language",
			"RowGoldSkin": "황금 무기 스킨" if is_kr else "Gold Gun Skin"
		}
		for r_key in row_names:
			var r_lbl = setting_row_labels.get(r_key)
			if r_lbl:
				r_lbl.text = row_names[r_key]
				if body_font: r_lbl.add_theme_font_override("font", body_font)
				r_lbl.add_theme_font_size_override("font_size", 16)
				r_lbl.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 0.95))
				r_lbl.add_theme_constant_override("outline_size", 2)
				r_lbl.add_theme_color_override("font_outline_color", Color.BLACK)

		for chk in [setting_motion_check, setting_vibration_check, setting_fullscreen_check, setting_gold_skin_check]:
			if chk:
				if body_font: chk.add_theme_font_override("font", body_font)
				chk.add_theme_font_size_override("font_size", 14)
		if setting_lang_btn_en and body_font:
			setting_lang_btn_en.add_theme_font_override("font", body_font)
			setting_lang_btn_en.add_theme_font_size_override("font_size", 14)
		if setting_lang_btn_kr and body_font:
			setting_lang_btn_kr.add_theme_font_override("font", body_font)
			setting_lang_btn_kr.add_theme_font_size_override("font_size", 14)
		if setting_sfx_val_lbl and body_font:
			setting_sfx_val_lbl.add_theme_font_override("font", body_font)
			setting_sfx_val_lbl.add_theme_font_size_override("font_size", 14)
		if setting_sens_val_lbl and body_font:
			setting_sens_val_lbl.add_theme_font_override("font", body_font)
			setting_sens_val_lbl.add_theme_font_size_override("font_size", 14)

		_update_setting_lang_toggle(is_kr)

		if settings_back_btn:
			settings_back_btn.text = "돌아가기" if is_kr else "BACK"
			if font: settings_back_btn.add_theme_font_override("font", font)
			settings_back_btn.add_theme_font_size_override("font_size", 20 if is_kr else 18)
			settings_back_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
			settings_back_btn.add_theme_constant_override("outline_size", 2)
			settings_back_btn.add_theme_color_override("font_outline_color", Color.BLACK)
		if settings_prompt_lbl:
			settings_prompt_lbl.text = "닫으려면 ESC를 누르세요" if is_kr else "PRESS ESC TO CLOSE"
			if font: settings_prompt_lbl.add_theme_font_override("font", font)
		if achievements_prompt_lbl:
			achievements_prompt_lbl.text = "닫으려면 ESC를 누르세요" if is_kr else "PRESS ESC TO CLOSE"
			if font: achievements_prompt_lbl.add_theme_font_override("font", font)
		if stats_prompt_lbl:
			stats_prompt_lbl.text = "닫으려면 ESC를 누르세요" if is_kr else "PRESS ESC TO CLOSE"
			if font: stats_prompt_lbl.add_theme_font_override("font", font)

func _build_settings_screen() -> void:
	settings_screen = Control.new()
	settings_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_screen.visible = false
	settings_screen.z_index = 50
	add_child(settings_screen)
	
	var bg = ColorRect.new()
	bg.color = Color(0.02, 0.01, 0.05, 0.96)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_screen.add_child(bg)
	
	var border = Panel.new()
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	border.offset_left = 24
	border.offset_top = 24
	border.offset_right = -24
	border.offset_bottom = -24
	
	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color(0, 0, 0, 0)
	border_style.border_width_left = 2
	border_style.border_width_top = 2
	border_style.border_width_right = 2
	border_style.border_width_bottom = 2
	border_style.border_color = Color(1.0, 0.85, 0.2, 0.4)
	border_style.corner_radius_top_left = 8
	border_style.corner_radius_top_right = 8
	border_style.corner_radius_bottom_left = 8
	border_style.corner_radius_bottom_right = 8
	border.add_theme_stylebox_override("panel", border_style)
	settings_screen.add_child(border)
	
	var center = CenterContainer.new()
	center.name = "CenterContainer"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_screen.add_child(center)
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.custom_minimum_size = Vector2(560, 0)
	vbox.add_theme_constant_override("separation", 12)
	center.add_child(vbox)
	
	var title_row = HBoxContainer.new()
	title_row.name = "TitleRow"
	title_row.add_theme_constant_override("separation", 12)
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(title_row)
	
	var title_icon = TextureRect.new()
	title_icon.name = "TitleIcon"
	title_icon.custom_minimum_size = Vector2(32, 32)
	title_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_icon.texture = load("res://assets/ui/menu_icons/settings.png")
	title_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_icon.modulate = Color(1.0, 0.85, 0.2, 1.0)
	title_row.add_child(title_icon)
	
	settings_title_lbl = Label.new()
	settings_title_lbl.name = "Title"
	settings_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	settings_title_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_row.add_child(settings_title_lbl)
	
	var divider = HSeparator.new()
	divider.name = "Divider"
	var div_style = StyleBoxLine.new()
	div_style.color = Color(1.0, 0.88, 0.3, 0.35)
	div_style.grow_begin = 0
	div_style.grow_end = 0
	div_style.thickness = 1
	divider.add_theme_stylebox_override("separator", div_style)
	vbox.add_child(divider)

	var make_cat = func(node_name: String, title_en: String, title_kr: String, top_margin: int) -> MarginContainer:
		var wrap = MarginContainer.new()
		wrap.name = node_name
		wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if top_margin > 0:
			wrap.add_theme_constant_override("margin_top", top_margin)
		
		var row = HBoxContainer.new()
		row.name = "HBox"
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 12)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrap.add_child(row)
		
		var plate = PanelContainer.new()
		plate.name = "Plate"
		plate.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color(1.0, 0.85, 0.2, 0.12)
		p_style.border_color = Color(1.0, 0.85, 0.2, 0.5)
		p_style.set_border_width_all(1)
		p_style.set_corner_radius_all(4)
		p_style.content_margin_left = 10
		p_style.content_margin_right = 10
		p_style.content_margin_top = 2
		p_style.content_margin_bottom = 2
		plate.add_theme_stylebox_override("panel", p_style)
		
		var lbl = Label.new()
		lbl.name = "Label"
		lbl.text = title_kr if GameState.language == "KR" else title_en
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
		lbl.add_theme_constant_override("outline_size", 1)
		lbl.add_theme_color_override("font_outline_color", Color.BLACK)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		plate.add_child(lbl)
		row.add_child(plate)
		
		var sep = HSeparator.new()
		sep.name = "Hairline"
		sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sep.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var line_style = StyleBoxLine.new()
		line_style.color = Color(1.0, 0.85, 0.2, 0.28)
		line_style.thickness = 1
		line_style.vertical = false
		sep.add_theme_stylebox_override("separator", line_style)
		row.add_child(sep)
		return wrap

	var style_btn_off = StyleBoxFlat.new()
	style_btn_off.bg_color = Color(0, 0, 0, 0.4)
	style_btn_off.border_color = Color(1.0, 0.88, 0.3, 0.4)
	style_btn_off.set_border_width_all(1)
	style_btn_off.set_corner_radius_all(4)

	var style_btn_on = StyleBoxFlat.new()
	style_btn_on.bg_color = Color(1.0, 0.88, 0.3, 0.25)
	style_btn_on.border_color = Color(1.0, 0.88, 0.3, 1.0)
	style_btn_on.set_border_width_all(1)
	style_btn_on.set_corner_radius_all(4)

	var style_focus = StyleBoxFlat.new()
	style_focus.bg_color = Color(0, 0, 0, 0)
	style_focus.border_color = Color(1.0, 0.85, 0.2, 1.0)
	style_focus.set_border_width_all(2)
	style_focus.set_corner_radius_all(6)

	var grab_tex = load("res://assets/ui/kenney_ui_pack/slide_hangle.png")

	# 1. AUDIO category
	var cat_audio_wrap = make_cat.call("CatHeaderAudio", "AUDIO", "오디오", 6)
	vbox.add_child(cat_audio_wrap)
	setting_cat_audio_lbl = cat_audio_wrap.get_node("HBox/Plate/Label")

	# RowSFX
	var row_sfx = HBoxContainer.new()
	row_sfx.name = "RowSFX"
	row_sfx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(row_sfx)

	var sfx_lbl = Label.new()
	sfx_lbl.name = "Label"
	sfx_lbl.custom_minimum_size = Vector2(280, 0)
	sfx_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sfx_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row_sfx.add_child(sfx_lbl)
	setting_row_labels["RowSFX"] = sfx_lbl

	setting_sfx_slider = HSlider.new()
	setting_sfx_slider.name = "Slider"
	setting_sfx_slider.custom_minimum_size = Vector2(180, 28)
	setting_sfx_slider.size_flags_horizontal = Control.SIZE_SHRINK_END
	setting_sfx_slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	setting_sfx_slider.min_value = 0.0
	setting_sfx_slider.max_value = 1.0
	setting_sfx_slider.step = 0.05
	setting_sfx_slider.value = GameState.sfx_volume
	if grab_tex:
		setting_sfx_slider.add_theme_icon_override("grabber", grab_tex)
		setting_sfx_slider.add_theme_icon_override("grabber_highlight", grab_tex)
	setting_sfx_slider.value_changed.connect(func(val):
		GameState.sfx_volume = val
		GameState.save_settings()
		if setting_sfx_val_lbl: setting_sfx_val_lbl.text = "%d%%" % int(round(val * 100.0))
		var db_val = linear_to_db(val)
		var idx1 = AudioServer.get_bus_index("SFX_WEAPON")
		if idx1 != -1: AudioServer.set_bus_volume_db(idx1, db_val)
		var idx2 = AudioServer.get_bus_index("SFX_UI")
		if idx2 != -1: AudioServer.set_bus_volume_db(idx2, db_val)
		var idx_master = AudioServer.get_bus_index("Master")
		if idx_master != -1: AudioServer.set_bus_volume_db(idx_master, db_val)
	)
	row_sfx.add_child(setting_sfx_slider)

	setting_sfx_val_lbl = Label.new()
	setting_sfx_val_lbl.name = "ValLabel"
	setting_sfx_val_lbl.custom_minimum_size = Vector2(52, 28)
	setting_sfx_val_lbl.size_flags_horizontal = Control.SIZE_SHRINK_END
	setting_sfx_val_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	setting_sfx_val_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	setting_sfx_val_lbl.add_theme_color_override("font_color", Color(1, 0.88, 0.3, 1))
	setting_sfx_val_lbl.add_theme_font_size_override("font_size", 14)
	setting_sfx_val_lbl.text = "%d%%" % int(round(GameState.sfx_volume * 100.0))
	setting_sfx_val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	setting_sfx_val_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row_sfx.add_child(setting_sfx_val_lbl)

	# 2. GAMEPLAY & CONTROLS category
	var cat_gameplay_wrap = make_cat.call("CatHeaderGameplay", "GAMEPLAY & CONTROLS", "조작 및 편의", 12)
	vbox.add_child(cat_gameplay_wrap)
	setting_cat_gameplay_lbl = cat_gameplay_wrap.get_node("HBox/Plate/Label")

	# RowSens
	var row_sens = HBoxContainer.new()
	row_sens.name = "RowSens"
	row_sens.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(row_sens)

	var sens_lbl = Label.new()
	sens_lbl.name = "Label"
	sens_lbl.custom_minimum_size = Vector2(280, 0)
	sens_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sens_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sens_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row_sens.add_child(sens_lbl)
	setting_row_labels["RowSens"] = sens_lbl

	setting_sens_slider = HSlider.new()
	setting_sens_slider.name = "Slider"
	setting_sens_slider.custom_minimum_size = Vector2(180, 28)
	setting_sens_slider.size_flags_horizontal = Control.SIZE_SHRINK_END
	setting_sens_slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	setting_sens_slider.min_value = 0.1
	setting_sens_slider.max_value = 2.0
	setting_sens_slider.step = 0.1
	setting_sens_slider.value = GameState.mouse_sensitivity
	if grab_tex:
		setting_sens_slider.add_theme_icon_override("grabber", grab_tex)
		setting_sens_slider.add_theme_icon_override("grabber_highlight", grab_tex)
	setting_sens_slider.value_changed.connect(func(val):
		GameState.mouse_sensitivity = val
		GameState.save_settings()
		if setting_sens_val_lbl: setting_sens_val_lbl.text = "%.1fx" % val
	)
	row_sens.add_child(setting_sens_slider)

	setting_sens_val_lbl = Label.new()
	setting_sens_val_lbl.name = "ValLabel"
	setting_sens_val_lbl.custom_minimum_size = Vector2(52, 28)
	setting_sens_val_lbl.size_flags_horizontal = Control.SIZE_SHRINK_END
	setting_sens_val_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	setting_sens_val_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	setting_sens_val_lbl.add_theme_color_override("font_color", Color(1, 0.88, 0.3, 1))
	setting_sens_val_lbl.add_theme_font_size_override("font_size", 14)
	setting_sens_val_lbl.text = "%.1fx" % GameState.mouse_sensitivity
	setting_sens_val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	setting_sens_val_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row_sens.add_child(setting_sens_val_lbl)

	# RowMotion
	var row_motion = HBoxContainer.new()
	row_motion.name = "RowMotion"
	row_motion.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(row_motion)

	var motion_lbl = Label.new()
	motion_lbl.name = "Label"
	motion_lbl.custom_minimum_size = Vector2(280, 0)
	motion_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	motion_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	motion_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row_motion.add_child(motion_lbl)
	setting_row_labels["RowMotion"] = motion_lbl

	setting_motion_check = Button.new()
	setting_motion_check.custom_minimum_size = Vector2(110, 34)
	setting_motion_check.size_flags_horizontal = Control.SIZE_SHRINK_END
	setting_motion_check.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	setting_motion_check.toggle_mode = true
	setting_motion_check.add_theme_stylebox_override("normal", style_btn_off)
	setting_motion_check.add_theme_stylebox_override("hover", style_btn_off)
	setting_motion_check.add_theme_stylebox_override("pressed", style_btn_on)
	setting_motion_check.add_theme_stylebox_override("focus", style_focus)
	setting_motion_check.toggled.connect(func(enabled):
		GameState.reduce_motion = enabled
		GameState.save_settings()
		_update_toggle_btn(setting_motion_check, enabled)
	)
	row_motion.add_child(setting_motion_check)

	# RowVibration
	var row_vibration = HBoxContainer.new()
	row_vibration.name = "RowVibration"
	row_vibration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(row_vibration)

	var vib_lbl = Label.new()
	vib_lbl.name = "Label"
	vib_lbl.custom_minimum_size = Vector2(280, 0)
	vib_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vib_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vib_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row_vibration.add_child(vib_lbl)
	setting_row_labels["RowVibration"] = vib_lbl

	setting_vibration_check = Button.new()
	setting_vibration_check.custom_minimum_size = Vector2(110, 34)
	setting_vibration_check.size_flags_horizontal = Control.SIZE_SHRINK_END
	setting_vibration_check.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	setting_vibration_check.toggle_mode = true
	setting_vibration_check.add_theme_stylebox_override("normal", style_btn_off)
	setting_vibration_check.add_theme_stylebox_override("hover", style_btn_off)
	setting_vibration_check.add_theme_stylebox_override("pressed", style_btn_on)
	setting_vibration_check.add_theme_stylebox_override("focus", style_focus)
	setting_vibration_check.toggled.connect(func(enabled):
		GameState.vibration_enabled = enabled
		GameState.save_settings()
		_update_toggle_btn(setting_vibration_check, enabled)
	)
	row_vibration.add_child(setting_vibration_check)

	# 3. DISPLAY & SYSTEM category
	var cat_system_wrap = make_cat.call("CatHeaderSystem", "DISPLAY & SYSTEM", "화면 및 시스템", 12)
	vbox.add_child(cat_system_wrap)
	setting_cat_system_lbl = cat_system_wrap.get_node("HBox/Plate/Label")

	# RowFullscreen
	var row_fs = HBoxContainer.new()
	row_fs.name = "RowFullscreen"
	row_fs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(row_fs)

	var fs_lbl = Label.new()
	fs_lbl.name = "Label"
	fs_lbl.custom_minimum_size = Vector2(280, 0)
	fs_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fs_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fs_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row_fs.add_child(fs_lbl)
	setting_row_labels["RowFullscreen"] = fs_lbl

	setting_fullscreen_check = Button.new()
	setting_fullscreen_check.custom_minimum_size = Vector2(110, 34)
	setting_fullscreen_check.size_flags_horizontal = Control.SIZE_SHRINK_END
	setting_fullscreen_check.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	setting_fullscreen_check.toggle_mode = true
	setting_fullscreen_check.add_theme_stylebox_override("normal", style_btn_off)
	setting_fullscreen_check.add_theme_stylebox_override("hover", style_btn_off)
	setting_fullscreen_check.add_theme_stylebox_override("pressed", style_btn_on)
	setting_fullscreen_check.add_theme_stylebox_override("focus", style_focus)
	setting_fullscreen_check.toggled.connect(func(enabled):
		GameState.fullscreen = enabled
		GameState.save_settings()
		_update_toggle_btn(setting_fullscreen_check, enabled)
		if enabled:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	)
	row_fs.add_child(setting_fullscreen_check)

	# RowLanguage
	var row_lang = HBoxContainer.new()
	row_lang.name = "RowLanguage"
	row_lang.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(row_lang)

	var lang_lbl = Label.new()
	lang_lbl.name = "Label"
	lang_lbl.custom_minimum_size = Vector2(280, 0)
	lang_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lang_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lang_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row_lang.add_child(lang_lbl)
	setting_row_labels["RowLanguage"] = lang_lbl

	var toggle_box = HBoxContainer.new()
	toggle_box.name = "ToggleBox"
	toggle_box.add_theme_constant_override("separation", 0)
	toggle_box.size_flags_horizontal = Control.SIZE_SHRINK_END
	row_lang.add_child(toggle_box)

	var baked_style = StyleBoxFlat.new()
	baked_style.bg_color = Color(0, 0, 0, 0)
	baked_style.set_border_width_all(0)
	baked_style.content_margin_left = 10
	baked_style.content_margin_right = 10
	baked_style.content_margin_top = 3
	baked_style.content_margin_bottom = 3

	setting_lang_btn_en = Button.new()
	setting_lang_btn_en.name = "LangEN"
	setting_lang_btn_en.text = "ENG"
	setting_lang_btn_en.add_theme_font_size_override("font_size", 14)
	setting_lang_btn_en.add_theme_constant_override("outline_size", 1)
	setting_lang_btn_en.add_theme_color_override("font_outline_color", Color.BLACK)
	setting_lang_btn_en.add_theme_stylebox_override("normal", baked_style)
	setting_lang_btn_en.add_theme_stylebox_override("hover", baked_style)
	setting_lang_btn_en.add_theme_stylebox_override("pressed", baked_style)
	setting_lang_btn_en.add_theme_stylebox_override("focus", style_focus)
	setting_lang_btn_en.pressed.connect(func():
		GameState.language = "EN"
		GameState.save_settings()
		_apply_settings_language()
	)
	toggle_box.add_child(setting_lang_btn_en)

	var lang_sep = Label.new()
	lang_sep.name = "Sep"
	lang_sep.text = " | "
	lang_sep.add_theme_font_size_override("font_size", 14)
	lang_sep.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 0.35))
	toggle_box.add_child(lang_sep)

	setting_lang_btn_kr = Button.new()
	setting_lang_btn_kr.name = "LangKR"
	setting_lang_btn_kr.text = "KOR"
	setting_lang_btn_kr.add_theme_font_size_override("font_size", 14)
	setting_lang_btn_kr.add_theme_constant_override("outline_size", 1)
	setting_lang_btn_kr.add_theme_color_override("font_outline_color", Color.BLACK)
	setting_lang_btn_kr.add_theme_stylebox_override("normal", baked_style)
	setting_lang_btn_kr.add_theme_stylebox_override("hover", baked_style)
	setting_lang_btn_kr.add_theme_stylebox_override("pressed", baked_style)
	setting_lang_btn_kr.add_theme_stylebox_override("focus", style_focus)
	setting_lang_btn_kr.pressed.connect(func():
		GameState.language = "KR"
		GameState.save_settings()
		_apply_settings_language()
	)
	toggle_box.add_child(setting_lang_btn_kr)

	# RowGoldSkin
	setting_gold_skin_row = HBoxContainer.new()
	setting_gold_skin_row.name = "RowGoldSkin"
	setting_gold_skin_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(setting_gold_skin_row)

	var gold_lbl = Label.new()
	gold_lbl.name = "Label"
	gold_lbl.custom_minimum_size = Vector2(280, 0)
	gold_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gold_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gold_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	setting_gold_skin_row.add_child(gold_lbl)
	setting_row_labels["RowGoldSkin"] = gold_lbl

	setting_gold_skin_check = Button.new()
	setting_gold_skin_check.custom_minimum_size = Vector2(110, 34)
	setting_gold_skin_check.size_flags_horizontal = Control.SIZE_SHRINK_END
	setting_gold_skin_check.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	setting_gold_skin_check.toggle_mode = true
	setting_gold_skin_check.add_theme_stylebox_override("normal", style_btn_off)
	setting_gold_skin_check.add_theme_stylebox_override("hover", style_btn_off)
	setting_gold_skin_check.add_theme_stylebox_override("pressed", style_btn_on)
	setting_gold_skin_check.add_theme_stylebox_override("focus", style_focus)
	setting_gold_skin_check.toggled.connect(func(enabled):
		GameState.gold_skin_enabled = enabled
		GameState.save_settings()
		_update_toggle_btn(setting_gold_skin_check, enabled)
	)
	setting_gold_skin_row.add_child(setting_gold_skin_check)

	# Divider 2
	var divider2 = HSeparator.new()
	divider2.name = "Divider2"
	var div2_style = StyleBoxLine.new()
	div2_style.color = Color(1.0, 0.88, 0.3, 0.35)
	div2_style.thickness = 1
	divider2.add_theme_stylebox_override("separator", div2_style)
	divider2.add_theme_constant_override("separation", 16)
	vbox.add_child(divider2)

	# Back button
	settings_back_btn = Button.new()
	settings_back_btn.name = "BackBtn"
	settings_back_btn.custom_minimum_size = Vector2(260, 38)
	settings_back_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color(0, 0, 0, 0.4)
	back_style.border_color = Color(1.0, 0.85, 0.2, 0.6)
	back_style.set_border_width_all(2)
	back_style.set_corner_radius_all(0)
	back_style.content_margin_left = 16
	back_style.content_margin_right = 16
	back_style.content_margin_top = 6
	back_style.content_margin_bottom = 6
	settings_back_btn.add_theme_stylebox_override("normal", back_style)
	var back_hover = back_style.duplicate()
	back_hover.bg_color = Color(1.0, 0.75, 0.15, 0.2)
	settings_back_btn.add_theme_stylebox_override("hover", back_hover)
	var back_pressed = back_style.duplicate()
	back_pressed.bg_color = Color(1.0, 0.85, 0.2, 0.4)
	back_pressed.border_color = Color(1.0, 0.9, 0.3, 1.0)
	settings_back_btn.add_theme_stylebox_override("pressed", back_pressed)
	settings_back_btn.add_theme_stylebox_override("focus", style_focus)
	settings_back_btn.pressed.connect(_hide_settings)
	vbox.add_child(settings_back_btn)

	# Close prompt
	settings_prompt_lbl = Label.new()
	settings_prompt_lbl.name = "ClosePrompt"
	settings_prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_prompt_lbl.add_theme_color_override("font_color", Color(1, 0.8, 0.2, 0.35))
	settings_prompt_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(settings_prompt_lbl)

func _show_settings() -> void:
	if is_starting or not settings_screen: return
	
	_update_toggle_btn(setting_motion_check, GameState.reduce_motion)
	_update_toggle_btn(setting_vibration_check, GameState.vibration_enabled)
	_update_toggle_btn(setting_fullscreen_check, GameState.fullscreen)
	_update_toggle_btn(setting_gold_skin_check, GameState.gold_skin_enabled)
	if setting_gold_skin_row:
		setting_gold_skin_row.visible = "dawn_breaks" in GameState.unlocked_achievements
	if setting_sfx_slider:
		setting_sfx_slider.value = GameState.sfx_volume
	if setting_sfx_val_lbl:
		setting_sfx_val_lbl.text = "%d%%" % int(round(GameState.sfx_volume * 100.0))
	if setting_sens_slider:
		setting_sens_slider.value = GameState.mouse_sensitivity
	if setting_sens_val_lbl:
		setting_sens_val_lbl.text = "%.1fx" % GameState.mouse_sensitivity
	
	_update_setting_lang_toggle(GameState.language == "KR")
	
	UIJuice.play_tick()
	
	settings_screen.modulate.a = 0.0
	settings_screen.visible = true
	var tw = create_tween()
	tw.tween_property(settings_screen, "modulate:a", 1.0, 0.2)
	await tw.finished
	if setting_sfx_slider: setting_sfx_slider.grab_focus()

func _hide_settings() -> void:
	if not settings_screen or not settings_screen.visible: return
	if settings_screen.get_meta("is_hiding", false): return
	settings_screen.set_meta("is_hiding", true)
	
	UIJuice.play_tick()
	
	var tw = create_tween()
	tw.tween_property(settings_screen, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func():
		settings_screen.visible = false
		settings_screen.set_meta("is_hiding", false)
		if settings_btn: settings_btn.grab_focus()
	)
