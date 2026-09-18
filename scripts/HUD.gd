extends CanvasLayer

signal sensitivity_changed(value: float)
signal reduce_motion_changed(enabled: bool)
signal filter_color_depth_changed(enabled: bool)
signal filter_dithering_changed(enabled: bool)
signal filter_ps1_changed(enabled: bool)
signal filter_heatwave_changed(enabled: bool)
signal weapon_changed(weapon_id: String)


@onready var weapon_wheel = $HUD/WeaponWheel
@onready var heat_bar = $HUD/SunHeatBar/BarContainer/HeatBar
@onready var mirage_bar = $HUD/SunHeatBar/BarContainer/MirageBar
@onready var heat_label = $HUD/SunHeatBar/Label
var heat_val_label: Label = null
@onready var tutorial_prompt = $HUD/TutorialPrompt
@onready var tutorial_aim_label = $HUD/TutorialPrompt/VBoxContainer/AimLabel
@onready var tutorial_shoot_label = $HUD/TutorialPrompt/VBoxContainer/ShootLabel
@onready var water_bar_container = $HUD/resource_container/water_row
@onready var water_plate = $HUD/resource_container/water_row/IconPlate
@onready var water_bar = $HUD/resource_container/water_row/WaterBar
@onready var water_icon = $HUD/resource_container/water_row/IconPlate/Icon
var water_label: Label = null

@onready var ice_row = $HUD/resource_container/ice_row
@onready var ice_plate = $HUD/resource_container/ice_row/IconPlate
@onready var ice_icon = $HUD/resource_container/ice_row/IconPlate/Icon
@onready var ice_bar_container = $HUD/resource_container/ice_row/IceBarContainer
@onready var ice_bar = $HUD/resource_container/ice_row/IceBarContainer/IceBar
@onready var ice_notch_overlay = $HUD/resource_container/ice_row/IceBarContainer/IceBar/NotchOverlay
@onready var ice_count_label = $HUD/resource_container/ice_row/IceBarContainer/IceBar/CountLabel
var ice_label: Label = null

@onready var catastrom_row = $HUD/resource_container/catastrom_row
@onready var catastrom_plate = $HUD/resource_container/catastrom_row/IconPlate
@onready var catastrom_icon = $HUD/resource_container/catastrom_row/IconPlate/Icon
@onready var catastrom_bar = $HUD/resource_container/catastrom_row/CatastromBar
@onready var ready_label = $HUD/resource_container/catastrom_row/CatastromBar/ReadyLabel
var catastrom_label: Label = null
@onready var grab_icon = $HUD/GrabIcon

@onready var toast_container = $HUD/ToastContainer
var achievement_toast_container: Control
var buff_toast_container: Control
@onready var crosshair = $HUD/Crosshair
@onready var win_screen = $HUD/WinScreen
var transition_overlay: ColorRect
@onready var level_label = $HUD/LevelLabel
@onready var win_title_lbl = $HUD/WinScreen/ColorRect/VBoxContainer/Title
@onready var win_level_lbl = $HUD/WinScreen/ColorRect/VBoxContainer/LevelLbl
@onready var win_loading_lbl = $HUD/WinScreen/ColorRect/VBoxContainer/LoadingLbl

@onready var end_screen        = $HUD/EndScreen
@onready var end_title_lbl     = $HUD/EndScreen/ColorRect/VBoxContainer/Title
@onready var end_title2_lbl    = $HUD/EndScreen/ColorRect/VBoxContainer/Title2
@onready var end_subtitle_lbl  = $HUD/EndScreen/ColorRect/VBoxContainer/Subtitle
@onready var end_level_lbl     = $HUD/EndScreen/ColorRect/VBoxContainer/LevelCount
@onready var end_unlock_lbl    = $HUD/EndScreen/ColorRect/VBoxContainer/UnlockPrompt
@onready var end_prompt_lbl    = $HUD/EndScreen/ColorRect/VBoxContainer/RestartPrompt

@onready var timer_label       = $HUD/TopRightInfo/TimerLabel
@onready var weather_icon_container = $HUD/WeatherIconContainer
@onready var weather_icon       = $HUD/WeatherIconContainer/Icon
@onready var score_label       = $HUD/TopRightInfo/ScoreLabel
@onready var combo_label       = $HUD/ComboLabel
var callout_label: Label
var active_perks_hud: HFlowContainer
var _ignore_focus_out_until: int = 0
var last_callout_tier: int = 0
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
@onready var pause_title        = $HUD/pause_screen/ColorRect/CenterContainer/VBoxContainer/TitleRow/Title
@onready var pause_resume_btn   = $HUD/pause_screen/ColorRect/CenterContainer/VBoxContainer/ResumeBtn
@onready var settings_btn       = $HUD/pause_screen/ColorRect/CenterContainer/VBoxContainer/SettingsBtn
@onready var filters_btn        = $HUD/pause_screen/ColorRect/CenterContainer/VBoxContainer/FiltersBtn
@onready var controller_btn     = $HUD/pause_screen/ColorRect/CenterContainer/VBoxContainer/ControllerBtn
@onready var keyboard_row = $HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardRow
@onready var xbox_row = $HUD/ControllerScreen/CenterContainer/VBoxContainer/XboxRow
@onready var credits_btn        = $HUD/pause_screen/ColorRect/CenterContainer/VBoxContainer/CreditsBtn
@onready var pause_menu_btn     = $HUD/pause_screen/ColorRect/CenterContainer/VBoxContainer/MainMenuBtn
@onready var esc_hint_label     = $HUD/esc_hint_label

@onready var settings_screen   = $HUD/SettingsScreen
@onready var settings_bg       = $HUD/SettingsScreen/BG
@onready var settings_title    = $HUD/SettingsScreen/CenterContainer/VBoxContainer/TitleRow/Title
@onready var settings_prompt   = $HUD/SettingsScreen/CenterContainer/VBoxContainer/ClosePrompt
@onready var sfx_slider        = $HUD/SettingsScreen/CenterContainer/VBoxContainer/RowSFX/Slider
@onready var sens_slider       = $HUD/SettingsScreen/CenterContainer/VBoxContainer/RowSens/Slider
@onready var motion_check      = $HUD/SettingsScreen/CenterContainer/VBoxContainer/RowMotion/Check
@onready var vibration_check   = $HUD/SettingsScreen/CenterContainer/VBoxContainer/RowVibration/Check
@onready var fullscreen_check  = $HUD/SettingsScreen/CenterContainer/VBoxContainer/RowFullscreen/Check
@onready var settings_back_btn = $HUD/SettingsScreen/CenterContainer/VBoxContainer/BackBtn

@onready var filters_screen    = $HUD/FiltersScreen
@onready var filters_bg        = $HUD/FiltersScreen/BG
@onready var filters_title     = $HUD/FiltersScreen/CenterContainer/VBoxContainer/TitleRow/Title
@onready var filters_prompt    = $HUD/FiltersScreen/CenterContainer/VBoxContainer/ClosePrompt
@onready var color_depth_check = $HUD/FiltersScreen/CenterContainer/VBoxContainer/RowColorDepth/Check
@onready var dithering_check   = $HUD/FiltersScreen/CenterContainer/VBoxContainer/RowDithering/Check
@onready var ps1_check         = $HUD/FiltersScreen/CenterContainer/VBoxContainer/RowPS1/Check
@onready var heatwave_check    = $HUD/FiltersScreen/CenterContainer/VBoxContainer/RowHeatwave/Check
@onready var filters_back_btn  = $HUD/FiltersScreen/CenterContainer/VBoxContainer/BackBtn

@onready var controller_screen   = $HUD/ControllerScreen
@onready var controller_title    = $HUD/ControllerScreen/CenterContainer/VBoxContainer/TitleRow/Title
@onready var controller_prompt   = $HUD/ControllerScreen/CenterContainer/VBoxContainer/ClosePrompt
@onready var controller_back_btn = $HUD/ControllerScreen/CenterContainer/VBoxContainer/BackBtn

var kenney_font: Font
var galmuri_font: Font
var lang_btn_en: Button
var lang_btn_kr: Button

@onready var credits_screen   = $HUD/CreditsScreen
@onready var credits_bg       = $HUD/CreditsScreen/BG
@onready var credits_title    = $HUD/CreditsScreen/CenterContainer/VBoxContainer/TitleRow/Title
@onready var credits_prompt   = $HUD/CreditsScreen/CenterContainer/VBoxContainer/ClosePrompt
@onready var credits_vbox     = $HUD/CreditsScreen/CenterContainer/VBoxContainer
@onready var credits_back_btn = $HUD/CreditsScreen/CenterContainer/VBoxContainer/BackBtn

var achievements_btn: Button
var achievements_screen: Control
var achievement_list: VBoxContainer

var buffs_btn: Button
var buffs_screen: Control
var buffs_list: VBoxContainer

signal game_paused
signal game_resumed
var opened_from_pause: bool = false

var water_tween: Tween
var hit_tween: Tween
var heat_tween: Tween
var weather_timer_lbl: Label

# Weapon HUD
var hud_weapon_crosshair: WeaponCrosshairIcon
var hud_weapon_bg: ColorRect
var hud_weapon_name_label: Label

var reduce_motion: bool = false
var vibration_enabled: bool = true
var cursor_screen_pos: Vector2 = Vector2.ZERO  # Tracks virtual mouse for captured mode
var target_heat: float = 100.0
var _last_displayed_temp: int = -1
var target_mirage_hp: float = 100.0
var target_water: float = 100.0

var ui_tick_player: AudioStreamPlayer = null

var display_score: int = 0
var score_tween: Tween

var credits_scroll_acc: float = 0.0


var _weather_pulse_tween: Tween

var drafting_screen = null

func show_drafting_screen() -> void:
	if not drafting_screen:
		drafting_screen = load("res://scripts/DraftingScreen.gd").new()
		drafting_screen.name = "DraftingScreen"
		$HUD.add_child(drafting_screen)
		# Keep transition overlay on top for fade-to-black during cinematic
		if transition_overlay:
			$HUD.move_child(transition_overlay, -1)
	drafting_screen.show_draft()

func update_active_perks_hud() -> void:
	_ignore_focus_out_until = Time.get_ticks_msec() + 500
	if not active_perks_hud: return
	
	for c in active_perks_hud.get_children():
		c.queue_free()
		
	var counts = {}
	for p in GameState.active_wave_perks:
		counts[p] = counts.get(p, 0) + 1
		
	for p in counts.keys():
		var p_cfg = GameState.WAVE_PERKS.get(p)
		if not p_cfg: continue
		
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(32, 32)
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0.4)
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.border_color = Color(1, 0.85, 0.2, 0.6)
		panel.add_theme_stylebox_override("panel", style)
		
		var icon = TextureRect.new()
		icon.texture = load(p_cfg.icon)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 4
		icon.offset_top = 4
		icon.offset_right = -4
		icon.offset_bottom = -4
		panel.add_child(icon)
		
		if counts[p] > 1:
			var badge = Label.new()
			badge.text = "x" + str(counts[p])
			var ls = LabelSettings.new()
			ls.font = load("res://assets/fonts/Galmuri11.ttf") if GameState.language == "KR" else load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
			ls.font_size = 12
			ls.font_color = Color(1.0, 0.9, 0.3)
			ls.outline_size = 4
			ls.outline_color = Color.BLACK
			badge.label_settings = ls
			badge.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
			# Small offset to push it slightly outside the box for standard pop
			badge.offset_left = -24
			badge.offset_top = -14
			badge.offset_right = 4
			badge.offset_bottom = 4
			badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			badge.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			panel.add_child(badge)
			
		active_perks_hud.add_child(panel)

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
			if abs(heat_bar.value - target_heat) < 0.05:
				heat_bar.value = target_heat
		_update_heat_display(heat_bar.value)
			
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
		var can_show_catastrom = (GameState.level >= 4 or (GameState.is_survival_mode and GameState.current_wave >= 4))
		if catastrom_row.visible != can_show_catastrom:
			catastrom_row.visible = can_show_catastrom
			
		if reduce_motion:
			catastrom_bar.value = target_catastrom
		else:
			catastrom_bar.value = lerp(catastrom_bar.value, float(target_catastrom), 12.0 * delta)
			
		if catastrom_bar.value >= 0.99:
			if ready_label:
				ready_label.visible = true
				var pulse = (sin(Time.get_ticks_msec() * 0.008) * 0.5 + 0.5)
				ready_label.modulate.a = 0.75 + pulse * 0.25
			if is_instance_valid(catastrom_plate):
				var p_sb = catastrom_plate.get_theme_stylebox("panel") as StyleBoxFlat
				if p_sb:
					var gold_pulse = (sin(Time.get_ticks_msec() * 0.008) * 0.5 + 0.5)
					p_sb.border_color = Color(1.0, 0.85, 0.2, 0.6 + gold_pulse * 0.4)
			if Engine.get_frames_drawn() % 30 == 0:
				catastrom_bar.tint_progress = Color(0.8, 0.4, 1.0, 1.0)
			elif Engine.get_frames_drawn() % 30 == 15:
				catastrom_bar.tint_progress = Color(0.6, 0, 1, 1)
		else:
			if ready_label:
				ready_label.visible = false
			if is_instance_valid(catastrom_plate):
				var p_sb = catastrom_plate.get_theme_stylebox("panel") as StyleBoxFlat
				if p_sb:
					p_sb.border_color = Color(0.8, 0.4, 1.0, 0.6)
			catastrom_bar.tint_progress = Color(0.6, 0, 1, 1)
			

	if credits_screen and credits_screen.visible:
		var scroll_area = credits_vbox.get_node_or_null("ScrollArea") if credits_vbox else null
		if scroll_area:
			credits_scroll_acc += 25.0 * delta
			if credits_scroll_acc >= 1.0:
				var amt = int(credits_scroll_acc)
				scroll_area.scroll_vertical += amt
				credits_scroll_acc -= amt
		
func reset() -> void:
	_stop_timer_pulse()
	# Hide prompt on reset by default
	if tutorial_prompt:
		tutorial_prompt.hide()
		tutorial_prompt.modulate.a = 1.0
	update_active_perks_hud()

func show_tutorial_prompt() -> void:
	if not tutorial_prompt: return
	
	var is_kr = GameState.language == "KR"
	tutorial_aim_label.text = "조준: 마우스 / 우측 스틱" if is_kr else "Aim: Mouse / Right Stick"
	tutorial_shoot_label.text = "발사: 좌클릭 / RT" if is_kr else "Shoot: Left Click / RT"
	
	tutorial_prompt.modulate.a = 0.0
	tutorial_prompt.show()
	
	var t = create_tween()
	t.tween_property(tutorial_prompt, "modulate:a", 1.0, 0.5)

