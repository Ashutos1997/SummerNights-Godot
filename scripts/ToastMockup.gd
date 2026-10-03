extends Control

# ToastMockup.gd
# Interactive and visual mockup testbed for the new HUD right-side notifications (toasts).

@onready var preview_column = $PreviewColumn
@onready var toast_container = $ToastContainer
@onready var lang_btn = $ControlPanel/LangToggleBtn

var is_kr: bool = false
var kenney_font: Font = null
var inter_font: Font = null
var galmuri_font: Font = null

func _ready() -> void:
	kenney_font = load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	inter_font = load("res://assets/fonts/Inter-Medium.ttf")
	galmuri_font = load("res://assets/fonts/Galmuri11.ttf")
	
	_connect_signals()
	_update_control_panel_texts()
	_build_static_showcase()
	
	# Initial entrance greeting toast
	await get_tree().create_timer(0.4).timeout
	trigger_toast_weapon()

func _connect_signals() -> void:
	$ControlPanel/BtnWeapon.pressed.connect(trigger_toast_weapon)
	$ControlPanel/BtnCelestial.pressed.connect(trigger_toast_celestial)
	$ControlPanel/BtnCatastrom.pressed.connect(trigger_toast_catastrom)
	$ControlPanel/BtnWeather.pressed.connect(trigger_toast_weather)
	$ControlPanel/BtnDrone.pressed.connect(trigger_toast_drone)
	$ControlPanel/BtnBurst.pressed.connect(trigger_burst)
	$ControlPanel/LangToggleBtn.pressed.connect(_toggle_lang)
	$ControlPanel/BtnClear.pressed.connect(_clear_toasts)
	$ControlPanel/BtnExit.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn"))

func _update_control_panel_texts() -> void:
	var body_font = galmuri_font if is_kr else inter_font
	var title_font = galmuri_font if is_kr else kenney_font
	
	$HeaderBox/HeaderTitle.add_theme_font_override("font", title_font)
	$HeaderBox/HeaderTitle.add_theme_font_size_override("font_size", 20)
	$HeaderBox/HeaderTitle.text = "HUD NOTIFICATION (TOAST) REDESIGN MOCKUP" if not is_kr else "HUD 알림 (토스트) 디자인 개편 목업"
	
	$HeaderBox/HeaderSubtitle.add_theme_font_override("font", body_font)
	$HeaderBox/HeaderSubtitle.add_theme_font_size_override("font_size", 12)
	$HeaderBox/HeaderSubtitle.text = "Clean arcade plate concept · Live entrance, depletion countdown & reflow testbed" if not is_kr else "깔끔한 아케이드 플레이트 디자인 · 실시간 등장, 소모 타이머 및 스택 테스트베드"
	
	$ControlPanel/PanelLabel.add_theme_font_override("font", body_font)
	$ControlPanel/PanelLabel.add_theme_font_size_override("font_size", 12)
	$ControlPanel/PanelLabel.text = "LIVE INTERACTION CONTROLS" if not is_kr else "실시간 상호작용 컨트롤"
	
	lang_btn.text = "LANGUAGE: [ KR ]" if is_kr else "LANGUAGE: [ EN ]"
	$ControlPanel/BtnWeapon.text = "[ UNLOCK ] Weapon Unlock" if not is_kr else "[ 무기 해금 ] 무기 알림"
	$ControlPanel/BtnCelestial.text = "[ TRANSCEND ] Celestial Ready" if not is_kr else "[ 각성 준비 ] 천상 각성"
	$ControlPanel/BtnCatastrom.text = "[ DUNK ] Catastrom Charge" if not is_kr else "[ 덩크 준비 ] 카타스트롬"
	$ControlPanel/BtnWeather.text = "[ WEATHER ] Rainstorm Alert" if not is_kr else "[ 기상 이변 ] 폭우 알림"
	$ControlPanel/BtnDrone.text = "[ SUPPLY ] Drone Delivered" if not is_kr else "[ 보급 전달 ] 드론 보급"
	$ControlPanel/BtnBurst.text = "[ BURST ] Trigger 3x Stacking" if not is_kr else "[ 연속 발생 ] 3연속 스택 테스트"
	$ControlPanel/BtnClear.text = "CLEAR ALL TOASTS" if not is_kr else "모든 알림 지우기"
	$ControlPanel/BtnExit.text = "BACK TO TITLE SCREEN" if not is_kr else "타이틀 화면으로 복귀"
	
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0, 0, 0, 0.5)
	normal_style.border_width_left = 1
	normal_style.border_width_top = 1
	normal_style.border_width_right = 1
	normal_style.border_width_bottom = 1
	normal_style.border_color = Color(1.0, 0.85, 0.2, 0.6)
	normal_style.corner_radius_top_left = 0
	normal_style.corner_radius_top_right = 0
	normal_style.corner_radius_bottom_right = 0
	normal_style.corner_radius_bottom_left = 0
	
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(1.0, 0.85, 0.2, 0.15)
	hover_style.border_color = Color(1.0, 0.85, 0.2, 1.0)
	
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(1.0, 0.85, 0.2, 0.3)
	pressed_style.border_color = Color(1.0, 1.0, 1.0, 1.0)
	
	for child in $ControlPanel.get_children():
		if child is Button:
			child.add_theme_font_override("font", body_font)
			child.add_theme_font_size_override("font_size", 12)
			child.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
			child.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
			child.add_theme_stylebox_override("normal", normal_style)
			child.add_theme_stylebox_override("hover", hover_style)
			child.add_theme_stylebox_override("pressed", pressed_style)
			child.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _toggle_lang() -> void:
	is_kr = not is_kr
	_update_control_panel_texts()
	_build_static_showcase()

