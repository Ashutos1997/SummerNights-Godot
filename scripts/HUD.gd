extends CanvasLayer

signal sensitivity_changed(value: float)
signal reduce_motion_changed(enabled: bool)

@onready var heat_bar = $HUD/SunHeatBar/HeatBar
@onready var heat_label = $HUD/SunHeatBar/Label
@onready var water_bar = $HUD/WaterBar/WaterBar
@onready var water_label = $HUD/WaterBar/Label
@onready var crosshair = $HUD/Crosshair
@onready var win_screen = $HUD/WinScreen
@onready var level_label = $HUD/LevelLabel
@onready var win_title_lbl = $HUD/WinScreen/ColorRect/VBoxContainer/Title
@onready var win_level_lbl = $HUD/WinScreen/ColorRect/VBoxContainer/LevelLbl
@onready var win_loading_lbl = $HUD/WinScreen/ColorRect/VBoxContainer/LoadingLbl
@onready var end_screen        = $HUD/EndScreen
@onready var end_title_lbl     = $HUD/EndScreen/ColorRect/VBoxContainer/Title
@onready var end_subtitle_lbl  = $HUD/EndScreen/ColorRect/VBoxContainer/Subtitle
@onready var end_level_lbl     = $HUD/EndScreen/ColorRect/VBoxContainer/LevelCount
@onready var end_prompt_lbl    = $HUD/EndScreen/ColorRect/VBoxContainer/RestartPrompt

@onready var timer_label       = $HUD/TimerLabel
@onready var phase2_label      = $HUD/Phase2Label
@onready var lose_screen       = $HUD/LoseScreen
@onready var lose_title_lbl    = $HUD/LoseScreen/ColorRect/VBoxContainer/Title
@onready var lose_subtitle_lbl = $HUD/LoseScreen/ColorRect/VBoxContainer/Subtitle
@onready var lose_level_lbl    = $HUD/LoseScreen/ColorRect/VBoxContainer/LevelLbl
@onready var retry_btn         = $HUD/LoseScreen/ColorRect/VBoxContainer/HBoxContainer/RetryBtn
@onready var menu_btn          = $HUD/LoseScreen/ColorRect/VBoxContainer/HBoxContainer/MenuBtn

@onready var settings_btn      = $HUD/TopRightButtons/SettingsBtn
@onready var settings_screen   = $HUD/SettingsScreen
@onready var settings_bg       = $HUD/SettingsScreen/BG
@onready var settings_title    = $HUD/SettingsScreen/CenterContainer/VBoxContainer/Title
@onready var settings_prompt   = $HUD/SettingsScreen/CenterContainer/VBoxContainer/ClosePrompt
@onready var sfx_slider        = $HUD/SettingsScreen/CenterContainer/VBoxContainer/RowSFX/Slider
@onready var sens_slider       = $HUD/SettingsScreen/CenterContainer/VBoxContainer/RowSens/Slider
@onready var motion_check      = $HUD/SettingsScreen/CenterContainer/VBoxContainer/RowMotion/Check
@onready var fullscreen_check  = $HUD/SettingsScreen/CenterContainer/VBoxContainer/RowFullscreen/Check
@onready var settings_back_btn = $HUD/SettingsScreen/CenterContainer/VBoxContainer/BackBtn

var kenney_font: Font
var galmuri_font: Font
var lang_btn_en: Button
var lang_btn_kr: Button

@onready var credits_btn      = $HUD/TopRightButtons/CreditsBtn
@onready var credits_screen   = $HUD/CreditsScreen
@onready var credits_bg       = $HUD/CreditsScreen/BG
@onready var credits_title    = $HUD/CreditsScreen/CenterContainer/VBoxContainer/Title
@onready var credits_prompt   = $HUD/CreditsScreen/CenterContainer/VBoxContainer/ClosePrompt
@onready var credits_vbox     = $HUD/CreditsScreen/CenterContainer/VBoxContainer
@onready var credits_back_btn = $HUD/CreditsScreen/CenterContainer/VBoxContainer/BackBtn

var water_tween: Tween
var hit_tween: Tween
var heat_tween: Tween

var reduce_motion: bool = false
var cursor_screen_pos: Vector2 = Vector2.ZERO  # Tracks virtual mouse for captured mode
var target_heat: float = 100.0
var target_water: float = 100.0

func _process(delta: float) -> void:
	if heat_bar:
		if reduce_motion:
			heat_bar.value = target_heat
		else:
			heat_bar.value = lerp(heat_bar.value, target_heat, 12.0 * delta)
			
	if water_bar:
		if reduce_motion:
			water_bar.value = target_water
		else:
			water_bar.value = lerp(water_bar.value, target_water, 12.0 * delta)
			
	# Update top right button hover colors in captured mode
	if credits_btn and not credits_screen.visible:
		var btn_rect = credits_btn.get_global_rect()
		var is_hovered = btn_rect.has_point(cursor_screen_pos)
		_on_credits_btn_hover(is_hovered)
		
	if settings_btn and not settings_screen.visible:
		var s_rect = settings_btn.get_global_rect()
		var s_hovered = s_rect.has_point(cursor_screen_pos)
		_on_settings_btn_hover(s_hovered)

