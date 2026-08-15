extends CanvasLayer

signal sensitivity_changed(value: float)
signal reduce_motion_changed(enabled: bool)
signal weapon_changed(weapon_id: String)


@onready var weapon_wheel = $HUD/WeaponWheel
@onready var heat_bar = $HUD/SunHeatBar/BarContainer/HeatBar
@onready var mirage_bar = $HUD/SunHeatBar/BarContainer/MirageBar
@onready var heat_label = $HUD/SunHeatBar/Label
@onready var water_bar_container = $HUD/resource_container/water_row
@onready var water_bar = $HUD/resource_container/water_row/WaterBar
@onready var water_label = $HUD/resource_container/water_row/Label

@onready var ice_row = $HUD/resource_container/ice_row
@onready var ice_label = $HUD/resource_container/ice_row/Label
@onready var ice_bar = $HUD/resource_container/ice_row/IceBarContainer/IceBar
@onready var charge_dots = $HUD/resource_container/ice_row/IceBarContainer/ChargeDots

@onready var catastrom_row = $HUD/resource_container/catastrom_row
@onready var catastrom_label = $HUD/resource_container/catastrom_row/Label
@onready var catastrom_bar = $HUD/resource_container/catastrom_row/CatastromBar
@onready var grab_icon = $HUD/GrabIcon

@onready var toast_container = $HUD/ToastContainer
var achievement_toast_container: Control
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
@onready var weather_icon_container = $HUD/WeatherIconContainer
@onready var weather_icon       = $HUD/WeatherIconContainer/Icon
@onready var score_label       = $HUD/ScoreLabel
@onready var phase2_label      = $HUD/Phase2Label
@onready var combo_label       = $HUD/ComboLabel
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

var achievements_btn: Button
var achievements_screen: Control
var achievement_list: VBoxContainer

signal game_paused
signal game_resumed
var opened_from_pause: bool = false

var water_tween: Tween
var hit_tween: Tween
var heat_tween: Tween

# Weapon HUD
var hud_weapon_icons: Dictionary = {}  # w_id -> ImageTexture
var hud_weapon_container: TextureRect

var reduce_motion: bool = false
var cursor_screen_pos: Vector2 = Vector2.ZERO  # Tracks virtual mouse for captured mode
var target_heat: float = 100.0
var target_mirage_hp: float = 100.0
var target_water: float = 100.0

var ui_tick_player: AudioStreamPlayer = null

var display_score: int = 0
var score_tween: Tween

var credits_scroll_acc: float = 0.0


var _weather_pulse_tween: Tween

func update_weather_icon(weather_type: String) -> void:
	if not weather_icon_container or not weather_icon: return
	
	weather_icon_container.visible = true
	
	if weather_type == "none":
		weather_icon.texture = load("res://assets/ui/ui_adventure/PNG/Default/minimap_icon_star_yellow.png")
		if _weather_pulse_tween:
			_weather_pulse_tween.kill()
		weather_icon_container.scale = Vector2(1, 1)
		return
		
	if weather_type == "rain":
		weather_icon.texture = load("res://assets/ui/ui_adventure/PNG/Default/minimap_icon_exclamation_white.png")
	elif weather_type == "eclipse":
		weather_icon.texture = load("res://assets/ui/ui_adventure/PNG/Default/minimap_icon_exclamation_red.png")
		
	if _weather_pulse_tween:
		_weather_pulse_tween.kill()
		
	# Reset scale
	weather_icon_container.scale = Vector2(1, 1)
	weather_icon_container.pivot_offset = weather_icon_container.size / 2.0
	
	if not reduce_motion:
		_weather_pulse_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_weather_pulse_tween.tween_property(weather_icon_container, "scale", Vector2(1.1, 1.1), 0.6)
		_weather_pulse_tween.tween_property(weather_icon_container, "scale", Vector2(1.0, 1.0), 0.6)

