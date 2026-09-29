extends Area3D

var speed: float = 110.0
var max_distance: float = 120.0
var distance_traveled: float = 0.0
var targeted_sun: bool = false
var has_hit: bool = false

func _process(delta: float) -> void:
	if has_hit:
		return
		
	var main_node = get_tree().current_scene
	var move_dist = speed * delta
	var prev_pos = global_position
	
	# If targeted at the sun, smoothly guide toward the moving sun to guarantee reliable crosshair hits
	if targeted_sun and is_instance_valid(main_node) and main_node.get("sun"):
		var sun_pos = main_node.sun.global_position
		var to_sun = (sun_pos - global_position).normalized()
		var cur_dir = -global_transform.basis.z
		var new_dir = cur_dir.lerp(to_sun, clamp(delta * 14.0, 0.0, 1.0)).normalized()
		look_at(global_position + new_dir * 10.0, Vector3.UP)

	# Advance along forward vector
	global_position -= global_transform.basis.z * move_dist
	var cur_pos = global_position
	distance_traveled += move_dist
	
	var move_vec = cur_pos - prev_pos
	var seg_len_sq = move_vec.length_squared()
	
	# 1. Check Solar Convergence Orbital Drones Intercept (AoE Cryo-Frost)
	if is_instance_valid(main_node) and "solar_convergence_mgr" in main_node and main_node.solar_convergence_mgr:
		if main_node.solar_convergence_mgr.check_ice_blast_intercept(cur_pos, 6.5):
			has_hit = true
			queue_free()
			return

	# 2. Check Magma Rock Interceptions (Continuous swept segment check to prevent tunneling)
	if is_instance_valid(main_node) and "active_magma_rocks" in main_node:
		for rock in main_node.active_magma_rocks:
			if is_instance_valid(rock):
				var r_pos = rock.global_position
				var t = 0.0
				if seg_len_sq > 0.0001:
					t = clampf((r_pos - prev_pos).dot(move_vec) / seg_len_sq, 0.0, 1.0)
				var closest_pt = prev_pos + move_vec * t
				if closest_pt.distance_to(r_pos) < 2.5:
					has_hit = true
					if not "rock_solid" in GameState.unlocked_achievements:
						GameState.unlock_achievement("rock_solid")
					if "sizzle_sfx" in main_node and main_node.sizzle_sfx:
						main_node.sizzle_sfx.play()
					GameState.add_score(150)
					rock.queue_free()
					main_node.active_magma_rocks.erase(rock)
					queue_free()
					return

	# 3. Check Heat Mirage Hits (Chunk mirage HP on impact)
	if is_instance_valid(main_node) and "active_mirages" in main_node and main_node.active_mirages.size() > 0:
		for m in main_node.active_mirages:
			var m_node = m.get("node") as Node3D
			if is_instance_valid(m_node):
				var m_pos = m_node.global_position
				var t = 0.0
				if seg_len_sq > 0.0001:
					t = clampf((m_pos - prev_pos).dot(move_vec) / seg_len_sq, 0.0, 1.0)
				var closest_pt = prev_pos + move_vec * t
				if closest_pt.distance_to(m_pos) <= 5.2:
					has_hit = true
					if "mirage_hp" in main_node:
						main_node.mirage_hp = max(0.0, main_node.mirage_hp - (main_node.max_mirage_hp * 0.40))
						if main_node.hud and main_node.hud.has_method("update_mirage_hp"):
							main_node.hud.update_mirage_hp(main_node.mirage_hp, main_node.max_mirage_hp)
						if main_node.mirage_hp <= 0.0:
							main_node._end_mirage()
							main_node.active_mirages.clear()
					if main_node.ice_hit_sfx:
						main_node.ice_hit_sfx.play()
					queue_free()
					return

	# 4. Check Sun Impact (Continuous swept segment check - mathematical anti-tunneling)
	if is_instance_valid(main_node) and main_node.get("sun"):
		var sun_pos = main_node.sun.global_position
		var t = 0.0
		if seg_len_sq > 0.0001:
			t = clampf((sun_pos - prev_pos).dot(move_vec) / seg_len_sq, 0.0, 1.0)
		var closest_pt = prev_pos + move_vec * t
		var dist_to_sun = closest_pt.distance_to(sun_pos)
		
		# Generous collision threshold (5.5m) matches visual sun sphere + corona
		# Fail-safe: if targeted at sun, crossing the sun's Z-depth within 7.0m guarantees a hit
		if dist_to_sun <= 5.5 or (targeted_sun and cur_pos.z <= sun_pos.z + 1.0 and cur_pos.distance_to(sun_pos) <= 7.0):
			has_hit = true
			if main_node.has_method("freeze_sun"):
				main_node.freeze_sun()
			queue_free()
			return

	if distance_traveled > max_distance:
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()

