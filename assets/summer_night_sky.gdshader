// Summer Nights Sky Shader
// Procedural stylized sunset sky with animated clouds and horizon glow.
// No external textures required.
// License: CC0

shader_type sky;
render_mode use_half_res_pass;

// ── Sky gradient colors ─────────────────────────────────────────────────────
uniform vec4 sky_zenith_color   : source_color = vec4(0.07, 0.03, 0.18, 1.0); // Deep dark purple at top
uniform vec4 sky_horizon_color  : source_color = vec4(0.85, 0.28, 0.06, 1.0); // Deep orange at horizon
uniform vec4 sky_sunset_color   : source_color = vec4(0.98, 0.52, 0.08, 1.0); // Bright amber band
uniform vec4 ground_color        : source_color = vec4(0.04, 0.02, 0.08, 1.0); // Near-black ground
uniform float horizon_spread     : hint_range(0.5, 8.0, 0.1) = 3.2;
uniform float sunset_band_height : hint_range(0.0, 0.4, 0.01) = 0.12;
uniform float sunset_band_sharp  : hint_range(1.0, 30.0, 0.5) = 12.0;

// ── Horizon glow ────────────────────────────────────────────────────────────
uniform vec4 horizon_glow_color : source_color = vec4(1.0, 0.55, 0.12, 1.0); // Warm amber glow
uniform float horizon_glow_size : hint_range(0.005, 0.15, 0.001) = 0.035;

// ── Animated cloud layer ────────────────────────────────────────────────────
uniform vec4 cloud_color_lit    : source_color = vec4(0.98, 0.62, 0.22, 1.0); // Lit cloud (orange-gold)
uniform vec4 cloud_color_shadow : source_color = vec4(0.35, 0.12, 0.28, 1.0); // Shadow cloud (deep plum)
uniform float cloud_coverage    : hint_range(0.0, 1.0, 0.01) = 0.42;
uniform float cloud_sharpness   : hint_range(1.0, 6.0, 0.1) = 2.2;
uniform float cloud_speed       : hint_range(0.0, 0.2, 0.001) = 0.018;
uniform float cloud_altitude    : hint_range(0.0, 0.7, 0.01) = 0.18; // vertical position
uniform float cloud_scale       : hint_range(0.5, 8.0, 0.1) = 3.5;

// ── Temperature-driven transition ───────────────────────────────────────────
// 0.0 = cool dusk blue, 1.0 = scorching orange sunset
uniform float sun_heat : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float eclipse_mix : hint_range(0.0, 1.0, 0.01) = 0.0;

// ─────────────────────────────────────────────────────────────────────────────
// Hash / value noise helpers (no texture needed)
// ─────────────────────────────────────────────────────────────────────────────
float hash(vec2 p) {
	p = fract(p * vec2(127.1, 311.7));
	p += dot(p, p + 19.19);
	return fract(p.x * p.y);
}

float hash3(vec3 p) {
	return fract(sin(dot(p, vec3(12.9898, 78.233, 45.164))) * 43758.5453);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f); // smoothstep
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// 3 octaves of fBm for cloud detail
float fbm(vec2 p) {
	float v = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 3; i++) {
		v += amp * value_noise(p);
		p *= 2.1;
		amp *= 0.5;
	}
	return v;
}

// ─────────────────────────────────────────────────────────────────────────────

