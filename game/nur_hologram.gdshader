shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 tint : source_color = vec4(0.32, 0.94, 0.78, 0.36);
uniform float animation = 1.0;
varying float elevation;

void vertex() {
 elevation = (MODEL_MATRIX*vec4(VERTEX,1.0)).y;
}

void fragment() {
 float line = smoothstep(0.76,0.95,fract(elevation*7.5-TIME*animation*0.9));
 float edge = pow(1.0-abs(dot(NORMAL,VIEW)),2.7);
 ALBEDO = tint.rgb * (0.79 + 0.2*line);
 ALPHA = tint.a * (0.29 + 0.43*edge + 0.53*line);
}
