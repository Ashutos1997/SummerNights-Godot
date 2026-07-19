extends Node2D

# ── Water Gun ──────────────────────────────────────────────────────────────
# Follows the mouse and rotates to aim at it.
# The rifle sprite points UP by default so we use that as base angle.

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _process(_delta: float) -> void:
	# Rotate gun to face the mouse
	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - global_position
	rotation = dir.angle() + PI / 2.0  # +90° offset because rifle sprite points up

func fire_recoil() -> void:
	# Small kick-back animation
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y + 12, 0.06)
	tween.tween_property(self, "position:y", position.y, 0.1)