func hide_tutorial_prompt() -> void:
	if not tutorial_prompt or not tutorial_prompt.visible: return
	
	var t = create_tween()
	t.tween_property(tutorial_prompt, "modulate:a", 0.0, 0.5)
	t.tween_callback(tutorial_prompt.hide)

func _ready() -> void:

	if heat_bar: heat_bar.step = 0.0
	if mirage_bar: mirage_bar.step = 0.0
	heat_label.scale = Vector2(1.0, 1.0)
	phase2_label.visible = false
	combo_label.visible = false
	timer_label.text = ""
	_stop_timer_pulse()
	
	if is_instance_valid(ice_notch_overlay):
		ice_notch_overlay.draw.connect(_draw_ice_notches)
	
	active_perks_hud = HFlowContainer.new()
	active_perks_hud.position = Vector2(24, 60)
	active_perks_hud.size = Vector2(240, 200)
	active_perks_hud.add_theme_constant_override("h_separation", 8)
	active_perks_hud.add_theme_constant_override("v_separation", 8)
	$HUD.add_child(active_perks_hud)
	$HUD.move_child(active_perks_hud, 0)
	
	callout_label = Label.new()
	combo_label.add_sibling(callout_label)
	callout_label.visible = false
	callout_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	callout_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	callout_label.position = combo_label.position + Vector2(0, 40)
	callout_label.set_anchors_preset(Control.PRESET_CENTER)
	
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
		
		weather_timer_lbl = Label.new()
		weather_timer_lbl.label_settings = LabelSettings.new()
		weather_timer_lbl.label_settings.font = load("res://assets/fonts/Galmuri11.ttf") if GameState.language == "KR" else load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
		weather_timer_lbl.label_settings.font_size = 14
		weather_timer_lbl.label_settings.font_color = Color(1.0, 0.4, 0.4)
		weather_timer_lbl.label_settings.outline_size = 4
		weather_timer_lbl.label_settings.outline_color = Color.BLACK
		weather_timer_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		weather_icon_container.get_parent().add_child(weather_timer_lbl)
		weather_timer_lbl.visible = false
		
	update_weather_icon("none")
	
	GameState.score_updated.connect(_on_score_updated)
	_on_score_updated(GameState.current_score)
	
	# Hide all screens initially except for crosshair and HUD elements
	win_screen.visible = false
	
	transition_overlay = ColorRect.new()
	transition_overlay.name = "TransitionOverlay"
	transition_overlay.color = Color(0, 0, 0, 0)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$HUD.add_child(transition_overlay)
	# Ensure it is absolutely on top
	$HUD.move_child(transition_overlay, -1)
	pause_screen.visible = false
	lose_screen.visible = false
	settings_screen.visible = false
	if filters_screen: filters_screen.visible = false
	if controller_screen: controller_screen.visible = false
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
	
	buff_toast_container = Control.new()
	buff_toast_container.name = "BuffToastContainer"
	buff_toast_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 0)
	buff_toast_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$HUD.add_child(buff_toast_container)
	
	if pause_screen:
		$HUD.move_child(achievement_toast_container, pause_screen.get_index())
		$HUD.move_child(buff_toast_container, pause_screen.get_index())
	GameState.achievement_unlocked.connect(show_achievement_toast)
	GameState.buff_unlocked.connect(show_buff_toast)
	
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
		
	# Duplicate plate StyleBoxes so runtime animations/flashes do not mutate shared scene resources
	if water_plate:
		var w_orig = water_plate.get_theme_stylebox("panel")
		if w_orig: water_plate.add_theme_stylebox_override("panel", w_orig.duplicate())
	if ice_plate:
		var i_orig = ice_plate.get_theme_stylebox("panel")
		if i_orig: ice_plate.add_theme_stylebox_override("panel", i_orig.duplicate())
	if catastrom_plate:
		var c_orig = catastrom_plate.get_theme_stylebox("panel")
		if c_orig: catastrom_plate.add_theme_stylebox_override("panel", c_orig.duplicate())
		
	# Connect to Global signals
	win_screen.pivot_offset = get_viewport().get_visible_rect().size / 2.0
	
	reduce_motion = GameState.reduce_motion
	vibration_enabled = GameState.vibration_enabled
	
	kenney_font = load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	galmuri_font = load("res://assets/fonts/Galmuri11.ttf")
	var font = kenney_font
	
	if ready_label:
		ready_label.visible = false
		var ready_font = galmuri_font if is_kr else kenney_font
		_style_lbl(ready_label, 14 if is_kr else 13, Color(1.0, 0.85, 0.2, 1.0), 3, Color.BLACK, ready_font)
		ready_label.text = "준비 완료!" if is_kr else "MAX READY!"
	
	var parent = heat_label.get_parent()
	var heat_hbox = HBoxContainer.new()
	heat_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	heat_hbox.add_theme_constant_override("separation", 6)
	parent.add_child(heat_hbox)
	parent.move_child(heat_hbox, heat_label.get_index())
	
	parent.remove_child(heat_label)
	heat_hbox.add_child(heat_label)
	
	heat_val_label = Label.new()
	heat_val_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	heat_hbox.add_child(heat_val_label)
	
	_style_lbl(heat_label, 22, Color(1.0, 1.0, 1.0, 0.9), 3, Color.BLACK, font)
	_style_lbl(heat_val_label, 22, Color(1.0, 0.95, 0.5, 1.0), 3, Color.BLACK, font)
	_style_lbl(water_label, 22, Color(0.4, 0.9, 1.0, 1.0), 3, Color.BLACK, font)
	_style_lbl(ice_label, 22, Color(0.5, 0.85, 1.0, 1.0), 3, Color.BLACK, font)
	_style_lbl(catastrom_label, 22, Color(0.8, 0.4, 1.0, 1.0), 3, Color.BLACK, font)

	_style_lbl(level_label, 22, Color(1.0, 0.9, 0.3, 1.0), 3, Color.BLACK, font)
	
	# Top right buttons (now in pause menu, styled separately below)

	# New elements
	_style_lbl(timer_label, 22, Color(1.0, 0.8, 0.2, 1.0), 2, Color.BLACK, font)
	
	var callout_font = galmuri_font if GameState.language == "KR" else kenney_font
	_style_lbl(callout_label, 36, Color(0.4, 0.9, 1.0, 1.0), 3, Color.BLACK, callout_font)
	
	if score_label:
		_style_lbl(score_label, 26, Color(1.0, 0.9, 0.3, 1.0), 3, Color.BLACK, font)
	_style_lbl(phase2_label, 48, Color(1.0, 0.4, 0.1, 1.0), 3, Color.BLACK, font)
	
	_style_lbl(lose_title_lbl, 64, Color(1.0, 0.4, 0.1, 1.0), 3, Color.BLACK, font)
	_style_lbl(lose_subtitle_lbl, 22, Color(1.0, 0.4, 0.1, 0.65), 2, Color.BLACK, font)
	_style_lbl(lose_level_lbl, 16, Color(1.0, 0.8, 0.2, 0.5), 2, Color.BLACK, font)

	var cfg = GameState.LEVEL_CONFIG[GameState.level]
	var can_show_ice = (cfg.ice_charges > 0) and not (GameState.is_survival_mode and GameState.current_wave < 2 and GameState.ice_charges_remaining <= 0)
	if can_show_ice:
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
	for lbl in [win_level_lbl, lose_subtitle_lbl, end_level_lbl, lose_level_lbl, lose_wave_time_lbl]:
		if lbl:
			_style_lbl(lbl, subtitle_size, title_color, 5, Color(0, 0, 0, 1.0), font)
			
	if end_subtitle_lbl:
		_style_lbl(end_subtitle_lbl, 28 if is_kr else 24, title_color, 5, Color(0, 0, 0, 1.0), font)
			
	if end_unlock_lbl:
		_style_lbl(end_unlock_lbl, subtitle_size, Color(0.2, 0.8, 1.0, 1.0), 5, Color(0, 0, 0, 1.0), font)
			
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
	_style_lbl(settings_title, 32, Color(1.0, 0.88, 0.3, 1.0), 4, Color.BLACK, font)
	if filters_title: _style_lbl(filters_title, 32, Color(1.0, 0.88, 0.3, 1.0), 4, Color.BLACK, font)
	_style_lbl(credits_title, 32, Color(1.0, 0.88, 0.3, 1.0), 4, Color.BLACK, font)
	
	# Close Prompts — Settings, Filters, and Credits (WCAG 10.7:1 PASS)
	for p_lbl in [settings_prompt, filters_prompt, credits_prompt]:
		if p_lbl:
			_style_lbl(p_lbl, 14, Color(1.0, 0.88, 0.3, 0.85), 1, Color.BLACK, font)
			if not reduce_motion:
				var sp_tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				sp_tw.tween_property(p_lbl, "modulate:a", 0.7, 1.2)
				sp_tw.tween_property(p_lbl, "modulate:a", 1.0, 1.2)
			else:
				p_lbl.modulate.a = 1.0
 
	# Row Labels styling (13.4:1 contrast PASS)
	for row_name in ["RowSFX", "RowSens", "RowMotion", "RowVibration", "RowFullscreen"]:
		var r_node = $HUD/SettingsScreen/CenterContainer/VBoxContainer.get_node_or_null(row_name)
		if r_node:
			var r_lbl = r_node.get_node_or_null("Label")
			if r_lbl:
				_style_lbl(r_lbl, 20, Color(1.0, 0.85, 0.2, 1.0), 2, Color.BLACK, font)
				r_lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	for row_name in ["RowColorDepth", "RowDithering", "RowPS1", "RowHeatwave"]:
		var filter_r_node = $HUD/FiltersScreen/CenterContainer/VBoxContainer.get_node_or_null(row_name)
		if filter_r_node:
			var r_lbl = filter_r_node.get_node_or_null("Label")
			if r_lbl:
				_style_lbl(r_lbl, 20, Color(1.0, 0.85, 0.2, 1.0), 2, Color.BLACK, font)
				r_lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	# Build language row programmatically (below RowFullscreen)
	_build_lang_row(font)

	if pause_resume_btn:
		pause_resume_btn.pressed.connect(_on_pause_resume_pressed)
	if settings_btn:
		settings_btn.pressed.connect(_on_settings_pressed)
	if filters_btn:
		filters_btn.pressed.connect(_on_filters_pressed)
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
		
		buffs_btn = achievements_btn.duplicate()
		buffs_btn.name = "BuffsBtn"
		achievements_btn.get_parent().add_child(buffs_btn)
		achievements_btn.get_parent().move_child(buffs_btn, achievements_btn.get_index() + 1)
		buffs_btn.pressed.connect(show_buffs_screen)
		
	_build_achievements_screen()
	_build_buffs_screen()

	if font:
		if pause_title: _style_lbl(pause_title, 32, Color(1.0, 0.85, 0.2, 1.0), 3, Color.BLACK, font)

	_apply_language(GameState.language)
	_setup_weapon_hud()
	
	# Apply unified Z-Depth drop shadows to all HUD panels
	_apply_unified_drop_shadows($HUD)

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
	# Standard Menu & Lose Screen buttons
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

	for btn in [retry_btn, menu_btn, pause_resume_btn, settings_btn, filters_btn, credits_btn, controller_btn, achievements_btn, buffs_btn, pause_menu_btn, settings_back_btn, filters_back_btn, credits_back_btn, controller_back_btn]:
		if btn:
			if font: btn.add_theme_font_override("font", font)
			btn.add_theme_font_size_override("font_size", 22)
			btn.add_theme_constant_override("letter_spacing", 1)
			btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
			btn.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.2, 1.0))
			btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.85, 0.2, 1.0))
			btn.add_theme_color_override("font_focus_color", Color(1.0, 0.85, 0.2, 1.0))
			btn.add_theme_color_override("font_disabled_color", Color(1.0, 0.85, 0.2, 1.0))
			btn.add_theme_constant_override("outline_size", 2)
			btn.add_theme_color_override("font_outline_color", Color.BLACK)
			btn.add_theme_stylebox_override("normal", style_menu_btn)
			btn.add_theme_stylebox_override("hover", style_menu_btn_hover)
			btn.add_theme_stylebox_override("pressed", style_menu_btn_pressed)
			btn.add_theme_stylebox_override("disabled", style_menu_btn_disabled)
			btn.add_theme_stylebox_override("focus", style_focus)
			btn.focus_mode = Control.FOCUS_ALL
			btn.custom_minimum_size = Vector2(280, 44)

			
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

	for btn in [motion_check, vibration_check, fullscreen_check, color_depth_check, dithering_check, ps1_check, heatwave_check]:
		if btn:
			if font: btn.add_theme_font_override("font", font)
			btn.add_theme_font_size_override("font_size", 18)
			btn.add_theme_constant_override("outline_size", 2)
			btn.add_theme_color_override("font_outline_color", Color.BLACK)
			btn.add_theme_stylebox_override("normal", style_btn_off)
			btn.add_theme_stylebox_override("hover", style_btn_off)
			btn.add_theme_stylebox_override("pressed", style_btn_on)
			btn.add_theme_stylebox_override("focus", style_focus)

	# Trust GameState.fullscreen which is loaded directly from settings.cfg
	# Do not poll OS mode here as macOS fullscreen transitions are asynchronous.

	# Apply GameState values to controls
	sfx_slider.value = GameState.sfx_volume
	sens_slider.value = GameState.mouse_sensitivity
	motion_check.button_pressed = GameState.reduce_motion
	if vibration_check: vibration_check.button_pressed = GameState.vibration_enabled
	fullscreen_check.button_pressed = GameState.fullscreen
	if color_depth_check: color_depth_check.button_pressed = GameState.filter_color_depth
	if dithering_check: dithering_check.button_pressed = GameState.filter_dithering
	if ps1_check: ps1_check.button_pressed = GameState.filter_ps1
	if heatwave_check: heatwave_check.button_pressed = GameState.filter_heatwave

	# Connect control signals
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	sens_slider.value_changed.connect(_on_sens_changed)
	motion_check.toggled.connect(_on_motion_toggled)
	if vibration_check: vibration_check.toggled.connect(_on_vibration_toggled)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	if color_depth_check: color_depth_check.toggled.connect(_on_color_depth_toggled)
	if dithering_check: dithering_check.toggled.connect(_on_dithering_toggled)
	if ps1_check: ps1_check.toggled.connect(_on_ps1_toggled)
	if heatwave_check: heatwave_check.toggled.connect(_on_heatwave_toggled)
	
	if settings_back_btn:
		settings_back_btn.pressed.connect(_close_settings)
	if filters_back_btn:
		filters_back_btn.pressed.connect(_close_filters)
	if credits_back_btn:
		credits_back_btn.pressed.connect(_close_credits)
	if controller_btn:
		controller_btn.pressed.connect(_on_controller_pressed)

	_build_input_toggle()
	if controller_back_btn:
		controller_back_btn.pressed.connect(_close_controller)

	# Apply initial AudioServer volume (since GameState doesn't manage AudioServer directly)
	_on_sfx_volume_changed(GameState.sfx_volume)
	
	# Emit signals for sensitivity and motion so Player/Camera can catch them, but avoid triggering save_settings
	sensitivity_changed.emit(GameState.mouse_sensitivity)
	reduce_motion_changed.emit(GameState.reduce_motion)
	
	# Apply initial visual button states without triggering full toggle logic
	_update_toggle_btn(motion_check, GameState.reduce_motion)
	if vibration_check: _update_toggle_btn(vibration_check, GameState.vibration_enabled)
	_update_toggle_btn(fullscreen_check, GameState.fullscreen)
	if color_depth_check: _update_toggle_btn(color_depth_check, GameState.filter_color_depth)
	if dithering_check: _update_toggle_btn(dithering_check, GameState.filter_dithering)
	if ps1_check: _update_toggle_btn(ps1_check, GameState.filter_ps1)
	if heatwave_check: _update_toggle_btn(heatwave_check, GameState.filter_heatwave)
	
	
	# Accessibility Metadata
	heat_bar.set_meta("accessible_name", "Sun heat level")
	water_bar.set_meta("accessible_name", "Water gun level")  
	level_label.set_meta("accessible_name", "Current level")
	crosshair.set_meta("accessible_name", "Crosshair")
	win_screen.set_meta("accessible_name", "Level complete screen")
	settings_screen.set_meta("accessible_name", "Settings screen")
	if filters_screen: filters_screen.set_meta("accessible_name", "Filters screen")
	credits_screen.set_meta("accessible_name", "Credits screen")
	
	_setup_controls_ui()

