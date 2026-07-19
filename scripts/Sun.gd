extends Node2D

# ── Sun ────────────────────────────────────────────────────────────────────
# The target. Bobs up and down and glows. Emits splash particles on hit.

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $HitParticles
@onready var glow: PointLight2D = $GlowLight

const BOB_AMPLITUDE = 10.0   # pixels
const BOB_SPEED     = 1.5    # radians per second
const ROTATE_SPEED  = 0.5    # radians per second

var _time: float = 0.0
var _base_y: float = 0.0
var _is_cooled: bool = false

func _ready() -> void:
	_base_y = position.y

func _process(delta: float) -> void:
	if _is_cooled:
		return
	_time += delta
	# Bobbing
	position.y = _base_y + sin(_time * BOB_SPEED) * BOB_AMPLITUDE
	# Slow rotation
	sprite.rotation += ROTATE_SPEED * delta

func get_hit() -> void:
	# Flash white
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(2, 2, 2, 1), 0.05)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.15)
	# Emit splash particles
	particles.restart()
	particles.emitting = true
	# Pulse glow
	var ltween = create_tween()
	ltween.tween_property(glow, "energy", 3.0, 0.05)
	ltween.tween_property(glow, "energy", 1.0, 0.3)

func set_cooled() -> void:
	_is_cooled = true
	# Fade to grey-blue (cooled sun)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(0.6, 0.8, 1.0, 1.0), 1.0)
	tween.tween_property(glow, "color", Color(0.4, 0.7, 1.0), 1.0)
	tween.parallel().tween_property(glow, "energy", 0.3, 1.0)
