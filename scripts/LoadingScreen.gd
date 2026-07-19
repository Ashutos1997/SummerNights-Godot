extends Control

@onready var title_lbl = $CenterContainer/VBoxContainer/Title
@onready var progress_bar = $CenterContainer/VBoxContainer/ProgressBar
@onready var tip_lbl = $CenterContainer/VBoxContainer/Tip

var tips: Array[String] = [
	"PREPARING WATER CANNON...",
	"GENERATING ENVIRONMENT...",
	"CALIBRATING SUN TEMPERATURE...",
	"FILLING WATER TANK..."
]

func _ready() -> void:
	progress_bar.value = 0.0
	tip_lbl.text = tips[0]

func start_sequence() -> void:
	modulate.a = 0.0
	var in_tw = create_tween()
	in_tw.tween_property(self, "modulate:a", 1.0, 0.2)
	await in_tw.finished

	var prog_tw = create_tween()
	prog_tw.set_ease(Tween.EASE_OUT)
	prog_tw.tween_property(progress_bar, "value", 60.0, 0.4)
	prog_tw.tween_callback(func(): tip_lbl.text = tips[1])
	await prog_tw.finished

func finish_sequence(level: int = 1) -> void:
	if tip_lbl:
		tip_lbl.text = "LEVEL %02d READY!" % level
	if progress_bar:
		var prog_tw = create_tween()
		prog_tw.set_ease(Tween.EASE_OUT)
		prog_tw.tween_property(progress_bar, "value", 100.0, 0.25)
		await prog_tw.finished
	
	var out_tw = create_tween()
	out_tw.tween_property(self, "modulate:a", 0.0, 0.35)
	await out_tw.finished
	queue_free()