void sky() {
	// UV in [-1,1] range
	vec3 dir = EYEDIR;

	// Vertical fraction: 0.0 = horizon, 1.0 = zenith, -1.0 = nadir
	float h = dir.y; // [-1, 1]

	// ── Base sky gradient ────────────────────────────────────────────────
	// Blend: ground -> horizon -> sunset_band -> zenith
	vec3 sky_col;

	// horizon blend factor (compressed at bottom)
	float t_horizon = clamp(h * horizon_spread, -1.0, 1.0) * 0.5 + 0.5;

	// Bottom half: ground -> horizon
	vec3 bottom = mix(ground_color.rgb, sky_horizon_color.rgb, smoothstep(-0.05, 0.05, h));

	// Sunset amber band just above horizon
	float band_mask = exp(-abs(h - sunset_band_height) * sunset_band_sharp);
	vec3 banded = mix(bottom, sky_sunset_color.rgb, band_mask * 0.85);

	// Upper half: blend to zenith
	vec3 upper = mix(banded, sky_zenith_color.rgb, smoothstep(0.0, 0.9, max(h, 0.0)));

	sky_col = mix(bottom, upper, smoothstep(-0.05, 0.1, h));

	// ── Temperature-driven cool shift ───────────────────────────────────
	// When sun cools (sun_heat → 0) the sky shifts toward deep dusk blue
	vec3 cool_zenith   = vec3(0.04, 0.06, 0.22);
	vec3 cool_horizon  = vec3(0.18, 0.35, 0.72);
	float cool_factor = 1.0 - sun_heat;
	sky_col = mix(sky_col,
		mix(cool_horizon, cool_zenith, smoothstep(-0.1, 0.8, h)),
		cool_factor * 0.7);
		
	// ── Eclipse override ─────────────────────────────────────────────────
	vec3 eclipse_zenith = vec3(0.02, 0.0, 0.05);
	vec3 eclipse_horizon = vec3(0.15, 0.02, 0.2);
	sky_col = mix(sky_col,
		mix(eclipse_horizon, eclipse_zenith, smoothstep(-0.1, 0.8, h)),
		eclipse_mix);

	// ── Horizon glow ─────────────────────────────────────────────────────
	float glow_mask = exp(-abs(h) / horizon_glow_size);
	sky_col += horizon_glow_color.rgb * glow_mask * 0.6 * sun_heat * (1.0 - eclipse_mix);

	// ── Procedural Stars ─────────────────────────────────────────────────
	if (h > 0.0) {
		vec3 p = dir * 600.0;
		vec3 i = floor(p);
		vec3 f = fract(p);
		
		float star_noise = hash3(i);
		// Only ~0.8% of cells get a star, giving varied brightness
		float star_mask = smoothstep(0.992, 1.0, star_noise);
		
		// Independent seed for size and color
		float star_seed = hash3(i + vec3(12.3, 45.6, 78.9));
		
		// Varied sizing: map seed to a slightly larger radius (0.2 to 0.6)
		float star_radius = mix(0.2, 0.6, star_seed);
		float dist = length(f - vec3(0.5));
		float shape = smoothstep(star_radius, star_radius * 0.1, dist);
		
		// Color variation
		vec3 color_a = vec3(1.0, 0.75, 0.45); // Subtle Orange
		vec3 color_b = vec3(0.65, 0.85, 1.0); // Subtle Blue
		vec3 color_c = vec3(1.0, 0.98, 0.95); // Warm White
		
		vec3 star_color = mix(mix(color_a, color_b, step(0.33, star_seed)), color_c, step(0.66, star_seed));
		
		float twinkle = sin(TIME * (2.0 + star_noise * 5.0) + star_noise * 100.0) * 0.5 + 0.5;
		
		// Map cool_factor (0.0 = hot, 1.0 = cool) so stars are fully visible earlier
		// At cool_factor 0.6 (Sun 40% heat), stars are fully visible.
		float star_visibility = clamp(smoothstep(0.2, 0.6, cool_factor) + eclipse_mix, 0.0, 1.0);
		
		float star_horizon_fade = smoothstep(0.1, 0.4, h);
		
		// Brightness scales with size for massive pop on the big stars
		float brightness = mix(2.0, 10.0, star_seed);
		
		sky_col += star_color * (star_mask * shape) * twinkle * star_visibility * star_horizon_fade * brightness;
	}

	// ── Animated clouds (Parallax) ────────────────────────────────────────
	// Only draw clouds in upper hemisphere (h > -0.04)
	if (h > -0.04) {
		float safe_h = max(h, 0.04);
		vec2 base_cloud_uv = (dir.xz / safe_h) * (1.0 / cloud_scale);

		// Secondary background clouds (parallax)
		vec2 bg_cloud_uv = base_cloud_uv * 1.5;
		bg_cloud_uv.x += TIME * cloud_speed * 0.6;
		
		// Primary foreground clouds
		vec2 fg_cloud_uv = base_cloud_uv;
		fg_cloud_uv.x += TIME * cloud_speed;
		
		float bg_noise = fbm(bg_cloud_uv);
		float fg_noise = fbm(fg_cloud_uv);
		
		// Fade clouds near horizon so they don't float on ground
		float altitude_fade = smoothstep(cloud_altitude - 0.06, cloud_altitude + 0.15, h);
		
		// Background Cloud Layer
		float bg_cloud_mask = smoothstep(cloud_coverage + 0.1, cloud_coverage + 0.1 + (1.0 / cloud_sharpness), bg_noise) * altitude_fade;
		float bg_lit = smoothstep(0.45, 0.75, bg_noise);
		vec3 bg_cloud_col = mix(cloud_color_shadow.rgb * 0.7, cloud_color_lit.rgb * 0.8, bg_lit);
		bg_cloud_col = mix(bg_cloud_col, vec3(0.2, 0.25, 0.45), cool_factor * 0.5);
		vec3 bg_eclipse_cloud = mix(vec3(0.005, 0.0, 0.02), vec3(0.05, 0.01, 0.1), bg_lit);
		bg_cloud_col = mix(bg_cloud_col, bg_eclipse_cloud, eclipse_mix);
		
		sky_col = mix(sky_col, bg_cloud_col, bg_cloud_mask * 0.5);

		// Foreground Cloud Layer
		float fg_cloud_mask = smoothstep(cloud_coverage, cloud_coverage + (1.0 / cloud_sharpness), fg_noise) * altitude_fade;
		float fg_lit = smoothstep(0.45, 0.75, fg_noise);
		vec3 fg_cloud_col = mix(cloud_color_shadow.rgb, cloud_color_lit.rgb, fg_lit);
		fg_cloud_col = mix(fg_cloud_col, vec3(0.25, 0.3, 0.55), cool_factor * 0.5);
		vec3 fg_eclipse_cloud = mix(vec3(0.01, 0.0, 0.05), vec3(0.1, 0.02, 0.2), fg_lit);
		fg_cloud_col = mix(fg_cloud_col, fg_eclipse_cloud, eclipse_mix);

		sky_col = mix(sky_col, fg_cloud_col, fg_cloud_mask * 0.88);
	}

	// ── Final output ─────────────────────────────────────────────────────
	COLOR = sky_col;
}
