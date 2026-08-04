shader_type canvas_item;

uniform float fill_ratio : hint_range(0.0, 1.0) = 0.5;
uniform float wave_speed : hint_range(0.0, 10.0) = 3.0;
uniform float wave_freq : hint_range(0.0, 100.0) = 15.0;
uniform float wave_amp : hint_range(0.0, 0.2) = 0.05;
uniform vec4 bg_color : source_color = vec4(0.1, 0.1, 0.1, 0.5);

void fragment() {
    vec2 uv = UV;
    
    // Create a sine wave for the vertical surface of the liquid (right edge)
    // The wave moves along the y axis
    float wave = sin(uv.y * wave_freq + TIME * wave_speed) * wave_amp;
    
    // The fill threshold is along the x axis (0 is left, 1 is right)
    // If fill_ratio is 1.0, threshold is 1.0 + wave
    float threshold = fill_ratio + wave;
    
    // If uv.x is above the threshold, it's empty (to the right of the liquid line)
    if (uv.x > threshold) {
        // Discard or draw background color
        COLOR = bg_color;
    } else {
        // Draw the original texture color (which is blue)
        COLOR = texture(TEXTURE, UV);
    }
}
