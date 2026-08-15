shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float wetness : hint_range(0.0, 1.0) = 0.0;

vec2 random2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    if (wetness > 0.01) {
        float time = TIME;
        
        // Layer 1: Large slow drops
        vec2 layer1_uv = uv * vec2(12.0, 8.0);
        layer1_uv.y -= time * 1.2;
        vec2 i1 = floor(layer1_uv);
        vec2 f1 = fract(layer1_uv);
        vec2 p1 = random2(i1);
        p1.x += sin(time * 2.0 + i1.y) * 0.1; // wobble
        
        float dist1 = length(f1 - p1);
        float active1 = step(random2(i1 + vec2(7.0)).x, wetness);
        
        if (active1 > 0.0 && dist1 < 0.25) {
            vec2 normal = (f1 - p1) / 0.25;
            uv += normal * 0.06 * wetness;
        }
        
        // Layer 2: Fast sliding streaks
        vec2 streak_uv = uv * vec2(24.0, 2.0);
        streak_uv.y -= time * 4.0;
        vec2 is = floor(streak_uv);
        if (random2(is).x < wetness * 0.4) {
            float sx = fract(streak_uv.x);
            if (abs(sx - 0.5) < 0.15) {
                uv.y += 0.015 * wetness;
                uv.x += sin(time * 10.0 + uv.y * 20.0) * 0.005; // tiny streak wobble
            }
        }
    }
    
    COLOR = texture(screen_texture, uv);
    
    // Subtle darkening / tint where wet
    if (wetness > 0.01 && length(uv - SCREEN_UV) > 0.001) {
        COLOR.rgb = mix(COLOR.rgb, vec3(0.6, 0.8, 1.0), 0.15 * wetness);
    }
}
