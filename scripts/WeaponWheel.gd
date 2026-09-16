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
		_adjust_gun_materials(model)
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
	
	open_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	var open_dur = 0.1 if "bird_watcher" in GameState.unlocked_achievements else 0.2
	open_tween.tween_property(self, "modulate:a", 1.0, open_dur)
	open_tween.tween_property(self, "scale", Vector2(1.0, 1.0), open_dur)
	if bg_dim and bg_dim.material:
		open_tween.tween_property(bg_dim.material, "shader_parameter/blur_amount", 2.5, open_dur)
		open_tween.tween_property(bg_dim.material, "shader_parameter/dim_amount", 0.5, open_dur)

func close() -> void:
	if not active: return
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
		text_panel.show()
		var w_id = weapons[selected_index]
		var w_cfg = GameState.WEAPONS[w_id]
		var is_kr = GameState.language == "KR"
		
		var font_path = "res://assets/fonts/Galmuri11.ttf" if is_kr else "res://assets/ui/fonts/Fonts/Kenney Future.ttf"
		var dyn_font = load(font_path)
		name_label.label_settings.font = dyn_font
		name_label.label_settings.font_size = 32 if is_kr else 28
		stats_label.label_settings.font = dyn_font
		stats_label.label_settings.font_size = 22 if is_kr else 18
		
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
			name_label.label_settings.font_color = Color(0.6, 0.6, 0.6, 1.0) # Greyed out name
			stats_label.label_settings.font_color = Color(1.0, 0.3, 0.3, 1.0) # Red warning
			if w_cfg.has("unlock_achievement"):
				var ach_id = w_cfg.unlock_achievement
				var ach_desc = GameState.ACHIEVEMENTS[ach_id].desc_kr if is_kr else GameState.ACHIEVEMENTS[ach_id].desc_en
				if is_kr:
					stats_label.text = "조건: %s" % ach_desc
				else:
					stats_label.text = "UNLOCK: %s" % ach_desc.to_upper()
			else:
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
		var segments = 16
		
		var cur_outer = outer_radius
		for j in range(segments + 1):
			var a = lerp(start_angle, end_angle, j / float(segments))
			points.push_back(center + Vector2(cos(a), sin(a)) * cur_outer)
			
		for j in range(segments + 1):
			var a = lerp(end_angle, start_angle, j / float(segments))
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
		var r = line_width / 2.0
		
		# 1) Draw the solid fill
		draw_colored_polygon(arrow_poly, arr_fill)
		
		# 2) Draw fill caps (puffs out the fill to meet the stroke caps seamlessly)
		draw_circle(rot_transform * p_tip, r, arr_fill)
		draw_circle(rot_transform * p_top, r, arr_fill)
		draw_circle(rot_transform * p_inner, r, arr_fill)
		draw_circle(rot_transform * p_bot, r, arr_fill)
		
		# 3) Draw thick stroke caps at the vertices for perfectly rounded corners
		draw_circle(rot_transform * p_tip, r, arr_stroke)
		draw_circle(rot_transform * p_top, r, arr_stroke)
		draw_circle(rot_transform * p_inner, r, arr_stroke)
		draw_circle(rot_transform * p_bot, r, arr_stroke)
		
		# 4) Draw thick stroke line to connect the caps
		var line_poly = arrow_poly.duplicate()
		line_poly.push_back(line_poly[0])
		draw_polyline(line_poly, arr_stroke, line_width, true)
		
		# 5) Refill the inner caps to overlay the stroke bleeding inwards at sharp joints!
		draw_circle(rot_transform * p_tip, maxf(r - 1.0, 0.1), arr_fill)
		draw_circle(rot_transform * p_top, maxf(r - 1.0, 0.1), arr_fill)
		draw_circle(rot_transform * p_inner, maxf(r - 1.0, 0.1), arr_fill)
		draw_circle(rot_transform * p_bot, maxf(r - 1.0, 0.1), arr_fill)