# ---------- Language -------------------------------------------------------

func _build_lang_row(font: Font) -> void:
	var vbox = $HUD/SettingsScreen/CenterContainer/VBoxContainer
	if not vbox: return

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
	var lang_focus = StyleBoxFlat.new()
	lang_focus.bg_color = Color(0, 0, 0, 0)
	lang_focus.border_color = Color(1.0, 0.85, 0.2, 1.0)
	lang_focus.set_border_width_all(2)
	lang_focus.set_corner_radius_all(6)
	
	btn_en.add_theme_stylebox_override("focus", lang_focus)
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
	btn_kr.add_theme_stylebox_override("focus", lang_focus)
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

	# Insert right before Divider2 (so the bottom divider stays directly above the BackBtn)
	var divider2 = vbox.get_node_or_null("Divider2")
	if divider2:
		vbox.add_child(row)
		vbox.move_child(row, divider2.get_index())
	else:
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
	GameState.language = lang
	var is_kr := lang == "KR"
	var font: Font = galmuri_font if is_kr else kenney_font
	var body_font: Font = galmuri_font if is_kr else load("res://assets/fonts/Inter-Medium.ttf")

	# ── Gameplay HUD (Galmuri11 is small, so we scale it up in KR to visually match EN) ──
	if heat_label:
		if font: heat_label.add_theme_font_override("font", font)
		heat_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)
		if heat_val_label:
			if font: heat_val_label.add_theme_font_override("font", font)
			heat_val_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)
		_update_heat_display(heat_bar.value if heat_bar else target_heat, true)
	if water_label:
		water_label.text = "물" if is_kr else "WATER"
		if font: water_label.add_theme_font_override("font", font)
		water_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)
	if ice_label:
		ice_label.text = "얼음 폭발" if is_kr else "ICE BURST"
		if font: ice_label.add_theme_font_override("font", font)
		ice_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)
	if ice_count_label:
		if font: ice_count_label.add_theme_font_override("font", font)
		ice_count_label.add_theme_font_size_override("font_size", 13 if is_kr else 12)
	if catastrom_label:
		catastrom_label.text = "카타스트롬" if is_kr else "CATASTROM"
		if font: catastrom_label.add_theme_font_override("font", font)
		catastrom_label.add_theme_font_size_override("font_size", 26 if is_kr else 22)
	if ready_label:
		ready_label.text = "준비 완료!" if is_kr else "MAX READY!"
		if font: ready_label.add_theme_font_override("font", font)
		ready_label.add_theme_font_size_override("font_size", 14 if is_kr else 13)

	if tutorial_aim_label:
		tutorial_aim_label.text = "조준: 마우스 / 우측 스틱" if is_kr else "Aim: Mouse / Right Stick"
		if font: tutorial_aim_label.add_theme_font_override("font", font)
		tutorial_aim_label.add_theme_font_size_override("font_size", 22 if is_kr else 18)
	if tutorial_shoot_label:
		tutorial_shoot_label.text = "발사: 좌클릭 / RT" if is_kr else "Shoot: Left Click / RT"
		if font: tutorial_shoot_label.add_theme_font_override("font", font)
		tutorial_shoot_label.add_theme_font_size_override("font_size", 24 if is_kr else 20)

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
		
	if callout_label:
		if font: callout_label.add_theme_font_override("font", font)
		callout_label.add_theme_font_size_override("font_size", 42 if is_kr else 36)

	# ── Top-right labels (in HBoxContainer, sizes scaled to match visually) ──
	# (These buttons were moved to the pause menu, styled in _ready and translated below)

	# ── Settings panel ────────────────────────────────────────────────────────
	var settings_vbox = $HUD/SettingsScreen/CenterContainer/VBoxContainer
	if settings_title:
		settings_title.text = "설정" if is_kr else "SETTINGS"
		if font: settings_title.add_theme_font_override("font", font)
		settings_title.add_theme_font_size_override("font_size", 32)
		settings_title.add_theme_constant_override("outline_size", 4)
		settings_title.add_theme_color_override("font_outline_color", Color.BLACK)

	# Style separators cleanly to match the Credits screen
	var sep_style = StyleBoxLine.new()
	sep_style.color = Color(1.0, 0.88, 0.3, 0.35)
	sep_style.grow_begin = 0
	sep_style.grow_end = 0
	sep_style.thickness = 2
	sep_style.content_margin_top = 0
	sep_style.content_margin_bottom = 0
	if settings_vbox:
		for sep_name in ["Divider", "Divider2"]:
			var sep = settings_vbox.get_node_or_null(sep_name)
			if sep:
				sep.add_theme_stylebox_override("separator", sep_style)

	var controller_vbox = controller_screen.get_node_or_null("CenterContainer/VBoxContainer") if controller_screen else null
	if controller_vbox:
		for sep_name in ["Divider", "Divider2"]:
			var sep = controller_vbox.get_node_or_null(sep_name)
			if sep:
				sep.add_theme_stylebox_override("separator", sep_style)

	var achieves_vbox = achievements_screen.get_node_or_null("CenterContainer/VBoxContainer") if achievements_screen else null
	if achieves_vbox:
		for sep_name in ["Divider", "Divider2"]:
			var sep = achieves_vbox.get_node_or_null(sep_name)
			if sep:
				sep.add_theme_stylebox_override("separator", sep_style)

	var buffs_vbox = buffs_screen.get_node_or_null("CenterContainer/VBoxContainer") if buffs_screen else null
	if buffs_vbox:
		for sep_name in ["Divider", "Divider2"]:
			var sep = buffs_vbox.get_node_or_null(sep_name)
			if sep:
				sep.add_theme_stylebox_override("separator", sep_style)

	var pause_vbox = $HUD/pause_screen/ColorRect/CenterContainer/VBoxContainer
	if pause_vbox:
		var pause_div = pause_vbox.get_node_or_null("Divider")
		if pause_div:
			pause_div.add_theme_stylebox_override("separator", sep_style)

	# ── Restyle Lose Screen (fix HDR bleed and match design system) ──
	if lose_screen:
		var lose_bg = lose_screen.get_node_or_null("ColorRect")
		if lose_bg:
			# Fully opaque to block Supernova HDR bleed-through
			lose_bg.color = Color(0.02, 0.01, 0.05, 1.0)
			
		if not lose_screen.has_node("LoseBorder"):
			var lose_border = Panel.new()
			lose_border.name = "LoseBorder"
			lose_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
			lose_border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			lose_border.offset_left = 24
			lose_border.offset_top = 24
			lose_border.offset_right = -24
			lose_border.offset_bottom = -24
			
			var b_style = StyleBoxFlat.new()
			b_style.bg_color = Color(0, 0, 0, 0)
			b_style.border_width_left = 2
			b_style.border_width_top = 2
			b_style.border_width_right = 2
			b_style.border_width_bottom = 2
			b_style.border_color = Color(1.0, 0.85, 0.2, 0.4)
			b_style.corner_radius_top_left = 8
			b_style.corner_radius_top_right = 8
			b_style.corner_radius_bottom_left = 8
			b_style.corner_radius_bottom_right = 8
			lose_border.add_theme_stylebox_override("panel", b_style)
			lose_screen.add_child(lose_border)
		
		var lose_vbox = lose_screen.get_node_or_null("ColorRect/VBoxContainer")
		if lose_vbox:
			lose_vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			lose_vbox.add_theme_constant_override("separation", 24)
			lose_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
			
			for child in lose_vbox.get_children():
				if child is Label:
					child.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				elif child is BoxContainer:
					child.alignment = BoxContainer.ALIGNMENT_CENTER
			
			var hbox = lose_vbox.get_node_or_null("HBoxContainer")
			if hbox:
				var btns = hbox.get_children()
				for b in btns:
					hbox.remove_child(b)
					lose_vbox.add_child(b)
				hbox.name = "HBoxContainer_deleted"
				hbox.queue_free()
			
			for s in ["SpacerDivider", "Spacer2", "CenterContainer"]:
				var n = lose_vbox.get_node_or_null(s)
				if n:
					n.name = s + "_deleted" # Rename to avoid matching again if queried
					n.queue_free()
			
			if not lose_vbox.has_node("LoseDivider"):
				var hsep = HSeparator.new()
				hsep.name = "LoseDivider"
				hsep.add_theme_stylebox_override("separator", sep_style)
				lose_vbox.add_child(hsep)
				# Move it after the titles
				lose_vbox.move_child(hsep, 2)

	# ── Restyle Win Screen (match design system) ──
	if win_screen:
		var win_bg = win_screen.get_node_or_null("ColorRect")
		if win_bg:
			win_bg.color = Color(0.02, 0.01, 0.05, 1.0)
			
		if not win_screen.has_node("WinBorder"):
			var win_border = Panel.new()
			win_border.name = "WinBorder"
			win_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
			win_border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			win_border.offset_left = 24
			win_border.offset_top = 24
			win_border.offset_right = -24
			win_border.offset_bottom = -24
			
			var b_style = StyleBoxFlat.new()
			b_style.bg_color = Color(0, 0, 0, 0)
			b_style.border_width_left = 2
			b_style.border_width_top = 2
			b_style.border_width_right = 2
			b_style.border_width_bottom = 2
			b_style.border_color = Color(1.0, 0.85, 0.2, 0.4)
			b_style.corner_radius_top_left = 8
			b_style.corner_radius_top_right = 8
			b_style.corner_radius_bottom_left = 8
			b_style.corner_radius_bottom_right = 8
			win_border.add_theme_stylebox_override("panel", b_style)
			win_screen.add_child(win_border)
		
		var win_vbox = win_screen.get_node_or_null("ColorRect/VBoxContainer")
		if win_vbox:
			win_vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			win_vbox.add_theme_constant_override("separation", 24)
			win_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
			
			for child in win_vbox.get_children():
				if child is Label:
					child.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				elif child is BoxContainer:
					child.alignment = BoxContainer.ALIGNMENT_CENTER
			
			if not win_vbox.has_node("WinDivider"):
				var hsep = HSeparator.new()
				hsep.name = "WinDivider"
				hsep.add_theme_stylebox_override("separator", sep_style)
				win_vbox.add_child(hsep)
				# Move it after the title
				win_vbox.move_child(hsep, 1)

	# Style TitleIcon panels across all menus
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = Color(0, 0, 0, 0)
	icon_style.border_color = Color(1.0, 0.85, 0.2, 0.4)
	icon_style.set_border_width_all(2)
	for icon_path in [
		"HUD/pause_screen/ColorRect/CenterContainer/VBoxContainer/TitleRow/TitleIcon",
		"HUD/SettingsScreen/CenterContainer/VBoxContainer/TitleRow/TitleIcon",
		"HUD/FiltersScreen/CenterContainer/VBoxContainer/TitleRow/TitleIcon",
		"HUD/CreditsScreen/CenterContainer/VBoxContainer/TitleRow/TitleIcon"
	]:
		var icon_panel = get_node_or_null(icon_path)
		if icon_panel:
			icon_panel.add_theme_stylebox_override("panel", icon_style)

	var row_texts_en := ["Master Volume", "Sensitivity", "Reduce Motion", "Vibration", "Fullscreen", "Language"]
	var row_texts_kr := ["전체 볼륨", "마우스 감도", "화면 흔들림 감소", "진동", "전체 화면", "언어"]
	var row_names    := ["RowSFX", "RowSens", "RowMotion", "RowVibration", "RowFullscreen", "RowLanguage"]
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
					r_lbl.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.2, 1.0))
					r_lbl.add_theme_color_override("font_pressed_color", Color(1.0, 0.85, 0.2, 1.0))
					r_lbl.add_theme_color_override("font_focus_color", Color(1.0, 0.85, 0.2, 1.0))
					r_lbl.add_theme_color_override("font_disabled_color", Color(1.0, 0.85, 0.2, 1.0))
					r_lbl.add_theme_constant_override("outline_size", 2)
					r_lbl.add_theme_color_override("font_outline_color", Color.BLACK)

	for btn in [settings_back_btn]:
		if btn:
			btn.text = "뒤로" if is_kr else "BACK"
			if font: btn.add_theme_font_override("font", font)

	if settings_prompt:
		if font: settings_prompt.add_theme_font_override("font", font)

	# ── Filters panel ─────────────────────────────────────────────────────────
	if filters_title:
		filters_title.text = "필터" if is_kr else "FILTERS"
		if font: filters_title.add_theme_font_override("font", font)
		filters_title.add_theme_font_size_override("font_size", 32)
		filters_title.add_theme_constant_override("outline_size", 4)
		filters_title.add_theme_color_override("font_outline_color", Color.BLACK)
	if filters_prompt:
		filters_prompt.text = "닫으려면 ESC를 누르세요" if is_kr else "PRESS ESC TO CLOSE"
		if font: filters_prompt.add_theme_font_override("font", font)
	if filters_back_btn:
		filters_back_btn.text = "뒤로" if is_kr else "BACK"
		if font: filters_back_btn.add_theme_font_override("font", font)

	var filter_vbox = filters_screen.get_node_or_null("CenterContainer/VBoxContainer") if filters_screen else null
	if filter_vbox:
		var filter_labels = {
			"RowColorDepth": "레트로 색상" if is_kr else "Retro Colors",
			"RowDithering": "디더링" if is_kr else "Dithering",
			"RowPS1": "PS1 셰이딩" if is_kr else "PS1 Shading",
			"RowHeatwave": "폭염 1984" if is_kr else "Heatwave 1984"
		}
		for r_name in filter_labels:
			var r = filter_vbox.get_node_or_null(r_name)
			if r:
				var r_lbl = r.get_node_or_null("Label")
				if r_lbl:
					r_lbl.text = filter_labels[r_name]
					if font: r_lbl.add_theme_font_override("font", font)
					r_lbl.add_theme_font_size_override("font_size", 20)
					r_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
					r_lbl.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.2, 1.0))
					r_lbl.add_theme_color_override("font_pressed_color", Color(1.0, 0.85, 0.2, 1.0))
					r_lbl.add_theme_color_override("font_focus_color", Color(1.0, 0.85, 0.2, 1.0))
					r_lbl.add_theme_color_override("font_disabled_color", Color(1.0, 0.85, 0.2, 1.0))
					r_lbl.add_theme_constant_override("outline_size", 2)
					r_lbl.add_theme_color_override("font_outline_color", Color.BLACK)

		for sep_name in ["Divider", "Divider2"]:
			var sep = filter_vbox.get_node_or_null(sep_name)
			if sep:
				sep.add_theme_stylebox_override("separator", sep_style)

	# ── Credits panel ─────────────────────────────────────────────────────────
	if credits_title:
		credits_title.text = "크레딧" if is_kr else "CREDITS"
		if font: credits_title.add_theme_font_override("font", font)
		credits_title.add_theme_font_size_override("font_size", 32)
		credits_title.add_theme_constant_override("outline_size", 4)
		credits_title.add_theme_color_override("font_outline_color", Color.BLACK)

	# Style separators cleanly
	sep_style = StyleBoxLine.new()
	sep_style.color = Color(1.0, 0.88, 0.3, 0.35)
	sep_style.grow_begin = 0
	sep_style.grow_end = 0
	sep_style.thickness = 2
	sep_style.content_margin_top = 0
	sep_style.content_margin_bottom = 0
	for sep_name in ["Divider", "Divider2"]:
		var sep = credits_vbox.get_node_or_null(sep_name)
		if sep:
			sep.add_theme_stylebox_override("separator", sep_style)

	# Style the credits content dynamically with clear text hierarchy and sizing
	var scroll_area = credits_vbox.get_node_or_null("ScrollArea")
	if scroll_area:
		var credits_list = scroll_area.get_node_or_null("CreditsList")
		if credits_list:
			# Translate headers and specific roles
			var hdr_core = credits_list.get_node_or_null("HdrCore")
			if hdr_core: hdr_core.text = "주요 팀원" if is_kr else "CORE TEAM"
			var hdr_3d = credits_list.get_node_or_null("Hdr3D")
			if hdr_3d: hdr_3d.text = "3D 모델" if is_kr else "3D MODELS"
			var hdr_tex = credits_list.get_node_or_null("HdrTextures")
			if hdr_tex: hdr_tex.text = "텍스처" if is_kr else "TEXTURES"
			var hdr_audio = credits_list.get_node_or_null("HdrAudio")
			if hdr_audio: hdr_audio.text = "오디오" if is_kr else "AUDIO"
			var hdr_engine = credits_list.get_node_or_null("HdrEngine")
			if hdr_engine: hdr_engine.text = "엔진" if is_kr else "ENGINE"
			var hdr_ui = credits_list.get_node_or_null("HdrUI")
			if hdr_ui: hdr_ui.text = "UI 및 폰트" if is_kr else "UI & FONT"
			var hdr_env = credits_list.get_node_or_null("HdrEnv")
			if hdr_env: hdr_env.text = "환경" if is_kr else "ENVIRONMENT"
			var hdr_special = credits_list.get_node_or_null("HdrSpecial")
			if hdr_special: hdr_special.text = "특별한 감사" if is_kr else "SPECIAL THANKS"

			var itm_core1 = credits_list.get_node_or_null("ItmCore1")
			if itm_core1: itm_core1.text = "Ashutos1997  ·  게임 기획 및 디렉션" if is_kr else "Ashutos1997  ·  Product Design & Direction"
			var itm_core2 = credits_list.get_node_or_null("ItmCore2")
			if itm_core2: itm_core2.text = "Ivy  ·  UI 및 시각 디자인" if is_kr else "Ivy  ·  UI & Visual Designer"
			var itm_special1 = credits_list.get_node_or_null("ItmSpecial1")
			if itm_special1: itm_special1.text = "Yodi (요디님) & 카카오톡 디자인 클럽  ·  초기 콘셉트 영감 제공" if is_kr else "Yodi (요디님) & Kakao based Design Club  ·  Original Concept Inspiration"
			var itm_ui1d = credits_list.get_node_or_null("ItmUI1d")
			if itm_ui1d: itm_ui1d.text = "HUD 미터 아이콘  ·  Yudhi Restu Pebriyanto, Jaya99, balyanbinmalkan (Noun Project)  ·  CC BY 3.0" if is_kr else "HUD Meter Icons  ·  Yudhi Restu Pebriyanto, Jaya99, balyanbinmalkan (Noun Project)  ·  CC BY 3.0"

			var itm_audio10 = credits_list.get_node_or_null("ItmAudio10")
			if itm_audio10: itm_audio10.text = "SFX - 얼음 발사음  ·  urupin (Freesound)  ·  CC0" if is_kr else "SFX - Ice Shoot  ·  urupin (Freesound)  ·  CC0"
			var itm_audio11 = credits_list.get_node_or_null("ItmAudio11")
			if itm_audio11: itm_audio11.text = "SFX - 얼음 피격음  ·  antonsoederberg (Freesound)  ·  CC0" if is_kr else "SFX - Ice Hit  ·  antonsoederberg (Freesound)  ·  CC0"
			var itm_audio12 = credits_list.get_node_or_null("ItmAudio12")
			if itm_audio12: itm_audio12.text = "SFX - 바다 파도 앰비언스  ·  CC0" if is_kr else "SFX - Ocean Waves Ambient  ·  CC0"
			var itm_audio13 = credits_list.get_node_or_null("ItmAudio13")
			if itm_audio13: itm_audio13.text = "SFX - 실드 파괴음  ·  IgnasD (OpenGameArt)  ·  CC0" if is_kr else "SFX - Shield Shatter  ·  IgnasD (OpenGameArt)  ·  CC0"
			var itm_audio14 = credits_list.get_node_or_null("ItmAudio14")
			if itm_audio14: itm_audio14.text = "SFX - 실드 생성음  ·  bart (OpenGameArt)  ·  CC0" if is_kr else "SFX - Shield Materialize  ·  bart (OpenGameArt)  ·  CC0"

			var itm_ice_vfx = credits_list.get_node_or_null("ItmIceVFX")
			if itm_ice_vfx: itm_ice_vfx.text = "VFX - 얼음 폭발 발사체 및 입자 효과  ·  절차적 Godot 기본 도형" if is_kr else "VFX - Ice Blast Projectile & Particles  ·  Procedural Godot Primitives"
			var itm_magma = credits_list.get_node_or_null("ItmMagmaDebris")
			if itm_magma: itm_magma.text = "VFX - 물리적 마그마 파편  ·  Quaternius Rock Models 및 Godot RigidBody3D" if is_kr else "VFX - Physical Magma Debris  ·  Quaternius Rock Models & RigidBody3D"
			var itm_solar_wind = credits_list.get_node_or_null("ItmSolarWind")
			if itm_solar_wind: itm_solar_wind.text = "VFX 및 오디오 - 태양풍  ·  절차적 파티클 및 AudioStreamGenerator" if is_kr else "VFX & Audio - Solar Wind Hazard  ·  Procedural Particles & Synth"
			var itm_stream_combo = credits_list.get_node_or_null("ItmStreamCombo")
			if itm_stream_combo: itm_stream_combo.text = "물줄기 콤보 UI 및 태양 표정  ·  절차적 GDScript 및 Godot Image API" if is_kr else "Stream Combo UI & Sun Expressions  ·  Procedural GDScript & Image API"
			var itm_shield_vfx = credits_list.get_node_or_null("ItmShieldVFX")
			if itm_shield_vfx: itm_shield_vfx.text = "VFX - 태양 플레어 실드  ·  절차적 프레넬 셰이더 및 파티클" if is_kr else "VFX - Solar Flare Shield  ·  Procedural Fresnel Shader & Particles"

			var itm_disclaimer = credits_list.get_node_or_null("ItmDisclaimer")
			if itm_disclaimer:
				itm_disclaimer.text = "*면책 조항: 가면라이더 및 관련 캐릭터(가면라이더 제츠 포함)는 토에이 주식회사 및 이시모리 프로덕션의 자산입니다. 본 게임은 비영리 팬 제작물이며 토에이의 공식 인가를 받지 않았습니다." if is_kr else "*Disclaimer: Kamen Rider and related characters (including Kamen Rider Zeztz) are the property of Toei Company, Ltd. and Ishimori Productions. This game is a non-profit, unofficial fan work and is not affiliated with or endorsed by Toei Company."

			for child in credits_list.get_children():
					if child is Label:
						var is_header = child.name.begins_with("Hdr")
						var is_disclaimer = child.name == "ItmDisclaimer"
						if is_header:
							if font: child.add_theme_font_override("font", font)
						else:
							if body_font: child.add_theme_font_override("font", body_font)
						child.add_theme_font_size_override("font_size", 20 if is_header else (12 if is_disclaimer else 15))
						# Outline and colors
						child.add_theme_constant_override("outline_size", 3 if is_header else (1 if is_disclaimer else 2))
						child.add_theme_color_override("font_outline_color", Color.BLACK)
						if is_header:
							child.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
							child.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.2, 1.0))
							child.add_theme_color_override("font_pressed_color", Color(1.0, 0.85, 0.2, 1.0))
							child.add_theme_color_override("font_focus_color", Color(1.0, 0.85, 0.2, 1.0))
							child.add_theme_color_override("font_disabled_color", Color(1.0, 0.85, 0.2, 1.0))
						elif is_disclaimer:
							child.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75, 0.7))
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
		win_title_lbl.add_theme_font_size_override("font_size", 56)
		win_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
		win_title_lbl.add_theme_constant_override("outline_size", 4)
		win_title_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	if win_level_lbl:
		# Note: The level text itself is usually updated at runtime, but we set font styles here.
		if font: win_level_lbl.add_theme_font_override("font", font)
		win_level_lbl.add_theme_font_size_override("font_size", 20 if is_kr else 18)
		win_level_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.7))
		win_level_lbl.add_theme_constant_override("outline_size", 4)
		win_level_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	if win_loading_lbl:
		win_loading_lbl.text = "다음 단계 로딩 중..." if is_kr else "NEXT LEVEL LOADING..."
		if font: win_loading_lbl.add_theme_font_override("font", font)
		win_loading_lbl.add_theme_font_size_override("font_size", 16 if is_kr else 14)
		win_loading_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.5))
		win_loading_lbl.add_theme_constant_override("outline_size", 4)
		win_loading_lbl.add_theme_color_override("font_outline_color", Color.BLACK)

	# ── Lose screen & Phase 2 ─────────────────────────────────────────────────
	if lose_title_lbl:
		lose_title_lbl.text = "태양이 이겼습니다" if is_kr else "THE SUN WON"
		if font: lose_title_lbl.add_theme_font_override("font", font)
		lose_title_lbl.add_theme_font_size_override("font_size", 56)
		lose_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
		lose_title_lbl.add_theme_constant_override("outline_size", 4)
		lose_title_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	if lose_title2_lbl:
		lose_title2_lbl.hide()
	if lose_subtitle_lbl:
		lose_subtitle_lbl.text = "너무 뜨겁습니다" if is_kr else "TOO HOT TO HANDLE"
		if font: lose_subtitle_lbl.add_theme_font_override("font", font)
		lose_subtitle_lbl.add_theme_font_size_override("font_size", 20 if is_kr else 18)
		lose_subtitle_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.7))
		lose_subtitle_lbl.add_theme_constant_override("outline_size", 4)
		lose_subtitle_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	if lose_level_lbl:
		lose_level_lbl.text = "%02d 단계 실패" % GameState.level if is_kr else "LEVEL %02d FAILED" % GameState.level
		if font: lose_level_lbl.add_theme_font_override("font", font)
		lose_level_lbl.add_theme_font_size_override("font_size", 20 if is_kr else 18)
		lose_level_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.7))
		lose_level_lbl.add_theme_constant_override("outline_size", 4)
		lose_level_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
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
		
	if hud_weapon_crosshair:
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
	if filters_btn:
		filters_btn.text = "필터" if is_kr else "FILTERS"
		if font: filters_btn.add_theme_font_override("font", font)
	if controller_btn:
		controller_btn.text = "조작법" if is_kr else "CONTROLS"
		if font: controller_btn.add_theme_font_override("font", font)
	if controller_title:
		controller_title.text = "조작법" if is_kr else "CONTROLS"
	for row_name in ["KeyboardRow", "XboxRow"]:
		var prefix = "ESC" if row_name == "KeyboardRow" else "MENU"
		var leg_pause = controller_screen.get_node_or_null("CenterContainer/VBoxContainer/" + row_name + "/LegendColumn/LegPause/Label")
		if leg_pause:
			leg_pause.text = prefix + " - 일시정지" if is_kr else "MENU - PAUSE" if row_name == "XboxRow" else prefix + " - PAUSE"
			if font: leg_pause.add_theme_font_override("font", font)

		var prefix_weap = "TAB" if row_name == "KeyboardRow" else "LB"
		var leg_weapons = controller_screen.get_node_or_null("CenterContainer/VBoxContainer/" + row_name + "/LegendColumn/LegWeapons/Label")
		if leg_weapons:
			leg_weapons.text = prefix_weap + " - 무기 변경" if is_kr else "LB - WEAPONS" if row_name == "XboxRow" else prefix_weap + " - WEAPONS"
			if font: leg_weapons.add_theme_font_override("font", font)

		var prefix_ice = "R" if row_name == "KeyboardRow" else "LT"
		var leg_ice = controller_screen.get_node_or_null("CenterContainer/VBoxContainer/" + row_name + "/LegendColumn/LegIceBlast/Label")
		if leg_ice:
			leg_ice.text = prefix_ice + " - 얼음 폭발" if is_kr else prefix_ice + " - ICE BLAST"
			if font: leg_ice.add_theme_font_override("font", font)

		var prefix_cat = "F" if row_name == "KeyboardRow" else "F"
		if row_name == "XboxRow": prefix_cat = "RB"
		var leg_catastrom = controller_screen.get_node_or_null("CenterContainer/VBoxContainer/" + row_name + "/LegendColumn/LegCatastrom/Label")
		if leg_catastrom:
			leg_catastrom.text = prefix_cat + " - 카타스트롬" if is_kr else prefix_cat + " - CATASTROM"
			if font: leg_catastrom.add_theme_font_override("font", font)

		var prefix_mouse = "MOUSE - 조준/발사" if is_kr else "MOUSE - AIM/SHOOT"
		if row_name == "XboxRow": prefix_mouse = "LS/RS - 조준 / RT - 발사" if is_kr else "LS/RS - AIM / RT - FIRE"
		var leg_mouse = controller_screen.get_node_or_null("CenterContainer/VBoxContainer/" + row_name + "/LegendColumn/LegMouse/Label")
		if leg_mouse:
			leg_mouse.text = prefix_mouse
			if font: leg_mouse.add_theme_font_override("font", font)
			
		var row = controller_screen.get_node_or_null("CenterContainer/VBoxContainer/" + row_name)
		if row and row.has_meta("group_labels"):
			var grp_labels = row.get_meta("group_labels")
			for i in range(grp_labels.size()):
				var lbl = grp_labels[i]
				if i == 0: lbl.text = "시스템" if is_kr else "SYSTEM"
				elif i == 1: lbl.text = "전투" if is_kr else "COMBAT"
				elif i == 2: lbl.text = "능력" if is_kr else "ABILITIES"
				if font: lbl.add_theme_font_override("font", font)

		if font: controller_title.add_theme_font_override("font", font)
		controller_title.add_theme_font_size_override("font_size", 32)
		controller_title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 1.0))
		controller_title.add_theme_constant_override("outline_size", 4)
		controller_title.add_theme_color_override("font_outline_color", Color.BLACK)
	if controller_prompt:
		controller_prompt.text = "닫으려면 ESC를 누르세요" if is_kr else "PRESS ESC TO CLOSE"
		if font: controller_prompt.add_theme_font_override("font", font)
	if controller_back_btn:
		controller_back_btn.text = "뒤로" if is_kr else "BACK"
		if font: controller_back_btn.add_theme_font_override("font", font)
	if filters_btn:
		filters_btn.text = "필터" if is_kr else "FILTERS"
		if font: filters_btn.add_theme_font_override("font", font)
	if credits_btn:
		credits_btn.text = "크레딧" if is_kr else "CREDITS"
		if font: credits_btn.add_theme_font_override("font", font)
	if achievements_btn:
		achievements_btn.text = "업적" if is_kr else "ACHIEVEMENTS"
		if font: achievements_btn.add_theme_font_override("font", font)
	if buffs_btn:
		buffs_btn.text = "활성화된 버프" if is_kr else "ACTIVE BUFFS"
		if font: buffs_btn.add_theme_font_override("font", font)
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
		if is_kr:
			end_level_lbl.text = "%d 레벨 완료" % GameState.level
		else:
			end_level_lbl.text = "%d LEVELS COMPLETED" % GameState.level
		if font: end_level_lbl.add_theme_font_override("font", font)
	if end_prompt_lbl:
		end_prompt_lbl.text = "클릭하거나 스페이스를 눌러 재시작" if is_kr else "CLICK OR PRESS SPACE TO RESTART"
		if font: end_prompt_lbl.add_theme_font_override("font", font)

	# ── Toggle highlight (color-only, no layout impact) ───────────────────────
	_update_lang_toggle(is_kr)
	
	if input_lbl_kb:
		_update_input_toggle_visuals(true)


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
	if timer_label:
		if enabled:
			if is_instance_valid(timer_pulse_tween):
				timer_pulse_tween.kill()
				timer_pulse_tween = null
			timer_label.modulate.a = 1.0
			timer_label.scale = Vector2.ONE
		elif timer_pulse_active:
			if is_instance_valid(timer_pulse_tween):
				timer_pulse_tween.kill()
			timer_pulse_tween = create_tween().set_loops()
			timer_pulse_tween.tween_property(timer_label, "modulate:a", 0.4, 0.35).set_trans(Tween.TRANS_SINE)
			timer_pulse_tween.tween_property(timer_label, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE)

