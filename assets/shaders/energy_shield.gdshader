shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;

uniform vec4 shield_color : source_color = vec4(0.2, 0.8, 1.0, 1.0);
uniform float fresnel_power = 2.5;
uniform float pulse_speed = 2.0;
uniform float pulse_intensity = 0.3;
uniform float base_alpha = 0.15;
uniform float shield_opacity = 1.0; // For spawn/shatter animation control

// Deflection impact ripple parameters
uniform vec3 hit_point = vec3(0.0, 0.0, 10.0);
uniform float hit_intensity = 0.0; // Decays from 1.0 -> 0.0
uniform float hit_time = 0.0;      // Seconds since hit for expanding ring

varying vec3 local_vertex;

void vertex() {
    local_vertex = VERTEX;
}

void fragment() {
    float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
    
    // Pulsing glow
    float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5) * pulse_intensity;
    
    // Hexagonal pattern using local UVs for a techy look
    vec2 hex_uv = local_vertex.xz * 0.6;
    float hex = abs(sin(hex_uv.x * 6.28) * sin(hex_uv.y * 6.28));
    float hex_line = smoothstep(0.02, 0.05, abs(hex - 0.5));
    
    // Deflection impact ripple & flash
    float hit_dist = distance(local_vertex, hit_point);
    float ring_radius = hit_time * 28.0;
    float ring = smoothstep(2.0, 0.0, abs(hit_dist - ring_radius));
    float impact_glow = smoothstep(5.0, 0.0, hit_dist) * hit_intensity;
    vec3 ripple_color = vec3(0.6, 0.95, 1.0) * (ring * 1.8 + impact_glow * 1.5) * hit_intensity;
    
    ALBEDO = shield_color.rgb + vec3(pulse * 0.3) + vec3((1.0 - hex_line) * 0.15) + ripple_color;
    ALPHA = clamp((fresnel * shield_color.a + base_alpha + pulse * 0.2 + (ring * 0.5 + impact_glow * 0.5) * hit_intensity) * shield_opacity, 0.0, 1.0);
}
