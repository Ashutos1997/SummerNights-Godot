extends CanvasLayer

signal sensitivity_changed(value: float)
signal reduce_motion_changed(enabled: bool)
signal weapon_changed(weapon_id: String)

@onready var weapon_wheel = $HUD/WeaponWheel
@onready var heat_bar = $HUD/SunHeatBar/HeatBar
@onready var heat_label = $HUD/SunHeatBar/Label
@onready var water_bar_container = $HUD/resource_container/water_row
@onready var water_bar = $HUD/resource_container/water_row/WaterBar
@onready var water_label = $HUD/resource_container/water_row/Label

@onready var ice_row = $HUD/resource_container/ice_row
@onready var ice_label = $HUD/resource_container/ice_row/Label
@onready var ice_bar = $HUD/resource_container/ice_row/IceBarContainer/IceBar
@onready var charge_dots = $HUD/resource_container/ice_row/IceBarContainer/ChargeDots
@onready var ice_unlock_label = $HUD/UnlockPrompts/IceUnlockLabel
@onready var weapon_unlock_label = $HUD/UnlockPrompts/WeaponUnlockLabel
@onready var crosshair = $HUD/Crosshair
@onready var win_screen = $HUD/WinScreen
@onready var level_label = $HUD/LevelLabel
@onready var win_title_lbl = $HUD/WinScreen/ColorRect/VBoxContainer/Title
@onready var win_level_lbl = $HUD/WinScreen/ColorRect/VBoxContainer/LevelLbl
@onready var win_loading_lbl = $HUD/WinScreen/ColorRect/VBoxContainer/LoadingLbl
@onready var end_screen        = $HUD/EndScreen
@onready var end_title_lbl     = $HUD/EndScreen/ColorRect/VBoxContainer/Title
@onready var end_title2_lbl    = $HUD/EndScreen/ColorRect/VBoxContainer/Title2
@onready var end_subtitle_lbl  = $HUD/EndScreen/ColorRect/VBoxContainer/Subtitle
@onready var end_level_lbl     = $HUD/EndScreen/ColorRect/VBoxContainer/LevelCount
@onready var end_prompt_lbl    = $HUD/EndScreen/ColorRect/VBoxContainer/RestartPrompt

@onready var timer_label       = $HUD/TimerLabel
@onready var phase2_label      = $HUD/Phase2Label
@onready var lose_screen       = $HUD/LoseScreen
@onready var lose_title_lbl    = $HUD/LoseScreen/ColorRect/VBoxContainer/Title
@onready var lose_title2_lbl   = $HUD/LoseScreen/ColorRect/VBoxContainer/Title2
@onready var lose_subtitle_lbl = $HUD/LoseScreen/ColorRect/VBoxContainer/Subtitle
@onready var lose_level_lbl    = $HUD/LoseScreen/ColorRect/VBoxContainer/LevelLbl
@onready var lose_wave_time_lbl= $HUD/LoseScreen/ColorRect/VBoxContainer/WaveTimeLbl
@onready var retry_btn         = $HUD/LoseScreen/ColorRect/VBoxContainer/HBoxContainer/RetryBtn
@onready var menu_btn          = $HUD/LoseScreen/ColorRect/VBoxContainer/HBoxContainer/MenuBtn

@onready var pause_screen       = $HUD/pause_screen
@onready var pause_title        = $HUD/pause_screen/ColorRect/VBoxContainer/Title
@onready var pause_resume_btn   = $HUD/pause_screen/ColorRect/VBoxContainer/ResumeBtn
@onready var settings_btn       = $HUD/pause_screen/ColorRect/VBoxContainer/SettingsBtn
@onready var credits_btn        = $HUD/pause_screen/ColorRect/VBoxContainer/CreditsBtn
@onready var pause_menu_btn     = $HUD/pause_screen/ColorRect/VBoxContainer/MainMenuBtn
@onready var esc_hint_label     = $HUD/esc_hint_label

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

