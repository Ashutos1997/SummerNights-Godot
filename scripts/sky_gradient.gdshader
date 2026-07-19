shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.9, 0.16, 0.05, 1.0);
uniform vec4 bottom_color : source_color = vec4(1.0, 0.75, 0.2, 1.0);

void fragment() {
	COLOR = mix(top_color, bottom_color, UV.y);
}
