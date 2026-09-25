extends Control

signal weapon_selected(weapon_id: String)

var active: bool = false
var selected_index: int = -1
var weapons: Array = []
const ARCHETYPES_EN = {
	"standard": "BALANCED",
	"heavy": "HIGH IMPACT",
	"precision": "HIGH CRIT",
	"scatter": "WIDE SPREAD",
	"tidal": "RAPID FIRE"
}

const ARCHETYPES_KR = {
	"standard": "밸런스",
	"heavy": "고화력",
	"precision": "고치명타",
	"scatter": "산탄",
	"tidal": "속사 개틀링"
}

var font_header_en: Font = preload("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
var font_body_en: Font = preload("res://assets/fonts/Inter-Medium.ttf")
var font_kr: Font = preload("res://assets/fonts/Galmuri11.ttf")

var open_tween: Tween
var containers: Array = []
var models: Array = []

var text_panel: PanelContainer
var panel_style: StyleBoxFlat

var header_row: HBoxContainer
var name_label: Label
var archetype_panel: PanelContainer
var archetype_label: Label

var divider: HSeparator
var divider_style: StyleBoxLine

var stats_row: HBoxContainer
var pwr_label: Label
var pwr_bar: ProgressBar
var pwr_val: Label
var cap_label: Label
var cap_bar: ProgressBar
var cap_val: Label
var crit_label: Label
var crit_val: Label


var lock_badge: PanelContainer
var lock_badge_label: Label
var lock_req_label: Label

var bg_dim: ColorRect
var whoosh_player: AudioStreamPlayer = null
var arrow_angle: float = -PI/2
var target_arrow_angle: float = -PI/2
var arrow_anim: float = 0.0
var target_arrow_anim: float = 0.0
var last_hovered_locked: bool = false

func _ready() -> void:
	weapons = GameState.WEAPONS.keys()
	hide()
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)
	
	bg_dim = ColorRect.new()
	bg_dim.color = Color.WHITE
	
	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 0.0;
