// Summer Nights Stylized Water Shader
// Procedural stylized 3D water with Gerstner waves, depth gradient, Voronoi surface foam, and subsurface scattering.
// License: CC0 / MIT

shader_type spatial;
render_mode depth_draw_always, specular_toon;

uniform sampler2D depth_texture : hint_depth_texture, filter_nearest;

// ── Colors ──────────────────────────────────────────────────────────────────
uniform vec4 color_shallow : source_color = vec4(0.12, 0.45, 0.55, 0.65); // Warm teal
uniform vec4 color_deep    : source_color = vec4(0.08, 0.15, 0.35, 1.0);  // Deep tropical blue-purple, fully opaque
uniform vec4 color_foam    : source_color = vec4(1.0, 1.0, 1.0, 1.0);     // Bright white foam

// ── Depth & Fog ─────────────────────────────────────────────────────────────
uniform float depth_distance : hint_range(0.1, 10.0, 0.1) = 4.0;
uniform float foam_amount    : hint_range(0.0, 4.0, 0.05) = 1.5;

// ── Waves ───────────────────────────────────────────────────────────────────
uniform float wave_speed  : hint_range(0.1, 4.0, 0.1) = 1.2;

// Gerstner Wave Parameters
uniform vec2 gerstner_dir1 = vec2(1.0, 0.5);
uniform float gerstner_steepness1 : hint_range(0.0, 1.0, 0.05) = 0.45;
uniform float gerstner_wavelength1 : hint_range(1.0, 50.0, 1.0) = 10.0;

uniform vec2 gerstner_dir2 = vec2(-0.5, 0.8);
uniform float gerstner_steepness2 : hint_range(0.0, 1.0, 0.05) = 0.35;
uniform float gerstner_wavelength2 : hint_range(1.0, 50.0, 1.0) = 7.0;

// ── Rogue Waves ─────────────────────────────────────────────────────────────
uniform float wave_pulse_offset = -1000.0;
uniform float pulse_width : hint_range(0.1, 20.0, 0.1) = 6.0;
uniform float pulse_height : hint_range(0.0, 15.0, 0.1) = 1.8;
uniform float pulse_curl : hint_range(0.0, 2.0, 0.05) = 0.0;

varying float pulse_mask;
varying float wave_height_factor; // Passed to fragment for fake SSS

// ─────────────────────────────────────────────────────────────────────────────
// Noise helpers
// ─────────────────────────────────────────────────────────────────────────────
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec2 random2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
	           mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float voronoi(vec2 x) {
    vec2 n = floor(x);
    vec2 f = fract(x);
    float m = 8.0;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 g = vec2(float(i), float(j));
            vec2 o = random2(n + g);
            o = 0.5 + 0.5 * sin(TIME * 0.5 + 6.2831 * o);
            vec2 r = g - f + o;
            float d = dot(r, r);
            m = min(m, d);
        }
    }
    return sqrt(m);
}

// ── Gerstner Wave Function ──
vec3 gerstner_wave(vec2 dir, float steepness, float wavelength, vec3 p, float t) {
    float k = 6.28318 / wavelength;
    float c = sqrt(9.8 / k) * wave_speed; // Physical speed
    vec2 d = normalize(dir);
    float f = k * (dot(d, p.xz) - c * t);
    float a = steepness / k;
    
    return vec3(d.x * (a * cos(f)), a * sin(f), d.y * (a * cos(f)));
}

// ─────────────────────────────────────────────────────────────────────────────

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float t = TIME;
	
	// Apply Gerstner waves
	vec3 g1 = gerstner_wave(gerstner_dir1, gerstner_steepness1, gerstner_wavelength1, world_pos, t);
	vec3 g2 = gerstner_wave(gerstner_dir2, gerstner_steepness2, gerstner_wavelength2, world_pos, t);
	
	// Rogue Wave Pulse traveling along Z
	float pulse_pos = wave_pulse_offset;
	float dist = abs(world_pos.z - pulse_pos);
	float p_mask = exp(-dist * dist / (pulse_width * pulse_width));
	pulse_mask = p_mask;
	
	// Combine displacements
	vec3 total_displacement = g1 + g2;
	
	// Add rogue wave
	total_displacement.y += (p_mask * pulse_height);
	total_displacement.z += (p_mask * pulse_height * pulse_curl);
	
	VERTEX += total_displacement;
	
	// Pass total wave height to fragment shader for SSS/crest highlighting
	// Normalize against expected max height
	wave_height_factor = clamp((total_displacement.y + 0.5) / 2.0, 0.0, 1.0);
}

void fragment() {
	float depth_raw = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_raw, 1.0);
	float pixel_depth = -upos.z / upos.w;
	float depth_diff = pixel_depth - VERTEX.z;
	
	// ── Color Gradient based on water depth ──────────────────────────────────
	float depth_factor = clamp(depth_diff / depth_distance, 0.0, 1.0);
	vec3 water_base = mix(color_shallow.rgb, color_deep.rgb, depth_factor);
	
	// ── Fake Subsurface Scattering (SSS) ─────────────────────────────────────
	// Brighten the wave crests based on height to fake SSS
	float crest_glow = pow(wave_height_factor, 1.5) * 0.4;
	water_base = mix(water_base, color_shallow.rgb * 1.5, crest_glow);
	
	// ── Edge Foam / Shoreline Foam ───────────────────────────────────────────
	float shore_mask = 1.0 - clamp(depth_diff / foam_amount, 0.0, 1.0);
	float foam_noise = noise(UV * 8.0 + vec2(TIME * 0.15, TIME * 0.1));
	float foam_final_mask = smoothstep(0.15, 0.65, shore_mask + (foam_noise * 0.25 * shore_mask));
	
	// ── Procedural Surface Foam (Voronoi) ────────────────────────────────────
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float v_noise = voronoi(world_pos.xz * 0.4 + vec2(TIME * -0.1, TIME * 0.05));
	// Sharp, thin foam lines
	float surface_foam = 1.0 - smoothstep(0.0, 0.25, v_noise);
	// Fade surface foam out in deep water so it doesn't look overwhelming
	surface_foam *= clamp(1.0 - depth_factor * 0.5, 0.0, 1.0) * 0.45;
	
	foam_final_mask = clamp(foam_final_mask + surface_foam, 0.0, 1.0);
	
	// Add rogue wave crest foam
	float rogue_foam_mask = smoothstep(0.5, 0.95, pulse_mask) * (0.8 + foam_noise * 0.5);
	foam_final_mask = clamp(foam_final_mask + rogue_foam_mask, 0.0, 1.0);
	
	vec3 final_color = mix(water_base, color_foam.rgb, foam_final_mask);
	
	// ── Toon specular reflection (Toon mode) ─────────────────────────────────
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	vec3 reflection_col = vec3(0.98, 0.72, 0.35); // Warm sunset reflection
	float dist_fade = smoothstep(150.0, 50.0, -VERTEX.z);
	final_color = mix(final_color, reflection_col, fresnel * 0.45 * dist_fade);
	
	ALBEDO = final_color;
	ALPHA = mix(color_shallow.a, color_deep.a, depth_factor);
	ROUGHNESS = 0.15;
	METALLIC = 0.1;
}
