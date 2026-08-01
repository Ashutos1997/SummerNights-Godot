// Summer Nights Heat Haze Shader
// Screen space post-processing distortion that warps the view based on temperature.
// License: CC0 / MIT

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float heat_ratio : hint_range(0.0, 1.0) = 1.0;
uniform float base_distortion : hint_range(0.0, 0.05) = 0.006;
uniform float wave_speed : hint_range(0.1, 10.0) = 3.5;
uniform float wave_frequency : hint_range(1.0, 50.0) = 22.0;

// Solar Wind
uniform float wind_strength : hint_range(0.0, 1.0) = 0.0;
uniform float wind_dir : hint_range(-1.0, 1.0) = 1.0;

// 2D noise helper
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

void fragment() {
	float current_distortion = base_distortion * heat_ratio;
	
	if (current_distortion > 0.0001 || wind_strength > 0.001) {
		vec2 uv = SCREEN_UV;
		
		// Base heat haze (rising air)
		vec2 noise_uv = uv * wave_frequency;
		noise_uv.y -= TIME * wave_speed;
		
		float offset_x = (noise(noise_uv) * 2.0 - 1.0) * current_distortion;
		float offset_y = (noise(noise_uv + vec2(15.0, 15.0)) * 2.0 - 1.0) * current_distortion * 0.4;
		
		// Wind distortion (fast horizontal streaking)
		if (wind_strength > 0.001) {
			vec2 wind_uv = uv * vec2(10.0, 40.0);
			wind_uv.x -= TIME * 15.0 * wind_dir; // Fast horizontal movement
			float wind_noise = noise(wind_uv);
			offset_x += (wind_noise * 2.0 - 1.0) * 0.015 * wind_strength;
			// Add a slight horizontal blur/streak effect using noise
			uv.x += (noise(wind_uv + vec2(30.0, 0.0)) - 0.5) * 0.02 * wind_strength;
		}
		
		uv.x += offset_x;
		uv.y += offset_y;
		
		COLOR = texture(screen_texture, uv);
	} else {
		COLOR = texture(screen_texture, SCREEN_UV);
	}
}
