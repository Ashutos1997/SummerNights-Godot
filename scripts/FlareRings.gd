extends Control

var main_scene: Node = null
var _was_drawing: bool = false

func _process(_delta: float) -> void:
	if not main_scene:
		return
	
	var has_charging = false
	for flare in main_scene.active_flares:
		if "charge_timer" in flare and flare["charge_timer"] > 0.0:
			has_charging = true
			break
	
	if has_charging:
		_was_drawing = true
		queue_redraw()
	elif _was_drawing:
		# Force one final empty redraw to clear the canvas
		_was_drawing = false
		queue_redraw()

func _draw() -> void:
	if not main_scene or not main_scene.camera or not main_scene.sun:
		return
	if not _was_drawing:
		return  # Nothing to draw — canvas is clean

	for flare in main_scene.active_flares:
		if "charge_timer" in flare and flare["charge_timer"] > 0.0:
			var c = flare["charge_timer"]
			var max_charge = 0.6
			var raw_ratio = 1.0 - clamp(c / max_charge, 0.0, 1.0)
			# Ease-out cubic for snappy fill that decelerates
			var fill_ratio = 1.0 - pow(1.0 - raw_ratio, 3.0)

			if main_scene.camera.is_position_behind(main_scene.sun.global_position):
				continue

			var center2d = main_scene.camera.unproject_position(main_scene.sun.global_position)

			# Project the actual mesh edge (collision radius 4.5) to screen space
			var sun_scale = main_scene.sun.scale.x
			var mesh_edge = main_scene.sun.global_position + main_scene.camera.global_transform.basis.x * (4.5 * sun_scale)
			var edge2d = main_scene.camera.unproject_position(mesh_edge)
			var mesh_radius = center2d.distance_to(edge2d)
			# Scale up 1.6x to clear bloom/glow, plus fixed gap
			var radius = mesh_radius * 1.6 + 10.0

			# ── Outer glow halo (soft, wide, translucent) ──
			var glow_alpha = 0.08 + 0.12 * fill_ratio
			var glow_color = Color(1.0, 0.5, 0.1, glow_alpha)
			draw_arc(center2d, radius, 0, TAU, 48, glow_color, 14.0, true)

			# ── Background track (dark ring) ──
			var bg_color = Color(0.0, 0.0, 0.0, 0.35)
			draw_arc(center2d, radius, 0, TAU, 48, bg_color, 6.0, true)

			# ── Foreground fill arc ──
			if fill_ratio > 0.0:
				# Color ramp: warm orange → hot yellow-white as it fills
				var fg_color = Color(1.0, 0.55, 0.1).lerp(Color(1.0, 0.9, 0.5), fill_ratio * 0.7)
				fg_color.a = 0.85 + 0.15 * fill_ratio
				var start_angle = -PI / 2.0
				var end_angle = start_angle + (TAU * fill_ratio)
				draw_arc(center2d, radius, start_angle, end_angle, 48, fg_color, 6.0, true)

				# ── Bright leading edge dot ──
				var dot_angle = end_angle
				var dot_pos = center2d + Vector2(cos(dot_angle), sin(dot_angle)) * radius
				var dot_color = Color(1.0, 0.95, 0.7, fg_color.a)
				draw_circle(dot_pos, 5.0, dot_color)

			# ── Tick marks at 12, 3, 6, 9 o'clock ──
			var tick_color = Color(1.0, 0.75, 0.15, 0.3 + 0.2 * fill_ratio)
			for i in 4:
				var angle = -PI / 2.0 + (TAU / 4.0) * i
				var inner_pt = center2d + Vector2(cos(angle), sin(angle)) * (radius - 4.0)
				var outer_pt = center2d + Vector2(cos(angle), sin(angle)) * (radius + 4.0)
				draw_line(inner_pt, outer_pt, tick_color, 2.0, true)