func _process(delta: float) -> void:	
	if heat_bar:
		if reduce_motion:
			heat_bar.value = target_heat
		else:
			heat_bar.value = lerp(heat_bar.value, target_heat, 12.0 * delta)
			
	if mirage_bar and mirage_bar.visible:
		if reduce_motion:
			mirage_bar.value = target_mirage_hp
		else:
			mirage_bar.value = lerp(mirage_bar.value, target_mirage_hp, 4.0 * delta)
			
	if water_bar:
		if reduce_motion:
			water_bar.value = target_water
		else:
			water_bar.value = lerp(water_bar.value, target_water, 12.0 * delta)
			
	if catastrom_bar:
		var target_catastrom = GameState.catastrom_charge
		if catastrom_row.visible != (GameState.level >= 4 or (GameState.is_survival_mode and GameState.current_wave >= 1)):
			catastrom_row.visible = (GameState.level >= 4 or (GameState.is_survival_mode and GameState.current_wave >= 1))
			
		if reduce_motion:
			catastrom_bar.value = target_catastrom
		else:
			catastrom_bar.value = lerp(catastrom_bar.value, float(target_catastrom), 12.0 * delta)
			
		if catastrom_bar.value >= 0.99:
			if Engine.get_frames_drawn() % 30 == 0:
				catastrom_bar.tint_progress = Color(0.8, 0.4, 1.0, 1.0)
			elif Engine.get_frames_drawn() % 30 == 15:
				catastrom_bar.tint_progress = Color(0.6, 0, 1, 1)
		else:
			catastrom_bar.tint_progress = Color(0.6, 0, 1, 1)
			
	if credits_btn and not credits_screen.visible:
		var btn_rect = credits_btn.get_global_rect()
		var is_hovered = btn_rect.has_point(cursor_screen_pos)
		_on_credits_btn_hover(is_hovered)
		
		var target_col = Color(1.0, 0.88, 0.3, 0.95) if is_hovered else Color(1.0, 1.0, 1.0, 0.6)
		credits_btn.add_theme_color_override("font_color", credits_btn.get_theme_color("font_color").lerp(target_col, 10.0 * delta))

		
	if credits_screen and credits_screen.visible:
		var scroll_area = credits_vbox.get_node_or_null("ScrollArea") if credits_vbox else null
		if scroll_area:
			credits_scroll_acc += 25.0 * delta
			if credits_scroll_acc >= 1.0:
				var amt = int(credits_scroll_acc)
				scroll_area.scroll_vertical += amt
				credits_scroll_acc -= amt
		
	if settings_btn and not settings_screen.visible:
		var s_rect = settings_btn.get_global_rect()
		var s_hovered = s_rect.has_point(cursor_screen_pos)
		_on_settings_btn_hover(s_hovered)

