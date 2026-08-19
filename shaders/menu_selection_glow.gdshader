shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.35, 0.95, 1.0, 1.0);
uniform float glow_strength : hint_range(0.0, 1.0) = 0.0;
uniform float outline_size : hint_range(0.0, 0.08) = 0.035;

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    float alpha = base.a;
    float halo = 0.0;
    vec2 texel = TEXTURE_PIXEL_SIZE * (outline_size * 48.0);
    halo += texture(TEXTURE, UV + vec2(texel.x, 0.0)).a;
    halo += texture(TEXTURE, UV - vec2(texel.x, 0.0)).a;
    halo += texture(TEXTURE, UV + vec2(0.0, texel.y)).a;
    halo += texture(TEXTURE, UV - vec2(0.0, texel.y)).a;
    halo += texture(TEXTURE, UV + texel).a;
    halo += texture(TEXTURE, UV - texel).a;
    halo += texture(TEXTURE, UV + vec2(texel.x, -texel.y)).a;
    halo += texture(TEXTURE, UV + vec2(-texel.x, texel.y)).a;
    halo = clamp(halo / 8.0 - alpha, 0.0, 1.0);
    float pulse = glow_strength * glow_strength;
    vec3 lit = mix(base.rgb, glow_color.rgb, clamp(pulse * 0.72, 0.0, 0.72));
    COLOR = vec4(lit + glow_color.rgb * halo * pulse * 0.85, max(alpha, halo * pulse * 0.8));
}
