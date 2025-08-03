shader_type canvas_item;

uniform bool enabled = true;
uniform float tint_strength : hint_range(0.0, 1.0) = 0.6; // 0=no tint, 1=full yellow tint

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec3 yellow = vec3(1.0, 1.0, 0.0);
    vec3 tinted = mix(tex_color.rgb, yellow, tint_strength);

    // Only apply the tint if enabled is true
    if (enabled) {
        COLOR = vec4(tinted, tex_color.a);
    } else {
        COLOR = tex_color;
    }
}