func _ready() -> void:


	heat_label.scale = Vector2(1.0, 1.0)
	phase2_label.visible = false
	combo_label.visible = false
	timer_label.text = ""
	
	if weather_icon_container:
		var w_style = StyleBoxFlat.new()
		w_style.bg_color = Color(0.0, 0.0, 0.0, 0.4)
		w_style.border_color = Color(1.0, 0.85, 0.2, 0.6)
		w_style.border_width_bottom = 2
		w_style.border_width_top = 2
		w_style.border_width_left = 2
		w_style.border_width_right = 2
		w_style.corner_radius_bottom_left = 8
		w_style.corner_radius_bottom_right = 8
		w_style.corner_radius_top_left = 8
		w_style.corner_radius_top_right = 8
		w_style.content_margin_left = 6.0
		w_style.content_margin_right = 6.0
		w_style.content_margin_top = 6.0
		w_style.content_margin_bottom = 6.0
		weather_icon_container.add_theme_stylebox_override("panel", w_style)
		
	update_weather_icon("none")
	
	GameState.score_updated.connect(_on_score_updated)
	_on_score_updated(GameState.current_score)
	
	# Hide all screens initially except for crosshair and HUD elements
	win_screen.visible = false
	pause_screen.visible = false
	lose_screen.visible = false
	settings_screen.visible = false
	credits_screen.visible = false
	end_screen.visible = false
	if mirage_bar:
		mirage_bar.visible = false
	

		
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# UI tick player for button hover SFX
	ui_tick_player = _make_ui_tick_player()

	# ───────────────────────────────────────────────
	# Achievements System UI Injection
	# ───────────────────────────────────────────────
	achievement_toast_container = Control.new()
	achievement_toast_container.name = "AchievementToastContainer"
	achievement_toast_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 0)
	achievement_toast_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$HUD.add_child(achievement_toast_container)
	if pause_screen:
		$HUD.move_child(achievement_toast_container, pause_screen.get_index())
	GameState.achievement_unlocked.connect(show_achievement_toast)
	
	# ───────────────────────────────────────────────

	if weapon_wheel:
		weapon_wheel.weapon_selected.connect(func(w_id):
			weapon_changed.emit(w_id)
			_update_weapon_hud(w_id)
		)

	var is_kr = GameState.language == "KR"
	crosshair.pivot_offset = crosshair.size / 2.0
	
	if water_bar:
		water_bar.material = null
		
	# Connect to Global signals
	win_screen.pivot_offset = get_viewport().get_visible_rect().size / 2.0
	
	reduce_motion = GameState.reduce_motion
	
	kenney_font = load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	galmuri_font = load("res://assets/fonts/Galmuri11.ttf")
	var font = kenney_font
	
	_style_lbl(heat_label, 22, Color(1.0, 0.9, 0.3, 1.0), 3, Color.BLACK, font)
	_style_lbl(water_label, 22, Color(0.4, 0.9, 1.0, 1.0), 3, Color.BLACK, font)
	_style_lbl(ice_label, 22, Color(0.5, 0.85, 1.0, 1.0), 3, Color.BLACK, font)
	_style_lbl(catastrom_label, 22, Color(0.8, 0.4, 1.0, 1.0), 3, Color.BLACK, font)

	_style_lbl(level_label, 22, Color(1.0, 0.9, 0.3, 1.0), 3, Color.BLACK, font)
	
	# Top right buttons (now in pause menu, styled separately below)

	# New elements
	_style_lbl(timer_label, 22, Color(1.0, 0.8, 0.2, 1.0), 2, Color.BLACK, font)
	if score_label:
		_style_lbl(score_label, 26, Color(1.0, 0.9, 0.3, 1.0), 3, Color.BLACK, font)
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
		
	if credits_btn:
		achievements_btn = credits_btn.duplicate()
		achievements_btn.name = "AchievementsBtn"
		credits_btn.get_parent().add_child(achievements_btn)
		credits_btn.get_parent().move_child(achievements_btn, credits_btn.get_index() + 1)
		if achievements_btn.pressed.is_connected(_on_credits_pressed):
			achievements_btn.pressed.disconnect(_on_credits_pressed)
		achievements_btn.pressed.connect(show_achievements_screen)
		
	_build_achievements_screen()

	if font:
		if pause_title: _style_lbl(pause_title, 32, Color(1.0, 0.85, 0.2, 1.0), 3, Color.BLACK, font)

	_apply_language(GameState.language)
	_setup_weapon_hud()

	if esc_hint_label:
		# Reparent to UnlockPrompts so it stacks above the weapon HUD
		var unlock_prompts = $HUD/UnlockPrompts
		if unlock_prompts:
			esc_hint_label.get_parent().remove_child(esc_hint_label)
			unlock_prompts.add_child(esc_hint_label)
			unlock_prompts.move_child(esc_hint_label, 0) # Put it at the top of the stack

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

	for btn in [retry_btn, menu_btn, pause_resume_btn, settings_btn, credits_btn, achievements_btn, pause_menu_btn]:
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
	GameState.save_settings()
	_apply_language(lang)