func _ready() -> void:
	heat_label.scale = Vector2(1.0, 1.0)
	win_screen.visible = false
	settings_screen.visible = false
	credits_screen.visible = false
	lose_screen.visible = false
	phase2_label.visible = false
	timer_label.text = ""
	crosshair.pivot_offset = crosshair.size / 2.0
	win_screen.pivot_offset = get_viewport().get_visible_rect().size / 2.0
	
	reduce_motion = GameState.reduce_motion
	
	kenney_font = load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	galmuri_font = load("res://assets/fonts/Galmuri11.ttf")
	if kenney_font:
		print("HUD: Kenney Future font loaded.")
	else:
		print("HUD Warning: Kenney Future font not found.")
	if galmuri_font:
		print("HUD: Galmuri11 font loaded.")
	else:
		print("HUD Warning: Galmuri11 font not found.")
	var font = kenney_font
	
	_style_lbl(heat_label, 20, Color(1.0, 0.9, 0.3, 1.0), 3, Color.BLACK, font)
	_style_lbl(water_label, 20, Color(0.4, 0.9, 1.0, 1.0), 3, Color.BLACK, font)
	_style_lbl(level_label, 22, Color(1.0, 0.9, 0.3, 1.0), 3, Color.BLACK, font)
	
	var lvl_sz = level_label.get_theme_font_size("font_size")
	print("LVL label font size: ", lvl_sz)
	
	# Top right buttons — match LVL label font size (22px) exactly, WCAG contrast 13.4:1
	_style_lbl(credits_btn, lvl_sz, Color(1.0, 0.88, 0.3, 0.95), 2, Color.BLACK, font)
	_style_lbl(settings_btn, lvl_sz, Color(1.0, 0.88, 0.3, 0.95), 2, Color.BLACK, font)

	# New elements
	_style_lbl(timer_label, 22, Color(1.0, 0.8, 0.2, 1.0), 2, Color.BLACK, font)
	_style_lbl(phase2_label, 48, Color(1.0, 0.4, 0.1, 1.0), 3, Color.BLACK, font)
	
	_style_lbl(lose_title_lbl, 64, Color(1.0, 0.4, 0.1, 1.0), 3, Color.BLACK, font)
	_style_lbl(lose_subtitle_lbl, 22, Color(1.0, 0.4, 0.1, 0.65), 2, Color.BLACK, font)
	_style_lbl(lose_level_lbl, 16, Color(1.0, 0.8, 0.2, 0.5), 2, Color.BLACK, font)

	# Win screen labels — matches Credits title (32), section header (20), and body (16)
	_style_lbl(win_title_lbl, 32, Color(1.0, 0.9, 0.2, 1.0), 4, Color(0.0, 0.0, 0.0, 1.0), font)
	_style_lbl(win_level_lbl, 20, Color(1.0, 0.85, 0.2, 1.0), 4, Color(0.0, 0.0, 0.0, 1.0), font)
	_style_lbl(win_loading_lbl, 16, Color(1.0, 1.0, 1.0, 1.0), 3, Color.BLACK, font)
	
	# End screen labels — match Title screen (64 / 22 / 16 / 16)
	_style_lbl(end_title_lbl, 64, Color(1.0, 0.8, 0.2, 1.0), 3, Color.BLACK, font, 4)
	_style_lbl(end_subtitle_lbl, 22, Color(1.0, 0.85, 0.2, 1.0), 2, Color.BLACK, font)
	_style_lbl(end_level_lbl, 16, Color(1.0, 1.0, 1.0, 1.0), 1, Color.BLACK, font)
	_style_lbl(end_prompt_lbl, 16, Color(1.0, 1.0, 1.0, 1.0), 2, Color.BLACK, font)
	if end_prompt_lbl and not reduce_motion:
		var p_tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		p_tw.tween_property(end_prompt_lbl, "modulate:a", 0.7, 1.2)
		p_tw.tween_property(end_prompt_lbl, "modulate:a", 1.0, 1.2)
	elif end_prompt_lbl:
		end_prompt_lbl.modulate.a = 1.0
	_style_lbl(settings_title, 36, Color(1.0, 0.88, 0.3, 1.0), 4, Color.BLACK, font)
	_style_lbl(credits_title, 32, Color(1.0, 0.88, 0.3, 1.0), 4, Color.BLACK, font)
	
	# Close Prompts — Settings and Credits (WCAG 10.7:1 PASS)
	for p_lbl in [settings_prompt, credits_prompt]:
		if p_lbl:
			_style_lbl(p_lbl, 14, Color(1.0, 0.88, 0.3, 0.85), 1, Color.BLACK, font)
			if not reduce_motion:
				var sp_tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				sp_tw.tween_property(p_lbl, "modulate:a", 0.7, 1.2)
				sp_tw.tween_property(p_lbl, "modulate:a", 1.0, 1.2)
			else:
				p_lbl.modulate.a = 1.0
 
	# Row Labels styling (13.4:1 contrast PASS)
	for row_name in ["RowSFX", "RowSens", "RowMotion", "RowFullscreen"]:
		var r_node = $HUD/SettingsScreen/CenterContainer/VBoxContainer.get_node_or_null(row_name)
		if r_node:
			var r_lbl = r_node.get_node_or_null("Label")
			if r_lbl:
				_style_lbl(r_lbl, 20, Color(1.0, 0.85, 0.2, 1.0), 2, Color.BLACK, font)

	# Build language row programmatically (below RowFullscreen)
	_build_lang_row(font)

	# Slider texture overrides
	var grab_tex = load("res://assets/ui/kenney_ui_pack/slide_hangle.png")
	if grab_tex:
		sfx_slider.add_theme_icon_override("grabber", grab_tex)
		sfx_slider.add_theme_icon_override("grabber_highlight", grab_tex)
		sens_slider.add_theme_icon_override("grabber", grab_tex)
		sens_slider.add_theme_icon_override("grabber_highlight", grab_tex)

	# Style Back buttons (transparent background, amber outline, 13.4:1 contrast, 160x44px, 20px font)
	var style_back = StyleBoxFlat.new()
	style_back.bg_color = Color(0, 0, 0, 0)
	style_back.border_color = Color(1.0, 0.88, 0.3, 0.7)
	style_back.set_border_width_all(1)
	style_back.set_corner_radius_all(4)

	var style_back_hover = StyleBoxFlat.new()
	style_back_hover.bg_color = Color(1.0, 0.88, 0.3, 0.15)
	style_back_hover.border_color = Color(1.0, 0.88, 0.3, 1.0)
	style_back_hover.set_border_width_all(1)
	style_back_hover.set_corner_radius_all(4)

	for btn in [settings_back_btn, credits_back_btn]:
		if btn:
			if font: btn.add_theme_font_override("font", font)
			btn.add_theme_font_size_override("font_size", 20)
			btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 0.95))
			btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.6, 1.0))
			btn.add_theme_constant_override("outline_size", 2)
			btn.add_theme_color_override("font_outline_color", Color.BLACK)
			btn.add_theme_stylebox_override("normal", style_back)
			btn.add_theme_stylebox_override("hover", style_back_hover)
			btn.add_theme_stylebox_override("pressed", style_back_hover)
			btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	# Lose Screen buttons
	for btn in [retry_btn, menu_btn]:
		if btn:
			if font: btn.add_theme_font_override("font", font)
			btn.add_theme_font_size_override("font_size", 18)
			btn.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))
			btn.add_theme_constant_override("outline_size", 2)
			btn.add_theme_color_override("font_outline_color", Color.BLACK)
			btn.add_theme_stylebox_override("normal", style_back)
			btn.add_theme_stylebox_override("hover", style_back_hover)
			btn.add_theme_stylebox_override("pressed", style_back_hover)
			btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
			
	if retry_btn:
		retry_btn.pressed.connect(_on_retry_pressed)
	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)

	# Style Toggle Buttons (OFF / ON - High WCAG Contrast 11.7:1 OFF / 13.6:1 ON)
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

	for btn in [motion_check, fullscreen_check]:
		if btn:
			if font: btn.add_theme_font_override("font", font)
			btn.add_theme_font_size_override("font_size", 18)
			btn.add_theme_constant_override("outline_size", 2)
			btn.add_theme_color_override("font_outline_color", Color.BLACK)
			btn.add_theme_stylebox_override("normal", style_btn_off)
			btn.add_theme_stylebox_override("hover", style_btn_off)
			btn.add_theme_stylebox_override("pressed", style_btn_on)
			btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	# Apply GameState values to controls
	sfx_slider.value = GameState.sfx_volume
	sens_slider.value = GameState.mouse_sensitivity
	motion_check.button_pressed = GameState.reduce_motion
	fullscreen_check.button_pressed = GameState.fullscreen

	# Connect control signals
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	sens_slider.value_changed.connect(_on_sens_changed)
	motion_check.toggled.connect(_on_motion_toggled)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	
	if settings_back_btn:
		settings_back_btn.pressed.connect(_close_settings)
	if credits_back_btn:
		credits_back_btn.pressed.connect(_close_credits)

	# Apply initial values
	_on_sfx_volume_changed(GameState.sfx_volume)
	_on_sens_changed(GameState.mouse_sensitivity)
	_on_motion_toggled(GameState.reduce_motion)
	_on_fullscreen_toggled(GameState.fullscreen)
	_apply_language(GameState.language)
	
	
	# Top right button hover/input connections
	credits_btn.mouse_entered.connect(_on_credits_btn_hover.bind(true))
	credits_btn.mouse_exited.connect(_on_credits_btn_hover.bind(false))
	credits_btn.gui_input.connect(_on_credits_btn_input)

	settings_btn.mouse_entered.connect(_on_settings_btn_hover.bind(true))
	settings_btn.mouse_exited.connect(_on_settings_btn_hover.bind(false))
	settings_btn.gui_input.connect(_on_settings_btn_input)

	# Accessibility Metadata
	heat_bar.set_meta("accessible_name", "Sun heat level")
	water_bar.set_meta("accessible_name", "Water gun level")  
	level_label.set_meta("accessible_name", "Current level")
	crosshair.set_meta("accessible_name", "Crosshair")
	win_screen.set_meta("accessible_name", "Level complete screen")
	settings_screen.set_meta("accessible_name", "Settings screen")
	credits_screen.set_meta("accessible_name", "Credits screen")
	
	_audit_labels()