func _on_vibration_toggled(enabled: bool) -> void:
	GameState.vibration_enabled = enabled
	GameState.save_settings()
	vibration_enabled = enabled
	if vibration_check: _update_toggle_btn(vibration_check, enabled)

func _on_color_depth_toggled(enabled: bool) -> void:
	GameState.filter_color_depth = enabled
	if enabled:
		if GameState.filter_dithering:
			GameState.filter_dithering = false
			if dithering_check:
				dithering_check.set_pressed_no_signal(false)
				_update_toggle_btn(dithering_check, false)
			filter_dithering_changed.emit(false)
		if GameState.filter_ps1:
			GameState.filter_ps1 = false
			if ps1_check:
				ps1_check.set_pressed_no_signal(false)
				_update_toggle_btn(ps1_check, false)
			filter_ps1_changed.emit(false)
		if GameState.filter_heatwave:
			GameState.filter_heatwave = false
			if heatwave_check:
				heatwave_check.set_pressed_no_signal(false)
				_update_toggle_btn(heatwave_check, false)
			filter_heatwave_changed.emit(false)
	GameState.save_settings()
	filter_color_depth_changed.emit(enabled)
	if color_depth_check: _update_toggle_btn(color_depth_check, enabled)

func _on_dithering_toggled(enabled: bool) -> void:
	GameState.filter_dithering = enabled
	if enabled:
		if GameState.filter_color_depth:
			GameState.filter_color_depth = false
			if color_depth_check:
				color_depth_check.set_pressed_no_signal(false)
				_update_toggle_btn(color_depth_check, false)
			filter_color_depth_changed.emit(false)
		if GameState.filter_ps1:
			GameState.filter_ps1 = false
			if ps1_check:
				ps1_check.set_pressed_no_signal(false)
				_update_toggle_btn(ps1_check, false)
			filter_ps1_changed.emit(false)
		if GameState.filter_heatwave:
			GameState.filter_heatwave = false
			if heatwave_check:
				heatwave_check.set_pressed_no_signal(false)
				_update_toggle_btn(heatwave_check, false)
			filter_heatwave_changed.emit(false)
	GameState.save_settings()
	filter_dithering_changed.emit(enabled)
	if dithering_check: _update_toggle_btn(dithering_check, enabled)

