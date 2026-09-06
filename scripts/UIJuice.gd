extends Node

var _tick_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 22050.0
	gen.buffer_length = 0.05
	_tick_player = AudioStreamPlayer.new()
	_tick_player.stream = gen
	_tick_player.bus = "SFX_UI"
	_tick_player.volume_db = -18.0
	add_child(_tick_player)
	
	get_tree().node_added.connect(_on_node_added)
	_apply_to_tree(get_tree().root)

func _play_tick() -> void:
	if not _tick_player.playing:
		_tick_player.play()
	var pb = _tick_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if not pb: return
	var frames = 512
	var freq = 1800.0
	for i in range(frames):
		var t = float(i) / 22050.0
		var envelope = 1.0 - (float(i) / float(frames))
		pb.push_frame(Vector2.ONE * sin(TAU * freq * t) * 0.25 * envelope)

func _on_node_added(node: Node) -> void:
	if node is Button:
		_hook_button(node)
	elif node is Slider:
		_hook_slider(node)

func _apply_to_tree(node: Node) -> void:
	_on_node_added(node)
	for child in node.get_children():
		_apply_to_tree(child)

func _hook_slider(slider: Slider) -> void:
	if not slider.value_changed.is_connected(_on_slider_value_changed):
		slider.value_changed.connect(_on_slider_value_changed)

func _on_slider_value_changed(_val: float) -> void:
	_play_tick()

func _hook_button(btn: Button) -> void:
	if not btn.mouse_entered.is_connected(_play_tick):
		btn.mouse_entered.connect(_play_tick)
	
	if not btn.mouse_entered.is_connected(_on_btn_hover):
		btn.mouse_entered.connect(_on_btn_hover.bind(btn))
	if not btn.mouse_exited.is_connected(_on_btn_normal):
		btn.mouse_exited.connect(_on_btn_normal.bind(btn))
	if not btn.button_down.is_connected(_on_btn_down):
		btn.button_down.connect(_on_btn_down.bind(btn))
	if not btn.button_up.is_connected(_on_btn_hover):
		btn.button_up.connect(_on_btn_hover.bind(btn))

func _get_btn_tween(btn: Button) -> Tween:
	var tw = btn.get_meta("juice_tween", null) as Tween
	if tw and tw.is_valid():
		tw.kill()
	tw = create_tween().bind_node(btn).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	btn.set_meta("juice_tween", tw)
	return tw

func _on_btn_hover(btn: Button) -> void:
	if btn.disabled: return
	btn.pivot_offset = btn.size / 2.0
	var tw = _get_btn_tween(btn)
	tw.tween_property(btn, "scale", Vector2(1.03, 1.03), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _on_btn_normal(btn: Button) -> void:
	btn.pivot_offset = btn.size / 2.0
	var tw = _get_btn_tween(btn)
	tw.tween_property(btn, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _on_btn_down(btn: Button) -> void:
	if btn.disabled: return
	_play_tick() # Audio feedback on click too
	btn.pivot_offset = btn.size / 2.0
	var tw = _get_btn_tween(btn)
	tw.tween_property(btn, "scale", Vector2(0.97, 0.97), 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