func _apply_language(lang: String) -> void:
	var is_kr := lang == "KR"
	var font: Font = galmuri_font if is_kr else kenney_font
	var body_font: Font = galmuri_font if is_kr else load("res://assets/fonts/Inter-Medium.ttf")

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
	if catastrom_label:
		catastrom_label.text = "카타스트롬" if is_kr else "CATASTROM"
		if font: catastrom_label.add_theme_font_override("font", font)
		catastrom_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)

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
	if score_label:
		if font: score_label.add_theme_font_override("font", font)
		score_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)
		_update_score_display(display_score)

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

	var row_texts_en := ["Master Volume", "Sensitivity", "Reduce Motion", "Fullscreen", "Language"]
	var row_texts_kr := ["전체 볼륨", "마우스 감도", "화면 흔들림 감소", "전체 화면", "언어"]
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

	# Style the credits content dynamically with clear text hierarchy and sizing
	var scroll_area = credits_vbox.get_node_or_null("ScrollArea")
	if scroll_area:
		var credits_list = scroll_area.get_node_or_null("CreditsList")
		if credits_list:
			for child in credits_list.get_children():
					if child is Label:
						var is_header = child.name.begins_with("Hdr")
						if is_header:
							if font: child.add_theme_font_override("font", font)
						else:
							if body_font: child.add_theme_font_override("font", body_font)
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
	if settings_back_btn:
		settings_back_btn.text = "뒤로" if is_kr else "BACK"
		if font: settings_back_btn.add_theme_font_override("font", font)
		
	if hud_weapon_container:
		_update_weapon_hud(GameState.current_weapon_id)

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
	if achievements_btn:
		achievements_btn.text = "업적" if is_kr else "ACHIEVEMENTS"
		if font: achievements_btn.add_theme_font_override("font", font)
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
	GameState.save_settings()
	var db_val = linear_to_db(val)
	var idx1 = AudioServer.get_bus_index("SFX_WEAPON")
	if idx1 != -1: AudioServer.set_bus_volume_db(idx1, db_val)
	var idx2 = AudioServer.get_bus_index("SFX_UI")
	if idx2 != -1: AudioServer.set_bus_volume_db(idx2, db_val)
	var idx_master = AudioServer.get_bus_index("Master")
	if idx_master != -1: AudioServer.set_bus_volume_db(idx_master, db_val)

func _on_sens_changed(val: float) -> void:
	GameState.mouse_sensitivity = val
	GameState.save_settings()
	sensitivity_changed.emit(val)

func _on_motion_toggled(enabled: bool) -> void:
	GameState.reduce_motion = enabled
	GameState.save_settings()
	reduce_motion = enabled
	reduce_motion_changed.emit(enabled)
	_update_toggle_btn(motion_check, enabled)

func _on_fullscreen_toggled(toggled: bool) -> void:
	GameState.fullscreen = toggled
	GameState.save_settings()
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

func _on_github_btn_pressed() -> void:
	OS.shell_open("https://github.com/Ashutos1997/SummerNights-Godot")
	ui_tick_player.play()


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
	if ratio > 0.90:
		heat_bar.tint_progress = Color(1.0, 0.0, 0.0) # critical red
		if reduce_motion:
			heat_bar.modulate.a = 1.0
		else:
			if not is_instance_valid(heat_tween) or not heat_tween.is_running():
				heat_tween = create_tween()
				heat_tween.set_loops()
				heat_tween.tween_property(heat_bar, "modulate:a", 0.7, 0.8)
				heat_tween.tween_property(heat_bar, "modulate:a", 1.0, 0.8)
	else:
		if is_instance_valid(heat_tween):
			heat_tween.kill()
		heat_bar.modulate.a = 1.0
		if ratio > 0.66:
			heat_bar.tint_progress = Color(1.0, 0.3, 0.1) # hot red-orange
		elif ratio > 0.33:
			heat_bar.tint_progress = Color(1.0, 0.65, 0.1) # amber
		else:
			heat_bar.tint_progress = Color(0.4, 0.9, 0.4) # cool green

func update_mirage_hp(current: float, max_val: float) -> void:
	if mirage_bar:
		if current <= 0.0 or max_val <= 0.0:
			mirage_bar.visible = false
		else:
			if not mirage_bar.visible:
				mirage_bar.value = 0.0 # Force visual fill-up over time
			mirage_bar.visible = true
			mirage_bar.max_value = max_val
			target_mirage_hp = current

