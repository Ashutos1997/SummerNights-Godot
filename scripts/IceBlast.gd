extends Area3D

var speed: float = 80.0
var max_distance: float = 100.0
var distance_traveled: float = 0.0

func _process(delta: float) -> void:
	var move_dist = speed * delta
	position -= transform.basis.z * move_dist
	distance_traveled += move_dist
	if distance_traveled > max_distance:
		queue_free()

func _on_area_entered(area: Area3D) -> void:
	if area.name == "Sun":
		var main_node = get_tree().current_scene
		if main_node.has_method("freeze_sun"):
			main_node.freeze_sun()
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	# Ignore if it's the player
	if body.name == "Player":
		return
	# Ignore invisible environment walls or other things
	pass

func _on_timer_timeout() -> void:
	queue_free()