@onready var credits_screen   = $HUD/CreditsScreen
@onready var credits_bg       = $HUD/CreditsScreen/BG
@onready var credits_title    = $HUD/CreditsScreen/CenterContainer/VBoxContainer/Title
@onready var credits_prompt   = $HUD/CreditsScreen/CenterContainer/VBoxContainer/ClosePrompt
@onready var credits_vbox     = $HUD/CreditsScreen/CenterContainer/VBoxContainer
@onready var credits_back_btn = $HUD/CreditsScreen/CenterContainer/VBoxContainer/BackBtn

signal game_paused
signal game_resumed
var opened_from_pause: bool = false

var water_tween: Tween
var hit_tween: Tween
var heat_tween: Tween

# Weapon HUD
var hud_weapon_vp: SubViewport
var hud_weapon_model: Node3D

var reduce_motion: bool = false
var cursor_screen_pos: Vector2 = Vector2.ZERO  # Tracks virtual mouse for captured mode
var target_heat: float = 100.0
var target_water: float = 100.0

var ui_tick_player: AudioStreamPlayer = null

func _process(delta: float) -> void:
	if is_instance_valid(hud_weapon_model):
		hud_weapon_model.rotation.y -= 1.5 * delta
		
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
	phase2_label.visible = false
	timer_label.text = ""
	
	# Hide all screens initially except for crosshair and HUD elements
	win_screen.visible = false
	pause_screen.visible = false
	lose_screen.visible = false
	settings_screen.visible = false
	credits_screen.visible = false
	end_screen.visible = false
	
	# UI tick player for button hover SFX
	ui_tick_player = _make_ui_tick_player()

	if weapon_wheel:
		weapon_wheel.weapon_selected.connect(func(w_id):
			weapon_changed.emit(w_id)
			_update_weapon_hud(w_id)
		)

	var is_kr = GameState.language == "KR"
	crosshair.pivot_offset = crosshair.size / 2.0
	win_screen.pivot_offset = get_viewport().get_visible_rect().size / 2.0
	
	reduce_motion = GameState.reduce_motion
	
	kenney_font = load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	galmuri_font = load("res://assets/fonts/Galmuri11.ttf")
	var font = kenney_font
	
	_style_lbl(heat_label, 22, Color(1.0, 0.9, 0.3, 1.0), 3, Color.BLACK, font)
	_style_lbl(water_label, 22, Color(0.4, 0.9, 1.0, 1.0), 3, Color.BLACK, font)
	_style_lbl(ice_label, 22, Color(0.5, 0.85, 1.0, 1.0), 3, Color.BLACK, font)
	_style_lbl(ice_unlock_label, 22, Color(0.5, 0.85, 1.0, 1.0), 3, Color.BLACK, font)
	if weapon_unlock_label:
		_style_lbl(weapon_unlock_label, 22, Color(1.0, 0.9, 0.2, 1.0), 3, Color.BLACK, font)
	_style_lbl(level_label, 22, Color(1.0, 0.9, 0.3, 1.0), 3, Color.BLACK, font)
	
	# Top right buttons (now in pause menu, styled separately below)

	# New elements
	_style_lbl(timer_label, 22, Color(1.0, 0.8, 0.2, 1.0), 2, Color.BLACK, font)
	_style_lbl(phase2_label, 48, Color(1.0, 0.4, 0.1, 1.0), 3, Color.BLACK, font)
	
	_style_lbl(lose_title_lbl, 64, Color(1.0, 0.4, 0.1, 1.0), 3, Color.BLACK, font)
	_style_lbl(lose_subtitle_lbl, 22, Color(1.0, 0.4, 0.1, 0.65), 2, Color.BLACK, font)
	_style_lbl(lose_level_lbl, 16, Color(1.0, 0.8, 0.2, 0.5), 2, Color.BLACK, font)

	var cfg = GameState.LEVEL_CONFIG[GameState.level]
	if cfg.ice_charges > 0:
		ice_row.visible = true
		if GameState.level == 3:
			ice_row.modulate.a = 0.0
			var tw = create_tween()
			tw.tween_interval(1.0)
			tw.tween_property(ice_row, "modulate:a", 1.0, 0.4)
	else:
		ice_row.visible = false

	var title_color = Color(1.0, 0.75, 0.15, 1.0)
	var subtitle_size = 20 if is_kr else 18
	var prompt_size = 16 if is_kr else 14
	
	# Common title style (matches Title Screen)
	for lbl in [win_title_lbl, end_title_lbl, end_title2_lbl, lose_title_lbl, lose_title2_lbl]:
		if lbl:
			_style_lbl(lbl, 72, title_color, 8, Color(0, 0, 0, 1.0), font)
			lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
			lbl.add_theme_constant_override("shadow_offset_x", 4)
			lbl.add_theme_constant_override("shadow_offset_y", 4)
			lbl.add_theme_constant_override("shadow_outline_size", 12)
			
	# Subtitles and Level Labels
	for lbl in [win_level_lbl, end_subtitle_lbl, lose_subtitle_lbl, end_level_lbl, lose_level_lbl, lose_wave_time_lbl]:
		if lbl:
			_style_lbl(lbl, subtitle_size, title_color, 5, Color(0, 0, 0, 1.0), font)
			
	# Prompts & small text
	for lbl in [win_loading_lbl, end_prompt_lbl]:
		if lbl:
			_style_lbl(lbl, prompt_size, Color.WHITE, 5, Color(0, 0, 0, 1.0), font)

	# Pulse animations for prompts
	if not reduce_motion:
		for lbl in [win_loading_lbl, end_prompt_lbl]:
			if lbl:
				var pulse_tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				pulse_tw.tween_property(lbl, "modulate:a", 0.7, 1.2)
				pulse_tw.tween_property(lbl, "modulate:a", 1.0, 1.2)
	else:
		for lbl in [win_loading_lbl, end_prompt_lbl]:
			if lbl:
				lbl.modulate.a = 1.0
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

	if pause_resume_btn:
		pause_resume_btn.pressed.connect(_on_pause_resume_pressed)
	if settings_btn:
		settings_btn.pressed.connect(_on_settings_pressed)
	if credits_btn:
		credits_btn.pressed.connect(_on_credits_pressed)
	if pause_menu_btn:
		pause_menu_btn.pressed.connect(_on_menu_pressed)

	if font:
		if pause_title: _style_lbl(pause_title, 32, Color(1.0, 0.85, 0.2, 1.0), 3, Color.BLACK, font)

	_apply_language(GameState.language)
	_setup_weapon_hud()

	if esc_hint_label:
		esc_hint_label.visible = true
		esc_hint_label.modulate.a = 0.6
		var tw = create_tween()
		tw.tween_interval(2.0)
		tw.tween_property(esc_hint_label, "modulate:a", 0.0, 1.0)
		tw.tween_callback(func(): esc_hint_label.visible = false)

	# Empty - removed injected functions
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
			btn.mouse_entered.connect(_play_ui_tick)

	# Lose Screen buttons
	var style_lose_btn = StyleBoxFlat.new()
	style_lose_btn.bg_color = Color(0, 0, 0, 0)
	style_lose_btn.border_color = Color(1.0, 0.8, 0.2, 1.0)
	style_lose_btn.set_border_width_all(1)
	style_lose_btn.set_corner_radius_all(4)
	style_lose_btn.content_margin_left = 16
	style_lose_btn.content_margin_right = 16
	style_lose_btn.content_margin_top = 8
	style_lose_btn.content_margin_bottom = 8

	var style_lose_btn_hover = style_lose_btn.duplicate()
	style_lose_btn_hover.bg_color = Color(1.0, 0.8, 0.2, 0.2)


	# Keyboard focus ring — amber outline so keyboard users can see where they are
	var style_focus = StyleBoxFlat.new()
	style_focus.bg_color = Color(0, 0, 0, 0)
	style_focus.border_color = Color(1.0, 0.85, 0.2, 1.0)
	style_focus.set_border_width_all(2)
	style_focus.set_corner_radius_all(6)
	style_focus.content_margin_left = 6
	style_focus.content_margin_right = 6
	style_focus.content_margin_top = 4
	style_focus.content_margin_bottom = 4

	for btn in [retry_btn, menu_btn, pause_resume_btn, settings_btn, credits_btn, pause_menu_btn]:
		if btn:
			if font: btn.add_theme_font_override("font", font)
			btn.add_theme_font_size_override("font_size", 18)
			btn.add_theme_constant_override("letter_spacing", 1)
			btn.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))
			btn.add_theme_constant_override("outline_size", 2)
			btn.add_theme_color_override("font_outline_color", Color.BLACK)
			btn.add_theme_stylebox_override("normal", style_lose_btn)
			btn.add_theme_stylebox_override("hover", style_lose_btn_hover)
			btn.add_theme_stylebox_override("pressed", style_lose_btn_hover)
			btn.add_theme_stylebox_override("focus", style_focus)
			btn.focus_mode = Control.FOCUS_ALL
			btn.mouse_entered.connect(_play_ui_tick)
			
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
	btn_en.mouse_entered.connect(_play_ui_tick)
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
	btn_kr.mouse_entered.connect(_play_ui_tick)
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
		heat_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)
	if water_label:
		water_label.text = "물" if is_kr else "WATER"
		if font: water_label.add_theme_font_override("font", font)
		water_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)
	if ice_label:
		ice_label.text = "얼음 폭발" if is_kr else "ICE BURST"
		if font: ice_label.add_theme_font_override("font", font)
		ice_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)
	if ice_unlock_label:
		ice_unlock_label.text = "아이스 버스트 해금: 태양을 얼려라  [RMB / R]" if is_kr else "ICE BURST UNLOCKED: FREEZE THE SUN [RMB / R]"
		ice_unlock_label.add_theme_font_override("font", kenney_font)
		ice_unlock_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)
	if weapon_unlock_label:
		weapon_unlock_label.text = "무기 해금됨: [TAB] 을 길게 눌러 장착" if is_kr else "WEAPON UNLOCKED: HOLD [TAB] TO EQUIP"
		weapon_unlock_label.add_theme_font_override("font", kenney_font)
		weapon_unlock_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)
	if level_label:
		if GameState.is_survival_mode:
			level_label.text = "웨이브 %02d" % GameState.current_wave if is_kr else "WAVE %02d" % GameState.current_wave
		else:
			level_label.text = "%02d 단계" % GameState.level if is_kr else "LVL  %02d" % GameState.level
		if font: level_label.add_theme_font_override("font", font)
		level_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)
	if timer_label:
		if font: timer_label.add_theme_font_override("font", font)
		timer_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)

	# ── Top-right labels (in HBoxContainer, sizes scaled to match visually) ──
	# (These buttons were moved to the pause menu, styled in _ready and translated below)

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
		lose_title_lbl.text = "태양이" if is_kr else "THE SUN"
		if font: lose_title_lbl.add_theme_font_override("font", font)
	if lose_title2_lbl:
		lose_title2_lbl.text = "이겼습니다" if is_kr else "WON"
		if font: lose_title2_lbl.add_theme_font_override("font", font)
	if lose_subtitle_lbl:
		lose_subtitle_lbl.text = "너무 뜨겁습니다" if is_kr else "TOO HOT TO HANDLE"
		if font: lose_subtitle_lbl.add_theme_font_override("font", font)
	if lose_level_lbl:
		lose_level_lbl.text = "%02d 단계 실패" % GameState.level if is_kr else "LEVEL %02d FAILED" % GameState.level
		if font: lose_level_lbl.add_theme_font_override("font", font)
	if lose_wave_time_lbl:
		lose_wave_time_lbl.hide()
	if retry_btn:
		retry_btn.text = "다시 시도" if is_kr else "RETRY"
		if font: retry_btn.add_theme_font_override("font", font)
	if menu_btn:
		menu_btn.text = "메인 메뉴" if is_kr else "MAIN MENU"
		if font: menu_btn.add_theme_font_override("font", font)
	if phase2_label:
		phase2_label.text = "2단계" if is_kr else "PHASE 2"
		if font: phase2_label.add_theme_font_override("font", font)

	# ── Pause screen ──────────────────────────────────────────────────────────
	if pause_title:
		pause_title.text = "일시정지" if is_kr else "PAUSED"
		if font: pause_title.add_theme_font_override("font", font)
	if pause_resume_btn:
		pause_resume_btn.text = "계속" if is_kr else "RESUME"
		if font: pause_resume_btn.add_theme_font_override("font", font)
	if settings_btn:
		settings_btn.text = "설정" if is_kr else "SETTINGS"
		if font: settings_btn.add_theme_font_override("font", font)
	if credits_btn:
		credits_btn.text = "크레딧" if is_kr else "CREDITS"
		if font: credits_btn.add_theme_font_override("font", font)
	if pause_menu_btn:
		pause_menu_btn.text = "메인 메뉴" if is_kr else "MAIN MENU"
		if font: pause_menu_btn.add_theme_font_override("font", font)
	if esc_hint_label:
		esc_hint_label.text = "ESC · 일시정지" if is_kr else "ESC · PAUSE"
		esc_hint_label.add_theme_font_override("font", kenney_font)

	# ── End screen ────────────────────────────────────────────────────────────
	if end_title_lbl:
		end_title_lbl.text = "여름은" if is_kr else "SUMMER'S"
		if font: end_title_lbl.add_theme_font_override("font", font)
	if end_title2_lbl:
		end_title2_lbl.text = "끝났다" if is_kr else "OVER"
		if font: end_title2_lbl.add_theme_font_override("font", font)
	if end_subtitle_lbl:
		end_subtitle_lbl.text = "태양이 길들여졌다" if is_kr else "THE SUN HAS BEEN TAMED"
		if font: end_subtitle_lbl.add_theme_font_override("font", font)
	if end_level_lbl:
		end_level_lbl.text = "%d 레벨 완료" % GameState.level if is_kr else "%d LEVELS COMPLETED" % GameState.level
		if font: end_level_lbl.add_theme_font_override("font", font)
	if end_prompt_lbl:
		end_prompt_lbl.text = "클릭하거나 스페이스를 눌러 재시작" if is_kr else "CLICK OR PRESS SPACE TO RESTART"
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

