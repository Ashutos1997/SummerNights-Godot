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

// ─────────────────────────────────────────────────────────────────────────────
// Hash / value noise helpers (no texture needed)
// ─────────────────────────────────────────────────────────────────────────────
float hash(vec2 p) {
	p = fract(p * vec2(127.1, 311.7));
	p += dot(p, p + 19.19);
	return fract(p.x * p.y);
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

	// ── Horizon glow ─────────────────────────────────────────────────────
	float glow_mask = exp(-abs(h) / horizon_glow_size);
	sky_col += horizon_glow_color.rgb * glow_mask * 0.6 * sun_heat;

	// ── Animated clouds ───────────────────────────────────────────────────
	// Only draw clouds in upper hemisphere (h > -0.04)
	if (h > -0.04) {
		// Project direction to a 2D plane for cloud sampling
		// xz gives a top-down-ish view, scaled by 1/max(h,epsilon) for perspective
		float safe_h = max(h, 0.04);
		vec2 cloud_uv = (dir.xz / safe_h) * (1.0 / cloud_scale);

		// Animated drift
		cloud_uv.x += TIME * cloud_speed;

		float noise = fbm(cloud_uv);

		// Threshold and sharpen to form stylized cloud shapes
		float cloud_mask = smoothstep(
			cloud_coverage,
			cloud_coverage + (1.0 / cloud_sharpness),
			noise
		);

		// Fade clouds near horizon so they don't float on ground
		float altitude_fade = smoothstep(cloud_altitude - 0.06, cloud_altitude + 0.15, h);
		cloud_mask *= altitude_fade;

		// Lit vs shadow based on noise variation
		float lit = smoothstep(0.45, 0.75, noise);
		vec3 cloud_col = mix(cloud_color_shadow.rgb, cloud_color_lit.rgb, lit);

		// Cool the cloud colors when sun cools
		cloud_col = mix(cloud_col, vec3(0.25, 0.3, 0.55), cool_factor * 0.5);

		sky_col = mix(sky_col, cloud_col, cloud_mask * 0.88);
	}

	// ── Final output ─────────────────────────────────────────────────────
	COLOR = sky_col;
}
