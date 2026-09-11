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
uniform float color_levels : hint_range(4.0, 64.0) = 32.0;
uniform bool dither_enabled = false;
uniform float dither_strength : hint_range(0.0, 2.0) = 1.0;
uniform float dither_pixel_size : hint_range(1.0, 8.0) = 2.0;
uniform bool heatwave_1984_enabled = false;

// Simple random function based on UV
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// 8x8 Ordered Bayer Matrix for silky retro cross-hatching [0.0, 63.0 / 64.0]
float bayer8x8(vec2 coord) {
    int x = int(coord.x) & 7;
    int y = int(coord.y) & 7;
    int index = x + y * 8;
    float bayer[64] = float[64](
         0.0/64.0, 32.0/64.0,  8.0/64.0, 40.0/64.0,  2.0/64.0, 34.0/64.0, 10.0/64.0, 42.0/64.0,
        48.0/64.0, 16.0/64.0, 56.0/64.0, 24.0/64.0, 50.0/64.0, 18.0/64.0, 58.0/64.0, 26.0/64.0,
        12.0/64.0, 44.0/64.0,  4.0/64.0, 36.0/64.0, 14.0/64.0, 46.0/64.0,  6.0/64.0, 38.0/64.0,
        60.0/64.0, 28.0/64.0, 52.0/64.0, 20.0/64.0, 62.0/64.0, 30.0/64.0, 54.0/64.0, 22.0/64.0,
         3.0/64.0, 35.0/64.0, 11.0/64.0, 43.0/64.0,  1.0/64.0, 33.0/64.0,  9.0/64.0, 41.0/64.0,
        51.0/64.0, 19.0/64.0, 59.0/64.0, 27.0/64.0, 49.0/64.0, 17.0/64.0, 57.0/64.0, 25.0/64.0,
        15.0/64.0, 47.0/64.0,  7.0/64.0, 39.0/64.0, 13.0/64.0, 45.0/64.0,  5.0/64.0, 37.0/64.0,
        63.0/64.0, 31.0/64.0, 55.0/64.0, 23.0/64.0, 61.0/64.0, 29.0/64.0, 53.0/64.0, 21.0/64.0
    );
    return bayer[index];
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // 1. Heat Haze (Distortion)
    // Subtle wavy offset to simulate intense summer heat
    float heat_wave = sin(uv.y * 60.0 + TIME * 4.0) * 0.0015;
    // Distort more towards the horizon/top of screen
    vec2 distorted_uv = uv + vec2(heat_wave * (1.0 - uv.y), 0.0);
    
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
    
    // 5a. "Retro Colors" (PS1 15-bit color reduction + NTSC composite chroma bleed + CRT micro-scanlines)
    if (color_reduction_enabled) {
        float levels = color_levels; // 32.0 levels per RGB channel (15-bit / 32,768 colors)
        
        // NTSC Composite Chroma Delay / Bleed:
        // Simulates analog composite video bandwidth limits where chroma shifts slightly horizontally
        vec2 px = SCREEN_PIXEL_SIZE;
        float r_bleed = texture(screen_texture, distorted_uv - vec2(px.x * 1.5, 0.0)).r;
        float b_bleed = texture(screen_texture, distorted_uv + vec2(px.x * 1.5, 0.0)).b;
        color.r = mix(color.r, r_bleed, 0.20);
        color.b = mix(color.b, b_bleed, 0.20);
        
        // 15-bit quantization
        color = floor(color * levels + 0.5) / levels;
        
        // Subtle CRT Aperture Grille Micro-Scanlines (3.5% alternating line modulation)
        float scanline = (int(FRAGCOORD.y) % 2 == 0) ? 0.965 : 1.0;
        color *= scanline;
        color = clamp(color, 0.0, 1.0);
    }

    // 5b. "Dithering" (8x8 Bayer matrix stippling + resolution-independent virtual retro grid)
    if (dither_enabled) {
        // Virtual retro resolution scaling: anchors the dither pattern to ~540p virtual raster
        // Ensures identical cross-hatching scale across 720p, 1080p, 1440p, and 4K displays
        float ref_scale = max(1.0, round(1.0 / (SCREEN_PIXEL_SIZE.y * 540.0)));
        vec2 dither_coord = floor(FRAGCOORD.xy / (ref_scale * dither_pixel_size * 0.5));
        float b = bayer8x8(dither_coord);
        
        float d_levels = 16.0; // Rich 16-level palette for classic 90s console / FMV stippling
        float cur_luma = dot(color, vec3(0.299, 0.587, 0.114));
        // Luma-weighted dither modulation: preserves crisp specular hot spots while stippling midtones & sky
        float luma_weight = clamp(1.2 - cur_luma * 0.5, 0.35, 1.15);
        
        color += vec3((b - 0.5) * (dither_strength / d_levels) * luma_weight);
        color = clamp(color, 0.0, 1.0);
        color = floor(color * d_levels + 0.5) / d_levels;
    }

    // 5c. "Heatwave 1984" Vintage Kodachrome Grade & Optical Halation Diffusion
    if (heatwave_1984_enabled) {
        // Film tone shoulder curve (smooth highlight compression, preserves facial expressions and cloud volume)
        color = color / (vec3(1.0) + color * 0.22);
        
        // Kodachrome color matrix: warm golden highlights, rich teal-olive shadows
        float h_luma = dot(color, vec3(0.299, 0.587, 0.114));
        vec3 warm_gold = vec3(1.12, 0.96, 0.76);
        vec3 film_shadow = vec3(0.04, 0.07, 0.06);
        
        // Sun-bleached warm highlights and deep rich shadows
        color = mix(color + film_shadow, color * warm_gold, smoothstep(0.12, 0.82, h_luma));
        
        // True Optical Halation Diffusion (4-tap radial cross kernel in screen UV)
        // Light penetrates film emulsion and scatters horizontally & vertically around intense highlights
        vec2 halo_step = SCREEN_PIXEL_SIZE * 5.0;
        vec3 s0 = texture(screen_texture, distorted_uv + vec2( halo_step.x,  0.0)).rgb;
        vec3 s1 = texture(screen_texture, distorted_uv - vec2( halo_step.x,  0.0)).rgb;
        vec3 s2 = texture(screen_texture, distorted_uv + vec2( 0.0,  halo_step.y)).rgb;
        vec3 s3 = texture(screen_texture, distorted_uv - vec2( 0.0,  halo_step.y)).rgb;
        
        float l0 = dot(s0, vec3(0.299, 0.587, 0.114));
        float l1 = dot(s1, vec3(0.299, 0.587, 0.114));
        float l2 = dot(s2, vec3(0.299, 0.587, 0.114));
        float l3 = dot(s3, vec3(0.299, 0.587, 0.114));
        
        float halo_luma = (l0 + l1 + l2 + l3) * 0.25;
        float halo_scatter = smoothstep(0.68, 0.98, halo_luma);
        // Halation color: warm amber-red emulsion back-scatter
        vec3 halation_glow = vec3(1.0, 0.26, 0.06) * (halo_scatter * 0.28);
        color += halation_glow;
        
        // Vintage 1980s lens optical warmth & radial falloff
        float lens_vignette = smoothstep(0.95, 0.35, length(center_dist));
        color = mix(color * vec3(0.88, 0.82, 0.74), color, lens_vignette);
        
        // Analog celluloid film grain
        float film_grain = (rand(uv + vec2(TIME * 0.05, TIME * 0.1)) - 0.5) * 0.035;
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