func _make_ui_tick_player() -> AudioStreamPlayer:
	# Synthesise a short 10ms 1kHz sine tick — no audio file needed
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 22050.0
	gen.buffer_length = 0.05
	var player = AudioStreamPlayer.new()
	player.stream = gen
	player.bus = "SFX_UI"
	player.volume_db = -18.0
	add_child(player)
	return player

func _play_ui_tick() -> void:
	if not ui_tick_player: return
	if not ui_tick_player.playing:
		ui_tick_player.play()
	var pb = ui_tick_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if not pb: return
	var frames = 512
	var freq = 1800.0
	for i in range(frames):
		var t = float(i) / 22050.0
		var envelope = 1.0 - (float(i) / float(frames))
		pb.push_frame(Vector2.ONE * sin(TAU * freq * t) * 0.25 * envelope)

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
	if GameState.is_survival_mode:
		level_label.text = "WAVE %02d" % GameState.current_wave
	else:
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
	if not visible:
		return
		
	if event is InputEventKey and event.keycode == KEY_TAB and not event.echo:
		if event.pressed:
			if not weapon_wheel.active and not pause_screen.visible and not win_screen.visible and not end_screen.visible and not lose_screen.visible:
				weapon_wheel.open()
				get_viewport().set_input_as_handled()
		else:
			if weapon_wheel.active:
				weapon_wheel.close()
				get_viewport().set_input_as_handled()

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if weapon_wheel.active:
			weapon_wheel.close()
			get_viewport().set_input_as_handled()
			return
			
		if settings_screen and settings_screen.visible:
			_close_settings()
			get_viewport().set_input_as_handled()
			return
		elif credits_screen and credits_screen.visible:
			_close_credits()
			get_viewport().set_input_as_handled()
			return
		
		if pause_screen.visible:
			_resume_game()
		else:
			_pause_game()
		get_viewport().set_input_as_handled()
		return

	if end_screen and end_screen.visible:
		if (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE) or (event is InputEventMouseButton and event.pressed):
			GameState.reset()
			get_viewport().set_input_as_handled()
			get_tree().change_scene_to_file("res://scenes/Main.tscn")
			return

