extends ColorRect

class_name DraftingScreen

var blur_mat: ShaderMaterial
var card_container: VBoxContainer
var title_lbl: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Fullscreen background (Matches Pause Menu)
	color = Color(0.02, 0.01, 0.05, 0.96)
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	# Global Golden Border
	var border = Panel.new()
	border.set_anchors_preset(PRESET_FULL_RECT)
	border.offset_left = 24
	border.offset_top = 24
	border.offset_right = -24
	border.offset_bottom = -24
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color(0,0,0,0)
	border_style.border_width_left = 2
	border_style.border_width_right = 2
	border_style.border_width_top = 2
	border_style.border_width_bottom = 2
	border_style.border_color = Color(1.0, 0.85, 0.2, 0.4)
	border_style.corner_radius_top_left = 8
	border_style.corner_radius_top_right = 8
	border_style.corner_radius_bottom_left = 8
	border_style.corner_radius_bottom_right = 8
	border.add_theme_stylebox_override("panel", border_style)
	add_child(border)
	
	var is_kr = GameState.language == "KR"
	var title_font = load("res://assets/fonts/Galmuri11.ttf") if is_kr else load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	var body_font = load("res://assets/fonts/Galmuri11.ttf") if is_kr else load("res://assets/fonts/Inter-Medium.ttf")
	
	# Create internal layout matching Achievements/Buffs Menu (Centered block)
	var center = CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 24)
	center.add_child(main_vbox)
	
	# Title Row
	var title_row = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 12)
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(title_row)
	
	var title_icon = TextureRect.new()
	title_icon.custom_minimum_size = Vector2(40, 40)
	title_icon.texture = load("res://assets/ui/menu_icons/dice.png")
	title_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_icon.modulate = Color(1.0, 0.85, 0.2, 1.0)
	title_row.add_child(title_icon)
	
	title_lbl = Label.new()
	title_lbl.text = "특성 선택" if is_kr else "CHOOSE A PERK"
	title_lbl.add_theme_font_override("font", title_font)
	title_lbl.add_theme_font_size_override("font_size", 32)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	title_lbl.add_theme_constant_override("outline_size", 4)
	title_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	title_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_row.add_child(title_lbl)
	
	# Divider
	var divider = HSeparator.new()
	var div_style = StyleBoxLine.new()
	div_style.color = Color(1.0, 0.88, 0.3, 0.35)
	div_style.thickness = 2
	divider.add_theme_stylebox_override("separator", div_style)
	main_vbox.add_child(divider)
	
	# Perk List Container
	card_container = VBoxContainer.new()
	card_container.add_theme_constant_override("separation", 16)
	main_vbox.add_child(card_container)
	
	hide()

func show_draft() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Clear old options
	for c in card_container.get_children():
		c.queue_free()
		
	# Weighted pool for rarity
	var pool = []
	for perk_id in GameState.WAVE_PERKS.keys():
		var weight = GameState.WAVE_PERKS[perk_id].get("weight", 100)
		for i in range(weight):
			pool.append(perk_id)
			
	var choices = []
	while choices.size() < 3 and pool.size() > 0:
		var pick = pool.pick_random()
		if not pick in choices:
			choices.append(pick)
	
	for perk_id in choices:
		var row = _create_perk_row(perk_id)
		card_container.add_child(row)
		
	modulate.a = 0.0
	show()
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(self, "modulate:a", 1.0, 0.3)
	
	# Grab focus so controller works
	if card_container.get_child_count() > 0:
		card_container.get_child(0).grab_focus()
	
func _create_perk_row(perk_id: String) -> Control:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(700, 100)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.1, 0.1, 0.15, 0.8)
	style_normal.border_width_left = 1
	style_normal.border_width_right = 1
	style_normal.border_width_top = 1
	style_normal.border_width_bottom = 1
	style_normal.border_color = Color(1.0, 0.85, 0.2, 0.5)
	style_normal.corner_radius_top_left = 6
	style_normal.corner_radius_top_right = 6
	style_normal.corner_radius_bottom_left = 6
	style_normal.corner_radius_bottom_right = 6
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(0.15, 0.15, 0.2, 0.9)
	style_hover.border_color = Color(1.0, 0.9, 0.3, 1.0)
	
	var style_focus = style_hover.duplicate()
	style_focus.border_color = Color(1.0, 0.85, 0.2, 1.0)
	style_focus.border_width_left = 2
	style_focus.border_width_right = 2
	style_focus.border_width_top = 2
	style_focus.border_width_bottom = 2
	
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = Color(0.05, 0.05, 0.1, 0.8)
	
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("focus", style_focus)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	
	var perk = GameState.WAVE_PERKS[perk_id]
	var is_kr = GameState.language == "KR"
	
	var margin = MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(hbox)
	
	var icon = TextureRect.new()
	icon.texture = load(perk.icon)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(64, 64)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(icon)
	
	var vbox_item = VBoxContainer.new()
	vbox_item.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox_item.add_theme_constant_override("separation", 0)
	vbox_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(vbox_item)
	
	var title = Label.new()
	title.text = perk.title_kr if is_kr else perk.title_en
	var title_font = load("res://assets/fonts/Galmuri11.ttf") if is_kr else load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	title.add_theme_font_override("font", title_font)
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_constant_override("outline_size", 2)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	vbox_item.add_child(title)
	
	var desc = Label.new()
	desc.text = perk.desc_kr if is_kr else perk.desc_en
	var body_font = load("res://assets/fonts/Galmuri11.ttf") if is_kr else load("res://assets/fonts/Inter-Medium.ttf")
	desc.add_theme_font_override("font", body_font)
	desc.add_theme_font_size_override("font_size", 16)
	desc.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.8))
	desc.add_theme_constant_override("outline_size", 1)
	desc.add_theme_color_override("font_outline_color", Color.BLACK)
	desc.custom_minimum_size = Vector2(550, 0)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox_item.add_child(desc)
	
	btn.mouse_entered.connect(func():
		btn.grab_focus()
	)
	
	btn.pressed.connect(func():
		_on_perk_selected(perk_id)
	)
	
	return btn

func _on_perk_selected(perk_id: String) -> void:
	GameState.active_wave_perks.append(perk_id)
	GameState._evaluate_milestones() # Recalculate stats
	
	# Resume game
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("_recalculate_stats"):
		main_scene._recalculate_stats()
		if main_scene.get("hud") and main_scene.hud.has_method("update_active_perks_hud"):
			main_scene.hud.update_active_perks_hud()
			
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func():
		hide()
	)