func _on_ps1_toggled(enabled: bool) -> void:
	GameState.filter_ps1 = enabled
	if enabled:
		if GameState.filter_color_depth:
			GameState.filter_color_depth = false
			if color_depth_check:
				color_depth_check.set_pressed_no_signal(false)
				_update_toggle_btn(color_depth_check, false)
			filter_color_depth_changed.emit(false)
		if GameState.filter_dithering:
			GameState.filter_dithering = false
			if dithering_check:
				dithering_check.set_pressed_no_signal(false)
				_update_toggle_btn(dithering_check, false)
			filter_dithering_changed.emit(false)
		if GameState.filter_heatwave:
			GameState.filter_heatwave = false
			if heatwave_check:
				heatwave_check.set_pressed_no_signal(false)
				_update_toggle_btn(heatwave_check, false)
			filter_heatwave_changed.emit(false)
	GameState.save_settings()
	filter_ps1_changed.emit(enabled)
	if ps1_check: _update_toggle_btn(ps1_check, enabled)

func _on_heatwave_toggled(enabled: bool) -> void:
	GameState.filter_heatwave = enabled
	if enabled:
		if GameState.filter_color_depth:
			GameState.filter_color_depth = false
			if color_depth_check:
				color_depth_check.set_pressed_no_signal(false)
				_update_toggle_btn(color_depth_check, false)
			filter_color_depth_changed.emit(false)
		if GameState.filter_dithering:
			GameState.filter_dithering = false
			if dithering_check:
				dithering_check.set_pressed_no_signal(false)
				_update_toggle_btn(dithering_check, false)
			filter_dithering_changed.emit(false)
		if GameState.filter_ps1:
			GameState.filter_ps1 = false
			if ps1_check:
				ps1_check.set_pressed_no_signal(false)
				_update_toggle_btn(ps1_check, false)
			filter_ps1_changed.emit(false)
	GameState.save_settings()
	filter_heatwave_changed.emit(enabled)
	if heatwave_check: _update_toggle_btn(heatwave_check, enabled)

func _on_fullscreen_toggled(toggled: bool) -> void:
	GameState.fullscreen = toggled
	GameState.save_settings()
	_update_toggle_btn(fullscreen_check, toggled)
	
	var current_mode = DisplayServer.window_get_mode()
	var is_currently_fullscreen = (current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN or current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	if toggled and not is_currently_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif not toggled and is_currently_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1280, 720))
		var screen = DisplayServer.window_get_current_screen()
		var screen_size = DisplayServer.screen_get_size(screen)
		DisplayServer.window_set_position(screen_size / 2 - Vector2i(1280, 720) / 2)

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
		
	# Unified Drop Shadow for all stylized HUD text
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	lbl.add_theme_constant_override("shadow_outline_size", 2)
	lbl.add_theme_constant_override("shadow_offset_x", 0)
	lbl.add_theme_constant_override("shadow_offset_y", 4)
	
func _apply_unified_drop_shadows(node: Node) -> void:
	if not node: return
	
	# Skip overlay menus so they don't get messy shadows
	var skip_names = ["SettingsScreen", "FiltersScreen", "PauseScreen", "GameOverScreen", "LevelClearScreen", "DraftingScreen"]
	if node.name in skip_names:
		return
		
	# Apply to panels
	if node is PanelContainer or node is Panel:
		var style = null
		if node.has_theme_stylebox_override("panel"):
			style = node.get_theme_stylebox("panel")
		elif node.get_theme_stylebox("panel") is StyleBoxFlat:
			style = node.get_theme_stylebox("panel").duplicate()
			node.add_theme_stylebox_override("panel", style)
				
		if style is StyleBoxFlat:
			style.shadow_color = Color(0, 0, 0, 0.45)
			style.shadow_size = 4
			style.shadow_offset = Vector2(0, 4)
			
	for child in node.get_children():
		_apply_unified_drop_shadows(child)

