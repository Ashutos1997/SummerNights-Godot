extends Area2D

# ── Water Blast ─────────────────────────────────────────────────────────────
# A projectile fired from the gun toward the cursor.
# Uses Area2D for lightweight collision detection with the Sun's hitbox.

signal hit_sun

const SPEED = 900.0   # pixels per second

var _velocity: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var lifetime_timer: Timer = $LifetimeTimer

func launch(from: Vector2, to: Vector2) -> void:
	global_position = from
	_velocity = (to - from).normalized() * SPEED
	# Rotate the laser sprite to face the direction of travel
	rotation = _velocity.angle() + PI / 2.0

func _physics_process(delta: float) -> void:
	global_position += _velocity * delta

func _on_lifetime_timer_timeout() -> void:
	queue_free()

func _on_body_entered(_body) -> void:
	pass  # unused — we use area collision

func _on_area_entered(area: Area2D) -> void:
	# The sun's HitArea is in group "sun_hit"
	if area.is_in_group("sun_hit"):
		# Notify the Sun parent node
		area.get_parent().get_hit()
		emit_signal("hit_sun")
		queue_free()