func _pause_game() -> void:
	pause_screen.visible = true
	pause_screen.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(pause_screen, "modulate:a", 1.0, 0.25)
	emit_signal("game_paused")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Set up Tab/arrow key order for pause menu buttons
	if pause_resume_btn and settings_btn and credits_btn and pause_menu_btn:
		pause_resume_btn.focus_neighbor_bottom = pause_resume_btn.get_path_to(settings_btn)
		settings_btn.focus_neighbor_top = settings_btn.get_path_to(pause_resume_btn)
		settings_btn.focus_neighbor_bottom = settings_btn.get_path_to(credits_btn)
		credits_btn.focus_neighbor_top = credits_btn.get_path_to(settings_btn)
		credits_btn.focus_neighbor_bottom = credits_btn.get_path_to(pause_menu_btn)
		pause_menu_btn.focus_neighbor_top = pause_menu_btn.get_path_to(credits_btn)
	await get_tree().process_frame
	if pause_resume_btn: pause_resume_btn.grab_focus()

func _resume_game() -> void:
	var tw = create_tween()
	tw.tween_property(pause_screen, "modulate:a", 0.0, 0.2)
	await tw.finished
	pause_screen.visible = false
	emit_signal("game_resumed")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_pause_resume_pressed() -> void:
	_resume_game()