func _on_heat_changed(value: float, max_value: float) -> void:
	heat_bar.max_value = max_value
	if value >= max_value and heat_bar.value < max_value * 0.5:
		heat_bar.value = value
	target_heat = value
	if reduce_motion or (value >= max_value and heat_bar.value >= max_value):
		_update_heat_display(value)
	
	var ratio = value / max_value
	if ratio > 0.85:
		heat_bar.tint_progress = Color(1.0, 0.0, 0.0) # critical red
		if reduce_motion:
			heat_bar.modulate.a = 1.0
		else:
			if not is_instance_valid(heat_tween) or not heat_tween.is_running():
				heat_tween = create_tween()
				heat_tween.set_loops()
				heat_tween.tween_property(heat_bar, "modulate:a", 0.7, 0.6).set_trans(Tween.TRANS_SINE)
				heat_tween.tween_property(heat_bar, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
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

func _update_heat_display(val: float, force: bool = false) -> void:
	if not heat_label:
		return
	var max_t: float = heat_bar.max_value if heat_bar else 100.0
	var rounded_val: int = clampi(roundi(val), 0, roundi(max_t))
	if not force and rounded_val == _last_displayed_temp:
		return
	_last_displayed_temp = rounded_val
	var is_kr := GameState.language == "KR"
	var prefix := "열기 |" if is_kr else "HEAT |"
	heat_label.text = prefix
	if heat_val_label:
		heat_val_label.text = "%d°C" % rounded_val

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
		# When capacity changes (weapon switch), snap the bar immediately
		# to prevent it visually flashing to full for a split second.
		if water_bar.max_value != max_val:
			water_bar.max_value = max_val
			water_bar.value = current
		else:
			water_bar.max_value = max_val
		target_water = current
			
		if current < max_val * 0.2:
			if is_instance_valid(water_plate):
				var w_sb = water_plate.get_theme_stylebox("panel") as StyleBoxFlat
				if w_sb:
					w_sb.border_color = Color(1.0, 0.3, 0.3, 0.9)
			if is_instance_valid(water_icon):
				water_icon.modulate = Color(1.0, 0.4, 0.4, 1.0)
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
			if is_instance_valid(water_plate):
				var w_sb = water_plate.get_theme_stylebox("panel") as StyleBoxFlat
				if w_sb:
					w_sb.border_color = Color(0.2, 0.8, 1.0, 0.6)
			if is_instance_valid(water_icon):
				water_icon.modulate = Color(0.4, 0.9, 1.0, 1.0)
			water_bar.tint_progress = Color(0.3, 0.75, 1.0)
			if is_instance_valid(water_tween):
				water_tween.kill()
			water_bar.modulate.a = 1.0
			
	if crosshair and crosshair.has_method("update_water"):
		crosshair.update_water(current, max_val)

func notify_weapon_style(weapon_id: String) -> void:
	if crosshair and crosshair.has_method("set_weapon_style"):
		crosshair.set_weapon_style(weapon_id)

func notify_firing(is_firing: bool) -> void:
	if crosshair and crosshair.has_method("set_firing"):
		crosshair.set_firing(is_firing)

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
		var is_kr = TranslationServer.get_locale() == "ko"
		if is_kr:
			win_level_lbl.text = "%02d  단계 완료" % level
		else:
			win_level_lbl.text = "LEVEL %02d  COMPLETE" % level
	
	win_screen.visible = true
	win_screen.modulate.a = 1.0
	win_screen.scale = Vector2(1.0, 1.0)
	
	# Auto-hide logic is now handled explicitly by Main.gd via fade_to_black
	
func fade_to_black(duration: float = 1.0) -> Signal:
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(transition_overlay, "color:a", 1.0, duration)
	return tw.finished

func fade_from_black(duration: float = 1.0, hide_win: bool = true) -> Signal:
	if win_screen and hide_win:
		win_screen.visible = false
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(transition_overlay, "color:a", 0.0, duration)
	return tw.finished

func show_end_screen() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if win_screen: win_screen.visible = false
	if credits_screen: credits_screen.visible = false
	if settings_screen: settings_screen.visible = false
	if filters_screen: filters_screen.visible = false
	if controller_screen: controller_screen.visible = false
	if lose_screen: lose_screen.visible = false
	
	if end_level_lbl:
		if GameState.language == "KR":
			end_level_lbl.text = "%d 레벨 완료" % GameState.level
		else:
			end_level_lbl.text = "%d LEVELS COMPLETED" % GameState.level
		
	if end_unlock_lbl:
		if GameState.newly_unlocked_endless:
			end_unlock_lbl.visible = true
			end_unlock_lbl.text = "무한 모드가 해제되었습니다!" if GameState.language == "KR" else "ENDLESS MODE UNLOCKED!"
		else:
			end_unlock_lbl.visible = false
		
	end_screen.visible = true
	end_screen.modulate.a = 0.0
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(end_screen, "modulate:a", 1.0, 0.4)

func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event.is_action("ui_weapons") and not event.is_echo():
		if event.pressed:
			if not weapon_wheel.active and not pause_screen.visible and not win_screen.visible and not end_screen.visible and not lose_screen.visible:
				weapon_wheel.open()
				get_viewport().set_input_as_handled()
		else:
			if weapon_wheel.active:
				weapon_wheel.close()
				get_viewport().set_input_as_handled()

	var is_cancel = event.is_action_pressed("ui_cancel")
	var is_pause = event.is_action_pressed("ui_pause")
	
	if (is_cancel or is_pause) and not event.is_echo():
		if weapon_wheel.active:
			weapon_wheel.close()
			get_viewport().set_input_as_handled()
			return
			
		if settings_screen and settings_screen.visible:
			_close_settings()
			get_viewport().set_input_as_handled()
			return
		elif filters_screen and filters_screen.visible:
			_close_filters()
			get_viewport().set_input_as_handled()
			return
		elif credits_screen and credits_screen.visible:
			_close_credits()
			get_viewport().set_input_as_handled()
			return
		elif controller_screen and controller_screen.visible:
			_close_controller()
			get_viewport().set_input_as_handled()
			return
		elif achievements_screen and achievements_screen.visible:
			hide_achievements_screen()
			get_viewport().set_input_as_handled()
			return
		elif buffs_screen and buffs_screen.visible:
			hide_buffs_screen()
			get_viewport().set_input_as_handled()
			return
		elif drafting_screen and drafting_screen.visible:
			get_viewport().set_input_as_handled()
			return
		
		# Guard against pausing during game over, victory celebration, or level complete
		if (lose_screen and lose_screen.visible) or (win_screen and win_screen.visible) or (end_screen and end_screen.visible):
			get_viewport().set_input_as_handled()
			return
		
		if pause_screen.visible:
			_resume_game()
			get_viewport().set_input_as_handled()
			return
		elif is_pause:
			_pause_game()
			get_viewport().set_input_as_handled()
			return

	if end_screen and end_screen.visible:
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_shoot"):
			GameState.reset()
			get_viewport().set_input_as_handled()
			get_tree().paused = false
			get_tree().call_deferred("change_scene_to_file", "res://scenes/Main.tscn")
			return

func _pause_game() -> void:
	pause_screen.visible = true
	pause_screen.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(pause_screen, "modulate:a", 1.0, 0.25)
	get_tree().paused = true
	emit_signal("game_paused")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Set up Tab/arrow key order for pause menu buttons
	if pause_resume_btn and settings_btn and filters_btn and credits_btn and controller_btn and pause_menu_btn:
		pause_resume_btn.focus_neighbor_bottom = pause_resume_btn.get_path_to(settings_btn)
		settings_btn.focus_neighbor_top = settings_btn.get_path_to(pause_resume_btn)
		settings_btn.focus_neighbor_bottom = settings_btn.get_path_to(filters_btn)
		filters_btn.focus_neighbor_top = filters_btn.get_path_to(settings_btn)
		filters_btn.focus_neighbor_bottom = filters_btn.get_path_to(credits_btn)
		credits_btn.focus_neighbor_top = credits_btn.get_path_to(filters_btn)
		if achievements_btn and buffs_btn:
			credits_btn.focus_neighbor_bottom = credits_btn.get_path_to(achievements_btn)
			achievements_btn.focus_neighbor_top = achievements_btn.get_path_to(credits_btn)
			
			achievements_btn.focus_neighbor_bottom = achievements_btn.get_path_to(buffs_btn)
			buffs_btn.focus_neighbor_top = buffs_btn.get_path_to(achievements_btn)
			
			buffs_btn.focus_neighbor_bottom = buffs_btn.get_path_to(controller_btn)
			controller_btn.focus_neighbor_top = controller_btn.get_path_to(buffs_btn)
			controller_btn.focus_neighbor_bottom = controller_btn.get_path_to(pause_menu_btn)
			pause_menu_btn.focus_neighbor_top = pause_menu_btn.get_path_to(controller_btn)
		else:
			credits_btn.focus_neighbor_bottom = credits_btn.get_path_to(controller_btn)
			controller_btn.focus_neighbor_top = controller_btn.get_path_to(credits_btn)
			controller_btn.focus_neighbor_bottom = controller_btn.get_path_to(pause_menu_btn)
			pause_menu_btn.focus_neighbor_top = pause_menu_btn.get_path_to(controller_btn)
	await get_tree().process_frame
	if pause_resume_btn: pause_resume_btn.grab_focus()

func _resume_game() -> void:
	var tw = create_tween()
	tw.tween_property(pause_screen, "modulate:a", 0.0, 0.2)
	await tw.finished
	pause_screen.visible = false
	get_tree().paused = false
	emit_signal("game_resumed")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_pause_resume_pressed() -> void:
	_resume_game()

func _on_settings_pressed() -> void:
	opened_from_pause = pause_screen.visible
	_open_settings()

func _on_filters_pressed() -> void:
	opened_from_pause = pause_screen.visible
	_open_filters()

func _on_credits_pressed() -> void:
	opened_from_pause = pause_screen.visible
	_open_credits()

func _on_controller_pressed() -> void:
	if ui_tick_player: ui_tick_player.play()
	if filters_screen: filters_screen.visible = false
	controller_screen.visible = true
	controller_screen.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(controller_screen, "modulate:a", 1.0, 0.3)
	await get_tree().process_frame
	if controller_back_btn: controller_back_btn.grab_focus()

func _close_controller() -> void:
	if ui_tick_player: ui_tick_player.play()
	var tw = create_tween()
	tw.tween_property(controller_screen, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func():
		controller_screen.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if controller_btn: controller_btn.grab_focus()
	)


func _open_settings() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if filters_screen: filters_screen.visible = false
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
			if settings_btn: settings_btn.grab_focus()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	)


func _open_filters() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if settings_screen: settings_screen.visible = false
	if credits_screen: credits_screen.visible = false
	if controller_screen: controller_screen.visible = false
	filters_screen.visible = true
	filters_screen.modulate.a = 0.0
	if color_depth_check and dithering_check and ps1_check and heatwave_check and filters_back_btn:
		color_depth_check.focus_neighbor_top = color_depth_check.get_path_to(filters_back_btn)
		color_depth_check.focus_neighbor_bottom = color_depth_check.get_path_to(dithering_check)
		dithering_check.focus_neighbor_top = dithering_check.get_path_to(color_depth_check)
		dithering_check.focus_neighbor_bottom = dithering_check.get_path_to(ps1_check)
		ps1_check.focus_neighbor_top = ps1_check.get_path_to(dithering_check)
		ps1_check.focus_neighbor_bottom = ps1_check.get_path_to(heatwave_check)
		heatwave_check.focus_neighbor_top = heatwave_check.get_path_to(ps1_check)
		heatwave_check.focus_neighbor_bottom = heatwave_check.get_path_to(filters_back_btn)
		filters_back_btn.focus_neighbor_top = filters_back_btn.get_path_to(heatwave_check)
		filters_back_btn.focus_neighbor_bottom = filters_back_btn.get_path_to(color_depth_check)
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(filters_screen, "modulate:a", 1.0, 0.3)
	await get_tree().process_frame
	if GameState.filter_color_depth and color_depth_check:
		color_depth_check.grab_focus()
	elif GameState.filter_dithering and dithering_check:
		dithering_check.grab_focus()
	elif GameState.filter_ps1 and ps1_check:
		ps1_check.grab_focus()
	elif GameState.filter_heatwave and heatwave_check:
		heatwave_check.grab_focus()
	elif filters_back_btn:
		filters_back_btn.grab_focus()

func _close_filters() -> void:
	var tw = create_tween()
	tw.tween_property(filters_screen, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func():
		filters_screen.visible = false
		if opened_from_pause:
			pause_screen.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if filters_btn: filters_btn.grab_focus()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	)


func _open_credits() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if settings_screen: settings_screen.visible = false
	if filters_screen: filters_screen.visible = false
	if controller_screen: controller_screen.visible = false
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
			if credits_btn: credits_btn.grab_focus()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	)



func _show_toast(header_kr: String, header_en: String, title_kr: String, title_en: String, icon_path: String, target_y: float, container: Control) -> void:
	if not container: return
	
	var is_kr = GameState.language == "KR"
	
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(440, 80)
	panel.position = Vector2(-220, -100)
	
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
	icon_rect.texture = load(icon_path)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.custom_minimum_size = Vector2(56, 56)
	icon_rect.position = Vector2(16, 12)
	icon_rect.pivot_offset = icon_rect.custom_minimum_size / 2.0
	icon_rect.scale = Vector2.ZERO
	panel.add_child(icon_rect)
	
	var header_lbl = Label.new()
	header_lbl.text = header_kr if is_kr else header_en
	header_lbl.position = Vector2(84, 14)
	_style_lbl(header_lbl, 16, Color(1.0, 1.0, 1.0, 0.9), 2, Color.BLACK, galmuri_font if is_kr else kenney_font)
	panel.add_child(header_lbl)
	
	var title_lbl = Label.new()
	title_lbl.text = title_kr if is_kr else title_en
	title_lbl.position = Vector2(84, 38)
	_style_lbl(title_lbl, 24, Color(1.0, 0.85, 0.2, 1.0), 3, Color.BLACK, galmuri_font if is_kr else kenney_font)
	panel.add_child(title_lbl)
	
	panel.process_mode = Node.PROCESS_MODE_PAUSABLE
	container.add_child(panel)
	
	# SFX
	var sfx = AudioStreamPlayer.new()
	sfx.stream = load("res://assets/sounds/ui/ui_tick.wav")
	sfx.volume_db = linear_to_db(GameState.sfx_volume)
	panel.add_child(sfx)
	sfx.play()
	
	# Animate Panel
	var tw = create_tween().bind_node(panel)
	tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(panel, "position:y", target_y, 0.6)
	tw.tween_interval(4.0)
	tw.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tw.tween_property(panel, "position:y", -120.0, 0.5)
	tw.tween_callback(panel.queue_free)
	
	# Animate Icon Pop
	var icon_tw = create_tween().bind_node(panel)
	icon_tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	icon_tw.tween_interval(0.3)
	icon_tw.tween_property(icon_rect, "scale", Vector2.ONE, 0.5)

func show_achievement_toast(id: String) -> void:
	if not GameState.ACHIEVEMENTS.has(id): return
	var ach = GameState.ACHIEVEMENTS[id]
	_show_toast("업적 달성!", "ACHIEVEMENT UNLOCKED!", ach["title_kr"], ach["title_en"], ach["icon"], 20.0, achievement_toast_container)

func show_buff_toast(id: String) -> void:
	if not GameState.BUFFS.has(id): return
	var buff = GameState.BUFFS[id]
	_show_toast("버프 활성화!", "BUFF UNLOCKED!", buff["title_kr"], buff["title_en"], buff["icon"], 110.0, buff_toast_container)
func hide_win_screen() -> void:
	if win_screen:
		win_screen.visible = false
		win_screen.modulate.a = 0.0

var timer_pulse_active: bool = false
var timer_pulse_tween: Tween = null
var _last_urgency_sec: int = -1

func _stop_timer_pulse() -> void:
	timer_pulse_active = false
	_last_urgency_sec = -1
	if is_instance_valid(timer_pulse_tween):
		timer_pulse_tween.kill()
		timer_pulse_tween = null
	if timer_label:
		timer_label.modulate.a = 1.0
		timer_label.scale = Vector2.ONE
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))

