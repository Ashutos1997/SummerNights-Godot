extends SceneTree

func _init():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_callback(func(): print("1: ", Time.get_ticks_msec()))
	tween.set_parallel(false)
	tween.tween_interval(2.0)
	tween.set_parallel(true)
	tween.tween_callback(func(): print("2: ", Time.get_ticks_msec()))
	tween.set_parallel(false)
	tween.tween_callback(func(): quit())
