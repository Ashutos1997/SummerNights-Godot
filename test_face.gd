extends SceneTree

const FACE_SIZE = 128
const FACE_COLOR = Color(0.15, 0.05, 0.0, 0.9)

func _init():
	var img = _draw_face("angry")
	var err = img.save_png("res://angry_face_test.png")
	print("Image saved with error code: ", err)
	quit()

func _draw_face(expression: String) -> Image:
	var img = Image.create(FACE_SIZE, FACE_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var cx = FACE_SIZE / 2
	var cy = FACE_SIZE / 2
	match expression:
		"angry": _draw_angry(img, cx, cy)
	return img

func _draw_circle_on_image(img: Image, cx: int, cy: int, radius: int, color: Color) -> void:
	for x in range(cx - radius, cx + radius + 1):
		for y in range(cy - radius, cy + radius + 1):
			if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= radius * radius:
				if x >= 0 and x < FACE_SIZE and y >= 0 and y < FACE_SIZE:
					img.set_pixel(x, y, color)

func _draw_line_on_image(img: Image, x1: int, y1: int, x2: int, y2: int, thickness: int, color: Color) -> void:
	var dx = abs(x2 - x1)
	var dy = abs(y2 - y1)
	var steps = max(dx, dy)
	if steps == 0: return
	var sx = float(x2 - x1) / steps
	var sy = float(y2 - y1) / steps
	for i in range(steps + 1):
		var px = int(x1 + sx * i)
		var py = int(y1 + sy * i)
		for tx in range(-thickness/2, thickness/2 + 1):
			for ty in range(-thickness/2, thickness/2 + 1):
				var fx = px + tx
				var fy = py + ty
				if fx >= 0 and fx < FACE_SIZE and fy >= 0 and fy < FACE_SIZE:
					img.set_pixel(fx, fy, color)

func _draw_arc_on_image(img: Image, cx: int, cy: int, radius: int, start_angle: float, end_angle: float, thickness: int, color: Color) -> void:
	var steps = 40
	var prev_x = -1
	var prev_y = -1
	for i in range(steps + 1):
		var angle = start_angle + (end_angle - start_angle) * i / steps
		var px = int(cx + cos(angle) * radius)
		var py = int(cy + sin(angle) * radius)
		if prev_x >= 0:
			_draw_line_on_image(img, prev_x, prev_y, px, py, thickness, color)
		prev_x = px
		prev_y = py

func _draw_angry(img: Image, cx: int, cy: int):
	_draw_circle_on_image(img, cx-22, cy-8, 6, FACE_COLOR)
	_draw_circle_on_image(img, cx+22, cy-8, 6, FACE_COLOR)
	_draw_line_on_image(img, cx-34, cy-22, cx-12, cy-14, 3, FACE_COLOR)
	_draw_line_on_image(img, cx+34, cy-22, cx+12, cy-14, 3, FACE_COLOR)
	_draw_arc_on_image(img, cx, cy+28, 18, deg_to_rad(200), deg_to_rad(340), 3, FACE_COLOR)
