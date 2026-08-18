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
signal show_achievements()

var is_starting: bool = false
var best_time_lbl: Label = null
var ach_btn: Button

var achievements_screen: Control
var achievement_list: VBoxContainer
var border_progress: float = -1.0:
	set(value):
		border_progress = value
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


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if lang_btn:
		lang_btn.pressed.connect(_on_lang_btn_pressed)
		
	if dev_btn: dev_btn.visible = false
	
	# Dynamically add Achievements button
	ach_btn = dev_btn.duplicate()
	ach_btn.name = "AchievementsBtn"
	ach_btn.visible = true
	dev_btn.get_parent().add_child(ach_btn)
	ach_btn.pressed.connect(_show_achievements)
	
	_build_achievements_screen()
	_update_language()

func _update_language() -> void:

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
			survival_btn.text = "무한 모드 (잠김)" if is_kr else "ENDLESS MODE (LOCKED)"
		else:
			survival_btn.text = "무한 모드" if is_kr else "ENDLESS MODE"
	if dev_btn: dev_btn.text = "DEV"
	if ach_btn: ach_btn.text = "업적" if is_kr else "ACHIEVEMENTS"
	
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
			for btn in [normal_btn, survival_btn, dev_btn, lang_btn, ach_btn]:
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
				elif btn == ach_btn:
					style_pressed.bg_color = Color(0.9, 0.6, 0.1, 0.4)
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
	# Skip the first 1.5s of silence/low noise so the swell begins immediately
	add_child(startup_audio)
	startup_audio.play(1.5)
	
	# Hide original border while loading
	$BorderPanel.visible = false
	border_progress = 0.0
	
	var load_tw = create_tween()
	load_tw.tween_property(self, "border_progress", 1.0, 4.0).set_trans(Tween.TRANS_LINEAR)
	
	# Wait 4.0s for the audio swell to hit its peak
	await get_tree().create_timer(4.0).timeout
	
	# Transition from drawing to real panel
	border_progress = -1.0
	$BorderPanel.visible = true
	
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
	vbox.add_theme_constant_override("separation", 24)
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
	scroll.custom_minimum_size = Vector2(700, 440)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	vbox.add_child(scroll)
	
	var list_margin = MarginContainer.new()
	list_margin.add_theme_constant_override("margin_right", 16)
	scroll.add_child(list_margin)
	
	achievement_list = VBoxContainer.new()
	achievement_list.add_theme_constant_override("separation", 16)
	list_margin.add_child(achievement_list)
	
	var back_btn = Button.new()
	back_btn.name = "BackBtn"
	back_btn.text = "BACK"
	back_btn.custom_minimum_size = Vector2(280, 52)
	
	var btn_center = CenterContainer.new()
	btn_center.name = "CenterContainer"
	btn_center.add_child(back_btn)
	vbox.add_child(btn_center)
	
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
	_style_label(title, 36, Color(1.0, 0.85, 0.2, 1.0), font)
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
	back_btn.add_theme_font_size_override("font_size", 22)
	back_btn.add_theme_constant_override("letter_spacing", 1)
	back_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
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
	back_btn.add_theme_stylebox_override("pressed", style_menu_btn_hover)
	back_btn.add_theme_stylebox_override("focus", style_focus)
	
	for ach_id in GameState.ACHIEVEMENTS.keys():
		var ach = GameState.ACHIEVEMENTS[ach_id]
		var unlocked = ach_id in GameState.unlocked_achievements
		
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(660, 100)
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
		hbox.add_theme_constant_override("separation", 20)
		margin.add_child(hbox)
		
		var icon_rect = TextureRect.new()
		icon_rect.texture = load(ach["icon"]) if unlocked else load("res://assets/ui/ui_adventure/PNG/Default/minimap_icon_star_white.png")
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.custom_minimum_size = Vector2(64, 64)
		icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon_rect.modulate = Color(1.0, 1.0, 1.0, 1.0) if unlocked else Color(0.3, 0.3, 0.3, 0.5)
		hbox.add_child(icon_rect)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 0)
		hbox.add_child(vbox)
		
		var ach_title = Label.new()
		ach_title.text = (ach["title_kr"] if is_kr else ach["title_en"]) if unlocked else "???"
		_style_label(ach_title, 28, Color(1.0, 0.85, 0.2, 1.0) if unlocked else Color(0.5, 0.5, 0.5, 1.0), font)
		ach_title.add_theme_constant_override("outline_size", 2)
		ach_title.add_theme_color_override("font_outline_color", Color.BLACK)
		vbox.add_child(ach_title)
		
		var ach_desc = Label.new()
		ach_desc.text = (ach["desc_kr"] if is_kr else ach["desc_en"]) if unlocked else ("잠김" if is_kr else "LOCKED")
		ach_desc.custom_minimum_size = Vector2(550, 0)
		ach_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
		_style_label(ach_desc, 16, Color(1.0, 1.0, 1.0, 0.8) if unlocked else Color(0.4, 0.4, 0.4, 0.8), body_font)
		ach_desc.add_theme_constant_override("outline_size", 1)
		ach_desc.add_theme_color_override("font_outline_color", Color.BLACK)
		vbox.add_child(ach_desc)
		
		achievement_list.add_child(panel)

	achievements_screen.visible = true
	achievements_screen.modulate.a = 0.0
	achievements_screen.set_meta("is_hiding", false)
	var tw = create_tween()
	tw.tween_property(achievements_screen, "modulate:a", 1.0, 0.25)
	
	var back_node = achievements_screen.get_node_or_null("CenterContainer/VBoxContainer/CenterContainer/BackBtn")
	if back_node: back_node.grab_focus()
	
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/sfx/ui_tick.wav")
	audio.bus = "SFX"
	add_child(audio)
	audio.play()
	audio.finished.connect(audio.queue_free)

func _hide_achievements() -> void:
	if not achievements_screen or not achievements_screen.visible: return
	if achievements_screen.get_meta("is_hiding", false): return
	achievements_screen.set_meta("is_hiding", true)
	
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/sfx/ui_tick.wav")
	audio.bus = "SFX"
	add_child(audio)
	audio.play()
	audio.finished.connect(audio.queue_free)
	
	var tw = create_tween()
	tw.tween_property(achievements_screen, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func(): 
		achievements_screen.visible = false
		achievements_screen.set_meta("is_hiding", false)
		if ach_btn: ach_btn.grab_focus()
	)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if achievements_screen and achievements_screen.visible:
			_hide_achievements()
			get_viewport().set_input_as_handled()