func _clear_toasts() -> void:
	for child in toast_container.get_children():
		child.queue_free()

func _build_static_showcase() -> void:
	for child in preview_column.get_children():
		child.queue_free()
		
	var body_font = galmuri_font if is_kr else inter_font
	
	var label = Label.new()
	label.text = "STATIC ANATOMY PREVIEW" if not is_kr else "정적 디자인 구조 미리보기"
	label.add_theme_font_override("font", body_font)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 0.7))
	preview_column.add_child(label)
	
	# 1. Weapon Unlock
	var t1 = create_toast_node(
		"[ UNLOCK ]" if not is_kr else "[ 무기 해금 ]",
		"KITSUNE BUSTER IX" if not is_kr else "키츠네 버스터 IX",
		"Hold [TAB] to equip in combat" if not is_kr else "[TAB] 을 길게 눌러 장착",
		"res://assets/ui/icons/padlock-open.svg",
		Color(1.0, 0.85, 0.2, 1.0),
		false
	)
	preview_column.add_child(t1)
	
	# 2. Celestial Awakening
	var t2 = create_toast_node(
		"[ TRANSCEND ]" if not is_kr else "[ 각성 준비 ]",
		"CELESTIAL AWAKENING READY" if not is_kr else "천상 각성 충전 완료",
		"Press [F] to transcend" if not is_kr else "[F] 키를 눌러 각성 돌입",
		"res://assets/ui/hud_elements/meter_celestial.svg",
		Color(0.35, 0.95, 1.0, 1.0),
		false
	)
	preview_column.add_child(t2)
	
	# 3. Catastrom Ready
	var t3 = create_toast_node(
		"[ DUNK READY ]" if not is_kr else "[ 덩크 준비 ]",
		"CATASTROM CHARGE MAX" if not is_kr else "카타스트롬 최대 충전",
		"Press [F] to dunk the Sun" if not is_kr else "[F] 키를 눌러 태양을 덩크",
		"res://assets/ui/hud_elements/meter_catastrom.svg",
		Color(0.8, 0.4, 1.0, 1.0),
		false
	)
	preview_column.add_child(t3)

func trigger_toast_weapon() -> void:
	spawn_live_toast(
		"[ UNLOCK ]" if not is_kr else "[ 무기 해금 ]",
		"KITSUNE BUSTER IX" if not is_kr else "키츠네 버스터 IX",
		"Hold [TAB] to equip in combat" if not is_kr else "[TAB] 을 길게 눌러 장착",
		"res://assets/ui/icons/padlock-open.svg",
		Color(1.0, 0.85, 0.2, 1.0)
	)

func trigger_toast_celestial() -> void:
	spawn_live_toast(
		"[ TRANSCEND ]" if not is_kr else "[ 각성 준비 ]",
		"CELESTIAL AWAKENING READY" if not is_kr else "천상 각성 충전 완료",
		"Press [F] to transcend" if not is_kr else "[F] 키를 눌러 각성 돌입",
		"res://assets/ui/hud_elements/meter_celestial.svg",
		Color(0.35, 0.95, 1.0, 1.0)
	)