# ---------- Language -------------------------------------------------------

func _build_lang_row(font: Font) -> void:
	var vbox = $HUD/SettingsScreen/CenterContainer/VBoxContainer
	if not vbox: return

	# Hide divider and spacer so language row flows flush with other rows
	var divider2 = vbox.get_node_or_null("Divider2")
	if divider2: divider2.visible = false
	var spacer_prompt = vbox.get_node_or_null("SpacerPrompt")
	if spacer_prompt: spacer_prompt.visible = false

	var row = HBoxContainer.new()
	row.name = "RowLanguage"
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 16)

	var lbl = Label.new()
	lbl.name = "Label"
	lbl.text = "Language"
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_lbl(lbl, 24, Color(1.0, 0.88, 0.3, 0.95), 2, Color.BLACK, font)
	row.add_child(lbl)

	# ENG | KOR inline toggle (matches ON/OFF button visual language)
	var toggle_box = HBoxContainer.new()
	toggle_box.add_theme_constant_override("separation", 0)
	toggle_box.size_flags_horizontal = Control.SIZE_SHRINK_END

	# ENG button
	var btn_en = Button.new()
	btn_en.name = "LangEN"
	btn_en.text = "ENG"
	if kenney_font: btn_en.add_theme_font_override("font", kenney_font)
	btn_en.add_theme_font_size_override("font_size", 18)
	btn_en.add_theme_constant_override("outline_size", 1)
	btn_en.add_theme_color_override("font_outline_color", Color.BLACK)
	btn_en.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_en.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	btn_en.pressed.connect(func(): _on_language_toggle("EN"))
	toggle_box.add_child(btn_en)
	lang_btn_en = btn_en

	# Separator
	var sep = Label.new()
	sep.text = " | "
	if kenney_font: sep.add_theme_font_override("font", kenney_font)
	sep.add_theme_font_size_override("font_size", 18)
	sep.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 0.35))
	toggle_box.add_child(sep)

	# KOR button
	var btn_kr = Button.new()
	btn_kr.name = "LangKR"
	btn_kr.text = "KOR"
	if kenney_font: btn_kr.add_theme_font_override("font", kenney_font)
	btn_kr.add_theme_font_size_override("font_size", 18)
	btn_kr.add_theme_constant_override("outline_size", 1)
	btn_kr.add_theme_color_override("font_outline_color", Color.BLACK)
	btn_kr.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_kr.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	btn_kr.pressed.connect(func(): _on_language_toggle("KR"))
	toggle_box.add_child(btn_kr)
	lang_btn_kr = btn_kr

	# Fixed-size stylebox baked once so runtime toggles never cause layout reflow
	var baked_style := StyleBoxFlat.new()
	baked_style.bg_color = Color(0, 0, 0, 0)
	baked_style.set_border_width_all(0)
	baked_style.content_margin_left = 10
	baked_style.content_margin_right = 10
	baked_style.content_margin_top = 3
	baked_style.content_margin_bottom = 3
	for b in [btn_en, btn_kr]:
		b.add_theme_stylebox_override("normal", baked_style)
		b.add_theme_stylebox_override("hover", baked_style)
		b.add_theme_stylebox_override("pressed", baked_style)

	row.add_child(toggle_box)

	# Insert right before BackBtn
	var back_btn = vbox.get_node_or_null("BackBtn")
	if back_btn:
		vbox.add_child(row)
		vbox.move_child(row, back_btn.get_index())
	else:
		vbox.add_child(row)

