// Open Source Rain on Glass
// Based on standard community Voronoi refraction logic (MIT)
// Adapted for Godot 4 and Summer Nights

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float wetness : hint_range(0.0, 1.0) = 0.0;
uniform float drop_size = 12.0;

vec2 rand(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    if (wetness > 0.01) {
        float t = TIME * 1.0;
        
        // --- Trails ---
        vec2 trail_uv = uv * vec2(drop_size * 2.0, drop_size * 0.5);
        trail_uv.y -= t * 2.0;
        vec2 trail_i = floor(trail_uv);
        vec2 trail_f = fract(trail_uv);
        
        float trail_active = rand(trail_i).x;
        if(trail_active < wetness * 0.6) {
            float trail_wobble = sin(uv.y * 30.0 + t) * 0.05;
            float trail_x = abs((trail_f.x - 0.5) + trail_wobble);
            if (trail_x < 0.08) {
                uv.y += 0.008 * wetness;
            }
        }
        
        // --- Drops (Voronoi) ---
        vec2 drop_uv = uv * vec2(drop_size, drop_size * 0.6);
        drop_uv.y -= t * 0.5;
        
        vec2 i = floor(drop_uv);
        vec2 f = fract(drop_uv);
        
        vec2 min_dist_vec = vec2(1.0);
        float min_dist = 1.0;
        float drop_val = 0.0;
        
        for(int y = -1; y <= 1; y++) {
            for(int x = -1; x <= 1; x++) {
                vec2 neighbor = vec2(float(x), float(y));
                vec2 p = rand(i + neighbor);
                
                // Add jitter to dropping
                p.y += sin(t * 2.0 + p.x * 8.0) * 0.1;
                
                float active_chance = rand(i + neighbor + vec2(1.0)).x;
                if (active_chance < wetness) {
                    vec2 diff = neighbor + p - f;
                    float dist = length(diff);
                    
                    if(dist < min_dist) {
                        min_dist = dist;
                        min_dist_vec = diff;
                        drop_val = 1.0;
                    }
                }
            }
        }
        
        float radius = 0.25 + wetness * 0.15;
        if(min_dist < radius && drop_val > 0.0) {
            vec2 normal = min_dist_vec / radius;
            
            // Refract SCREEN_UV
            uv += normal * 0.025 * wetness;
            
            vec4 base_color = texture(screen_texture, uv);
            
            // Specular Highlight
            vec2 light_dir = normalize(vec2(-1.0, -1.0));
            float spec = max(0.0, dot(normal, light_dir));
            spec = pow(spec, 6.0);
            
            COLOR = base_color + vec4(spec * 0.35 * wetness);
        } else {
            COLOR = texture(screen_texture, uv);
        }
        
        // Very subtle bluish tint for wetness
        COLOR.rgb = mix(COLOR.rgb, vec3(0.8, 0.9, 1.0), 0.05 * wetness);
        
    } else {
        COLOR = texture(screen_texture, uv);
    }
}
