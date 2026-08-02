extends Control

signal weapon_selected(weapon_id: String)

var active: bool = false
var selected_index: int = -1
var weapons: Array = []
var custom_font: Font

var open_tween: Tween
var containers: Array = []
var models: Array = []

var text_panel: PanelContainer
var name_label: Label
var stats_label: Label

var bg_dim: ColorRect
var whoosh_player: AudioStreamPlayer = null

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
	get_parent().call_deferred("add_child", bg_dim)
	get_parent().call_deferred("move_child", bg_dim, get_index())
	
	var is_kr = GameState.language == "KR"
	var font_path = "res://assets/ui/fonts/Galmuri11.ttf" if is_kr else "res://assets/ui/fonts/Fonts/Kenney Future.ttf"
	custom_font = load(font_path)
	
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
		vp.add_child(model)
		models.append(model)
		
	# Setup Text Panel (Kept at the bottom so it doesn't clutter the center)
	text_panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.02, 0.1, 0.85)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_right = 16
	style.corner_radius_bottom_left = 16
	style.expand_margin_left = 16.0
	style.expand_margin_right = 16.0
	style.expand_margin_top = 8.0
	style.expand_margin_bottom = 8.0
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color(1.0, 0.9, 0.3, 1.0) # Matches the yellow wheel selection
	text_panel.add_theme_stylebox_override("panel", style)
	add_child(text_panel)
	
	var vbox = VBoxContainer.new()
	text_panel.add_child(vbox)
	
	name_label = Label.new()
	name_label.label_settings = LabelSettings.new()
	name_label.label_settings.font = custom_font
	name_label.label_settings.font_size = 28
	name_label.label_settings.font_color = Color(1.0, 0.95, 0.5, 1.0)
	name_label.label_settings.outline_size = 4
	name_label.label_settings.outline_color = Color.BLACK
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)
	
	stats_label = Label.new()
	stats_label.label_settings = LabelSettings.new()
	stats_label.label_settings.font = custom_font
	stats_label.label_settings.font_size = 18
	stats_label.label_settings.font_color = Color(1.0, 0.8, 0.2, 1.0)
	stats_label.label_settings.outline_size = 3
	stats_label.label_settings.outline_color = Color.BLACK
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(stats_label)
	
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
			var prog = GameState.current_wave if GameState.is_survival_mode else GameState.level
			if prog >= w_cfg.unlock_level:
				close()
				get_viewport().set_input_as_handled()

func open() -> void:
	if active: return
	active = true
	show()
	Engine.time_scale = 0.2
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_viewport().warp_mouse(get_viewport_rect().size / 2.0)
	
	pivot_offset = size / 2.0
	
	if open_tween: open_tween.kill()
	
	# Ensure bg_dim is always directly behind this wheel in the draw order
	if bg_dim and bg_dim.get_parent():
		bg_dim.get_parent().move_child(bg_dim, get_index())
	
	open_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	open_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	open_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	if bg_dim and bg_dim.material:
		open_tween.tween_property(bg_dim.material, "shader_parameter/blur_amount", 2.5, 0.2)
		open_tween.tween_property(bg_dim.material, "shader_parameter/dim_amount", 0.5, 0.2)