func _on_timer_tick(seconds: float) -> void:
	if not timer_label: return
	var total_secs = max(0, int(ceil(seconds))) if seconds > 0.0 else 0
	var mins = total_secs / 60
	var secs = total_secs % 60
	
	var prefix = "시간: " if GameState.language == "KR" else "TIME: "
	timer_label.text = prefix + ("%d:%02d" % [mins, secs])

	if seconds <= 10.0 and seconds > 0.0:
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2, 1.0))
		if reduce_motion:
			# Reduced motion: suppress all animated pulses and bounces
			if is_instance_valid(timer_pulse_tween):
				timer_pulse_tween.kill()
				timer_pulse_tween = null
			timer_label.modulate.a = 1.0
			timer_label.scale = Vector2.ONE
		else:
			if not timer_pulse_active or not is_instance_valid(timer_pulse_tween):
				timer_pulse_active = true
				if is_instance_valid(timer_pulse_tween):
					timer_pulse_tween.kill()
				timer_pulse_tween = create_tween().set_loops()
				timer_pulse_tween.tween_property(timer_label, "modulate:a", 0.4, 0.35).set_trans(Tween.TRANS_SINE)
				timer_pulse_tween.tween_property(timer_label, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE)
			
			if total_secs != _last_urgency_sec:
				_last_urgency_sec = total_secs
				timer_label.pivot_offset = Vector2(timer_label.size.x, timer_label.size.y / 2.0)
				var bounce_tw = create_tween()
				timer_label.scale = Vector2(1.12, 1.12)
				bounce_tw.tween_property(timer_label, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	else:
		if timer_pulse_active or seconds <= 0.0:
			_stop_timer_pulse()

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
		last_callout_tier = 0
		if callout_label: callout_label.visible = false
		if combo_label.visible:
			var tw = create_tween()
			tw.tween_property(combo_label, "modulate:a", 0.0, 0.2)
			tw.tween_callback(func(): combo_label.visible = false)

func update_combo_text(mult: float) -> void:
	if not combo_label: return
	combo_label.text = "%.2fx COMBO!" % mult
	
	if callout_label:
		var tier = 0
		var callout_text = ""
		if mult >= 3.0:
			tier = 4
			callout_text = "절대영도!" if GameState.language == "KR" else "SUB-ZERO!"
		elif mult >= 2.5:
			tier = 3
			callout_text = "빙점!" if GameState.language == "KR" else "ICE COLD!"
		elif mult >= 2.0:
			tier = 2
			callout_text = "짜릿해!" if GameState.language == "KR" else "FROSTY!"
		elif mult >= 1.5:
			tier = 1
			callout_text = "시원해!" if GameState.language == "KR" else "CHILL!"
			
		if tier > last_callout_tier:
			last_callout_tier = tier
			callout_label.text = callout_text
			callout_label.visible = true
			callout_label.modulate = Color(1, 1, 1, 1)
			callout_label.scale = Vector2.ONE * 0.5
			callout_label.rotation = randf_range(-0.1, 0.1)
			
			var c_tw = create_tween()
			c_tw.set_parallel(true)
			c_tw.tween_property(callout_label, "scale", Vector2(1.2, 1.2), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			c_tw.chain().tween_property(callout_label, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_IN_OUT)
			c_tw.parallel().tween_property(callout_label, "modulate:a", 0.0, 1.5).set_delay(1.0)
			c_tw.chain().tween_callback(func(): callout_label.visible = false)

func _on_supernova_triggered() -> void:
	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 1.0, 0.0) # Start transparent
	flash.anchor_right = 1.0
	flash.anchor_bottom = 1.0
	flash.z_index = 200
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	
	var tw = create_tween()
	# Sync with the sun expansion in Main.gd (1.2 seconds), but fade in smoothly to give an evaporating effect
	tw.tween_property(flash, "color:a", 1.0, 1.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	# Hold for 0.5s impact
	tw.tween_interval(0.5)
	# Reveal game over UI (it takes 0.4s to fade in)
	tw.tween_callback(show_lose_screen)
	# Wait for LoseScreen to fully fade in before removing the solid white flash!
	tw.tween_interval(0.5)
	# Fade whiteout away
	tw.tween_property(flash, "color:a", 0.0, 1.0)
	tw.tween_callback(flash.queue_free)

func _on_timer_expired() -> void:
	show_lose_screen()

func show_lose_screen() -> void:
	if not lose_screen: return
	if weapon_wheel and weapon_wheel.active:
		weapon_wheel.close()
	Engine.time_scale = 1.0
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
	await get_tree().process_frame
	if retry_btn: retry_btn.grab_focus()

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
	Engine.time_scale = 1.0
	GameState.level = 1
	GameState.current_wave = 1
	GameState.is_retrying = true
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")

func _on_menu_pressed() -> void:
	Engine.time_scale = 1.0
	GameState.level = 1
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Main.tscn")

var _current_max_ice_charges: int = 1
var _ice_tween: Tween = null

func _draw_ice_notches() -> void:
	if not is_instance_valid(ice_notch_overlay) or _current_max_ice_charges <= 1:
		return
	if _current_max_ice_charges > 16:
		return
	var w = ice_notch_overlay.size.x
	var h = ice_notch_overlay.size.y
	if w <= 0: w = 200.0
	if h <= 0: h = 24.0
	var col = Color(0.02, 0.01, 0.05, 0.6)
	for i in range(1, _current_max_ice_charges):
		var x = round((w / float(_current_max_ice_charges)) * float(i))
		ice_notch_overlay.draw_line(Vector2(x, 2), Vector2(x, h - 2), col, 1.5)

func update_ice_charges(charges: int, max_charges: int) -> void:
	if max_charges <= 0 or (GameState.is_survival_mode and GameState.current_wave < 2 and charges <= 0):
		ice_row.visible = false
		return

	ice_row.visible = true
	_current_max_ice_charges = max_charges

	# Dim plate and container when completely empty
	var is_depleted = (charges == 0)
	if is_instance_valid(ice_plate):
		ice_plate.modulate.a = 0.45 if is_depleted else 1.0
		var i_sb = ice_plate.get_theme_stylebox("panel") as StyleBoxFlat
		if i_sb:
			i_sb.border_color = Color(0.55, 0.9, 1.0, 0.25 if is_depleted else 0.6)
	if is_instance_valid(ice_bar_container):
		ice_bar_container.modulate.a = 0.45 if is_depleted else 1.0

	if is_instance_valid(ice_bar):
		var target_val = (float(charges) / float(max_charges)) * 100.0 if max_charges > 0 else 0.0
		if reduce_motion:
			ice_bar.value = target_val
		else:
			if is_instance_valid(_ice_tween):
				_ice_tween.kill()
			_ice_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			_ice_tween.tween_property(ice_bar, "value", target_val, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if is_instance_valid(ice_count_label):
		ice_count_label.text = "%d / %d" % [charges, max_charges]
		var is_kr = GameState.language == "KR"
		var font = galmuri_font if is_kr else kenney_font
		if font:
			ice_count_label.add_theme_font_override("font", font)
		ice_count_label.add_theme_font_size_override("font_size", 13 if is_kr else 12)
		ice_count_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 0.6) if is_depleted else Color.WHITE)

	if is_instance_valid(ice_notch_overlay):
		ice_notch_overlay.queue_redraw()

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
	show_toast(title, desc, "res://assets/ui/hud_elements/meter_ice.svg", Color(0.5, 0.85, 1.0, 1.0))

func show_weapon_unlock() -> void:
	var is_kr = GameState.language == "KR"
	var title = "무기 해금됨" if is_kr else "WEAPON UNLOCKED"
	var desc = "[TAB] 을 길게 눌러 장착" if is_kr else "HOLD [TAB] TO EQUIP"
	show_toast(title, desc, "res://assets/ui/ui_adventure/PNG/Default/minimap_icon_star_yellow.png", Color(1.0, 0.9, 0.2, 1.0))

func show_catastrom_unlock() -> void:
	var is_kr = GameState.language == "KR"
	var title = "카타스트롬 해금됨" if is_kr else "CATASTROM UNLOCKED"
	var desc = "태양을 바다로 덩크하라 [F]" if is_kr else "DUNK THE SUN INTO THE OCEAN [F]"
	var icon_path = "res://assets/ui/achievements/ball-glow.png" if OS.has_feature("safe_audio") else "res://assets/ui/Catastrom.png"
	show_toast(title, desc, icon_path, Color(0.8, 0.4, 1.0, 1.0))

func _setup_weapon_hud() -> void:
	var margin = MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	margin.add_theme_constant_override("margin_left", 0)
	margin.add_theme_constant_override("margin_top", 16)
	
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.45)
	style.border_color = Color(0.2, 0.84, 1.0, 0.6)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", style)
	margin.add_child(panel)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)
	
	var icon_container = MarginContainer.new()
	icon_container.custom_minimum_size = Vector2(64, 64)
	hbox.add_child(icon_container)
	
	hud_weapon_bg = ColorRect.new()
	hud_weapon_bg.color = Color(0.2, 0.84, 1.0, 0.2)
	icon_container.add_child(hud_weapon_bg)
	
	var crosshair = WeaponCrosshairIcon.new()
	crosshair.custom_minimum_size = Vector2(64, 64)
	icon_container.add_child(crosshair)
	hud_weapon_crosshair = crosshair
	
	hud_weapon_name_label = Label.new()
	hud_weapon_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var ls = LabelSettings.new()
	var is_kr = GameState.language == "KR"
	ls.font = load("res://assets/ui/fonts/Galmuri11.ttf") if is_kr else load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	ls.font_size = 20 if is_kr else 18
	ls.font_color = Color(1.0, 0.95, 0.5, 1.0)
	ls.outline_size = 4
	ls.outline_color = Color.BLACK
	hud_weapon_name_label.label_settings = ls
	
	var lbl_margin = MarginContainer.new()
	lbl_margin.add_theme_constant_override("margin_right", 12)
	lbl_margin.add_child(hud_weapon_name_label)
	hbox.add_child(lbl_margin)
	
	# Add to UnlockPrompts at the bottom
	var rc = $HUD/UnlockPrompts
	if rc:
		rc.add_child(margin)
	
	_update_weapon_hud(GameState.current_weapon_id)

func _update_weapon_hud(w_id: String) -> void:
	if not hud_weapon_crosshair: return
	
	var w_color = Color(0.2, 0.84, 1.0)
		
	hud_weapon_bg.color = Color(w_color.r, w_color.g, w_color.b, 0.2)
	hud_weapon_crosshair.weapon_id = w_id
	hud_weapon_crosshair.icon_color = w_color
	hud_weapon_crosshair.queue_redraw()
		
	if hud_weapon_name_label and GameState.WEAPONS.has(w_id):
		var w_name = GameState.WEAPONS[w_id].name.to_upper().replace(" ", "\n")
		if GameState.language == "KR":
			match w_id:
				"standard": w_name = "표준\n블래스터"
				"heavy": w_name = "헤비\n캐논"
				"precision": w_name = "정밀\n스트림"
				"scatter": w_name = "스캐터\n노즐"
				"tidal": w_name = "타이달\n개틀링"
		hud_weapon_name_label.text = w_name
		hud_weapon_name_label.label_settings.font_color = w_color
		
	var hbox = hud_weapon_bg.get_parent().get_parent()
	if hbox:
		var panel = hbox.get_parent() as PanelContainer
		if panel:
			var style = panel.get_theme_stylebox("panel") as StyleBoxFlat
			if style:
				style.border_color = Color(w_color, 0.6)
			
			if not reduce_motion:
				panel.pivot_offset = panel.size / 2.0
				var pop_tween = create_tween()
				panel.scale = Vector2(1.15, 1.15)
				pop_tween.tween_property(panel, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

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
	# It will be styled by _apply_language
	vbox.add_child(divider2)
	
	var back_btn = Button.new()
	back_btn.name = "BackBtn"
	back_btn.text = "BACK"
	back_btn.custom_minimum_size = Vector2(280, 44)

	
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
	
	var title = achievements_screen.get_node("CenterContainer/VBoxContainer/TitleRow/Title")
	title.text = "업적" if is_kr else "ACHIEVEMENTS"
	_style_lbl(title, 32, Color(1.0, 0.85, 0.2, 1.0), 4, Color.BLACK, font)
	
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
		
		var icon_rect = TextureRect.new()
		icon_rect.texture = load(ach["icon"]) if unlocked else load("res://assets/ui/ui_adventure/PNG/Default/minimap_icon_star_white.png")
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.custom_minimum_size = Vector2(56, 56)
		icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon_rect.modulate = Color(1.0, 1.0, 1.0, 1.0) if unlocked else Color(0.3, 0.3, 0.3, 0.5)
		hbox.add_child(icon_rect)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 2)
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)
		
		var ach_title = Label.new()
		ach_title.text = (ach["title_kr"] if is_kr else ach["title_en"])
		_style_lbl(ach_title, 24, Color(1.0, 0.85, 0.2, 1.0) if unlocked else Color(0.6, 0.6, 0.6, 1.0), 2, Color.BLACK, font)
		vbox.add_child(ach_title)
		
		var ach_desc = Label.new()
		ach_desc.text = (ach["desc_kr"] if is_kr else ach["desc_en"])
		ach_desc.custom_minimum_size = Vector2(360, 0)
		ach_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
		_style_lbl(ach_desc, 15, Color(1.0, 1.0, 1.0, 0.85) if unlocked else Color(0.45, 0.45, 0.45, 0.8), 1, Color.BLACK, body_font)
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
			_style_lbl(badge, 13, Color(1.0, 0.85, 0.2, 1.0), 2, Color.BLACK, font)
			badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			status_col.add_child(badge)
		else:
			var count_lbl = Label.new()
			count_lbl.text = pdata.text
			_style_lbl(count_lbl, 13, Color(0.85, 0.85, 0.9, 0.8), 2, Color.BLACK, font)
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

func _build_buffs_screen() -> void:
	buffs_screen = Control.new()
	buffs_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	buffs_screen.visible = false
	buffs_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	buffs_screen.z_index = 50 # ensure it draws over everything
	$HUD.add_child(buffs_screen)
	
	var bg = ColorRect.new()
	bg.color = Color(0.02, 0.01, 0.05, 0.96)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	buffs_screen.add_child(bg)
	
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
	buffs_screen.add_child(border)
	
	var center = CenterContainer.new()
	center.name = "CenterContainer"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	buffs_screen.add_child(center)
	
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
	title_icon.texture = load("res://assets/ui/menu_icons/buffs.png")
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
	
	buffs_list = VBoxContainer.new()
	buffs_list.add_theme_constant_override("separation", 16)
	list_margin.add_child(buffs_list)
	
	var divider2 = HSeparator.new()
	divider2.name = "Divider2"
	# It will be styled by _apply_language
	vbox.add_child(divider2)
	
	var back_btn = Button.new()
	back_btn.name = "BackBtn"
	back_btn.text = "BACK"
	back_btn.custom_minimum_size = Vector2(280, 44)

	
	var btn_center = CenterContainer.new()
	btn_center.name = "CenterContainer"
	btn_center.add_child(back_btn)
	vbox.add_child(btn_center)
	
	back_btn.pressed.connect(hide_buffs_screen)

