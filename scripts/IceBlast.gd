extends Area3D

var speed: float = 80.0
var max_distance: float = 100.0
var distance_traveled: float = 0.0

func _process(delta: float) -> void:
	var move_dist = speed * delta
	position -= transform.basis.z * move_dist
	distance_traveled += move_dist
	
	var main_node = get_tree().current_scene
	if main_node and main_node.get("sun"):
		var dist = global_position.distance_to(main_node.sun.global_position)
		if dist < 4.5:
			if main_node.has_method("freeze_sun"):
				main_node.freeze_sun()
			queue_free()
			return

	if main_node and "active_magma_rocks" in main_node:
		for rock in main_node.active_magma_rocks:
			if is_instance_valid(rock) and global_position.distance_to(rock.global_position) < 2.0:
				if not "rock_solid" in GameState.unlocked_achievements:
					GameState.unlock_achievement("rock_solid")
				if "sizzle_sfx" in main_node and main_node.sizzle_sfx:
					main_node.sizzle_sfx.play()
				GameState.add_score(150)
				rock.queue_free()
				main_node.active_magma_rocks.erase(rock)
				queue_free()
				return

	if distance_traveled > max_distance:
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