func _update_lang_toggle(is_kr: bool) -> void:
	# Color-only update — styleboxes are baked at build time, no layout reflow
	if lang_btn_en:
		lang_btn_en.add_theme_color_override("font_color",
			Color(1.0, 0.88, 0.3, 1.0) if not is_kr else Color(0.75, 0.75, 0.75, 0.45))
	if lang_btn_kr:
		lang_btn_kr.add_theme_color_override("font_color",
			Color(1.0, 0.88, 0.3, 1.0) if is_kr else Color(0.75, 0.75, 0.75, 0.45))

func _on_language_toggle(lang: String) -> void:
	GameState.language = lang
	_apply_language(lang)

func _apply_language(lang: String) -> void:
	var is_kr := lang == "KR"
	var font: Font = galmuri_font if is_kr else kenney_font

	# ── Gameplay HUD (Galmuri11 is small, so we scale it up in KR to visually match EN) ──
	if heat_label:
		heat_label.text = "열기" if is_kr else "HEAT"
		if font: heat_label.add_theme_font_override("font", font)
		heat_label.add_theme_font_size_override("font_size", 24 if is_kr else 20)
	if water_label:
		water_label.text = "물" if is_kr else "WATER"
		if font: water_label.add_theme_font_override("font", font)
		water_label.add_theme_font_size_override("font_size", 24 if is_kr else 20)
	if level_label:
		level_label.text = "%02d 단계" % GameState.level if is_kr else "LVL  %02d" % GameState.level
		if font: level_label.add_theme_font_override("font", font)
		level_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)

	# ── Top-right labels (in HBoxContainer, sizes scaled to match visually) ──
	if settings_btn:
		settings_btn.text = "설정" if is_kr else "SETTINGS"
		if font: settings_btn.add_theme_font_override("font", font)
		settings_btn.add_theme_font_size_override("font_size", 26 if is_kr else 22)
	if credits_btn:
		credits_btn.text = "크레딧" if is_kr else "CREDITS"
		if font: credits_btn.add_theme_font_override("font", font)
		credits_btn.add_theme_font_size_override("font_size", 26 if is_kr else 22)

	# ── Settings panel ────────────────────────────────────────────────────────
	var settings_vbox = $HUD/SettingsScreen/CenterContainer/VBoxContainer
	if settings_title:
		settings_title.text = "설정" if is_kr else "SETTINGS"
		if font: settings_title.add_theme_font_override("font", font)
		settings_title.add_theme_font_size_override("font_size", 36)
		settings_title.add_theme_constant_override("outline_size", 4)
		settings_title.add_theme_color_override("font_outline_color", Color.BLACK)

	# Style separators cleanly to match the Credits screen
	var sep_style = StyleBoxLine.new()
	sep_style.color = Color(1.0, 0.88, 0.3, 0.35)
	sep_style.grow_begin = 0
	sep_style.grow_end = 0
	sep_style.thickness = 2
	if settings_vbox:
		for sep_name in ["Divider", "Divider2"]:
			var sep = settings_vbox.get_node_or_null(sep_name)
			if sep:
				sep.add_theme_stylebox_override("separator", sep_style)

	var row_texts_en := ["SFX Volume", "Sensitivity", "Reduce Motion", "Fullscreen", "Language"]
	var row_texts_kr := ["효과음 볼륨", "감도", "화면 움직임 감소", "전체 화면", "언어"]
	var row_names    := ["RowSFX", "RowSens", "RowMotion", "RowFullscreen", "RowLanguage"]
	if settings_vbox:
		for i in range(row_names.size()):
			var r = settings_vbox.get_node_or_null(row_names[i])
			if r:
				var r_lbl = r.get_node_or_null("Label")
				if r_lbl:
					r_lbl.text = row_texts_kr[i] if is_kr else row_texts_en[i]
					if font: r_lbl.add_theme_font_override("font", font)
					r_lbl.add_theme_font_size_override("font_size", 20)
					r_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
					r_lbl.add_theme_constant_override("outline_size", 2)
					r_lbl.add_theme_color_override("font_outline_color", Color.BLACK)

	for btn in [settings_back_btn]:
		if btn:
			btn.text = "뒤로" if is_kr else "BACK"
			if font: btn.add_theme_font_override("font", font)

	if settings_prompt:
		if font: settings_prompt.add_theme_font_override("font", font)

	# ── Credits panel ─────────────────────────────────────────────────────────
	if credits_title:
		credits_title.text = "크레딧" if is_kr else "CREDITS"
		if font: credits_title.add_theme_font_override("font", font)
		credits_title.add_theme_font_size_override("font_size", 36)
		credits_title.add_theme_constant_override("outline_size", 4)
		credits_title.add_theme_color_override("font_outline_color", Color.BLACK)

	# Style separators cleanly
	sep_style = StyleBoxLine.new()
	sep_style.color = Color(1.0, 0.88, 0.3, 0.35)
	sep_style.grow_begin = 0
	sep_style.grow_end = 0
	sep_style.thickness = 2
	for sep_name in ["Divider", "Divider2"]:
		var sep = credits_vbox.get_node_or_null(sep_name)
		if sep:
			sep.add_theme_stylebox_override("separator", sep_style)

	# Style the 2-column credits content dynamically with clear text hierarchy and sizing
	var col_container = credits_vbox.get_node_or_null("ColContainer")
	if col_container:
		for col in [col_container.get_node_or_null("ColLeft"), col_container.get_node_or_null("ColRight")]:
			if col:
				for child in col.get_children():
					if child is Label:
						if font: child.add_theme_font_override("font", font)
						var is_header = child.name.begins_with("Hdr")
						child.add_theme_font_size_override("font_size", 20 if is_header else 15)
						# Outline and colors
						child.add_theme_constant_override("outline_size", 3 if is_header else 2)
						child.add_theme_color_override("font_outline_color", Color.BLACK)
						if is_header:
							child.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
						else:
							child.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 0.9))

	for btn in [credits_back_btn]:
		if btn:
			btn.text = "뒤로" if is_kr else "BACK"
			if font: btn.add_theme_font_override("font", font)

	if credits_prompt:
		if font: credits_prompt.add_theme_font_override("font", font)

	# ── Win screen ────────────────────────────────────────────────────────────
	if win_title_lbl:
		win_title_lbl.text = "냉각 완료!" if is_kr else "COOLED DOWN!"
		if font: win_title_lbl.add_theme_font_override("font", font)
	if win_loading_lbl:
		win_loading_lbl.text = "다음 단계 로딩 중..." if is_kr else "Next level loading..."
		if font: win_loading_lbl.add_theme_font_override("font", font)

	# ── Lose screen & Phase 2 ─────────────────────────────────────────────────
	if lose_title_lbl:
		lose_title_lbl.text = "태양이 이겼습니다" if is_kr else "☀ THE SUN WON"
		if font: lose_title_lbl.add_theme_font_override("font", font)
	if lose_subtitle_lbl:
		lose_subtitle_lbl.text = "너무 뜨겁습니다" if is_kr else "TOO HOT TO HANDLE"
		if font: lose_subtitle_lbl.add_theme_font_override("font", font)
	if lose_level_lbl:
		lose_level_lbl.text = "%02d 단계 실패" % GameState.level if is_kr else "LEVEL %02d FAILED" % GameState.level
		if font: lose_level_lbl.add_theme_font_override("font", font)
	if retry_btn:
		retry_btn.text = "다시 시도" if is_kr else "RETRY"
		if font: retry_btn.add_theme_font_override("font", font)
	if menu_btn:
		menu_btn.text = "메인 메뉴" if is_kr else "MAIN MENU"
		if font: menu_btn.add_theme_font_override("font", font)
	if phase2_label:
		phase2_label.text = "2단계" if is_kr else "PHASE 2"
		if font: phase2_label.add_theme_font_override("font", font)

	# ── End screen ────────────────────────────────────────────────────────────
	if end_title_lbl:
		end_title_lbl.text = "여름 끝!" if is_kr else "SUMMER'S OVER"
		if font: end_title_lbl.add_theme_font_override("font", font)
	if end_subtitle_lbl:
		end_subtitle_lbl.text = "태양이 식었습니다." if is_kr else "The sun has been tamed."
		if font: end_subtitle_lbl.add_theme_font_override("font", font)
	if end_prompt_lbl:
		end_prompt_lbl.text = "클릭 또는 스페이스바로 재시작" if is_kr else "Click or press Space to restart"
		if font: end_prompt_lbl.add_theme_font_override("font", font)

	# ── Toggle highlight (color-only, no layout impact) ───────────────────────
	_update_lang_toggle(is_kr)