func close() -> void:
	if not active: return
	active = false
	Engine.time_scale = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	pivot_offset = size / 2.0
	
	if open_tween: open_tween.kill()
	open_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	open_tween.tween_property(self, "modulate:a", 0.0, 0.15)
	open_tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.15)
	if bg_dim and bg_dim.material:
		open_tween.tween_property(bg_dim.material, "shader_parameter/blur_amount", 0.0, 0.15)
		open_tween.tween_property(bg_dim.material, "shader_parameter/dim_amount", 0.0, 0.15)
	
	if selected_index >= 0 and selected_index < weapons.size():
		var chosen = weapons[selected_index]
		var w_cfg = GameState.WEAPONS[chosen]
		var prog = GameState.current_wave if GameState.is_survival_mode else GameState.level
		if prog >= w_cfg.unlock_level:
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
	var mouse_pos = get_local_mouse_position()
	var diff = mouse_pos - center
	
	# Determine selection
	if diff.length() > 40.0 and diff.length() <= 260.0:
		var angle = diff.angle()
		if angle < 0: angle += TAU
		var slice_size = TAU / weapons.size()
		var offset = PI/2 + slice_size/2
		var adjusted_angle = fmod(angle + offset, TAU)
		selected_index = int(adjusted_angle / slice_size)
	else:
		selected_index = -1
		
	# Update positions of 3D viewports and rotate models
	var radius = 170.0 # Midpoint between inner(100) and outer(240) radius
	var slice_size = TAU / weapons.size()
	for i in range(weapons.size()):
		var mid_angle = i * slice_size - PI/2
		var is_selected = (i == selected_index)
		
		var w_id = weapons[i]
		var prog = GameState.current_wave if GameState.is_survival_mode else GameState.level
		var is_locked = prog < GameState.WEAPONS[w_id].unlock_level
		
		# Rotate model
		var actual_delta = delta / Engine.time_scale
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
		text_panel.show()
		var w_id = weapons[selected_index]
		var w_cfg = GameState.WEAPONS[w_id]
		var is_kr = GameState.language == "KR"
		
		var prog = GameState.current_wave if GameState.is_survival_mode else GameState.level
		var is_locked = prog < w_cfg.unlock_level
		
		var w_name = w_cfg.name.to_upper()
		if is_kr:
			match w_id:
				"standard": w_name = "표준 블래스터"
				"heavy": w_name = "헤비 캐논"
				"precision": w_name = "정밀 스트림"
		name_label.text = w_name
		
		if is_locked:
			name_label.label_settings.font_color = Color(0.6, 0.6, 0.6, 1.0) # Greyed out name
			stats_label.label_settings.font_color = Color(1.0, 0.3, 0.3, 1.0) # Red warning
			if GameState.is_survival_mode:
				if is_kr:
					stats_label.text = "웨이브 %d 에서 잠금 해제됨" % w_cfg.unlock_level
				else:
					stats_label.text = "UNLOCKS AT WAVE %d" % w_cfg.unlock_level
			else:
				if is_kr:
					stats_label.text = "레벨 %d 에서 잠금 해제됨" % w_cfg.unlock_level
				else:
					stats_label.text = "UNLOCKS AT LEVEL %d" % w_cfg.unlock_level
		else:
			name_label.label_settings.font_color = Color(1.0, 0.95, 0.5, 1.0)
			stats_label.label_settings.font_color = Color(1.0, 0.8, 0.2, 1.0)
			if is_kr:
				stats_label.text = "파워: %d   용량: %d" % [int(w_cfg.cooling_power), int(w_cfg.water_capacity)]
			else:
				stats_label.text = "POWER: %d   CAPACITY: %d" % [int(w_cfg.cooling_power), int(w_cfg.water_capacity)]
		
		text_panel.reset_size()
		text_panel.position = Vector2(center.x - text_panel.size.x / 2.0, center.y + 240.0)
	else:
		text_panel.hide()
		
	queue_redraw()

func _draw() -> void:
	var center = size / 2.0
	
	var inner_radius = 100.0
	var outer_radius = 240.0
	var slice_size = TAU / weapons.size()
	var padding_angle = 0.05
	
	for i in range(weapons.size()):
		var start_angle = i * slice_size - PI/2 - slice_size/2 + padding_angle
		var end_angle = start_angle + slice_size - padding_angle * 2.0
		var is_selected = (i == selected_index)
		
		var w_id = weapons[i]
		var is_locked = GameState.level < GameState.WEAPONS[w_id].unlock_level
		
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
		var segments = 16
		
		var cur_outer = outer_radius
		for j in range(segments + 1):
			var a = lerp(start_angle, end_angle, j / float(segments))
			points.push_back(center + Vector2(cos(a), sin(a)) * cur_outer)
			
		for j in range(segments + 1):
			var a = lerp(end_angle, start_angle, j / float(segments))
			points.push_back(center + Vector2(cos(a), sin(a)) * inner_radius)
			
		draw_colored_polygon(points, fill_color)
		points.push_back(points[0]) # close line
		draw_polyline(points, stroke_color, 4.0 if is_selected else 2.0, true)
		
	# Draw center neutral dot
	if selected_index == -1:
		draw_circle(center, 4.0, Color(0.5, 0.5, 0.4, 0.8))
