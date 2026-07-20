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

	if distance_traveled > max_distance:
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