func _on_water_changed(current: float, max_val: float) -> void:
	if water_bar:
		water_bar.max_value = max_val
		target_water = current
			
		if current < max_val * 0.2:
			if reduce_motion:
				water_bar.tint_progress = Color(1.0, 0.3, 0.3)
				water_bar.modulate.a = 1.0
			else:
				water_bar.tint_progress = Color(1.0, 0.3, 0.3)
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
	
	if end_level_lbl:
		end_level_lbl.text = "%d 레벨 완료" % GameState.level if GameState.language == "KR" else "%d LEVELS COMPLETED" % GameState.level
		
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
		elif achievements_screen and achievements_screen.visible:
			hide_achievements_screen()
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
		if achievements_btn:
			credits_btn.focus_neighbor_bottom = credits_btn.get_path_to(achievements_btn)
			achievements_btn.focus_neighbor_top = achievements_btn.get_path_to(credits_btn)
			achievements_btn.focus_neighbor_bottom = achievements_btn.get_path_to(pause_menu_btn)
			pause_menu_btn.focus_neighbor_top = pause_menu_btn.get_path_to(achievements_btn)
		else:
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
	
	var scroll_area = credits_vbox.get_node_or_null("ScrollArea") if credits_vbox else null
	if scroll_area:
		scroll_area.scroll_vertical = 0
		credits_scroll_acc = 0.0
		
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



func show_achievement_toast(id: String) -> void:
	if not achievement_toast_container: return
	if not GameState.ACHIEVEMENTS.has(id): return
	
	var ach = GameState.ACHIEVEMENTS[id]
	var is_kr = GameState.language == "KR"
	
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(440, 80)
	panel.position = Vector2(-220, -100) # Start above screen, centered since parent is top wide but wait, parent is just a point if it's PRESET_TOP_WIDE
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.15, 0.95)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.85, 0.2, 0.9)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.shadow_size = 10
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_offset = Vector2(0, 4)
	panel.add_theme_stylebox_override("panel", style)
	
	var icon_rect = TextureRect.new()
	icon_rect.texture = load(ach["icon"])
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.custom_minimum_size = Vector2(56, 56)
	icon_rect.position = Vector2(16, 12)
	icon_rect.pivot_offset = icon_rect.custom_minimum_size / 2.0
	icon_rect.scale = Vector2.ZERO
	panel.add_child(icon_rect)
	
	var header_lbl = Label.new()
	header_lbl.text = "업적 달성!" if is_kr else "ACHIEVEMENT UNLOCKED!"
	header_lbl.position = Vector2(84, 14)
	_style_lbl(header_lbl, 16, Color(1.0, 1.0, 1.0, 0.9), 2, Color.BLACK, galmuri_font if is_kr else kenney_font)
	panel.add_child(header_lbl)
	
	var title_lbl = Label.new()
	title_lbl.text = ach["title_kr"] if is_kr else ach["title_en"]
	title_lbl.position = Vector2(84, 38)
	_style_lbl(title_lbl, 24, Color(1.0, 0.85, 0.2, 1.0), 3, Color.BLACK, galmuri_font if is_kr else kenney_font)
	panel.add_child(title_lbl)
	
	panel.process_mode = Node.PROCESS_MODE_PAUSABLE
	achievement_toast_container.add_child(panel)
	
	# SFX
	var sfx = AudioStreamPlayer.new()
	sfx.stream = load("res://assets/sounds/ui/ui_tick.wav")
	sfx.volume_db = linear_to_db(GameState.sfx_volume)
	panel.add_child(sfx)
	sfx.play()
	
	# Animate Panel
	var tw = create_tween().bind_node(panel)
	tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(panel, "position:y", 20.0, 0.6)
	tw.tween_interval(4.0)
	tw.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tw.tween_property(panel, "position:y", -120.0, 0.5)
	tw.tween_callback(panel.queue_free)
	
	# Animate Icon Pop
	var icon_tw = create_tween().bind_node(panel)
	icon_tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	icon_tw.tween_interval(0.3)
	icon_tw.tween_property(icon_rect, "scale", Vector2.ONE, 0.5)
func hide_win_screen() -> void:
	if win_screen:
		win_screen.visible = false
		win_screen.modulate.a = 0.0

var timer_pulse_active: bool = false

