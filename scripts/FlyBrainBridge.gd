extends Node

# ==============================================================================
# FlyBrainBridge (MaleCNS v1.0 Continuous Learning Auto-Pilot for Summer Nights)
# 
# Connects Summer Nights to the biological MaleCNS fruit fly brain model over UDP.
# Features:
# - Continuous Training Loop: Auto-starts rounds and auto-retries on game over!
# - Auto-advances through wave drafting perks hands-free!
# - Checkpointing: Preserves learned synaptic connections across sessions.
# - Toggle ON/OFF anytime during gameplay with F9.
# - Zero modifications to Main.gd or existing gameplay files.
# ==============================================================================

var udp: PacketPeerUDP
var server_host: String = "127.0.0.1"
var server_port: int = 9999

var is_brain_active: bool = false
var hud_canvas: CanvasLayer = null
var hud_label: Label = null
var dopamine_level: float = 0.0
var active_neurons: int = 0
var last_temp: float = 100.0

var is_restarting: bool = false
var is_drafting_pending: bool = false
var round_episode: int = 1
var accuracy_pct: int = 0

var prefer_endless_mode: bool = true
var is_title_starting: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	udp = PacketPeerUDP.new()
	udp.set_dest_address(server_host, server_port)
	_setup_hud_overlay()

func _setup_hud_overlay() -> void:
	hud_canvas = CanvasLayer.new()
	hud_canvas.layer = 128 # Always on top
	add_child(hud_canvas)
	
	hud_label = Label.new()
	hud_label.position = Vector2(24, 20)
	hud_label.visible = false
	hud_label.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))
	hud_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	hud_label.add_theme_constant_override("shadow_offset_x", 1)
	hud_label.add_theme_constant_override("shadow_offset_y", 1)
	hud_label.text = "🧠 MALE CNS FLY BRAIN: READY [Press F9 to Toggle]"
	hud_canvas.add_child(hud_label)