uniform float dim_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 bg = textureLod(screen_texture, SCREEN_UV, blur_amount);
	COLOR = mix(bg, vec4(0.0, 0.0, 0.0, 1.0), dim_amount);
}
"""
	var smat = ShaderMaterial.new()
	smat.shader = shader
	smat.set_shader_parameter("blur_amount", 0.0)
	smat.set_shader_parameter("dim_amount", 0.0)
	bg_dim.material = smat
	
	bg_dim.set_anchors_preset(PRESET_FULL_RECT)
	bg_dim.mouse_filter = MOUSE_FILTER_IGNORE
	bg_dim.visible = false
	get_parent().call_deferred("add_child", bg_dim)
	get_parent().call_deferred("move_child", bg_dim, get_index())
	
	# Spawn 3D viewports
	for i in range(weapons.size()):
		var w_id = weapons[i]
		var w_cfg = GameState.WEAPONS[w_id]
		
		var svc = SubViewportContainer.new()
		svc.stretch = true
		svc.custom_minimum_size = Vector2(180, 180)
		svc.pivot_offset = Vector2(90, 90) # Scale from center
		add_child(svc)
		containers.append(svc)
		
		var vp = SubViewport.new()
		vp.transparent_bg = true
		vp.own_world_3d = true
		svc.add_child(vp)
		
		var cam = Camera3D.new()
		cam.position = Vector3(0, 0, 2.5) # Pulled back to prevent clipping
		vp.add_child(cam)
		
		var light = DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-30, 45, 0)
		light.light_energy = 1.2
		vp.add_child(light)
		
		var model = load(w_cfg.model).instantiate()
		model.scale = w_cfg.scale * 0.7 # Scaled up for better visibility
		model.position = Vector3(0, -0.3, -0.1) # Center vertically like in Main.gd
		_adjust_gun_materials(model)
		vp.add_child(model)
		models.append(model)
	
	# Setup Text Panel (Option C: Header + Archetype badge, Mini-bars for PWR/CAP, CRIT readout, and Locked banner)
	text_panel = PanelContainer.new()
	text_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_panel.custom_minimum_size = Vector2(490, 88)
	
	panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.03, 0.11, 0.92)
	panel_style.set_corner_radius_all(16)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(1.0, 0.86, 0.24, 0.95)
	panel_style.content_margin_left = 22.0
	panel_style.content_margin_right = 22.0
	panel_style.content_margin_top = 13.0
	panel_style.content_margin_bottom = 13.0
	text_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(text_panel)
	
	var vbox = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 8)
	text_panel.add_child(vbox)
	
	# Header Row: Gun Name + Spacer + Archetype Badge
	header_row = HBoxContainer.new()
	header_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	vbox.add_child(header_row)
	
	name_label = Label.new()
	name_label.label_settings = LabelSettings.new()
	name_label.label_settings.font = font_header_en
	name_label.label_settings.font_size = 22
	name_label.label_settings.font_color = Color(1.0, 0.96, 0.6, 1.0)
	name_label.label_settings.outline_size = 3
	name_label.label_settings.outline_color = Color.BLACK
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header_row.add_child(name_label)
	
	var header_spacer = Control.new()
	header_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(header_spacer)
	
	archetype_panel = PanelContainer.new()
	archetype_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	archetype_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var arch_style = StyleBoxFlat.new()
	arch_style.bg_color = Color(1.0, 0.85, 0.2, 0.12)
	arch_style.border_color = Color(1.0, 0.85, 0.2, 0.55)
	arch_style.border_width_left = 1
	arch_style.border_width_top = 1
	arch_style.border_width_right = 1
	arch_style.border_width_bottom = 1
	arch_style.set_corner_radius_all(6)
	arch_style.content_margin_left = 12.0
	arch_style.content_margin_right = 12.0
	arch_style.content_margin_top = 4.0
	arch_style.content_margin_bottom = 4.0
	archetype_panel.add_theme_stylebox_override("panel", arch_style)
	header_row.add_child(archetype_panel)
	
	archetype_label = Label.new()
	archetype_label.label_settings = LabelSettings.new()
	archetype_label.label_settings.font = font_body_en
	archetype_label.label_settings.font_size = 12
	archetype_label.label_settings.font_color = Color(1.0, 0.88, 0.35, 1.0)
	archetype_label.label_settings.outline_size = 2
	archetype_label.label_settings.outline_color = Color.BLACK
	archetype_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	archetype_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	archetype_panel.add_child(archetype_label)
	
	# Faint Golden Divider
	divider = HSeparator.new()
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	divider_style = StyleBoxLine.new()
	divider_style.color = Color(1.0, 0.85, 0.2, 0.28)
	divider_style.thickness = 1
	divider_style.grow_begin = 0
	divider_style.grow_end = 0
	divider.add_theme_stylebox_override("separator", divider_style)
	vbox.add_child(divider)
	
	# Stats Row: PWR Mini-Bar + CAP Mini-Bar + CRIT Readout
	stats_row = HBoxContainer.new()
	stats_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stats_row.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_row.add_theme_constant_override("separation", 18)
	vbox.add_child(stats_row)
	
	# PWR Group
	var pwr_box = HBoxContainer.new()
	pwr_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pwr_box.alignment = BoxContainer.ALIGNMENT_CENTER
	pwr_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pwr_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pwr_box.add_theme_constant_override("separation", 10)
	stats_row.add_child(pwr_box)
	
	pwr_label = Label.new()
	pwr_label.label_settings = LabelSettings.new()
	pwr_label.label_settings.font = font_body_en
	pwr_label.label_settings.font_size = 12
	pwr_label.label_settings.font_color = Color(0.75, 0.75, 0.8, 1.0)
	pwr_label.label_settings.outline_size = 2
	pwr_label.label_settings.outline_color = Color.BLACK
	pwr_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pwr_label.text = "PWR"
	pwr_box.add_child(pwr_label)
	
	pwr_bar = ProgressBar.new()
	pwr_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pwr_bar.custom_minimum_size = Vector2(40, 9)
	pwr_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pwr_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pwr_bar.show_percentage = false
	pwr_bar.min_value = 0.0
	pwr_bar.max_value = 45.0
	var pbar_bg = StyleBoxFlat.new()
	pbar_bg.bg_color = Color(0.12, 0.1, 0.16, 0.9)
	pbar_bg.border_color = Color(0.28, 0.24, 0.32, 0.8)
	pbar_bg.border_width_left = 1
	pbar_bg.border_width_top = 1
	pbar_bg.border_width_right = 1
	pbar_bg.border_width_bottom = 1
	pbar_bg.set_corner_radius_all(3)
	pwr_bar.add_theme_stylebox_override("background", pbar_bg)
	var pwr_fill = StyleBoxFlat.new()
	pwr_fill.bg_color = Color(1.0, 0.8, 0.15, 1.0)
	pwr_fill.set_corner_radius_all(3)
	pwr_bar.add_theme_stylebox_override("fill", pwr_fill)
	pwr_box.add_child(pwr_bar)
	
	pwr_val = Label.new()
	pwr_val.label_settings = LabelSettings.new()
	pwr_val.label_settings.font = font_body_en
	pwr_val.label_settings.font_size = 13
	pwr_val.label_settings.font_color = Color(1.0, 0.9, 0.4, 1.0)
	pwr_val.label_settings.outline_size = 2
	pwr_val.label_settings.outline_color = Color.BLACK
	pwr_val.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pwr_box.add_child(pwr_val)
	
	# CAP Group
	var cap_box = HBoxContainer.new()
	cap_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap_box.alignment = BoxContainer.ALIGNMENT_CENTER
	cap_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cap_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cap_box.add_theme_constant_override("separation", 10)
	stats_row.add_child(cap_box)
	
	cap_label = Label.new()
	cap_label.label_settings = LabelSettings.new()
	cap_label.label_settings.font = font_body_en
	cap_label.label_settings.font_size = 12
	cap_label.label_settings.font_color = Color(0.75, 0.75, 0.8, 1.0)
	cap_label.label_settings.outline_size = 2
	cap_label.label_settings.outline_color = Color.BLACK
	cap_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cap_label.text = "CAP"
	cap_box.add_child(cap_label)
	
	cap_bar = ProgressBar.new()
	cap_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap_bar.custom_minimum_size = Vector2(40, 9)
	cap_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cap_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cap_bar.show_percentage = false
	cap_bar.min_value = 0.0
	cap_bar.max_value = 250.0
	var cbar_bg = StyleBoxFlat.new()
	cbar_bg.bg_color = Color(0.12, 0.1, 0.16, 0.9)
	cbar_bg.border_color = Color(0.28, 0.24, 0.32, 0.8)
	cbar_bg.border_width_left = 1
	cbar_bg.border_width_top = 1
	cbar_bg.border_width_right = 1
	cbar_bg.border_width_bottom = 1
	cbar_bg.set_corner_radius_all(3)
	cap_bar.add_theme_stylebox_override("background", cbar_bg)
	var cap_fill = StyleBoxFlat.new()
	cap_fill.bg_color = Color(0.2, 0.75, 1.0, 1.0)
	cap_fill.set_corner_radius_all(3)
	cap_bar.add_theme_stylebox_override("fill", cap_fill)
	cap_box.add_child(cap_bar)
	
	cap_val = Label.new()
	cap_val.label_settings = LabelSettings.new()
	cap_val.label_settings.font = font_body_en
	cap_val.label_settings.font_size = 13
	cap_val.label_settings.font_color = Color(0.45, 0.85, 1.0, 1.0)
	cap_val.label_settings.outline_size = 2
	cap_val.label_settings.outline_color = Color.BLACK
	cap_val.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cap_box.add_child(cap_val)
	
	# CRIT Group
	var crit_box = HBoxContainer.new()
	crit_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crit_box.alignment = BoxContainer.ALIGNMENT_CENTER
	crit_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	crit_box.add_theme_constant_override("separation", 10)
	stats_row.add_child(crit_box)
	
	crit_label = Label.new()
	crit_label.label_settings = LabelSettings.new()
	crit_label.label_settings.font = font_body_en
	crit_label.label_settings.font_size = 12
	crit_label.label_settings.font_color = Color(0.75, 0.75, 0.8, 1.0)
	crit_label.label_settings.outline_size = 2
	crit_label.label_settings.outline_color = Color.BLACK
	crit_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	crit_label.text = "CRIT"
	crit_box.add_child(crit_label)
	
	crit_val = Label.new()
	crit_val.label_settings = LabelSettings.new()
	crit_val.label_settings.font = font_body_en
	crit_val.label_settings.font_size = 13
	crit_val.label_settings.font_color = Color(0.9, 0.92, 0.95, 1.0)
	crit_val.label_settings.outline_size = 2
	crit_val.label_settings.outline_color = Color.BLACK
	crit_val.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	crit_box.add_child(crit_val)
	
	# Lock Badge (replaces archetype_panel in header_row when locked)
	lock_badge = PanelContainer.new()
	lock_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lock_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var lock_style = StyleBoxFlat.new()
	lock_style.bg_color = Color(0.8, 0.2, 0.2, 0.15)
	lock_style.border_color = Color(0.9, 0.3, 0.3, 0.7)
	lock_style.border_width_left = 1
	lock_style.border_width_top = 1
	lock_style.border_width_right = 1
	lock_style.border_width_bottom = 1
	lock_style.set_corner_radius_all(6)
	lock_style.content_margin_left = 10.0
	lock_style.content_margin_right = 10.0
	lock_style.content_margin_top = 4.0
	lock_style.content_margin_bottom = 4.0
	lock_badge.add_theme_stylebox_override("panel", lock_style)
	header_row.add_child(lock_badge)
	
	lock_badge_label = Label.new()
	lock_badge_label.label_settings = LabelSettings.new()
	lock_badge_label.label_settings.font = font_body_en
	lock_badge_label.label_settings.font_size = 12
	lock_badge_label.label_settings.font_color = Color(1.0, 0.4, 0.4, 1.0)
	lock_badge_label.label_settings.outline_size = 2
	lock_badge_label.label_settings.outline_color = Color.BLACK
	lock_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lock_badge.add_child(lock_badge_label)
	
	# Lock Requirement Label (replaces stats_row below divider when locked)
	lock_req_label = Label.new()
	lock_req_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lock_req_label.label_settings = LabelSettings.new()
	lock_req_label.label_settings.font = font_body_en
	lock_req_label.label_settings.font_size = 13
	lock_req_label.label_settings.font_color = Color(0.95, 0.78, 0.78, 1.0)
	lock_req_label.label_settings.outline_size = 2
	lock_req_label.label_settings.outline_color = Color.BLACK
	lock_req_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lock_req_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lock_req_label)
	
	text_panel.hide()

	# Synthesised weapon-switch whoosh — frequency sweep from 800→200Hz over 80ms
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 22050.0
	gen.buffer_length = 0.15
	whoosh_player = AudioStreamPlayer.new()
	whoosh_player.stream = gen
	whoosh_player.bus = "SFX_UI"
	whoosh_player.volume_db = -14.0
	add_child(whoosh_player)

func _input(event: InputEvent) -> void:
	if not active: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_index >= 0 and selected_index < weapons.size():
			var w_id = weapons[selected_index]
			var w_cfg = GameState.WEAPONS[w_id]
			var is_locked = false
			if w_cfg.has("unlock_achievement"):
				is_locked = not (w_cfg.unlock_achievement in GameState.unlocked_achievements)
			else:
				var prog = GameState.current_wave if GameState.is_survival_mode else GameState.level
				is_locked = prog < w_cfg.unlock_level
				
			if not is_locked:
				close()
				get_viewport().set_input_as_handled()

func _adjust_gun_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var count = node.get_surface_override_material_count()
		if count == 0 and node.mesh:
			count = node.mesh.get_surface_count()
		for i in range(count):
			var mat = node.get_surface_override_material(i)
			if not mat and node.mesh:
				mat = node.mesh.surface_get_material(i)
			if mat is StandardMaterial3D:
				var new_mat = mat.duplicate() as StandardMaterial3D
				if GameState.high_score >= 50000:
					new_mat.albedo_color = Color(1.0, 0.85, 0.1) # Solid Gold!
					new_mat.metallic = 0.8
					new_mat.roughness = 0.2
				elif new_mat.metallic > 0.1:
					new_mat.metallic = 0.0
				node.set_surface_override_material(i, new_mat)
	for child in node.get_children():
		_adjust_gun_materials(child)

func open() -> void:
	if active: return
	active = true
	show()
	Engine.time_scale = 0.2
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_viewport().warp_mouse(get_viewport_rect().size / 2.0)
	
	pivot_offset = size / 2.0
	arrow_anim = 0.0
	target_arrow_anim = 0.0
	selected_index = -1
	
	if open_tween: open_tween.kill()
	
	# Ensure bg_dim draws behind the wheel regardless of child order changes
	if bg_dim and bg_dim.get_parent():
		var parent = bg_dim.get_parent()
		parent.move_child(bg_dim, parent.get_child_count() - 1)
		parent.move_child(self, parent.get_child_count() - 1)
		bg_dim.visible = true
	
	open_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	var open_dur = 0.1 if "bird_watcher" in GameState.unlocked_achievements else 0.2
	open_tween.tween_property(self, "modulate:a", 1.0, open_dur)
	open_tween.tween_property(self, "scale", Vector2(1.0, 1.0), open_dur)
	if bg_dim and bg_dim.material:
		open_tween.tween_property(bg_dim.material, "shader_parameter/blur_amount", 2.5, open_dur)
		open_tween.tween_property(bg_dim.material, "shader_parameter/dim_amount", 0.5, open_dur)

func close_immediate() -> void:
	active = false
	modulate.a = 0.0
	hide()
	if open_tween: open_tween.kill()
	if is_instance_valid(bg_dim):
		bg_dim.visible = false
		if bg_dim.material:
			bg_dim.material.set_shader_parameter("blur_amount", 0.0)
			bg_dim.material.set_shader_parameter("dim_amount", 0.0)

func close() -> void:
	if not active:
		if is_instance_valid(bg_dim):
			bg_dim.visible = false
		return
	active = false
	Engine.time_scale = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	pivot_offset = size / 2.0
	
	if open_tween: open_tween.kill()
	open_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	var close_dur = 0.075 if "bird_watcher" in GameState.unlocked_achievements else 0.15
	open_tween.tween_property(self, "modulate:a", 0.0, close_dur)
	open_tween.tween_property(self, "scale", Vector2(0.9, 0.9), close_dur)
	if bg_dim and bg_dim.material:
		open_tween.tween_property(bg_dim.material, "shader_parameter/blur_amount", 0.0, close_dur)
		open_tween.tween_property(bg_dim.material, "shader_parameter/dim_amount", 0.0, close_dur)
	open_tween.chain().tween_callback(func():
		if is_instance_valid(bg_dim):
			bg_dim.visible = false
	)
	
	if selected_index >= 0 and selected_index < weapons.size():
		var chosen = weapons[selected_index]
		var w_cfg = GameState.WEAPONS[chosen]
		var is_locked = false
		if w_cfg.has("unlock_achievement"):
			is_locked = not (w_cfg.unlock_achievement in GameState.unlocked_achievements)
		else:
			var prog = GameState.current_wave if GameState.is_survival_mode else GameState.level
			is_locked = prog < w_cfg.unlock_level
			
		if not is_locked:
			_play_whoosh()
			open_tween.chain().tween_callback(func():
				hide()
				weapon_selected.emit(chosen)
			)
		else:
			open_tween.chain().tween_callback(hide)
	else:
		open_tween.chain().tween_callback(hide)

func _play_whoosh() -> void:
	if not whoosh_player: return
	if not whoosh_player.playing:
		whoosh_player.play()
	var pb = whoosh_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if not pb: return
	var frames = 1764  # ~80ms at 22050Hz
	for i in range(frames):
		var t = float(i) / 22050.0
		var freq = lerp(800.0, 200.0, float(i) / float(frames))
		var envelope = pow(1.0 - float(i) / float(frames), 0.5)
		pb.push_frame(Vector2.ONE * sin(TAU * freq * t) * 0.3 * envelope)

func _process(delta: float) -> void:
	if not active: return
	
	var center = size / 2.0
	var diff = Vector2.ZERO
	
	var aim_dir = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_dir.length() < 0.2:
		aim_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
	if aim_dir.length() > 0.2:
		diff = aim_dir * 100.0
	else:
		var mouse_pos = get_local_mouse_position()
		diff = mouse_pos - center
	
	# Determine selection
	var slice_size = TAU / weapons.size()
	var prev_selected = selected_index
	
	if diff.length() > 40.0 and diff.length() <= 260.0:
		var angle = diff.angle()
		if angle < 0: angle += TAU
		var offset = PI/2 + slice_size/2
		var adjusted_angle = fmod(angle + offset, TAU)
		selected_index = int(adjusted_angle / slice_size)
		target_arrow_angle = selected_index * slice_size - PI/2
		target_arrow_anim = 1.0
		
		var w_cfg = GameState.WEAPONS[weapons[selected_index]]
		if w_cfg.has("unlock_achievement"):
			last_hovered_locked = not (w_cfg.unlock_achievement in GameState.unlocked_achievements)
		else:
			var prog = GameState.current_wave if GameState.is_survival_mode else GameState.level
			last_hovered_locked = prog < w_cfg.unlock_level
	else:
		selected_index = -1
		target_arrow_anim = 0.0
		
	if selected_index != prev_selected and selected_index != -1:
		UIJuice.play_tick()
		
	var actual_delta = clampf(delta / maxf(Engine.time_scale, 0.01), 0.001, 0.05)
	arrow_angle = lerp_angle(arrow_angle, target_arrow_angle, 14.0 * actual_delta)
	arrow_anim = lerp(arrow_anim, target_arrow_anim, 14.0 * actual_delta)
		
	# Update positions of 3D viewports and rotate models
	var radius = 170.0 # Midpoint between inner(100) and outer(240) radius
	slice_size = TAU / weapons.size()
	for i in range(weapons.size()):
		var mid_angle = i * slice_size - PI/2
		var is_selected = (i == selected_index)
		
		var w_id = weapons[i]
		var w_cfg = GameState.WEAPONS[w_id]
		var is_locked = false
		
		if w_cfg.has("unlock_achievement"):
			is_locked = not (w_cfg.unlock_achievement in GameState.unlocked_achievements)
		else:
			var prog = GameState.current_wave if GameState.is_survival_mode else GameState.level
			is_locked = prog < w_cfg.unlock_level
		
		# Rotate model
		if models[i]:
			models[i].rotation.y -= 1.5 * actual_delta * (2.5 if (is_selected and not is_locked) else 1.0)
		
		# Position container
		var c = containers[i]
		var c_size = c.custom_minimum_size
		var target_pos = center + Vector2(cos(mid_angle), sin(mid_angle)) * radius - (c_size / 2.0)
		
		if is_locked:
			c.modulate = Color(0.1, 0.1, 0.1, 0.8) # Grey out model viewport completely
			c.scale = c.scale.lerp(Vector2(1.0, 1.0), 10.0 * actual_delta)
		elif is_selected:
			c.scale = c.scale.lerp(Vector2(1.2, 1.2), 15.0 * actual_delta)
			c.modulate = Color.WHITE
		else:
			c.scale = c.scale.lerp(Vector2(1.0, 1.0), 10.0 * actual_delta)
			c.modulate = Color.WHITE
			
		c.position = target_pos
		
	if selected_index >= 0:
		_update_info_panel(selected_index)
	else:
		text_panel.hide()
		
	queue_redraw()

func _update_info_panel(idx: int) -> void:
	if idx < 0 or idx >= weapons.size():
		text_panel.hide()
		return
		
	text_panel.show()
	var w_id = weapons[idx]
	var w_cfg = GameState.WEAPONS[w_id]
	var is_kr = GameState.language == "KR"
	
	# Kenney Future for gun name (EN) / Galmuri11 (KR)
	var font_header = font_kr if is_kr else font_header_en
	# Inter for body text (EN) / Galmuri11 (KR)
	var font_body = font_kr if is_kr else font_body_en
	
	name_label.label_settings.font = font_header
	name_label.label_settings.font_size = 22 if is_kr else 22
	
	archetype_label.label_settings.font = font_body
	archetype_label.label_settings.font_size = 12 if is_kr else 12
	
	pwr_label.label_settings.font = font_body
	pwr_val.label_settings.font = font_body
	cap_label.label_settings.font = font_body
	cap_val.label_settings.font = font_body
	crit_label.label_settings.font = font_body
	crit_val.label_settings.font = font_body
	
	lock_badge_label.label_settings.font = font_body
	lock_req_label.label_settings.font = font_body
	
	var is_locked = false
	if w_cfg.has("unlock_achievement"):
		is_locked = not (w_cfg.unlock_achievement in GameState.unlocked_achievements)
	else:
		var prog = GameState.current_wave if GameState.is_survival_mode else GameState.level
		is_locked = prog < w_cfg.unlock_level
	
	var w_name = w_cfg.name.to_upper()
	if is_kr:
		match w_id:
			"standard": w_name = "표준 블래스터"
			"heavy": w_name = "헤비 캐논"
			"precision": w_name = "정밀 스트림"
			"scatter": w_name = "스캐터 노즐"
			"tidal": w_name = "타이달 개틀링"
	name_label.text = w_name
	
	if is_locked:
		panel_style.border_color = Color(0.42, 0.44, 0.48, 0.85)
		divider_style.color = Color(0.5, 0.52, 0.6, 0.25)
		name_label.label_settings.font_color = Color(0.65, 0.65, 0.7, 1.0)
		archetype_panel.hide()
		lock_badge.show()
		stats_row.hide()
		lock_req_label.show()
		
		lock_badge_label.text = "[ 잠김 ]" if is_kr else "[ LOCKED ]"
		if w_cfg.has("unlock_achievement"):
			var ach_id = w_cfg.unlock_achievement
			var ach_desc = GameState.ACHIEVEMENTS[ach_id].desc_kr if is_kr else GameState.ACHIEVEMENTS[ach_id].desc_en
			if is_kr:
				lock_req_label.text = "조건: %s" % ach_desc
			else:
				lock_req_label.text = "UNLOCK: %s" % ach_desc.to_upper()
		else:
			if GameState.is_survival_mode:
				if is_kr:
					lock_req_label.text = "웨이브 %d 에서 잠금 해제됨" % w_cfg.unlock_level
				else:
					lock_req_label.text = "UNLOCKS AT WAVE %d" % w_cfg.unlock_level
			else:
				if is_kr:
					lock_req_label.text = "레벨 %d 에서 잠금 해제됨" % w_cfg.unlock_level
				else:
					lock_req_label.text = "UNLOCKS AT LEVEL %d" % w_cfg.unlock_level
	else:
		panel_style.border_color = Color(1.0, 0.86, 0.24, 0.95)
		divider_style.color = Color(1.0, 0.85, 0.2, 0.28)
		name_label.label_settings.font_color = Color(1.0, 0.96, 0.6, 1.0)
		archetype_panel.show()
		lock_badge.hide()
		stats_row.show()
		lock_req_label.hide()
		
		var arch_dict = ARCHETYPES_KR if is_kr else ARCHETYPES_EN
		archetype_label.text = arch_dict.get(w_id, "BALANCED")
		
		pwr_label.text = "파워" if is_kr else "PWR"
		cap_label.text = "용량" if is_kr else "CAP"
		crit_label.text = "치명타" if is_kr else "CRIT"
		
		pwr_bar.value = w_cfg.cooling_power
		pwr_val.text = str(int(w_cfg.cooling_power))
		
		cap_bar.value = w_cfg.water_capacity
		cap_val.text = str(int(w_cfg.water_capacity))
		
		crit_val.text = "%.1fx" % w_cfg.crit_multiplier
		if w_cfg.crit_multiplier >= 4.0:
			crit_val.label_settings.font_color = Color(0.65, 1.0, 0.35, 1.0)
		elif w_cfg.crit_multiplier >= 2.0:
			crit_val.label_settings.font_color = Color(1.0, 0.88, 0.35, 1.0)
		else:
			crit_val.label_settings.font_color = Color(0.9, 0.92, 0.95, 1.0)
	
	text_panel.reset_size()
	var center = size / 2.0
	text_panel.position = Vector2(center.x - text_panel.size.x / 2.0, center.y + 246.0)
		
	queue_redraw()

func _draw() -> void:
	var center = size / 2.0
	
	var inner_radius = 100.0
	var outer_radius = 240.0
	var slice_size = TAU / weapons.size()
	var gap_width = 12.0 # Even, consistent linear spacing in pixels between slices
	var pad_outer = asin((gap_width / 2.0) / outer_radius)
	var pad_inner = asin((gap_width / 2.0) / inner_radius)
	
	for i in range(weapons.size()):
		var base_start = i * slice_size - PI/2 - slice_size/2
		var base_end = base_start + slice_size
		var start_outer = base_start + pad_outer
		var end_outer = base_end - pad_outer
		var start_inner = base_start + pad_inner
		var end_inner = base_end - pad_inner
		var is_selected = (i == selected_index)
		
		var w_id = weapons[i]
		var w_cfg = GameState.WEAPONS[w_id]
		var is_locked = false
		if w_cfg.has("unlock_achievement"):
			is_locked = not (w_cfg.unlock_achievement in GameState.unlocked_achievements)
		else:
			var prog = GameState.current_wave if GameState.is_survival_mode else GameState.level
			is_locked = prog < w_cfg.unlock_level
		
		# Yellow Colors
		var fill_color = Color(0.2, 0.18, 0.08, 0.6)
		var stroke_color = Color(0.4, 0.35, 0.2, 0.8)
		
		if is_locked:
			fill_color = Color(0.1, 0.1, 0.1, 0.6) # Flat grey for locked
			stroke_color = Color(0.3, 0.3, 0.3, 0.8)
		elif is_selected:
			fill_color = Color(0.8, 0.7, 0.1, 0.5)
			stroke_color = Color(1.0, 0.9, 0.3, 1.0)
		
		# Draw thick arc (donut slice)
		var points = PackedVector2Array()
		var segments = 24
		
		var cur_outer = outer_radius
		for j in range(segments + 1):
			var a = lerp(start_outer, end_outer, j / float(segments))
			points.push_back(center + Vector2(cos(a), sin(a)) * cur_outer)
			
		for j in range(segments + 1):
			var a = lerp(end_inner, start_inner, j / float(segments))
			points.push_back(center + Vector2(cos(a), sin(a)) * inner_radius)
			
		# Subtle Z-depth drop shadow matching HUD panels
		var shadow_points = PackedVector2Array()
		for pt in points:
			shadow_points.push_back(pt + Vector2(0, 4.0))
		draw_colored_polygon(shadow_points, Color(0.0, 0.0, 0.0, 0.35 if not is_selected else 0.45))
		
		draw_colored_polygon(points, fill_color)
		points.push_back(points[0]) # close line
		draw_polyline(points, stroke_color, 4.0 if is_selected else 2.0, true)
		
	# Draw neutral dot fading and shrinking into emerging arrow
	var t = arrow_anim
	var dot_progress = clampf(1.0 - t * 1.6, 0.0, 1.0)
	if dot_progress > 0.01:
		var dot_radius = 4.5 * dot_progress
		draw_circle(center + Vector2(0, 2.0), dot_radius, Color(0.0, 0.0, 0.0, 0.3 * dot_progress))
		draw_circle(center, dot_radius, Color(1.0, 0.85, 0.2, 0.9 * dot_progress))
		draw_arc(center, dot_radius, 0, TAU, 16, Color(0.3, 0.25, 0.1, 0.5 * dot_progress), 1.0)
		
	# Draw sleek arrowhead smoothly scaling and extending from center dot
	if t > 0.01:
		# Base chevron arrowhead pointing Right (0 radians) scaled by t
		var p_tip = Vector2(24.0, 0.0) * t
		var p_top = Vector2(-12.0, -12.0) * t
		var p_inner = Vector2(-4.0, 0.0) * t
		var p_bot = Vector2(-12.0, 12.0) * t
		
		var arrow_alpha = clampf(t * 1.5, 0.0, 1.0)
		
		# Subtle needle shadow (scales and moves with needle)
		var shadow_transform = Transform2D(arrow_angle, center + Vector2(0, 2.5 * t))
		var shadow_arrow_poly = PackedVector2Array([
			shadow_transform * p_tip,
			shadow_transform * p_top,
			shadow_transform * p_inner,
			shadow_transform * p_bot
		])
		draw_colored_polygon(shadow_arrow_poly, Color(0.0, 0.0, 0.0, 0.35 * arrow_alpha))
		
		var rot_transform = Transform2D(arrow_angle, center)
		var arrow_poly = PackedVector2Array([
			rot_transform * p_tip,
			rot_transform * p_top,
			rot_transform * p_inner,
			rot_transform * p_bot
		])
		
		var is_locked = last_hovered_locked
		if selected_index != -1:
			var w_cfg = GameState.WEAPONS[weapons[selected_index]]
			if w_cfg.has("unlock_achievement"):
				is_locked = not (w_cfg.unlock_achievement in GameState.unlocked_achievements)
			else:
				var prog = GameState.current_wave if GameState.is_survival_mode else GameState.level
				is_locked = prog < w_cfg.unlock_level
			last_hovered_locked = is_locked
		
		var arr_fill = Color(0.8, 0.7, 0.1, 0.8 * arrow_alpha)
		var arr_stroke = Color(1.0, 0.9, 0.3, 1.0 * arrow_alpha)
		if is_locked:
			arr_fill = Color(0.3, 0.3, 0.3, 0.8 * arrow_alpha)
			arr_stroke = Color(0.5, 0.5, 0.5, 1.0 * arrow_alpha)
		
		var line_width = 4.0 * clampf(t * 1.2, 0.25, 1.0)
		
		# Draw the solid fill
		draw_colored_polygon(arrow_poly, arr_fill)
		
		# Draw stroke outline
		var line_poly = arrow_poly.duplicate()
		line_poly.push_back(line_poly[0])
		draw_polyline(line_poly, arr_stroke, line_width, true)