func _on_timer_tick(seconds: float) -> void:
	if not timer_label: return
	var secs = max(0, int(seconds))
	var mins = secs / 60
	secs = secs % 60
	
	var prefix = "시간: " if GameState.language == "KR" else "TIME: "
	timer_label.text = prefix + ("%d:%02d" % [mins, secs])

	if seconds <= 10.0:
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2, 1.0))
		if not timer_pulse_active:
			timer_pulse_active = true
			var tw = create_tween().set_loops()
			tw.tween_property(timer_label, "modulate:a", 0.3, 0.4)
			tw.tween_property(timer_label, "modulate:a", 1.0, 0.4)
	else:
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))

func show_combo(active: bool) -> void:
	if not combo_label: return
	
	if active:
		combo_label.visible = true
		combo_label.modulate = Color(1, 1, 1, 0)
		combo_label.scale = Vector2.ONE
		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(combo_label, "modulate:a", 1.0, 0.2)
		tw.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	else:
		if combo_label.visible:
			var tw = create_tween()
			tw.tween_property(combo_label, "modulate:a", 0.0, 0.2)
			tw.tween_callback(func(): combo_label.visible = false)

func update_combo_text(mult: float) -> void:
	if not combo_label: return
	combo_label.text = "%.2fx COMBO!" % mult

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
					lose_wave_time_lbl.text = "SURVIVAL TIME: %02d:%02d" % [m, s]
			
			if GameState.survival_time > GameState.best_survival_time:
				GameState.best_survival_time = GameState.survival_time
				GameState.save_settings()
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
	GameState.level = 1
	GameState.current_wave = 1
	GameState.is_retrying = true
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

