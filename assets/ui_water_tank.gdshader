shader_type canvas_item;

uniform float fill_ratio : hint_range(0.0, 1.0) = 0.5;
uniform float wave_speed : hint_range(0.0, 10.0) = 3.0;
uniform float wave_freq : hint_range(0.0, 100.0) = 15.0;
uniform float wave_amp : hint_range(0.0, 0.2) = 0.05;
uniform vec4 bg_color : source_color = vec4(0.1, 0.1, 0.1, 0.5);

void fragment() {
    vec2 uv = UV;
    
    // Create a sine wave for the top surface of the liquid
    // The y axis is inverted in 2D (0 is top, 1 is bottom)
    // So liquid fill height is (1.0 - fill_ratio)
    float wave = sin(uv.x * wave_freq + TIME * wave_speed) * wave_amp;
    float threshold = 1.0 - fill_ratio + wave;
    
    // If uv.y is below the threshold, it's empty (above the liquid line)
    if (uv.y < threshold) {
        // Discard or draw background color
        COLOR = bg_color;
    } else {
        // Draw the original texture color (which is blue)
        COLOR = texture(TEXTURE, UV);
    }
}