func _on_settings_pressed() -> void:
	opened_from_pause = pause_screen.visible
	_open_settings()

func _on_credits_pressed() -> void:
	opened_from_pause = pause_screen.visible
	_open_credits()

func _on_settings_btn_hover(hovered: bool) -> void:
	if hovered:
		settings_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 0.6, 1.0))
	else:
		settings_btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 0.95))

func _on_settings_btn_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_settings_pressed()

func _open_settings() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if credits_screen: credits_screen.visible = false
	settings_screen.visible = true
	settings_screen.modulate.a = 0.0
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(settings_screen, "modulate:a", 1.0, 0.3)
	await get_tree().process_frame
	if sfx_slider: sfx_slider.grab_focus()

func _close_settings() -> void:
	var tw = create_tween()
	tw.tween_property(settings_screen, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func():
		settings_screen.visible = false
		if opened_from_pause:
			pause_screen.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if pause_resume_btn: pause_resume_btn.grab_focus()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	)

func _on_credits_btn_hover(hovered: bool) -> void:
	if hovered:
		credits_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 0.6, 1.0))
	else:
		credits_btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 0.95))

func _on_credits_btn_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_credits_pressed()

func _open_credits() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if settings_screen: settings_screen.visible = false
	credits_screen.visible = true
	credits_screen.modulate.a = 0.0
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(credits_screen, "modulate:a", 1.0, 0.25)
	await get_tree().process_frame
	if credits_back_btn: credits_back_btn.grab_focus()

