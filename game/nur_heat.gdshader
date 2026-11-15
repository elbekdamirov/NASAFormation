shader_type spatial;
render_mode unshaded, shadows_disabled, depth_draw_never, cull_disabled;

uniform sampler2D scene : hint_screen_texture, repeat_disable, filter_linear;
uniform float strength = 0.0;

void fragment() {
 vec2 center = abs(UV - vec2(0.5));
 float edge = (1.0 - smoothstep(0.13, 0.49, center.x))
             * (1.0 - smoothstep(0.35, 0.50, center.y));
 float pulse = sin(UV.y * 55.0 - TIME * 7.0)
             + sin(UV.y * 110.0 + UV.x * 34.0 - TIME * 12.0) * 0.34;
 vec2 offset = vec2(pulse, sin(UV.x * 51.0 + TIME * 2.9) * 0.25)
             * edge * strength * 0.0038;
 ALBEDO = texture(scene, SCREEN_UV + offset).rgb;
 ALPHA = edge * 0.72 * strength;
}