func trigger_toast_catastrom() -> void:
	spawn_live_toast(
		"[ DUNK READY ]" if not is_kr else "[ 덩크 준비 ]",
		"CATASTROM CHARGE MAX" if not is_kr else "카타스트롬 최대 충전",
		"Press [F] to dunk the Sun" if not is_kr else "[F] 키를 눌러 태양을 덩크",
		"res://assets/ui/hud_elements/meter_catastrom.svg",
		Color(0.8, 0.4, 1.0, 1.0)
	)

func trigger_toast_weather() -> void:
	spawn_live_toast(
		"[ WEATHER ANOMALY ]" if not is_kr else "[ 기상 이변 ]",
		"TROPICAL RAINSTORM" if not is_kr else "열대성 폭우 발생",
		"Infinite water supply active" if not is_kr else "물이 무한으로 공급됩니다",
		"res://assets/ui/hud_elements/meter_ice.svg",
		Color(0.4, 0.85, 1.0, 1.0)
	)

func trigger_toast_drone() -> void:
	spawn_live_toast(
		"[ SUPPLY DROP ]" if not is_kr else "[ 보급 전달 ]",
		"DRONE CACHE DELIVERED" if not is_kr else "보급 드론 전달 완료",
		"Water & core health restored" if not is_kr else "물 및 체력이 회복되었습니다",
		"res://assets/ui/icons/delivery-drone.svg",
		Color(1.0, 0.65, 0.2, 1.0)
	)

func trigger_burst() -> void:
	trigger_toast_weapon()
	await get_tree().create_timer(0.25).timeout
	trigger_toast_celestial()
	await get_tree().create_timer(0.25).timeout
	trigger_toast_weather()

func create_toast_node(kicker: String, title: String, desc: String, icon_path: String, accent_color: Color, enable_timer: bool = true) -> Control:
	var title_font = galmuri_font if is_kr else kenney_font
	var body_font = galmuri_font if is_kr else inter_font
	
	var toast = Control.new()
	toast.custom_minimum_size = Vector2(380, 72)
	toast.size_flags_horizontal = Control.SIZE_SHRINK_END
	
	# Root Panel Container
	var panel = PanelContainer.new()
	panel.name = "Panel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.04, 0.08, 0.94)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(accent_color.r, accent_color.g, accent_color.b, 0.35)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_right = 0
	style.corner_radius_bottom_left = 0
	style.shadow_color = Color(0, 0, 0, 0.7)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 4)
	panel.add_theme_stylebox_override("panel", style)
	toast.add_child(panel)
	
	# Content Margin Container (Symmetrical 16px horizontal margins without left spine)
	var margin = MarginContainer.new()
	margin.name = "ContentMargin"
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	
	# Content Row
	var content_row = HBoxContainer.new()
	content_row.name = "ContentRow"
	content_row.add_theme_constant_override("separation", 14)
	content_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	margin.add_child(content_row)
	
	# Recessed Icon Plate (40x40 even number dimensions)
	var icon_plate = PanelContainer.new()
	icon_plate.name = "IconPlate"
	icon_plate.custom_minimum_size = Vector2(40, 40)
	icon_plate.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_plate.pivot_offset = Vector2(20, 20)
	
	var plate_style = StyleBoxFlat.new()
	plate_style.bg_color = Color(0.02, 0.02, 0.04, 0.95)
	plate_style.border_width_left = 1
	plate_style.border_width_top = 1
	plate_style.border_width_right = 1
	plate_style.border_width_bottom = 1
	plate_style.border_color = Color(accent_color.r, accent_color.g, accent_color.b, 0.45)
	plate_style.corner_radius_top_left = 2
	plate_style.corner_radius_top_right = 2
	plate_style.corner_radius_bottom_right = 2
	plate_style.corner_radius_bottom_left = 2
	icon_plate.add_theme_stylebox_override("panel", plate_style)
	
	var icon_tex = TextureRect.new()
	if icon_path != "":
		icon_tex.texture = load(icon_path)
	icon_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_tex.custom_minimum_size = Vector2(26, 26)
	icon_tex.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_tex.modulate = accent_color
	icon_plate.add_child(icon_tex)
	content_row.add_child(icon_plate)
	
	# Text Column
	var text_col = VBoxContainer.new()
	text_col.name = "TextCol"
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.alignment = BoxContainer.ALIGNMENT_CENTER
	text_col.add_theme_constant_override("separation", 2)
	content_row.add_child(text_col)
	
	# 1. Kicker Label (Micro-category tag) -> Uses BODY typeface (Inter-Medium / Galmuri11)
	var kicker_lbl = Label.new()
	kicker_lbl.name = "KickerLabel"
	kicker_lbl.text = kicker
	kicker_lbl.add_theme_font_override("font", body_font)
	kicker_lbl.add_theme_font_size_override("font_size", 10)
	kicker_lbl.add_theme_color_override("font_color", accent_color)
	kicker_lbl.add_theme_constant_override("letter_spacing", 1)
	text_col.add_child(kicker_lbl)
	
	# 2. Main Title Label -> Uses TITLE typeface (Kenney Future / Galmuri11)
	var title_lbl = Label.new()
	title_lbl.name = "TitleLabel"
	title_lbl.text = title
	title_lbl.add_theme_font_override("font", title_font)
	title_lbl.add_theme_font_size_override("font_size", 14)
	title_lbl.add_theme_color_override("font_color", Color.WHITE)
	title_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	title_lbl.add_theme_constant_override("outline_size", 3)
	text_col.add_child(title_lbl)
	
	# 3. Description Callout -> Uses BODY typeface (Inter-Medium / Galmuri11)
	var desc_lbl = Label.new()
	desc_lbl.name = "DescLabel"
	desc_lbl.text = desc
	desc_lbl.add_theme_font_override("font", body_font)
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92))
	desc_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	desc_lbl.add_theme_constant_override("outline_size", 2)
	text_col.add_child(desc_lbl)
	
	# 4. Auto-Dismiss Depletion Bar (1.5px Hairline across full bottom edge)
	var depletion_bar = ColorRect.new()
	depletion_bar.name = "DepletionBar"
	depletion_bar.color = accent_color
	depletion_bar.layout_mode = 1
	depletion_bar.anchors_preset = Control.PRESET_BOTTOM_WIDE
	depletion_bar.offset_left = 0.0
	depletion_bar.offset_top = -2.0
	depletion_bar.offset_right = 0.0
	depletion_bar.offset_bottom = 0.0
	depletion_bar.pivot_offset = Vector2.ZERO
	toast.add_child(depletion_bar)
	
	# Store direct references in metadata for bulletproof, path-independent lookup
	toast.set_meta("panel", panel)
	toast.set_meta("icon_plate", icon_plate)
	toast.set_meta("depletion_bar", depletion_bar)
	
	return toast

