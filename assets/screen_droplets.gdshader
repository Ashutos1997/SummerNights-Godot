shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float wetness : hint_range(0.0, 1.0) = 0.0;

// Simple random generator
vec2 random2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 col = texture(screen_texture, uv);
    
    if (wetness > 0.01) {
        float t = TIME * 1.5;
        
        // Base grid for large chunky drops
        vec2 grid = vec2(8.0, 5.0);
        vec2 guv = uv * grid;
        
        // Drops slide down
        guv.y -= t;
        
        vec2 i_guv = floor(guv);
        vec2 f_guv = fract(guv);
        
        // Jitter drop position per cell
        vec2 offset = random2(i_guv) * 0.5 - 0.25;
        vec2 drop_center = vec2(0.5) + offset;
        
        // Procedural wobble to make them look like chunky irregular blobs
        float angle = atan(f_guv.y - drop_center.y, f_guv.x - drop_center.x);
        float wobble = sin(angle * 4.0 + t * 5.0) * 0.06;
        
        float dist = length(f_guv - drop_center) + wobble;
        float drop_chance = random2(i_guv + vec2(3.14)).x;
        
        // Radius scales strongly with wetness to create massive splats at 1.0
        float radius = 0.15 + (wetness * 0.4) * random2(i_guv).y;
        
        if (drop_chance < wetness) {
            if (dist < radius) {
                // Inside drop! Pure 2D flat cyan style
                vec3 drop_color = vec3(0.1, 0.75, 1.0); 
                
                // Hard outline (thick dark blue)
                if (dist > radius * 0.75) {
                    drop_color = vec3(0.02, 0.2, 0.5);
                } 
                // Hard stylized cel-shaded highlight crescent
                else {
                    vec2 light_dir = normalize(vec2(-1.0, -1.0));
                    float highlight = dot(normalize(f_guv - drop_center), light_dir);
                    if (highlight > 0.65 && dist > radius * 0.3 && dist < radius * 0.6) {
                        drop_color = vec3(1.0); // Pure white highlight
                    }
                }
                
                // Apply flat color over the screen
                col.rgb = mix(col.rgb, drop_color, min(1.0, wetness * 1.5));
            }
        }
        
        // Layer 2: Fast sliding cartoon streaks
        vec2 streak_uv = uv * vec2(18.0, 1.0);
        streak_uv.y -= t * 2.5;
        vec2 is = floor(streak_uv);
        
        if (random2(is).x < wetness * 0.6) {
            float sx = fract(streak_uv.x);
            float sy = fract(streak_uv.y);
            
            // Wobble streak width
            float s_wobble = sin(uv.y * 40.0 + t * 10.0) * 0.04;
            float s_width = 0.12 + s_wobble;
            
            // Short streaky bursts
            if (abs(sx - 0.5) < s_width && sy < 0.2) {
                vec3 streak_color = vec3(0.2, 0.8, 1.0);
                // Thick vertical borders for the streak
                if (abs(sx - 0.5) > s_width * 0.6 || sy < 0.02 || sy > 0.18) {
                    streak_color = vec3(0.02, 0.2, 0.5); // Outline
                }
                col.rgb = mix(col.rgb, streak_color, min(1.0, wetness * 1.5));
            }
        }
    }
    
    COLOR = col;
}