func _input(event: InputEvent) -> void:
	if not is_brain_active:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			# Prevent Escape from freezing the game while Fly Brain is training!
			# Remind user their mouse is already unlocked to interact with the dashboard.
			get_viewport().set_input_as_handled()
			if hud_label:
				hud_label.visible = true
				hud_label.text = "🧠 FLY BRAIN: MOUSE IS UNLOCKED • SWITCH TO BROWSER ANYTIME (F9 to Stop AI)"
				hud_label.modulate = Color(0.3, 0.9, 1.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F8:
			prefer_endless_mode = !prefer_endless_mode
			if hud_label:
				hud_label.visible = true
				var mode_str = "ENDLESS ROGUE-LITE" if prefer_endless_mode else "CAMPAIGN (LVLS 1-5)"
				hud_label.text = "🧠 TARGET MODE: %s [F8 to Switch • F9 to Play]" % mode_str
				hud_label.modulate = Color(1.0, 0.7, 0.2)

		elif event.keycode == KEY_F9:
			is_brain_active = !is_brain_active
			var main = get_tree().current_scene
			var hud = main.get("hud") if (main and is_instance_valid(main)) else null
			
			if is_brain_active:
				# 1. Unlock mouse so user can freely click browser without pressing Escape!
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				if hud and is_instance_valid(hud):
					hud.set("_ignore_focus_out_until", Time.get_ticks_msec() + 86400000)
				
				if hud_label:
					hud_label.visible = true
					var mode_str = "ENDLESS" if prefer_endless_mode else "CAMPAIGN"
					hud_label.text = "🧠 MALE CNS FLY BRAIN: ACTIVE [%s • F8: Mode • F9: Stop • F11: Windowed]" % mode_str
					hud_label.modulate = Color(0.4, 1.0, 0.5)
					
				# Auto-start if currently on Title Screen!
				if main and is_instance_valid(main) and main.get("is_title_screen") == true:
					_start_title_game(main)
			else:
				# Restore normal player controls, mouse capture, and pause behavior
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				if hud and is_instance_valid(hud):
					hud.set("_ignore_focus_out_until", 0)
					
				if hud_label:
					hud_label.visible = true
					hud_label.text = "🧠 MALE CNS FLY BRAIN: DISABLED (Manual Control Restored)"
					hud_label.modulate = Color(0.8, 0.8, 0.8)
					
				if main and is_instance_valid(main):
					main.set("is_shooting", false)
				get_tree().create_timer(1.8).timeout.connect(func():
					if not is_brain_active and hud_label:
						hud_label.visible = false
				)

		elif event.keycode == KEY_F11:
			var mode = DisplayServer.window_get_mode()
			if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _start_title_game(main: Node) -> void:
	if is_title_starting:
		return
	is_title_starting = true
	
	var mode_name = "ENDLESS MODE" if prefer_endless_mode else "CAMPAIGN LVL 1"
	if hud_label:
		hud_label.visible = true
		hud_label.text = "🧠 MALE CNS FLY BRAIN: STARTING %s..." % mode_name
		hud_label.modulate = Color(0.4, 1.0, 0.5)

	# Ensure GameState is pre-configured for target mode with normal gun
	GameState.reset()
	GameState.is_survival_mode = prefer_endless_mode
	GameState.current_weapon_id = "standard"
	if prefer_endless_mode:
		GameState.current_wave = 1
		main.set("heat_regen_base", 2.5)
		main.set("level_timer", 60.0)
		main.set("wave_timer", 0.0)
	else:
		GameState.level = 1

	var ts = main.get("title_screen_ui")
	if ts and is_instance_valid(ts):
		# Enable Endless button on Title Screen UI if needed
		var btn = ts.get_node_or_null("ColorRect/VBoxContainer/ButtonsBox/SurvivalBtn")
		if btn and is_instance_valid(btn):
			btn.disabled = false
			btn.text = "ENDLESS MODE"
			
		if prefer_endless_mode and ts.has_method("_on_survival_pressed"):
			ts.call("_on_survival_pressed")
			return
		elif not prefer_endless_mode and ts.has_method("_on_normal_pressed"):
			ts.call("_on_normal_pressed")
			return

	# Fallback if title_screen_ui is missing
	if main.has_method("_on_title_start_game"):
		main.call("_on_title_start_game", prefer_endless_mode)

func _process(delta: float) -> void:
	if not is_brain_active:
		return
		
	var main = get_tree().current_scene
	if not main or not is_instance_valid(main):
		return

	# Keep mouse unlocked & suppress focus-out auto-pause while Fly Brain is active
	var hud_ref = main.get("hud")
	if hud_ref and is_instance_valid(hud_ref):
		hud_ref.set("_ignore_focus_out_until", Time.get_ticks_msec() + 86400000)
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	# 1. If on Title Screen, start the game cleanly once
	if main.get("is_title_screen") == true:
		_start_title_game(main)
		return
	else:
		is_title_starting = false
		
	# 2. Auto-Select Perk on Drafting Screen (Wave Progression Perks)
	var hud = main.get("hud")
	if hud and is_instance_valid(hud):
		var ds = hud.get("drafting_screen")
		if ds and is_instance_valid(ds) and ds.visible:
			if not is_drafting_pending:
				is_drafting_pending = true
				if hud_label:
					hud_label.text = "🧠 FLY BRAIN: SELECTING WAVE PERK & RESUMING NEXT WAVE..."
					hud_label.modulate = Color(0.3, 0.9, 1.0)
				get_tree().create_timer(0.6, true, false, true).timeout.connect(func():
					is_drafting_pending = false
					if ds and is_instance_valid(ds) and ds.visible:
						var card_box = ds.get("card_container")
						if card_box and is_instance_valid(card_box) and card_box.get_child_count() > 0:
							var btn = card_box.get_child(0)
							if btn and is_instance_valid(btn):
								btn.emit_signal("pressed")
								return
						if ds.has_method("_on_perk_selected"):
							ds.call("_on_perk_selected", "cooling_boost")
						elif ds.has_signal("perk_selected"):
							ds.perk_selected.emit("cooling_boost")
				)
			return

	# 3. Unpause / dismiss lingering transition overlay if paused between waves
	if get_tree().paused and (not hud or not hud.get("drafting_screen") or not hud.drafting_screen.visible):
		get_tree().paused = false

	# 4. Continuous Auto-Restart Loop on TRUE Game Over (Defeat)
	var is_defeat = bool(main.get("defeat_triggered"))
	if not is_defeat and hud and is_instance_valid(hud):
		var ls = hud.get("lose_screen")
		if ls and is_instance_valid(ls) and ls.visible:
			is_defeat = true
	if not is_defeat and float(main.get("level_timer")) <= 0.0 and bool(main.get("game_over")):
		is_defeat = true

	if is_defeat:
		if not is_restarting:
			is_restarting = true
			if hud_label:
				hud_label.text = "🧠 FLY BRAIN: ROUND COMPLETE • SAVING & RESTARTING NEXT ROUND..."
				hud_label.modulate = Color(1.0, 0.8, 0.2)
			get_tree().create_timer(2.2, true, false, true).timeout.connect(func():
				is_restarting = false
				if is_brain_active:
					GameState.is_retrying = true
					if prefer_endless_mode:
						GameState.is_survival_mode = true
					get_tree().reload_current_scene()
			)
		return

	var sun = main.get("sun")
	var camera = main.get("camera")
	if not sun or not camera or not is_instance_valid(sun) or not is_instance_valid(camera):
		return
		
	var vp = get_viewport()
	if not vp:
		return
	var vp_size = vp.get_visible_rect().size
	if vp_size.x <= 0 or vp_size.y <= 0:
		return
		
	var sun_screen_pos = camera.unproject_position(sun.global_position)
	var is_behind = camera.is_position_behind(sun.global_position)
	var v_mouse = main.get("virtual_mouse_pos")
	if v_mouse == null:
		return
		
	# Normalized directional error from crosshair to Sun [-1.0, 1.0]
	var sun_dx = clampf((sun_screen_pos.x - v_mouse.x) / (vp_size.x * 0.5), -1.0, 1.0)
	var sun_dy = clampf((sun_screen_pos.y - v_mouse.y) / (vp_size.y * 0.5), -1.0, 1.0)
	if is_behind:
		sun_dx = -1.0 if sun_dx >= 0 else 1.0
	
	# Normalized screen coordinates [-1.0, 1.0]
	var crosshair_x = clampf((v_mouse.x - vp_size.x * 0.5) / (vp_size.x * 0.5), -1.0, 1.0)
	var crosshair_y = clampf((v_mouse.y - vp_size.y * 0.5) / (vp_size.y * 0.5), -1.0, 1.0)
	var sun_x = clampf((sun_screen_pos.x - vp_size.x * 0.5) / (vp_size.x * 0.5), -1.0, 1.0)
	var sun_y = clampf((sun_screen_pos.y - vp_size.y * 0.5) / (vp_size.y * 0.5), -1.0, 1.0)
	
	var temp = float(main.get("temperature"))
	var water = float(main.get("water_tank"))
	var is_crit = bool(main.get("is_heat_critical"))
	var is_firing = bool(main.get("is_firing"))
	
	# Hit registered if we cooled the Sun
	var hit_registered = (temp < last_temp - 0.05) or (is_firing and abs(sun_dx) < 0.22 and abs(sun_dy) < 0.22)
	last_temp = temp
	
	# ── v2.0: Mirage position telemetry ──────────────────────────────
	var mirage_positions: Array = []
	var mirage_arr = main.get("active_mirages")
	var hit_mirage_flag: bool = false
	if mirage_arr != null and mirage_arr.size() > 0:
		for m in mirage_arr:
			var node = m["node"] as Node3D
			if is_instance_valid(node) and not camera.is_position_behind(node.global_position):
				var m_screen = camera.unproject_position(node.global_position)
				# Normalized offset from crosshair [-1, 1]
				var m_x = clampf((m_screen.x - v_mouse.x) / (vp_size.x * 0.5), -1.0, 1.0)
				var m_y = clampf((m_screen.y - v_mouse.y) / (vp_size.y * 0.5), -1.0, 1.0)
				mirage_positions.append({"x": m_x, "y": m_y})
		# Check if we're hitting a mirage (closer to crosshair than the sun)
		if is_firing and mirage_positions.size() > 0:
			var sun_dist_2d = Vector2(sun_dx, sun_dy).length()
			for mp in mirage_positions:
				var m_dist = Vector2(mp["x"], mp["y"]).length()
				if m_dist < sun_dist_2d and m_dist < 0.3:
					hit_mirage_flag = true
					break
	
	var is_sun_frozen_val = bool(main.get("is_sun_frozen")) if main.get("is_sun_frozen") != null else false
	
	# Telemetry packet to Python connectome agent
	var payload = {
		"sun_dx": sun_dx,
		"sun_dy": sun_dy,
		"crosshair_x": crosshair_x,
		"crosshair_y": crosshair_y,
		"sun_x": sun_x,
		"sun_y": sun_y,
		"temperature": temp,
		"water": water,
		"is_critical": is_crit,
		"hit_registered": hit_registered,
		"damage_taken": false,
		"round_completed": false,
		"level": int(GameState.level),
		"wave": int(GameState.current_wave),
		"is_survival": bool(GameState.is_survival_mode),
		"active_mirages": int(mirage_arr.size()) if mirage_arr != null else 0,
		"active_flares": int(main.get("active_flares").size()) if main.get("active_flares") != null else 0,
		"current_weapon": str(GameState.current_weapon_id),
		# v2.0 telemetry
		"mirage_positions": mirage_positions,
		"mirage_count": mirage_positions.size(),
		"ice_charges": int(GameState.ice_charges_remaining),
		"hit_mirage": hit_mirage_flag,
		"is_sun_frozen": is_sun_frozen_val
	}
	
	var json_bytes = JSON.stringify(payload).to_utf8_buffer()
	udp.put_packet(json_bytes)
	
	# Process motor response from Python
	while udp.get_available_packet_count() > 0:
		var pkt = udp.get_packet()
		if pkt.size() > 0:
			var resp_str = pkt.get_string_from_utf8()
			var parse_res = JSON.parse_string(resp_str)
			if parse_res is Dictionary:
				_apply_brain_action(main, parse_res, delta, vp_size)

func _apply_brain_action(main: Node, action: Dictionary, delta: float, vp_size: Vector2) -> void:
	var aim_x = float(action.get("aim_x", 0.0))
	var aim_y = float(action.get("aim_y", 0.0))
	var should_shoot = bool(action.get("shoot", false))
	var should_ice = bool(action.get("ice_blast", false))
	dopamine_level = float(action.get("dopamine", 0.0))
	active_neurons = int(action.get("active_neurons", 0))
	round_episode = int(action.get("episode", 1))
	accuracy_pct = int(action.get("accuracy_pct", 0))
	var is_saved = bool(action.get("checkpoint_saved", false))
	
	# Normal Gun (Standard Blaster) - Keep consistent weapon for training
	if GameState.current_weapon_id != "standard":
		GameState.current_weapon_id = "standard"
		if main.has_method("_on_weapon_changed"):
			main.call("_on_weapon_changed", "standard")
	
	# Update HUD telemetry with continuous learning stats
	if hud_label and is_brain_active:
		var da_str = ("+%.2f" % dopamine_level) if dopamine_level >= 0 else ("%.2f" % dopamine_level)
		var da_tag = "PAM" if dopamine_level >= 0 else "PPL1"
		var save_tag = " [💾 SAVED]" if is_saved else ""
		var state_tag = "💧 COOLING SUN" if should_shoot else "🎯 TRACKING"
		var w_name = GameState.current_weapon_id.capitalize()
		hud_label.text = "🧠 FLY BRAIN [ROUND %d] %s • %s • ACC: %d%% • DA: %s %s%s" % [round_episode, state_tag, w_name, accuracy_pct, da_str, da_tag, save_tag]
		hud_label.modulate = Color(0.3, 1.0, 0.4) if dopamine_level >= 0 else Color(1.0, 0.5, 0.5)
	
	# Apply steering torque to virtual_mouse_pos
	var speed = 900.0
	main.virtual_mouse_pos.x = clampf(main.virtual_mouse_pos.x + aim_x * speed * delta, 0.0, vp_size.x)
	main.virtual_mouse_pos.y = clampf(main.virtual_mouse_pos.y + aim_y * speed * delta, 0.0, vp_size.y)
	
	# Control firing with smart water refill cycling
	var water = float(main.get("water_tank"))
	if water <= 4.0:
		main.set("is_shooting", false) # Release to recharge
	else:
		main.set("is_shooting", should_shoot)
	
	# Ice blast — call the correct function name
	if should_ice and main.has_method("_shoot_ice") and GameState.ice_charges_remaining > 0:
		main.call("_shoot_ice")