# ---------- Toggle button ---------------------------------------------------

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

func _on_sfx_volume_changed(val: float) -> void:
	GameState.sfx_volume = val
	var db_val = linear_to_db(val)
	var idx1 = AudioServer.get_bus_index("SFX_WEAPON")
	if idx1 != -1: AudioServer.set_bus_volume_db(idx1, db_val)
	var idx2 = AudioServer.get_bus_index("SFX_UI")
	if idx2 != -1: AudioServer.set_bus_volume_db(idx2, db_val)

func _on_sens_changed(val: float) -> void:
	GameState.mouse_sensitivity = val
	sensitivity_changed.emit(val)

func _on_motion_toggled(enabled: bool) -> void:
	GameState.reduce_motion = enabled
	reduce_motion = enabled
	reduce_motion_changed.emit(enabled)
	_update_toggle_btn(motion_check, enabled)

func _on_fullscreen_toggled(toggled: bool) -> void:
	GameState.fullscreen = toggled
	_update_toggle_btn(fullscreen_check, toggled)
	if toggled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _audit_labels() -> void:
	_register_labels_recursive(self)
	print("--- HUD LABEL AUDIT ---")
	for label in get_tree().get_nodes_in_group("labels"):
		if label.is_inside_tree() and (label.get_tree().current_scene == self or label.get_parent() != null):
			var sz = label.get_theme_font_size("font_size")
			print(label.name, " font_size: ", sz)

