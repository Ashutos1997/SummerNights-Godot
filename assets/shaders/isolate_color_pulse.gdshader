shader_type canvas_item;

uniform vec4 target_color : source_color = vec4(1.0);
uniform float tolerance : hint_range(0.0, 1.0) = 0.15;
uniform float pulse_multiplier : hint_range(1.0, 5.0) = 1.0;
uniform float dim_multiplier : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    // Calculate distance in RGB space to isolate our target color
    float dist = distance(tex.rgb, target_color.rgb);
    if (dist < tolerance && tex.a > 0.1) {
        COLOR = vec4(tex.rgb * pulse_multiplier, tex.a);
    } else {
        COLOR = vec4(tex.rgb * dim_multiplier, tex.a);
    }
}