func show_buffs_screen() -> void:
	if not buffs_screen: return
	_play_ui_tick()
	
	for child in buffs_list.get_children():
		child.queue_free()
		
	var is_kr = (GameState.language == "KR")
	var font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/ui/fonts/Fonts/Kenney Future.ttf"
	var body_font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/fonts/Inter-Medium.ttf"
	var font = load(font_path)
	var body_font = load(body_font_path)
	
	var title = buffs_screen.get_node("CenterContainer/VBoxContainer/TitleRow/Title")
	title.text = "활성화된 버프" if is_kr else "ACTIVE BUFFS"
	_style_lbl(title, 32, Color(1.0, 0.85, 0.2, 1.0), 4, Color.BLACK, font)
	
	var title_icon = buffs_screen.get_node_or_null("CenterContainer/VBoxContainer/TitleRow/TitleIcon")
	if title_icon:
		var icon_style = StyleBoxFlat.new()
		icon_style.bg_color = Color(0, 0, 0, 0)
		icon_style.border_color = Color(1.0, 0.85, 0.2, 0.4)
		icon_style.set_border_width_all(2)
		title_icon.add_theme_stylebox_override("panel", icon_style)
	
	var back_btn = buffs_screen.get_node("CenterContainer/VBoxContainer/CenterContainer/BackBtn")
	back_btn.text = "돌아가기" if is_kr else "BACK"
	if font: back_btn.add_theme_font_override("font", font)
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
	
	var active_buffs = []
	for buff_id in GameState.BUFFS:
		var buff = GameState.BUFFS[buff_id].duplicate()
		var unlocked = false
		match buff_id:
			"tank_upgrade": unlocked = GameState.high_score >= 5000
			"cooling_upgrade": unlocked = GameState.high_score >= 15000
			"ice_upgrade": unlocked = GameState.high_score >= 20000
			"gold_weapon": unlocked = GameState.high_score >= 50000
			"catastrom_buff": unlocked = "slam_dunk" in GameState.unlocked_achievements
			"combo_grace": unlocked = "untouchable" in GameState.unlocked_achievements
			"flare_boost": unlocked = "flare_catcher" in GameState.unlocked_achievements
			"heat_resist": unlocked = "rock_solid" in GameState.unlocked_achievements
			"featherweight": unlocked = "bird_watcher" in GameState.unlocked_achievements
			"eclipse_timer": unlocked = "shadow_walker" in GameState.unlocked_achievements
		buff["condition"] = unlocked
		active_buffs.append(buff)
	
	for buff in active_buffs:
		var unlocked = buff["condition"]
		
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
		icon_rect.texture = load(buff["icon"]) if unlocked else load("res://assets/ui/ui_adventure/PNG/Default/minimap_icon_star_white.png")
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.custom_minimum_size = Vector2(64, 64)
		icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon_rect.modulate = Color(1.0, 1.0, 1.0, 1.0) if unlocked else Color(0.3, 0.3, 0.3, 0.5)
		hbox.add_child(icon_rect)
		
		var vbox_item = VBoxContainer.new()
		vbox_item.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox_item.add_theme_constant_override("separation", 2)
		hbox.add_child(vbox_item)
		
		var title_lbl = Label.new()
		title_lbl.text = (buff["title_kr"] if is_kr else buff["title_en"])
		_style_lbl(title_lbl, 24, Color(1.0, 0.85, 0.2, 1.0) if unlocked else Color(0.5, 0.5, 0.5, 1.0), 2, Color.BLACK, font)
		vbox_item.add_child(title_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.text = (buff["desc_kr"] if is_kr else buff["desc_en"])
		desc_lbl.custom_minimum_size = Vector2(550, 0)
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		_style_lbl(desc_lbl, 15, Color(1.0, 1.0, 1.0, 0.8) if unlocked else Color(0.4, 0.4, 0.4, 0.8), 1, Color.BLACK, body_font)
		vbox_item.add_child(desc_lbl)
		
		buffs_list.add_child(panel)

	buffs_screen.visible = true
	buffs_screen.modulate.a = 0.0
	buffs_screen.set_meta("is_hiding", false)
	var tw = create_tween()
	tw.tween_property(buffs_screen, "modulate:a", 1.0, 0.25)
	
	if back_btn: back_btn.grab_focus()

func hide_buffs_screen() -> void:
	if not buffs_screen or not buffs_screen.visible: return
	if buffs_screen.get_meta("is_hiding", false): return
	buffs_screen.set_meta("is_hiding", true)
	
	_play_ui_tick()
	
	var tw = create_tween()
	tw.tween_property(buffs_screen, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func(): 
		buffs_screen.visible = false 
		buffs_screen.set_meta("is_hiding", false)
		pause_screen.visible = true
		if buffs_btn: buffs_btn.grab_focus()
	)


func _on_input_select_changed(index: int) -> void:
	if index == 0:
		keyboard_row.visible = true
		xbox_row.visible = false
	else:
		keyboard_row.visible = false
		xbox_row.visible = true

# ---------- Input Toggle Pill ------------------------------------------------
var input_toggle_state: int = 0
var input_highlight: ColorRect
var input_lbl_kb: Label
var input_lbl_xb: Label
var input_toggle_tween: Tween

func _build_input_toggle() -> void:
	var row = $HUD/ControllerScreen/CenterContainer/VBoxContainer/InputSelectRow
	if not row: return
	
	var container = Control.new()
	container.custom_minimum_size = Vector2(880, 50)
	row.add_child(container)
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.4)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.add_child(bg)
	
	var border = ReferenceRect.new()
	border.border_color = Color(1.0, 0.85, 0.2, 0.6)
	border.border_width = 2.0
	border.editor_only = false
	border.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.add_child(border)
	
	input_highlight = ColorRect.new()
	input_highlight.color = Color(1.0, 0.85, 0.2, 1.0)
	input_highlight.size = Vector2(440, 50)
	input_highlight.position = Vector2(0, 0)
	container.add_child(input_highlight)
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 0)
	container.add_child(hbox)
	
	input_lbl_kb = Label.new()
	input_lbl_kb.text = "KEYBOARD"
	input_lbl_kb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	input_lbl_kb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	input_lbl_kb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(input_lbl_kb)
	
	input_lbl_xb = Label.new()
	input_lbl_xb.text = "XBOX"
	input_lbl_xb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	input_lbl_xb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	input_lbl_xb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(input_lbl_xb)
	
	var btn = Button.new()
	btn.flat = true
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.pressed.connect(_on_input_toggle_pressed)

	container.add_child(btn)
	
	_update_input_toggle_visuals(true)

func _on_input_toggle_pressed() -> void:
	input_toggle_state = 1 if input_toggle_state == 0 else 0
	_update_input_toggle_visuals(false)
	_on_input_select_changed(input_toggle_state)

func _update_input_toggle_visuals(instant: bool = false) -> void:
	var target_x = 0.0 if input_toggle_state == 0 else 440.0
	
	var font = load("res://assets/fonts/Galmuri11.ttf") if GameState.language == "KR" else load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	if input_lbl_kb:
		input_lbl_kb.add_theme_font_override("font", font)
		input_lbl_kb.add_theme_font_size_override("font_size", 20)
		input_lbl_kb.text = "키보드" if GameState.language == "KR" else "KEYBOARD"
	if input_lbl_xb:
		input_lbl_xb.add_theme_font_override("font", font)
		input_lbl_xb.add_theme_font_size_override("font_size", 20)
		
	if instant:
		input_highlight.position.x = target_x
		input_lbl_kb.add_theme_color_override("font_color", Color(0,0,0,1) if input_toggle_state == 0 else Color(1,0.85,0.2,1))
		input_lbl_xb.add_theme_color_override("font_color", Color(0,0,0,1) if input_toggle_state == 1 else Color(1,0.85,0.2,1))
	else:
		if input_toggle_tween and input_toggle_tween.is_valid():
			input_toggle_tween.kill()
		input_toggle_tween = create_tween().set_parallel(true)
		input_toggle_tween.tween_property(input_highlight, "position:x", target_x, 0.25).set_trans(Tween.TRANS_SINE)
		# Text colors
		if input_toggle_state == 0:
			input_toggle_tween.tween_method(func(c): input_lbl_kb.add_theme_color_override("font_color", c), input_lbl_kb.get_theme_color("font_color"), Color(0,0,0,1), 0.15)
			input_toggle_tween.tween_method(func(c): input_lbl_xb.add_theme_color_override("font_color", c), input_lbl_xb.get_theme_color("font_color"), Color(1,0.85,0.2,1), 0.15)
		else:
			input_toggle_tween.tween_method(func(c): input_lbl_kb.add_theme_color_override("font_color", c), input_lbl_kb.get_theme_color("font_color"), Color(1,0.85,0.2,1), 0.15)
			input_toggle_tween.tween_method(func(c): input_lbl_xb.add_theme_color_override("font_color", c), input_lbl_xb.get_theme_color("font_color"), Color(0,0,0,1), 0.15)


# ---------- Dynamic Controls UI Setup ----------------------------------------
func _setup_controls_ui() -> void:
	var font = load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	var font_kr = load("res://assets/fonts/Galmuri11.ttf")
	var shader = load("res://assets/shaders/isolate_color_pulse.gdshader")
	
	var groups = [
		{"name_en": "SYSTEM", "name_kr": "시스템", "nodes": ["LegPause"]},
		{"name_en": "COMBAT", "name_kr": "전투", "nodes": ["LegMouse", "LegWeapons"]},
		{"name_en": "ABILITIES", "name_kr": "능력", "nodes": ["LegIceBlast", "LegCatastrom"]}
	]
	
	for row_name in ["KeyboardRow", "XboxRow"]:
		var row = $HUD/ControllerScreen/CenterContainer/VBoxContainer.get_node_or_null(row_name)
		if not row: continue
		
		var tex_rect = row.get_node_or_null("KeyboardLayout/TextureRect")
		if not tex_rect: tex_rect = row.get_node_or_null("XboxLayout/TextureRect")
		
		if tex_rect and shader:
			var mat = ShaderMaterial.new()
			mat.shader = shader
			tex_rect.material = mat
			
		var legend = row.get_node_or_null("LegendColumn")
		if not legend: continue
		legend.add_theme_constant_override("separation", 8)
		
		var is_kr = GameState.language == "KR"
		var group_labels = []
		
		# Move and group
		for group in groups:
			var hdr = Label.new()
			hdr.text = group["name_kr"] if is_kr else group["name_en"]
			hdr.add_theme_font_override("font", font_kr if is_kr else font)
			hdr.add_theme_font_size_override("font_size", 14)
			hdr.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 0.6))
			hdr.add_theme_constant_override("outline_size", 2)
			hdr.add_theme_color_override("font_outline_color", Color.BLACK)
			
			var m = MarginContainer.new()
			if group_labels.size() > 0:
				m.add_theme_constant_override("margin_top", 16)
			m.add_child(hdr)
			legend.add_child(m)
			group_labels.append(hdr)
			row.set_meta("group_labels", group_labels)
			
			for node_name in group["nodes"]:
				var n = legend.get_node_or_null(node_name)
				if n:
					legend.move_child(n, -1)
					n.focus_mode = Control.FOCUS_ALL
					
					var target_color = Color.WHITE
					var swatch = n.get_node_or_null("Swatch")
					if swatch and swatch.get("theme_override_styles/panel"):
						target_color = swatch.get("theme_override_styles/panel").bg_color
						target_color.a = 1.0
						
					var hover_cb = func():
						if n.has_meta("pulse_tween"):
							var tw = n.get_meta("pulse_tween")
							if is_instance_valid(tw): tw.kill()
						if n.has_meta("dim_tween"):
							var tw = n.get_meta("dim_tween")
							if is_instance_valid(tw): tw.kill()
						
						var lbl = n.get_node_or_null("Label")
						if lbl: lbl.add_theme_color_override("font_color", Color.WHITE)
						
						if tex_rect and tex_rect.material:
							tex_rect.material.set_shader_parameter("target_color", target_color)
							var tw = create_tween().set_loops()
							tw.tween_method(func(v): tex_rect.material.set_shader_parameter("pulse_multiplier", v), 1.5, 4.0, 0.6).set_trans(Tween.TRANS_SINE)
							tw.tween_method(func(v): tex_rect.material.set_shader_parameter("pulse_multiplier", v), 4.0, 1.5, 0.6).set_trans(Tween.TRANS_SINE)
							n.set_meta("pulse_tween", tw)
							
							var dim_tw = create_tween()
							var curr_dim = tex_rect.material.get_shader_parameter("dim_multiplier")
							if curr_dim == null: curr_dim = 1.0
							dim_tw.tween_method(func(v): tex_rect.material.set_shader_parameter("dim_multiplier", v), curr_dim, 0.3, 0.2)
							n.set_meta("dim_tween", dim_tw)
							
					var exit_cb = func():
						if n.has_meta("pulse_tween"):
							var tw = n.get_meta("pulse_tween")
							if is_instance_valid(tw): tw.kill()
							n.remove_meta("pulse_tween")
						if n.has_meta("dim_tween"):
							var tw = n.get_meta("dim_tween")
							if is_instance_valid(tw): tw.kill()
							n.remove_meta("dim_tween")
							
						var lbl = n.get_node_or_null("Label")
						if lbl: lbl.remove_theme_color_override("font_color")
						
						if tex_rect and tex_rect.material:
							var dim_tw = create_tween()
							var curr_dim = tex_rect.material.get_shader_parameter("dim_multiplier")
							if curr_dim == null: curr_dim = 1.0
							dim_tw.tween_method(func(v): tex_rect.material.set_shader_parameter("dim_multiplier", v), curr_dim, 1.0, 0.2)
							dim_tw.tween_callback(func(): tex_rect.material.set_shader_parameter("pulse_multiplier", 1.0))
							n.set_meta("dim_tween", dim_tw)
					
					if not n.mouse_entered.is_connected(hover_cb):
						n.mouse_entered.connect(hover_cb)
						n.focus_entered.connect(hover_cb)
						n.mouse_exited.connect(exit_cb)
						n.focus_exited.connect(exit_cb)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if not visible:
			return
		if Time.get_ticks_msec() < _ignore_focus_out_until:
			return
		if not pause_screen:
			return
		if not pause_screen.visible and not (end_screen and end_screen.visible) and not (win_screen and win_screen.visible) and not (drafting_screen and drafting_screen.visible) and not (lose_screen and lose_screen.visible):
			if weapon_wheel and weapon_wheel.active:
				weapon_wheel.close()
			_pause_game()

class WeaponCrosshairIcon extends Control:
	var weapon_id: String = "standard"
	var icon_color: Color = Color.WHITE
	
	func _draw() -> void:
		var center = size / 2.0
		match weapon_id:
			"standard":
				var radius = min(size.x, size.y) * 0.25
				draw_arc(center, radius, 0, TAU, 32, icon_color, 3.0, true)
			"precision":
				var gap = 4.0
				var arm = 12.0
				var thick = 2.0
				draw_line(center + Vector2(-arm - gap, 0), center + Vector2(-gap, 0), icon_color, thick, true)
				draw_line(center + Vector2(gap, 0), center + Vector2(arm + gap, 0), icon_color, thick, true)
				draw_line(center + Vector2(0, -arm - gap), center + Vector2(0, -gap), icon_color, thick, true)
				draw_line(center + Vector2(0, gap), center + Vector2(0, arm + gap), icon_color, thick, true)
				draw_circle(center, 2.0, icon_color)
			"heavy":
				var r = 12.0
				var arm = 8.0
				var thick = 3.5
				draw_line(center + Vector2(-r - arm, -r), center + Vector2(-r, -r), icon_color, thick, true)
				draw_line(center + Vector2(-r, -r), center + Vector2(-r, -r + arm), icon_color, thick, true)
				draw_line(center + Vector2(r, -r), center + Vector2(r + arm, -r), icon_color, thick, true)
				draw_line(center + Vector2(r, -r), center + Vector2(r, -r + arm), icon_color, thick, true)
				draw_line(center + Vector2(-r - arm, r), center + Vector2(-r, r), icon_color, thick, true)
				draw_line(center + Vector2(-r, r), center + Vector2(-r, r - arm), icon_color, thick, true)
				draw_line(center + Vector2(r, r), center + Vector2(r + arm, r), icon_color, thick, true)
				draw_line(center + Vector2(r, r), center + Vector2(r, r - arm), icon_color, thick, true)
			"scatter":
				var thick = 3.0
				var scatter_center = center + Vector2(0, 10)
				for ang_deg in [-35.0, 0.0, 35.0]:
					var ang = deg_to_rad(ang_deg - 90.0)
					var s = scatter_center + Vector2(cos(ang), sin(ang)) * 6.0
					var e = scatter_center + Vector2(cos(ang), sin(ang)) * 20.0
					draw_line(s, e, icon_color, thick, true)
				draw_line(scatter_center + Vector2(-5, 0), scatter_center + Vector2(5, 0), icon_color, thick, true)
			"tidal":
				var radius = 16.0
				var num_dashes = 8
				var dash_arc = deg_to_rad(22.0)
				var gap_arc  = (TAU / num_dashes) - dash_arc
				var offset   = 0.0
				for i in range(num_dashes):
					var start_a = offset + i * (dash_arc + gap_arc)
					draw_arc(center, radius, start_a, start_a + dash_arc, 8, icon_color, 3.0, true)
				var c_arm = 4.0
				draw_line(center + Vector2(-c_arm, 0), center + Vector2(c_arm, 0), icon_color, 2.0, true)
				draw_line(center + Vector2(0, -c_arm), center + Vector2(0, c_arm), icon_color, 2.0, true)
