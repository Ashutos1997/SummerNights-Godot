shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float aberration_amount : hint_range(0.0, 10.0) = 1.0;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform float noise_amount : hint_range(0.0, 1.0) = 0.03;
uniform bool reduce_motion = false;

// Simple random function based on UV
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Scale aberration based on distance from center for a lens effect
    vec2 center_dist = uv - vec2(0.5);
    
    vec3 color = texture(screen_texture, uv).rgb;
    
    // 2. Film Grain (Noise)
    if (noise_amount > 0.0) {
        float noise_val;
        if (reduce_motion) {
            // Static noise to prevent flickering for a11y
            noise_val = rand(uv) * noise_amount;
        } else {
            // Animated noise
            noise_val = rand(uv + vec2(TIME * 0.1, TIME * 0.2)) * noise_amount;
        }
        // Subtract noise to give a darker film grain look
        color -= vec3(noise_val);
    }
    
    // 3. Color Grading (Improved Contrast & Saturation)
    
    // Contrast (S-Curve)
    color = mix(color, smoothstep(0.0, 1.0, color), 0.25);
    
    // Saturation boost
    float luma = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 luma_vec = vec3(luma);
    // Boost saturation by 15%
    color = mix(luma_vec, color, 1.15);
    
    // Synthwave Tinting (Deep blue/purple shadows, warm bright highlights)
    vec3 shadow_color = vec3(0.1, 0.05, 0.25); 
    vec3 highlight_color = vec3(1.0, 0.9, 0.8);
    // Blend shadows based on inverse luma, highlights based on luma
    color = mix(color, color + shadow_color, (1.0 - luma) * 0.3);
    color = mix(color, color * highlight_color, luma * 0.3);
    
    // 4. Vignette
    float vignette = smoothstep(0.8, vignette_intensity, length(center_dist));
    color = mix(color, color * vignette, vignette_opacity);
    
    COLOR = vec4(color, 1.0);
}