func _register_labels_recursive(node: Node) -> void:
	if node is Label:
		if not node.is_in_group("labels"):
			node.add_to_group("labels")
	for child in node.get_children():
		_register_labels_recursive(child)

func _style_lbl(lbl: Label, size: int, color: Color, out_size: int, out_color: Color, font: Font = null, letter_space: int = 0) -> void:
	if not lbl: return
	if font:
		lbl.add_theme_font_override("font", font)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	if out_size > 0:
		lbl.add_theme_constant_override("outline_size", out_size)
		lbl.add_theme_color_override("font_outline_color", out_color)
	if letter_space > 0:
		lbl.add_theme_constant_override("letter_spacing", letter_space)

func _on_heat_changed(value: float, max_value: float) -> void:
	heat_bar.max_value = max_value
	target_heat = value
	
	var ratio = value / max_value
	if ratio > 0.66:
		heat_bar.tint_progress = Color(1.0, 0.3, 0.1) # hot red-orange
	elif ratio > 0.33:
		heat_bar.tint_progress = Color(1.0, 0.65, 0.1) # amber
	else:
		heat_bar.tint_progress = Color(0.4, 0.9, 0.4) # cool green

func _on_water_changed(value: float, max_value: float) -> void:
	water_bar.max_value = max_value
	target_water = value
	
	var ratio = value / max_value
	if ratio < 0.2:
		if reduce_motion:
			water_bar.tint_progress = Color(1.0, 0.2, 0.2, 1.0)
			water_bar.modulate.a = 1.0
		else:
			water_bar.tint_progress = Color(0.3, 0.75, 1.0)
			if not is_instance_valid(water_tween) or not water_tween.is_running():
				water_tween = create_tween()
				water_tween.set_loops()
				water_tween.tween_property(water_bar, "modulate:a", 0.4, 0.4)
				water_tween.tween_property(water_bar, "modulate:a", 1.0, 0.4)
	else:
		water_bar.tint_progress = Color(0.3, 0.75, 1.0)
		if is_instance_valid(water_tween):
			water_tween.kill()
		water_bar.modulate.a = 1.0

