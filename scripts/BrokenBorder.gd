extends Control

@export var border_color: Color = Color(1.0, 0.85, 0.2, 0.4)
@export var border_width: float = 2.0
@export var corner_radius: float = 8.0
@export var gap_size: float = 320.0

func _ready():
	resized.connect(queue_redraw)

func _draw():
	var resolution = 8
	var pts = PackedVector2Array()
	var rect = Rect2(border_width/2.0, border_width/2.0, size.x - border_width, size.y - border_width)
	
	# Start on the bottom edge, moving left
	pts.append(Vector2(rect.position.x + rect.size.x - gap_size, rect.position.y + rect.size.y))
	
	# Bottom-Left corner
	for i in range(resolution + 1):
		var angle = PI / 2.0 + (PI / 2.0) * (float(i) / resolution)
		pts.append(Vector2(rect.position.x + corner_radius + cos(angle) * corner_radius, rect.position.y + rect.size.y - corner_radius + sin(angle) * corner_radius))
	
	# Top-Left corner
	for i in range(resolution + 1):
		var angle = PI + (PI / 2.0) * (float(i) / resolution)
		pts.append(Vector2(rect.position.x + corner_radius + cos(angle) * corner_radius, rect.position.y + corner_radius + sin(angle) * corner_radius))
		
	# Top-Right corner
	for i in range(resolution + 1):
		var angle = PI * 1.5 + (PI / 2.0) * (float(i) / resolution)
		pts.append(Vector2(rect.position.x + rect.size.x - corner_radius + cos(angle) * corner_radius, rect.position.y + corner_radius + sin(angle) * corner_radius))
		
	# Right edge (top to bottom), stopping before the gap
	pts.append(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y - gap_size))
	
	draw_polyline(pts, border_color, border_width, true)
