extends Control

@onready var esc_lbl = $EscLabel
@onready var tab_lbl = $TabLabel
@onready var r_lbl = $RLabel
@onready var f_lbl = $FLabel

# Pixel anchors for the keys based on 559x231 scaling
var key_pos_esc = Vector2(35, 24) # Top of ESC
var key_pos_tab = Vector2(13, 107) # Left of TAB
var key_pos_r = Vector2(162, 95) # Top of R
var key_pos_f = Vector2(169, 147) # Bottom of F

func _ready():
	queue_redraw()

func _draw():
	var line_color = Color(1.0, 0.843, 0.0) # Gold
	var r_color = Color(0.31, 0.765, 0.969)
	var f_color = Color(1.0, 0.427, 0.0)
	var line_width = 2.0
	var gap = 10.0
	
	# ESC -> PAUSE
	if esc_lbl:
		var lbl_rect = esc_lbl.get_rect()
		var label_right = Vector2(lbl_rect.end.x, lbl_rect.position.y + lbl_rect.size.y / 2.0)
		draw_polyline(PackedVector2Array([key_pos_esc, Vector2(key_pos_esc.x, label_right.y), label_right + Vector2(gap, 0)]), line_color, line_width)
		draw_circle(label_right + Vector2(gap, 0), 3, line_color)

	# TAB -> WEAPONS
	if tab_lbl:
		var lbl_rect = tab_lbl.get_rect()
		var label_right = Vector2(lbl_rect.end.x, lbl_rect.position.y + lbl_rect.size.y / 2.0)
		draw_polyline(PackedVector2Array([key_pos_tab, Vector2(label_right.x + gap, key_pos_tab.y)]), line_color, line_width)
		draw_circle(Vector2(label_right.x + gap, key_pos_tab.y), 3, line_color)

	# R -> ICE BLAST
	if r_lbl:
		var lbl_rect = r_lbl.get_rect()
		var label_left = Vector2(lbl_rect.position.x, lbl_rect.position.y + lbl_rect.size.y / 2.0)
		draw_polyline(PackedVector2Array([key_pos_r, Vector2(key_pos_r.x, label_left.y), label_left - Vector2(gap, 0)]), r_color, line_width)
		draw_circle(label_left - Vector2(gap, 0), 3, r_color)

	# F -> CATASTROM
	if f_lbl:
		var lbl_rect = f_lbl.get_rect()
		var label_left = Vector2(lbl_rect.position.x, lbl_rect.position.y + lbl_rect.size.y / 2.0)
		# Extend line down to clear keyboard (Y=200) then bend to label
		draw_polyline(PackedVector2Array([key_pos_f, Vector2(key_pos_f.x, 200), Vector2(label_left.x - gap, 200), label_left - Vector2(gap, 0)]), f_color, line_width)
		draw_circle(label_left - Vector2(gap, 0), 3, f_color)
