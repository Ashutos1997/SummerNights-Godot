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
uniform vec4 ground_color        : source_color = vec4(0.06, 0.14, 0.30, 1.0); // Deep ocean horizon blue
uniform float horizon_spread     : hint_range(0.5, 8.0, 0.1) = 3.2;
uniform float sunset_band_height : hint_range(0.0, 0.4, 0.01) = 0.12;
uniform float sunset_band_sharp  : hint_range(1.0, 30.0, 0.5) = 12.0;

// ── Horizon glow (Atmospheric Bloom) ────────────────────────────────────────
uniform vec4 horizon_glow_color  : source_color = vec4(1.0, 0.58, 0.14, 1.0); // Warm amber sunset glow
uniform float horizon_glow_size  : hint_range(0.01, 0.25, 0.005) = 0.08;      // Broad Gaussian dispersion
uniform float horizon_glow_offset: hint_range(-0.1, 0.1, 0.005) = -0.015;     // Aligns peak with 3D ocean waterline

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
uniform float coronal_mix : hint_range(0.0, 1.0, 0.01) = 0.0;

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

	// Bottom half: deep ocean horizon -> sunset sky
	vec3 bottom = mix(ground_color.rgb, sky_horizon_color.rgb, smoothstep(-0.06, 0.05, h));

	// Sunset amber band just above horizon (smooth Gaussian instead of sharp cusp)
	float band_diff = (h - sunset_band_height) * (sunset_band_sharp * 0.45);
	float band_mask = exp(-band_diff * band_diff);
	vec3 banded = mix(bottom, sky_sunset_color.rgb, band_mask * 0.85);

	// Upper half: blend to zenith
	vec3 upper = mix(banded, sky_zenith_color.rgb, smoothstep(0.0, 0.9, max(h, 0.0)));

	sky_col = mix(bottom, upper, smoothstep(-0.05, 0.1, h));

	// ── Temperature-driven cool shift ───────────────────────────────────
	// When sun cools (sun_heat → 0), transition into multi-band twilight "Summer Night"
	float cool_factor = 1.0 - sun_heat;
	
	// Multi-band twilight palette (Belt of Venus + turquoise seafoam afterglow)
	vec3 cool_ground        = vec3(0.03, 0.08, 0.20); // Deep twilight oceanic navy (matches ocean depth)
	vec3 cool_horizon       = vec3(0.08, 0.48, 0.65); // Vibrant turquoise/aquamarine sea afterglow
	vec3 cool_twilight_band = vec3(0.38, 0.18, 0.48); // Dreamy lavender-pink twilight band (Belt of Venus)
	vec3 cool_mid_sky       = vec3(0.07, 0.15, 0.38); // Deep royal twilight blue
	vec3 cool_zenith        = vec3(0.02, 0.03, 0.14); // Deep cosmic midnight sapphire

	// Step 1: Deep ocean to turquoise horizon
	vec3 cool_bottom = mix(cool_ground, cool_horizon, smoothstep(-0.06, 0.05, h));
	
	// Step 2: Twilight lavender-rose band just above the horizon (h ~ 0.08 - 0.25)
	float cool_band_diff = (h - 0.14) * 4.2;
	float cool_band_mask = exp(-cool_band_diff * cool_band_diff);
	vec3 cool_banded = mix(cool_bottom, cool_twilight_band, cool_band_mask * 0.75);
	
	// Step 3: Upper hemisphere to mid-sky and zenith
	vec3 cool_upper = mix(cool_banded, cool_mid_sky, smoothstep(0.08, 0.50, max(h, 0.0)));
	cool_upper = mix(cool_upper, cool_zenith, smoothstep(0.40, 0.95, max(h, 0.0)));
	
	vec3 cool_sky = mix(cool_bottom, cool_upper, smoothstep(-0.05, 0.10, h));
	sky_col = mix(sky_col, cool_sky, cool_factor * 0.88);
		
	// ── Eclipse override: Normal Eclipse (Cold Lunar Silver-Indigo) ─────
	vec3 eclipse_zenith = vec3(0.01, 0.015, 0.04); // Deep cosmic midnight navy
	vec3 eclipse_horizon = vec3(0.04, 0.10, 0.20); // Pale silvery moonlit horizon rim
	sky_col = mix(sky_col,
		mix(eclipse_horizon, eclipse_zenith, smoothstep(-0.1, 0.8, h)),
		eclipse_mix);

	// ── Coronal Eclipse override: Wave 45+ Solar Maximum (Neon Violet / Magenta) ──
	vec3 coronal_zenith = vec3(0.035, 0.0, 0.07); // Dark obsidian violet
	vec3 coronal_horizon = vec3(0.26, 0.03, 0.30); // Violent electric neon magenta-violet
	sky_col = mix(sky_col,
		mix(coronal_horizon, coronal_zenith, smoothstep(-0.1, 0.8, h)),
		coronal_mix);

	// ── Atmospheric Horizon Glow (Replaces sharp "tube" with natural sunset bloom) ──
	float h_norm = (h - horizon_glow_offset) / horizon_glow_size;
	float glow_mask = exp(-h_norm * h_norm * 0.5);
	// Taper below the sea waterline so the deep ocean stays rich and deep
	glow_mask *= smoothstep(-0.12, -0.02, h);
	// Soft forward bias toward the sun (-Z direction)
	float fwd_bias = mix(0.55, 1.0, clamp(-dir.z, 0.0, 1.0));
	glow_mask *= fwd_bias;

	vec3 sunset_glow = horizon_glow_color.rgb * 0.45;
	vec3 twilight_glow = vec3(0.10, 0.68, 0.82) * 0.32; // Luminous seafoam waterline glow
	vec3 active_glow = mix(sunset_glow, twilight_glow, cool_factor);
	float weather_occlusion = 1.0 - clamp(eclipse_mix + coronal_mix, 0.0, 1.0);
	sky_col += active_glow * glow_mask * weather_occlusion;

	// ── Cosmic Nebula / Milky Way Ribbon ─────────────────────────────────
	if (h > 0.06 && cool_factor > 0.25) {
		vec3 galaxy_normal = normalize(vec3(0.55, 0.72, 0.42));
		float galaxy_dist = abs(dot(dir, galaxy_normal));
		float galaxy_band = smoothstep(0.40, 0.0, galaxy_dist);
		
		if (galaxy_band > 0.01) {
			vec2 galaxy_uv = vec2(dot(dir, vec3(0.7, -0.4, 0.5)), dot(dir, vec3(-0.3, 0.5, 0.7))) * 3.2;
			float nebula_noise = fbm(galaxy_uv);
			float nebula_intensity = smoothstep(0.38, 0.72, nebula_noise) * galaxy_band;
			
			vec3 nebula_magenta = vec3(0.26, 0.08, 0.36);
			vec3 nebula_cyan    = vec3(0.06, 0.24, 0.38);
			vec3 nebula_col = mix(nebula_magenta, nebula_cyan, sin(galaxy_uv.x * 2.2 + TIME * 0.03) * 0.5 + 0.5);
			
			float nebula_vis = smoothstep(0.25, 0.80, cool_factor) * weather_occlusion;
			sky_col += nebula_col * nebula_intensity * nebula_vis * 0.7;
		}
	}

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
		// Normal eclipse reveals brilliant starry sky; coronal eclipse is partially hazed by ultraviolet flare ions
		float star_visibility = clamp(smoothstep(0.15, 0.55, cool_factor) + eclipse_mix + coronal_mix * 0.35, 0.0, 1.0);
		
		float star_horizon_fade = smoothstep(0.08, 0.35, h);
		
		// Brightness scales with size for massive pop on the big stars
		float brightness = mix(2.0, 10.0, star_seed);
		
		sky_col += star_color * (star_mask * shape) * twinkle * star_visibility * star_horizon_fade * brightness;
	}

	// ── Prominent Evening Star (Twilight Venus) ─────────────────────────
	if (h > 0.12 && cool_factor > 0.20) {
		vec3 venus_dir = normalize(vec3(0.68, 0.32, -0.65));
		float venus_dist = length(dir - venus_dir);
		
		// Brilliant diamond core
		float venus_core = smoothstep(0.008, 0.001, venus_dist);
		float venus_halo = smoothstep(0.05, 0.002, venus_dist) * 0.4;
		
		// 4-point diffraction cross (sparkle)
		vec3 d_rel = dir - venus_dir;
		float cross_x = smoothstep(0.0015, 0.0, abs(d_rel.x)) * smoothstep(0.045, 0.0, abs(d_rel.y));
		float cross_y = smoothstep(0.0015, 0.0, abs(d_rel.y)) * smoothstep(0.045, 0.0, abs(d_rel.x));
		float venus_cross = (cross_x + cross_y) * 1.5;
		
		float venus_twinkle = sin(TIME * 2.8) * 0.15 + 0.85;
		vec3 venus_col = vec3(0.88, 0.96, 1.0); // Crystalline white-cyan
		float venus_vis = smoothstep(0.20, 0.65, cool_factor) * (1.0 - eclipse_mix);
		
		sky_col += venus_col * (venus_core * 3.5 + venus_halo + venus_cross) * venus_twinkle * venus_vis;
	}

	// ── Shooting Stars / Meteors ─────────────────────────────────────────
	if (h > 0.18 && cool_factor > 0.35) {
		float meteor_cycle = 4.0;
		float m_time = TIME / meteor_cycle;
		float m_id = floor(m_time);
		float m_phase = fract(m_time);
		
		// Meteor streak lasts ~0.7 seconds (0.175 of cycle)
		float streak_dur = 0.175;
		if (m_phase < streak_dur) {
			float t_streak = m_phase / streak_dur; // 0.0 to 1.0 along the path
			
			float m_seed = hash(vec2(m_id, 41.13));
			float m_seed2 = hash(vec2(m_id + 7.3, 89.21));
			
			float start_azimuth = m_seed * 6.28318;
			float start_h = mix(0.40, 0.85, m_seed2);
			vec3 m_start = normalize(vec3(cos(start_azimuth), start_h, sin(start_azimuth)));
			
			vec3 m_delta = normalize(vec3(-sin(start_azimuth + 0.8), -0.65, cos(start_azimuth + 0.8))) * 0.35;
			vec3 m_head = m_start + m_delta * t_streak;
			
			// Line distance on sphere
			vec3 m_v = dir - m_start;
			float m_proj = dot(m_v, m_delta) / dot(m_delta, m_delta);
			m_proj = clamp(m_proj, max(0.0, t_streak - 0.40), t_streak);
			vec3 m_closest = m_start + m_delta * m_proj;
			float m_dist = length(dir - m_closest);
			
			float m_line = smoothstep(0.005, 0.0006, m_dist);
			float tail_fade = smoothstep(max(0.0, t_streak - 0.40), t_streak, m_proj);
			float head_glow = smoothstep(0.02, 0.0, length(dir - m_head)) * 2.0;
			
			vec3 meteor_color = mix(vec3(0.5, 0.85, 1.0), vec3(1.0, 0.95, 0.8), tail_fade);
			float meteor_vis = smoothstep(0.35, 0.8, cool_factor) * (1.0 - eclipse_mix);
			sky_col += meteor_color * (m_line * tail_fade * 4.0 + head_glow) * meteor_vis;
		}
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
		
		// Cool night clouds: deep indigo silhouettes with silver/cyan lit rims
		vec3 bg_cool_shadow = vec3(0.05, 0.06, 0.15);
		vec3 bg_cool_lit    = vec3(0.45, 0.65, 0.88);
		vec3 bg_cool_col    = mix(bg_cool_shadow, bg_cool_lit, bg_lit);
		bg_cloud_col = mix(bg_cloud_col, bg_cool_col, cool_factor * 0.82);

		// Normal Eclipse clouds (cold indigo with silver moonlit rim)
		vec3 bg_eclipse_cloud = mix(vec3(0.015, 0.02, 0.05), vec3(0.25, 0.38, 0.55), bg_lit);
		// Coronal Eclipse clouds (dark violet with neon magenta prominence rim)
		vec3 bg_coronal_cloud = mix(vec3(0.02, 0.0, 0.04), vec3(0.40, 0.06, 0.45), bg_lit);
		bg_cloud_col = mix(bg_cloud_col, bg_eclipse_cloud, eclipse_mix);
		bg_cloud_col = mix(bg_cloud_col, bg_coronal_cloud, coronal_mix);
		
		sky_col = mix(sky_col, bg_cloud_col, bg_cloud_mask * 0.5);

		// Foreground Cloud Layer
		float fg_cloud_mask = smoothstep(cloud_coverage, cloud_coverage + (1.0 / cloud_sharpness), fg_noise) * altitude_fade;
		float fg_lit = smoothstep(0.45, 0.75, fg_noise);
		vec3 fg_cloud_col = mix(cloud_color_shadow.rgb, cloud_color_lit.rgb, fg_lit);
		
		vec3 fg_cool_shadow = vec3(0.06, 0.08, 0.18); // Deep plum/indigo silhouette
		vec3 fg_cool_lit    = vec3(0.60, 0.78, 0.98); // Brilliant silver/moonlit rim
		vec3 fg_cool_col    = mix(fg_cool_shadow, fg_cool_lit, fg_lit);
		fg_cloud_col = mix(fg_cloud_col, fg_cool_col, cool_factor * 0.85);

		// Normal Eclipse foreground clouds
		vec3 fg_eclipse_cloud = mix(vec3(0.02, 0.03, 0.07), vec3(0.42, 0.58, 0.78), fg_lit);
		// Coronal Eclipse foreground clouds
		vec3 fg_coronal_cloud = mix(vec3(0.03, 0.0, 0.06), vec3(0.60, 0.12, 0.65), fg_lit);
		fg_cloud_col = mix(fg_cloud_col, fg_eclipse_cloud, eclipse_mix);
		fg_cloud_col = mix(fg_cloud_col, fg_coronal_cloud, coronal_mix);

		sky_col = mix(sky_col, fg_cloud_col, fg_cloud_mask * 0.88);
	}

	// ── Final output ─────────────────────────────────────────────────────
	COLOR = sky_col;
}