func spawn_live_toast(kicker: String, title: String, desc: String, icon_path: String, accent_color: Color) -> void:
	var toast = create_toast_node(kicker, title, desc, icon_path, accent_color, true)
	toast_container.add_child(toast)
	
	var panel: PanelContainer = toast.get_meta("panel", null)
	if not panel:
		panel = toast.get_node_or_null("Panel")
	
	var icon_plate: PanelContainer = toast.get_meta("icon_plate", null)
	if not icon_plate:
		icon_plate = toast.find_child("IconPlate", true, false)
		
	var depletion_bar: ColorRect = toast.get_meta("depletion_bar", null)
	if not depletion_bar:
		depletion_bar = toast.find_child("DepletionBar", true, false)
	
	# Entrance sound
	var sfx = AudioStreamPlayer.new()
	sfx.stream = load("res://assets/audio/sfx/perk_hover.wav")
	sfx.volume_db = -8.0
	sfx.bus = "SFX"
	add_child(sfx)
	sfx.play()
	
	# Initial entrance state
	if panel:
		panel.position.x = 400.0
		panel.modulate.a = 0.0
	if icon_plate:
		icon_plate.scale = Vector2(0.6, 0.6)
	
	# Entrance Animation
	var tw = create_tween().set_parallel(true)
	if panel:
		tw.tween_property(panel, "position:x", 0.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(panel, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if icon_plate:
		tw.tween_property(icon_plate, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.08)
	
	# Auto-dismiss Depletion Bar (3.5s countdown)
	if depletion_bar:
		var tw_bar = create_tween()
		tw_bar.tween_property(depletion_bar, "scale:x", 0.0, 3.5).set_trans(Tween.TRANS_LINEAR)
	
	# Wait 3.5s then slide out and trigger reflow
	await get_tree().create_timer(3.5).timeout
	
	if not is_instance_valid(toast): return
	
	# Slide-out and Collapse Animation
	var tw_out = create_tween().set_parallel(true)
	if panel and is_instance_valid(panel):
		tw_out.tween_property(panel, "position:x", 420.0, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tw_out.tween_property(panel, "modulate:a", 0.0, 0.25)
	tw_out.tween_property(toast, "custom_minimum_size:y", 0.0, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	tw_out.chain().tween_callback(func():
		if is_instance_valid(toast):
			toast.queue_free()
		if is_instance_valid(sfx):
			sfx.queue_free()
	)