func _on_crosshair_moved(screen_pos: Vector2, is_behind: bool) -> void:
	crosshair.visible = not is_behind
	var viewport_size = get_viewport().get_visible_rect().size
	var target_pos = screen_pos - crosshair.size * 0.5
	target_pos.x = clamp(target_pos.x, 0, viewport_size.x - crosshair.size.x)
	target_pos.y = clamp(target_pos.y, 0, viewport_size.y - crosshair.size.y)
	crosshair.set_deferred("position", target_pos)
	
	# Align virtual cursor exactly to the center of the visual crosshair
	cursor_screen_pos = target_pos + crosshair.size * 0.5

func _on_projectile_hit() -> void:
	if reduce_motion:
		if is_instance_valid(hit_tween): hit_tween.kill()
		hit_tween = create_tween()
		crosshair.modulate.a = 1.0
		hit_tween.tween_property(crosshair, "modulate:a", 0.5, 0.1)
		return

	if is_instance_valid(hit_tween):
		hit_tween.kill()
	hit_tween = create_tween()
	hit_tween.tween_property(crosshair, "scale", Vector2(1.4, 1.4), 0.08)
	hit_tween.tween_property(crosshair, "scale", Vector2(1.0, 1.0), 0.12)

func _on_critical_hit() -> void:
	if reduce_motion:
		if is_instance_valid(hit_tween): hit_tween.kill()
		hit_tween = create_tween()
		crosshair.modulate = Color(1.0, 0.95, 0.4, 1.0)
		hit_tween.tween_property(crosshair, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)
		return

	if is_instance_valid(hit_tween):
		hit_tween.kill()
	hit_tween = create_tween()
	crosshair.modulate = Color(1.0, 0.95, 0.4, 1.0)
	hit_tween.tween_property(crosshair, "scale", Vector2(1.8, 1.8), 0.08)
	hit_tween.tween_property(crosshair, "scale", Vector2(1.0, 1.0), 0.12)
	hit_tween.tween_property(crosshair, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)

