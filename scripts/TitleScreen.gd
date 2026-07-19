extends Control

@onready var color_rect = $ColorRect
@onready var title_lbl = $ColorRect/VBoxContainer/Title
@onready var subtitle_lbl = $ColorRect/VBoxContainer/Subtitle
@onready var prompt_lbl = $ColorRect/VBoxContainer/Prompt
@onready var credit_lbl = $CreditLine

var main_scene = preload("res://scenes/Main.tscn")
var loading_scene = preload("res://scenes/LoadingScreen.tscn")
var is_starting: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var font = load("res://assets/ui/fonts/Fonts/Kenney Future.ttf")
	if font:
		_style_label(title_lbl, 64, Color(1.0, 0.8, 0.2, 1.0), 3, Color.BLACK, font, 4)
		_style_label(subtitle_lbl, 22, Color(1.0, 0.88, 0.3, 0.95), 2, Color.BLACK, font)
		_style_label(prompt_lbl, 16, Color(1.0, 0.88, 0.3, 0.95), 2, Color.BLACK, font)
		_style_label(credit_lbl, 12, Color(1.0, 1.0, 1.0, 0.85), 1, Color.BLACK, font)

	color_rect.modulate.a = 0.0
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(color_rect, "modulate:a", 1.0, 0.5)

	# Pulse animation on prompt label — respects Reduce Motion setting (WCAG 2.2.2)
	var reduce_motion = GameState.reduce_motion
	if prompt_lbl and not reduce_motion:
		var pulse_tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		pulse_tw.tween_property(prompt_lbl, "modulate:a", 0.7, 1.2)
		pulse_tw.tween_property(prompt_lbl, "modulate:a", 1.0, 1.2)
	elif prompt_lbl:
		prompt_lbl.modulate.a = 1.0

	_audit_labels()

func _audit_labels() -> void:
	_register_labels_recursive(self)
	print("--- TITLE SCREEN LABEL AUDIT ---")
	for label in get_tree().get_nodes_in_group("labels"):
		if label.is_inside_tree() and label.get_tree().current_scene == self:
			var sz = label.get_theme_font_size("font_size")
			print(label.name, " font_size: ", sz)

func _register_labels_recursive(node: Node) -> void:
	if node is Label:
		if not node.is_in_group("labels"):
			node.add_to_group("labels")
	for child in node.get_children():
		_register_labels_recursive(child)

func _style_label(lbl: Label, size: int, color: Color, out_size: int, out_color: Color, font: Font, letter_space: int = 0) -> void:
	if not lbl: return
	if font:
		lbl.add_theme_font_override("font", font)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	if out_size > 0:
		lbl.add_theme_constant_override("outline_size", out_size)
		lbl.add_theme_color_override("font_outline_color", out_color)
	if letter_space > 0:
		lbl.add_theme_constant_override("letter_spacing", letter_space)

func _input(event: InputEvent) -> void:
	if is_starting: return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			_start_game()
	elif event is InputEventMouseButton and event.pressed:
		_start_game()

func _start_game() -> void:
	if is_starting: return
	is_starting = true
	GameState.reset()
	
	var loader = loading_scene.instantiate()
	get_tree().root.add_child(loader)
	await loader.start_sequence()
	get_tree().change_scene_to_packed(main_scene)
