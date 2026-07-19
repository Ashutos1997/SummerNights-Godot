// Summer Nights Stylized Water Shader
// Procedural stylized 3D water with vertex waves, depth gradient, and shoreline foam.
// License: CC0 / MIT

shader_type spatial;
render_mode depth_draw_always, specular_toon;

uniform sampler2D depth_texture : hint_depth_texture, filter_nearest;

// ── Colors ──────────────────────────────────────────────────────────────────
uniform vec4 color_shallow : source_color = vec4(0.12, 0.45, 0.55, 0.65); // Warm teal
uniform vec4 color_deep    : source_color = vec4(0.08, 0.15, 0.35, 0.9);  // Deep tropical blue-purple
uniform vec4 color_foam    : source_color = vec4(1.0, 1.0, 1.0, 1.0);     // Bright white foam

// ── Depth & Fog ─────────────────────────────────────────────────────────────
uniform float depth_distance : hint_range(0.1, 10.0, 0.1) = 4.0;
uniform float foam_amount    : hint_range(0.0, 4.0, 0.05) = 0.8;

// ── Waves ───────────────────────────────────────────────────────────────────
uniform float wave_speed  : hint_range(0.1, 4.0, 0.1) = 1.2;
uniform float wave_scale  : hint_range(0.1, 5.0, 0.1) = 1.5;
uniform vec2 wave_dir1    = vec2(1.0, 0.5);
uniform vec2 wave_dir2    = vec2(-0.5, 0.8);
uniform float wave_height1 : hint_range(0.0, 1.0, 0.05) = 0.25;
uniform float wave_height2 : hint_range(0.0, 1.0, 0.05) = 0.15;

// ─────────────────────────────────────────────────────────────────────────────
// Noise helper for wave displacement & foam pattern
// ─────────────────────────────────────────────────────────────────────────────
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
	           mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

// ─────────────────────────────────────────────────────────────────────────────

void vertex() {
	// Generate stylized vertex waves
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	float t = TIME * wave_speed;
	
	// Stacked sine waves for stylized low-poly wave motion
	float w1 = sin(world_pos.x * wave_scale * wave_dir1.x + world_pos.z * wave_scale * wave_dir1.y + t) * wave_height1;
	float w2 = cos(world_pos.x * wave_scale * wave_dir2.x + world_pos.z * wave_scale * wave_dir2.y + t * 1.5) * wave_height2;
	
	VERTEX.y += w1 + w2;
}

void fragment() {
	// ── Depth Buffer sampling for shoreline foam detection ───────────────────
	float depth_raw = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	
	// Convert NDC depth to linear eye depth
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_raw, 1.0);
	float pixel_depth = -upos.z / upos.w;
	
	// Distance from water surface to geometry below it
	float depth_diff = pixel_depth - VERTEX.z;
	
	// ── Color Gradient based on water depth ──────────────────────────────────
	float depth_factor = clamp(depth_diff / depth_distance, 0.0, 1.0);
	vec3 water_base = mix(color_shallow.rgb, color_deep.rgb, depth_factor);
	
	// ── Edge Foam / Shoreline Foam ───────────────────────────────────────────
	// High foam where depth difference is very small (near intersection edges)
	float shore_mask = 1.0 - clamp(depth_diff / foam_amount, 0.0, 1.0);
	
	// Add scrolling noise to shoreline foam for stylized organic wave break
	float foam_noise = noise(UV * 8.0 + vec2(TIME * 0.15, TIME * 0.1));
	float foam_final_mask = smoothstep(0.15, 0.65, shore_mask + (foam_noise * 0.25 * shore_mask));
	
	vec3 final_color = mix(water_base, color_foam.rgb, foam_final_mask);
	
	// ── Toon specular reflection (Toon mode) ─────────────────────────────────
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	vec3 reflection_col = vec3(0.98, 0.72, 0.35); // Warm sunset reflection
	final_color = mix(final_color, reflection_col, fresnel * 0.45);
	
	ALBEDO = final_color;
	ALPHA = mix(color_shallow.a, color_deep.a, depth_factor);
	ROUGHNESS = 0.15;
	METALLIC = 0.1;
}