func _on_sun_defeated(level: int) -> void:
	level_label.text = "LVL  %02d" % level
	if win_level_lbl:
		win_level_lbl.text = "LEVEL %02d COMPLETE" % level
	
	win_screen.visible = true
	win_screen.modulate.a = 0.0
	win_screen.scale = Vector2(1.0, 1.0)
	
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_SINE)
	tw.tween_property(win_screen, "modulate:a", 1.0, 0.35)
		
	await get_tree().create_timer(2.5).timeout
	if win_screen.visible:
		var hide_tw = create_tween()
		hide_tw.tween_property(win_screen, "modulate:a", 0.0, 0.3)
		hide_tw.tween_callback(func(): win_screen.visible = false)

func show_end_screen() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if win_screen: win_screen.visible = false
	if credits_screen: credits_screen.visible = false
	if settings_screen: settings_screen.visible = false
	if lose_screen: lose_screen.visible = false
	end_screen.visible = true
	end_screen.modulate.a = 0.0
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(end_screen, "modulate:a", 1.0, 0.4)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if settings_screen and settings_screen.visible:
			_close_settings()
			get_viewport().set_input_as_handled()
			return
		elif credits_screen and credits_screen.visible:
			_close_credits()
			get_viewport().set_input_as_handled()
			return

	if end_screen and end_screen.visible:
		if (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE) or (event is InputEventMouseButton and event.pressed):
			GameState.reset()
			get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
			get_viewport().set_input_as_handled()
			return
			
	# Handle top right button clicks in captured mouse mode via virtual cursor position
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not settings_screen.visible and not credits_screen.visible:
			var s_rect = settings_btn.get_global_rect()
			if s_rect.has_point(cursor_screen_pos):
				_open_settings()
				get_viewport().set_input_as_handled()
				return
			var c_rect = credits_btn.get_global_rect()
			if c_rect.has_point(cursor_screen_pos):
				_open_credits()
				get_viewport().set_input_as_handled()
				return

func _on_settings_btn_hover(hovered: bool) -> void:
	if hovered:
		settings_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 0.6, 1.0))
	else:
		settings_btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 0.95))

func _on_settings_btn_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_open_settings()

func _open_settings() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if credits_screen: credits_screen.visible = false
	settings_screen.visible = true
	settings_screen.modulate.a = 0.0
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(settings_screen, "modulate:a", 1.0, 0.3)

func _close_settings() -> void:
	var tw = create_tween()
	tw.tween_property(settings_screen, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func():
		settings_screen.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	)

func _on_credits_btn_hover(hovered: bool) -> void:
	if hovered:
		credits_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 0.6, 1.0))
	else:
		credits_btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 0.95))

func _on_credits_btn_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_open_credits()

func _open_credits() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if settings_screen: settings_screen.visible = false
	credits_screen.visible = true
	credits_screen.modulate.a = 0.0
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(credits_screen, "modulate:a", 1.0, 0.25)

func _close_credits() -> void:
	var tw = create_tween()
	tw.tween_property(credits_screen, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func():
		credits_screen.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	)

func hide_win_screen() -> void:
	if win_screen:
		win_screen.visible = false
		win_screen.modulate.a = 0.0

var timer_pulse_active: bool = false

func _on_timer_tick(seconds: float) -> void:
	if not timer_label: return
	var secs = max(0, int(seconds))
	timer_label.text = "%02d" % secs
	
	if seconds <= 10.0:
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2, 1.0))
		if not timer_pulse_active:
			timer_pulse_active = true
			var tw = create_tween().set_loops()
			tw.tween_property(timer_label, "modulate:a", 0.3, 0.4)
			tw.tween_property(timer_label, "modulate:a", 1.0, 0.4)

func _on_timer_expired() -> void:
	show_lose_screen()

func show_lose_screen() -> void:
	if not lose_screen: return
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if lose_level_lbl:
		lose_level_lbl.text = "%02d 단계 실패" % GameState.level if GameState.language == "KR" else "LEVEL %02d FAILED" % GameState.level
	lose_screen.visible = true
	lose_screen.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(lose_screen, "modulate:a", 1.0, 0.4)
	tw.set_ease(Tween.EASE_OUT)

func _on_phase2_started() -> void:
	var flash = ColorRect.new()
	flash.color = Color(1.0, 0.5, 0.0, 0.4)
	flash.anchor_right = 1.0
	flash.anchor_bottom = 1.0
	flash.z_index = 150
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	var tw = create_tween()
	tw.tween_property(flash, "modulate:a", 0.0, 0.5)
	tw.tween_callback(flash.queue_free)
	
	if phase2_label:
		phase2_label.modulate.a = 0.0
		phase2_label.visible = true
		var p_tw = create_tween()
		p_tw.tween_property(phase2_label, "modulate:a", 1.0, 0.5)
		p_tw.tween_interval(1.5)
		p_tw.tween_property(phase2_label, "modulate:a", 0.0, 0.5)
		p_tw.tween_callback(func(): phase2_label.visible = false)

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	GameState.level = 1
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