func show_toast(title: String, description: String, icon_path: String, color: Color) -> void:
	if not toast_container: return
	
	var is_kr = GameState.language == "KR"
	var font = kenney_font if kenney_font else load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.1, 0.85)
	style.border_color = color
	style.set_border_width_all(2)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.content_margin_left = 12
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)
	
	if icon_path != "":
		var tex_rect = TextureRect.new()
		tex_rect.texture = load(icon_path)
		tex_rect.custom_minimum_size = Vector2(32, 32)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tex_rect.modulate = color
		hbox.add_child(tex_rect)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(vbox)
	
	var title_lbl = Label.new()
	title_lbl.text = title
	title_lbl.add_theme_font_override("font", font)
	title_lbl.add_theme_font_size_override("font_size", 24 if is_kr else 20)
	title_lbl.add_theme_color_override("font_color", color)
	title_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	title_lbl.add_theme_constant_override("outline_size", 3)
	vbox.add_child(title_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = description
	desc_lbl.add_theme_font_override("font", font)
	desc_lbl.add_theme_font_size_override("font_size", 18 if is_kr else 14)
	desc_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	desc_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	desc_lbl.add_theme_constant_override("outline_size", 2)
	vbox.add_child(desc_lbl)
	
	toast_container.add_child(panel)
	
	# Play a little sound if we have one
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/sfx/ui_tick.wav")
	audio.volume_db = -5.0
	audio.bus = "SFX"
	add_child(audio)
	audio.play()
	
	# Calculate target right-aligned position and stacking Y position
	var target_size = panel.get_minimum_size()
	var target_x = toast_container.size.x - target_size.x
	var target_y = (toast_container.get_child_count() - 1) * (target_size.y + 12)
	
	# Slide in animation
	panel.position = Vector2(target_x + 400, target_y)
	panel.modulate.a = 0.0
	var tween = create_tween()
	
	# 1. Slide in
	tween.set_parallel(true)
	tween.tween_property(panel, "position:x", target_x, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# 2. Wait
	tween.set_parallel(false)
	tween.tween_interval(3.5)
	
	# 3. Slide out
	tween.tween_property(panel, "position:x", target_x + 400.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	# 4. Cleanup
	tween.set_parallel(false)
	tween.tween_callback(func():
		panel.queue_free()
		audio.queue_free()
	)

func show_ice_unlock() -> void:
	var is_kr = GameState.language == "KR"
	var title = "아이스 버스트 해금" if is_kr else "ICE BURST UNLOCKED"
	var desc = "태양을 얼려라 [RMB / R]" if is_kr else "FREEZE THE SUN [RMB / R]"
	show_toast(title, desc, "res://assets/ui/ui_adventure/PNG/Default/minimap_icon_star_white.png", Color(0.5, 0.85, 1.0, 1.0))

func show_weapon_unlock() -> void:
	var is_kr = GameState.language == "KR"
	var title = "무기 해금됨" if is_kr else "WEAPON UNLOCKED"
	var desc = "[TAB] 을 길게 눌러 장착" if is_kr else "HOLD [TAB] TO EQUIP"
	show_toast(title, desc, "res://assets/ui/ui_adventure/PNG/Default/minimap_icon_star_yellow.png", Color(1.0, 0.9, 0.2, 1.0))

func _setup_weapon_hud() -> void:
	var margin = MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	margin.add_theme_constant_override("margin_left", 0)
	margin.add_theme_constant_override("margin_top", 16)
	
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.5)
	style.border_color = Color(0.5, 0.85, 1.0, 0.5)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", style)
	margin.add_child(panel)
	
	var hud_weapon_tex_rect = TextureRect.new()
	hud_weapon_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hud_weapon_tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hud_weapon_tex_rect.custom_minimum_size = Vector2(64, 64)
	panel.add_child(hud_weapon_tex_rect)
	hud_weapon_container = hud_weapon_tex_rect
	
	# Render each weapon into a SubViewport and capture its image
	var temp_viewports: Array = []
	var temp_w_ids: Array = []
	
	for w_id in GameState.WEAPONS.keys():
		var w_cfg = GameState.WEAPONS[w_id]
		
		var vp = SubViewport.new()
		vp.size = Vector2i(256, 256)
		vp.transparent_bg = true
		vp.own_world_3d = true
		vp.render_target_update_mode = SubViewport.UPDATE_ONCE
		add_child(vp)
		
		var cam = Camera3D.new()
		cam.position = Vector3(0, 0, 2.0)
		vp.add_child(cam)
		
		var light = DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-30, 45, 0)
		light.light_energy = 1.2
		vp.add_child(light)
		
		var model = load(w_cfg.model).instantiate()
		model.scale = w_cfg.scale * 1.0
		model.position = Vector3(0, -0.3, -0.1)
		vp.add_child(model)
		
		temp_viewports.append(vp)
		temp_w_ids.append(w_id)
	
	# Add to UnlockPrompts at the bottom
	var rc = $HUD/UnlockPrompts
	if rc:
		rc.add_child(margin)
	
	# Wait 2 frames for viewports to render, then capture and free them
	await get_tree().process_frame
	await get_tree().process_frame
	
	for i in temp_viewports.size():
		var vp = temp_viewports[i]
		var img = vp.get_texture().get_image()
		var img_tex = ImageTexture.create_from_image(img)
		hud_weapon_icons[temp_w_ids[i]] = img_tex
		vp.queue_free()
	
	_update_weapon_hud(GameState.current_weapon_id)

func _update_weapon_hud(w_id: String) -> void:
	if not hud_weapon_container: return
	var tex = hud_weapon_icons.get(w_id)
	if tex:
		hud_weapon_container.texture = tex

func _on_score_updated(new_score: int) -> void:
	if not score_label: return
	if is_instance_valid(score_tween):
		score_tween.kill()
	
	score_tween = create_tween()
	score_tween.set_parallel(true)
	score_tween.tween_method(_update_score_display, display_score, new_score, 0.2)
	
	if not reduce_motion:
		score_label.pivot_offset = Vector2(score_label.size.x, score_label.size.y / 2.0)
		score_label.scale = Vector2(1.2, 1.2)
		score_tween.tween_property(score_label, "scale", Vector2.ONE, 0.2).set_delay(0.0)

func _update_score_display(val: int) -> void:
	display_score = val
	var prefix = "점수: " if GameState.language == "KR" else "SCORE: "
	
	# Format with commas
	var s = str(val)
	var formatted = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		formatted = s[i] + formatted
		count += 1
		if count % 3 == 0 and i != 0:
			formatted = "," + formatted
			
	if score_label:
		score_label.text = prefix + formatted
func _build_achievements_screen() -> void:
	achievements_screen = Control.new()
	achievements_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	achievements_screen.visible = false
	achievements_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	achievements_screen.z_index = 50 # ensure it draws over everything
	$HUD.add_child(achievements_screen)
	
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
	
	var title = Label.new()
	title.name = "Title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
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
	back_btn.custom_minimum_size = Vector2(240, 48)
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	style_normal.border_width_left = 2
	style_normal.border_width_right = 2
	style_normal.border_width_top = 2
	style_normal.border_width_bottom = 2
	style_normal.border_color = Color(0.3, 0.3, 0.3, 0.8)
	style_normal.corner_radius_top_left = 4
	style_normal.corner_radius_top_right = 4
	style_normal.corner_radius_bottom_left = 4
	style_normal.corner_radius_bottom_right = 4
	back_btn.add_theme_stylebox_override("normal", style_normal)
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	style_hover.border_color = Color(1.0, 0.85, 0.2, 1.0)
	back_btn.add_theme_stylebox_override("hover", style_hover)
	
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = Color(1.0, 0.85, 0.2, 0.4)
	back_btn.add_theme_stylebox_override("pressed", style_pressed)
	back_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	var btn_center = CenterContainer.new()
	btn_center.name = "CenterContainer"
	btn_center.add_child(back_btn)
	vbox.add_child(btn_center)
	
	back_btn.pressed.connect(hide_achievements_screen)

func show_achievements_screen() -> void:
	if not achievements_screen: return
	
	for child in achievement_list.get_children():
		child.queue_free()
		
	var is_kr = GameState.language == "KR"
	var font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/ui/fonts/Fonts/Kenney Future.ttf"
	var body_font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/fonts/Inter-Medium.ttf"
	var font = load(font_path)
	var body_font = load(body_font_path)
	
	var title = achievements_screen.get_node("CenterContainer/VBoxContainer/Title")
	title.text = "업적" if is_kr else "ACHIEVEMENTS"
	_style_lbl(title, 36, Color(1.0, 0.85, 0.2, 1.0), 4, Color.BLACK, font)
	
	var back_btn = achievements_screen.get_node("CenterContainer/VBoxContainer/CenterContainer/BackBtn")
	back_btn.text = "돌아가기" if is_kr else "BACK"
	back_btn.add_theme_font_override("font", font)
	back_btn.add_theme_font_size_override("font_size", 24)
	back_btn.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	back_btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	
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
		_style_lbl(ach_title, 28, Color(1.0, 0.85, 0.2, 1.0) if unlocked else Color(0.5, 0.5, 0.5, 1.0), 2, Color.BLACK, font)
		vbox.add_child(ach_title)
		
		var ach_desc = Label.new()
		ach_desc.text = (ach["desc_kr"] if is_kr else ach["desc_en"]) if unlocked else ("잠김" if is_kr else "LOCKED")
		ach_desc.custom_minimum_size = Vector2(550, 0)
		ach_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
		_style_lbl(ach_desc, 16, Color(1.0, 1.0, 1.0, 0.8) if unlocked else Color(0.4, 0.4, 0.4, 0.8), 1, Color.BLACK, body_font)
		vbox.add_child(ach_desc)
		
		achievement_list.add_child(panel)

	achievements_screen.visible = true
	achievements_screen.modulate.a = 0.0
	achievements_screen.set_meta("is_hiding", false)
	var tw = create_tween()
	tw.tween_property(achievements_screen, "modulate:a", 1.0, 0.25)
	
	_play_ui_tick()
	if back_btn: back_btn.grab_focus()

func hide_achievements_screen() -> void:
	if not achievements_screen or not achievements_screen.visible: return
	if achievements_screen.get_meta("is_hiding", false): return
	achievements_screen.set_meta("is_hiding", true)
	
	_play_ui_tick()
	
	var tw = create_tween()
	tw.tween_property(achievements_screen, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func(): 
		achievements_screen.visible = false 
		achievements_screen.set_meta("is_hiding", false)
		pause_screen.visible = true
		if achievements_btn: achievements_btn.grab_focus()
	)