func _close_credits() -> void:
	var tw = create_tween()
	tw.tween_property(credits_screen, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func():
		credits_screen.visible = false
		if opened_from_pause:
			pause_screen.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if pause_resume_btn: pause_resume_btn.grab_focus()
		else:
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
	else:
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))

func _on_timer_expired() -> void:
	show_lose_screen()

func show_lose_screen() -> void:
	if not lose_screen: return
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if lose_level_lbl:
		if GameState.is_survival_mode:
			var m = int(GameState.survival_time) / 60
			var s = int(GameState.survival_time) % 60
			if GameState.language == "KR":
				lose_level_lbl.text = "도달 웨이브: %d" % GameState.current_wave
			else:
				lose_level_lbl.text = "WAVES CLEARED: %d" % GameState.current_wave
			
			if lose_wave_time_lbl:
				lose_wave_time_lbl.show()
				if GameState.language == "KR":
					lose_wave_time_lbl.text = "생존 시간: %02d:%02d" % [m, s]
				else:
					lose_wave_time_lbl.text = "SURVIVED: %02d:%02d" % [m, s]
		else:
			lose_level_lbl.text = "%02d 단계 실패" % GameState.level if GameState.language == "KR" else "LEVEL %02d FAILED" % GameState.level
			if lose_wave_time_lbl:
				lose_wave_time_lbl.hide()
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
	p_tw.tween_property(phase2_label, "modulate:a", 1.0, 0.4)
	p_tw.tween_interval(2.0)
	p_tw.tween_property(phase2_label, "modulate:a", 0.0, 0.5)
	p_tw.tween_callback(func(): phase2_label.visible = false)

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	GameState.level = 1
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func update_ice_charges(charges: int, max_charges: int) -> void:
	if max_charges <= 0:
		ice_row.visible = false
	else:
		ice_row.visible = true
		ice_bar.value = (float(charges) / float(max_charges)) * 100.0

