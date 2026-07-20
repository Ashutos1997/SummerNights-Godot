extends Control

@onready var title_lbl = $CenterContainer/VBoxContainer/Title
@onready var progress_bar = $CenterContainer/VBoxContainer/ProgressBar
@onready var tip_lbl = $CenterContainer/VBoxContainer/Tip

var tips_en: Array[String] = [
	"PREPARING WATER CANNON...",
	"GENERATING ENVIRONMENT...",
	"CALIBRATING SUN TEMPERATURE...",
	"FILLING WATER TANK..."
]

var tips_kr: Array[String] = [
	"물대포 준비 중...",
	"환경 생성 중...",
	"태양 온도 조정 중...",
	"물탱크 채우는 중..."
]

func _ready() -> void:
	var is_kr = GameState.language == "KR"
	var font_path = "res://assets/ui/fonts/Galmuri11.ttf" if is_kr else "res://assets/ui/fonts/Fonts/Kenney Future.ttf"
	var font = load(font_path)
	
	if title_lbl:
		title_lbl.text = "태양을 식히는 중..." if is_kr else "COOLING DOWN THE SUN..."
		if font: title_lbl.add_theme_font_override("font", font)
		title_lbl.add_theme_font_size_override("font_size", 42 if is_kr else 36)
	
	if tip_lbl:
		if font: tip_lbl.add_theme_font_override("font", font)
		tip_lbl.add_theme_font_size_override("font_size", 22 if is_kr else 18)
		tip_lbl.text = tips_kr[0] if is_kr else tips_en[0]

	progress_bar.value = 0.0

func start_sequence() -> void:
	modulate.a = 0.0
	var in_tw = create_tween()
	in_tw.tween_property(self, "modulate:a", 1.0, 0.2)
	await in_tw.finished

	var prog_tw = create_tween()
	prog_tw.set_ease(Tween.EASE_OUT)
	prog_tw.tween_property(progress_bar, "value", 60.0, 0.4)
	var is_kr = GameState.language == "KR"
	var next_tip = tips_kr[1] if is_kr else tips_en[1]
	prog_tw.tween_callback(func(): tip_lbl.text = next_tip)
	await prog_tw.finished

func finish_sequence(level: int = 1) -> void:
	var is_kr = GameState.language == "KR"
	if tip_lbl:
		tip_lbl.text = "%02d 단계 준비 완료!" % level if is_kr else "LEVEL %02d READY!" % level
	if progress_bar:
		var prog_tw = create_tween()
		prog_tw.set_ease(Tween.EASE_OUT)
		prog_tw.tween_property(progress_bar, "value", 100.0, 0.25)
		await prog_tw.finished
	
	var out_tw = create_tween()
	out_tw.tween_property(self, "modulate:a", 0.0, 0.35)
	await out_tw.finished
	queue_free()
