shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float aberration_amount : hint_range(0.0, 10.0) = 1.0;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 heat_border_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform float flash_mix : hint_range(0.0, 1.0) = 0.0;
uniform float frost_mix : hint_range(0.0, 1.0) = 0.0;
uniform float noise_amount : hint_range(0.0, 1.0) = 0.03;
uniform bool reduce_motion = false;
uniform bool color_reduction_enabled = false;
uniform float color_levels : hint_range(4.0, 32.0) = 10.0;
uniform bool dither_enabled = false;
uniform float dither_strength : hint_range(0.0, 2.0) = 1.0;
uniform float dither_pixel_size : hint_range(1.0, 8.0) = 3.0;
uniform bool ps1_shading_enabled = false;
uniform bool heatwave_1984_enabled = false;

// Simple random function based on UV
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}


// 4x4 Ordered Bayer Matrix for retro dithering [0.0, 15.0 / 16.0]
// Implemented via constant vectors for 100% universal compatibility across all GPU platforms
float bayer4x4(vec2 coord) {
    int x = int(abs(coord.x)) & 3;
    int y = int(abs(coord.y)) & 3;
    vec4 row;
    if (y == 0) row = vec4(0.0, 8.0, 2.0, 10.0);
    else if (y == 1) row = vec4(12.0, 4.0, 14.0, 6.0);
    else if (y == 2) row = vec4(3.0, 11.0, 1.0, 9.0);
    else row = vec4(15.0, 7.0, 13.0, 5.0);
    
    if (x == 0) return row.x / 16.0;
    if (x == 1) return row.y / 16.0;
    if (x == 2) return row.z / 16.0;
    return row.w / 16.0;
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // 1. Heat Haze (Distortion)
    // Subtle wavy offset to simulate intense summer heat
    float heat_wave = sin(uv.y * 60.0 + TIME * 4.0) * 0.0015;
    // Distort more towards the horizon/top of screen
    vec2 distorted_uv = uv + vec2(heat_wave * (1.0 - uv.y), 0.0);
    
    // Robust pixel size calculator for multi-tap kernels (supports variable DPI and headless viewports)
    vec2 px = fwidth(distorted_uv);
    if (px.x <= 0.0 || px.y <= 0.0) {
        px = SCREEN_PIXEL_SIZE;
    }
    if (px.x <= 0.0 || px.y <= 0.0) {
        px = vec2(1.0 / 1280.0, 1.0 / 720.0);
    }
    
    // Scale aberration based on distance from center for a lens effect
    vec2 center_dist = distorted_uv - vec2(0.5);
    
    vec3 color = texture(screen_texture, distorted_uv).rgb;
    
    // 3. Film Grain (Noise)
    if (noise_amount > 0.0) {
        float noise_val;
        if (reduce_motion) {
            // Static noise to prevent flickering for a11y
            noise_val = rand(distorted_uv) * noise_amount;
        } else {
            // Animated noise
            noise_val = rand(distorted_uv + vec2(TIME * 0.1, TIME * 0.2)) * noise_amount;
        }
        // Subtract noise to give a darker film grain look
        color -= vec3(noise_val);
    }
    
    // 4. Color Grading (Improved Contrast & Saturation)
    
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
    
    // 5a. "Retro Colors" (PS1 / Arcade 10-level color reduction + NTSC composite chroma bleed + CRT scanlines)
    if (color_reduction_enabled) {
        float r_bleed = texture(screen_texture, distorted_uv - vec2(px.x * 2.5, 0.0)).r;
        float b_bleed = texture(screen_texture, distorted_uv + vec2(px.x * 2.5, 0.0)).b;
        color.r = mix(color.r, r_bleed, 0.25);
        color.b = mix(color.b, b_bleed, 0.25);
        
        color = floor(color * color_levels + 0.5) / color_levels;
        
        // Crisp 10% CRT scanline modulation (2-pixel cadence)
        float scanline = (int(floor(FRAGCOORD.y / 2.0)) % 2 == 0) ? 0.90 : 1.0;
        color *= scanline;
        color = clamp(color, 0.0, 1.0);
    }

    // 5b. "Dithering" (Classic 4x4 Bayer matrix stippling with 8-level quantization)
    if (dither_enabled) {
        float b = bayer4x4(floor(FRAGCOORD.xy / dither_pixel_size));
        float d_levels = 8.0;
        color += vec3((b - 0.5) * (dither_strength / d_levels));
        color = clamp(color, 0.0, 1.0);
        color = floor(color * d_levels + 0.5) / d_levels;
    }

    // 5c. "PS1 Shading" (384x216 virtual low-res raster + 15-bit stepped shading + hardware 4x4 Bayer dither + composite bleed)
    if (ps1_shading_enabled) {
        vec2 retro_res = vec2(384.0, 216.0);
        vec2 retro_uv = floor(distorted_uv * retro_res) / retro_res;
        vec2 retro_px = vec2(1.0) / retro_res;
        
        // Re-sample color from the downsampled 384x216 virtual framebuffer
        vec3 ps1_c = texture(screen_texture, retro_uv).rgb;
        
        // Analog composite NTSC chroma delay / horizontal bleed across neighboring virtual texels
        float r_bleed = texture(screen_texture, retro_uv - vec2(retro_px.x * 1.5, 0.0)).r;
        float b_bleed = texture(screen_texture, retro_uv + vec2(retro_px.x * 1.5, 0.0)).b;
        ps1_c.r = mix(ps1_c.r, r_bleed, 0.30);
        ps1_c.b = mix(ps1_c.b, b_bleed, 0.30);
        
        // Authentic PS1 hardware 4x4 Bayer dither on the virtual pixel raster
        vec2 dither_pos = floor(distorted_uv * retro_res);
        float b = bayer4x4(dither_pos);
        float ps1_levels = 16.0; // 15-bit / high-contrast console stepped lighting
        ps1_c += vec3((b - 0.5) * (1.0 / ps1_levels));
        ps1_c = clamp(ps1_c, 0.0, 1.0);
        ps1_c = floor(ps1_c * ps1_levels + 0.5) / ps1_levels;
        
        // CRT 240p alternating micro-scanlines (2-pixel cadence on physical screen)
        float scanline = (int(floor(FRAGCOORD.y / 2.0)) % 2 == 0) ? 0.88 : 1.0;
        ps1_c *= scanline;
        color = clamp(ps1_c, 0.0, 1.0);
    }

    // 5d. "Heatwave 1984" Vintage Kodachrome Grade & Optical Halation Diffusion
    if (heatwave_1984_enabled) {
        // Film S-Curve contrast boost
        color = color * color * (3.0 - 2.0 * color);
        
        // Kodachrome color matrix: warm golden highlights, rich teal-olive shadows
        float h_luma = dot(color, vec3(0.299, 0.587, 0.114));
        vec3 warm_gold = vec3(1.15, 0.96, 0.78);
        vec3 film_shadow = vec3(0.06, 0.09, 0.08);
        color = mix(color + film_shadow, color * warm_gold, smoothstep(0.12, 0.85, h_luma));
        
        // Optical Halation Diffusion using robust pixel radius
        vec2 halo_step = px * 6.0;
        vec3 s0 = texture(screen_texture, distorted_uv + vec2( halo_step.x, 0.0)).rgb;
        vec3 s1 = texture(screen_texture, distorted_uv - vec2( halo_step.x, 0.0)).rgb;
        vec3 s2 = texture(screen_texture, distorted_uv + vec2( 0.0, halo_step.y)).rgb;
        vec3 s3 = texture(screen_texture, distorted_uv - vec2( 0.0, halo_step.y)).rgb;
        float halo_luma = (dot(s0, vec3(0.299, 0.587, 0.114)) + dot(s1, vec3(0.299, 0.587, 0.114)) + dot(s2, vec3(0.299, 0.587, 0.114)) + dot(s3, vec3(0.299, 0.587, 0.114))) * 0.25;
        float halation_factor = max(smoothstep(0.60, 0.95, h_luma), smoothstep(0.55, 0.90, halo_luma) * 0.8);
        vec3 halation_glow = vec3(1.0, 0.28, 0.08) * (halation_factor * 0.35);
        color += halation_glow;
        
        // Warm 1980s lens optical falloff (amber vignette)
        float lens_vignette = smoothstep(0.9, 0.35, length(center_dist));
        color = mix(color * vec3(0.86, 0.80, 0.72), color, lens_vignette);
        
        // Analog celluloid film grain
        float film_grain = (rand(uv + vec2(TIME * 0.05, TIME * 0.1)) - 0.5) * 0.04;
        color += vec3(film_grain * 1.2, film_grain * 0.8, film_grain * 0.4);
        color = clamp(color, 0.0, 1.0);
    }

    
    // 6. Vignette
    float vignette = smoothstep(0.8, vignette_intensity, length(center_dist));
    color = mix(color, color * vignette, vignette_opacity);
    // Tint edges based on vignette_color alpha
    color = mix(color, vignette_color.rgb, (1.0 - vignette) * vignette_color.a);
    
    // Heat Warning Border (Tint edges based on heat_border_color alpha)
    // Create a very soft, thin translucent gradient border
    vec2 edge_dist = min(uv, 1.0 - uv);
    float soft_border = 1.0 - (smoothstep(0.0, 0.06, edge_dist.x) * smoothstep(0.0, 0.06, edge_dist.y));
    
    // Multiply the base color by a fiery red tint so it meshes perfectly with the scene textures
    vec3 tinted_border = color * vec3(1.5, 0.2, 0.2); 
    color = mix(color, tinted_border, soft_border * heat_border_color.a);
    
    // Frost Border (Tint edges based on frost_mix)
    vec3 icy_border = color * vec3(0.6, 0.8, 1.5) + vec3(0.0, 0.2, 0.4);
    color = mix(color, icy_border, soft_border * frost_mix);
    
    // 7. Searing Flash (Damage/Impact)
    vec3 searing_color = vec3(1.0, 0.8, 0.5); // Searing white/orange
    color = mix(color, searing_color, flash_mix);
    
    COLOR = vec4(color, 1.0);
}
