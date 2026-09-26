shader_type canvas_item;

// Energy color (cyan default, shifts to amber at low timer)
uniform vec4 energy_color : source_color = vec4(0.17, 0.90, 1.0, 1.0);
// Overall intensity (0 = invisible, 1 = full strength)
uniform float energy_alpha : hint_range(0.0, 1.0) = 0.0;
// Pulse speed (radians per second)
uniform float pulse_speed : hint_range(0.0, 16.0) = 3.0;
// Pulse depth — how much alpha oscillates (0 = no pulse, 1 = full swing)
uniform float pulse_depth : hint_range(0.0, 0.5) = 0.08;
// Vignette softness — higher = larger transparent center
uniform float vignette_inner : hint_range(0.0, 1.0) = 0.46;
uniform float vignette_outer : hint_range(0.0, 1.5) = 0.95;

// --- Procedural energy particle motes ---
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV - 0.5; // Center-origin UV
	float dist = length(uv * vec2(1.0, 0.5625)); // Adjust for 16:9 aspect
	
	// Radial vignette mask: 0 at center, 1 at edges
	float vignette = smoothstep(vignette_inner, vignette_outer, dist);
	
	// Breathing pulse
	float pulse = 1.0 - pulse_depth + pulse_depth * sin(TIME * pulse_speed);
	float final_alpha = energy_alpha * vignette * pulse;
	
	// --- Delicate energy particle motes ---
	vec3 mote_rgb = vec3(0.0);
	float mote_total_intensity = 0.0;
	
	if (energy_alpha > 0.01) {
		// Motes stay along the outer vignette border
		float mote_zone = smoothstep(vignette_inner * 0.85, vignette_outer, dist);
		
		for (int layer = 0; layer < 3; layer++) {
			float fl = float(layer);
			float layer_offset = fl * 23.7;
			
			// Gentle rising drift with swaying motion
			vec2 drift = vec2(
				sin(TIME * (0.3 + fl * 0.12) + layer_offset) * 0.04,
				-TIME * (0.025 + fl * 0.015)
			);
			vec2 pos = UV + drift;
			
			// Cell grid for distributing motes
			float cell_size = 0.08 + fl * 0.04;
			vec2 cell = floor(pos / cell_size);
			vec2 cell_uv = fract(pos / cell_size);
			
			// Random position within cell (padded to stay within bounds)
			vec2 p = vec2(hash(cell + layer_offset), hash(cell + 13.9 + layer_offset));
			p = 0.18 + 0.64 * p;
			
			float d = length(cell_uv - p);
			
			// Gentle sparkle twinkle frequency per mote
			float twinkle_spd = 2.0 + hash(cell + 4.1) * 3.0;
			float twinkle = 0.4 + 0.6 * sin(TIME * twinkle_spd + hash(cell + 8.2) * 6.28);
			
			// Delicate core and soft bloom halo
			float core = smoothstep(0.045, 0.0, d);
			float halo = smoothstep(0.16, 0.0, d) * 0.3;
			float m = (core * 1.1 + halo) * twinkle * mote_zone;
			
			// Subtle incandescent center blending into energy color halo
			vec3 col = mix(energy_color.rgb, vec3(1.0, 1.0, 1.0), core * 0.6);
			mote_rgb += col * m;
			mote_total_intensity += m * (0.45 - fl * 0.1);
		}
	}
	
	// Balanced blend: softer motes and clean atmospheric vignette
	vec3 out_color = mix(energy_color.rgb, mote_rgb, clamp(mote_total_intensity * 0.5, 0.0, 1.0));
	float mote_alpha = mote_total_intensity * clamp(energy_alpha * 1.3, 0.0, 0.35);
	float combined_alpha = clamp(final_alpha + mote_alpha, 0.0, 0.70);
	
	COLOR = vec4(out_color, combined_alpha);
}
