shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;

uniform vec4 shield_color : source_color = vec4(0.2, 0.8, 1.0, 1.0);
uniform float fresnel_power = 2.5;
uniform float pulse_speed = 2.0;
uniform float pulse_intensity = 0.3;
uniform float base_alpha = 0.15;
uniform float shield_opacity = 1.0; // For spawn/shatter animation control

void fragment() {
    float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
    
    // Pulsing glow
    float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5) * pulse_intensity;
    
    // Hexagonal pattern using world-space UVs for a techy look
    vec2 hex_uv = VERTEX.xz * 0.6;
    float hex = abs(sin(hex_uv.x * 6.28) * sin(hex_uv.y * 6.28));
    float hex_line = smoothstep(0.02, 0.05, abs(hex - 0.5));
    
    ALBEDO = shield_color.rgb + vec3(pulse * 0.3) + vec3((1.0 - hex_line) * 0.15);
    ALPHA = clamp((fresnel * shield_color.a + base_alpha + pulse * 0.2) * shield_opacity, 0.0, 1.0);
}
