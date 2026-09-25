shader_type spatial;
render_mode blend_add, unshaded, cull_disabled, depth_draw_never;

uniform vec4 ray_color : source_color = vec4(1.0, 0.86, 0.45, 0.38);
uniform float heat_ratio : hint_range(0.0, 1.0) = 1.0;
uniform float wave_speed : hint_range(0.5, 5.0) = 2.2;

void fragment() {
	// Normalized centered coordinates: [-1.0, 1.0]
	vec2 center_uv = (UV - vec2(0.5)) * 2.0;
	float r = length(center_uv);
	
	// Outer boundary smooth fade (zero square quad border)
	float outer_fade = smoothstep(1.0, 0.45, r);
	
	// Organic heat-haze angular wobble (prevents rigid mathematical circle)
	float angle = atan(center_uv.y, center_uv.x);
	float wobble = sin(angle * 6.0 + TIME * 1.5) * 0.035 * r;
	float dist = clamp(r + wobble, 0.0, 1.0);
	
	// 1. Core Coronal Glow (soft exponential atmospheric bloom crowning the sun)
	float core_glow = exp(-dist * 3.4);
	
	// 2. Concentric Expanding Heat Ripples (radiating outward into the sky)
	float ripple_phase = dist * 14.0 - TIME * wave_speed;
	float ripple_wave = sin(ripple_phase) * 0.5 + 0.5;
	float ripples = pow(ripple_wave, 2.8); // Soft, luminous ripple crests
	
	// Envelope: ripples emerge gently past sun disk and fade before outer perimeter
	float ripple_envelope = smoothstep(0.12, 0.32, dist) * (1.0 - smoothstep(0.5, 0.95, dist));
	float heat_waves = ripples * ripple_envelope * 0.52 * heat_ratio;
	
	// Combined luminous celestial aura
	float total_lum = (core_glow + heat_waves) * outer_fade;
	
	// Dynamic heat scaling: dissolves cleanly to 0.0 as sun cools
	float alpha = clamp(total_lum * ray_color.a * heat_ratio, 0.0, 1.0);
	
	ALBEDO = ray_color.rgb;
	ALPHA = alpha;
}