func show_ice_unlock() -> void:
	ice_unlock_label.visible = true
	var tween = create_tween()
	ice_unlock_label.modulate.a = 0.0
	tween.tween_property(ice_unlock_label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(6.0)
	tween.tween_property(ice_unlock_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): ice_unlock_label.visible = false)

func show_weapon_unlock() -> void:
	if not weapon_unlock_label: return
	weapon_unlock_label.visible = true
	var tween = create_tween()
	weapon_unlock_label.modulate.a = 0.0
	tween.tween_property(weapon_unlock_label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(5.0)
	tween.tween_property(weapon_unlock_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): weapon_unlock_label.visible = false)

func _setup_weapon_hud() -> void:
	var cc = CenterContainer.new()
	cc.size_flags_horizontal = Control.SIZE_SHRINK_END
	
	var svc = SubViewportContainer.new()
	svc.stretch = true
	svc.custom_minimum_size = Vector2(100, 100)
	cc.add_child(svc)
	
	# Add to resource_container at index 0 (above water/ice)
	var rc = $HUD/resource_container
	if rc:
		rc.add_child(cc)
		rc.move_child(cc, 0)
		
	hud_weapon_vp = SubViewport.new()
	hud_weapon_vp.transparent_bg = true
	hud_weapon_vp.own_world_3d = true
	svc.add_child(hud_weapon_vp)
	
	var cam = Camera3D.new()
	cam.position = Vector3(0, 0, 2.0)
	hud_weapon_vp.add_child(cam)
	
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-30, 45, 0)
	light.light_energy = 1.2
	hud_weapon_vp.add_child(light)
	
	_update_weapon_hud(GameState.current_weapon_id)

func _update_weapon_hud(w_id: String) -> void:
	if not hud_weapon_vp: return
	
	if is_instance_valid(hud_weapon_model):
		hud_weapon_model.queue_free()
		
	var w_cfg = GameState.WEAPONS.get(w_id)
	if w_cfg:
		hud_weapon_model = load(w_cfg.model).instantiate()
		hud_weapon_model.scale = w_cfg.scale * 0.4
		hud_weapon_model.position = Vector3(0, -0.3, -0.1)
		hud_weapon_vp.add_child(hud_weapon_model)
