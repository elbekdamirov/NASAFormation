shader_type spatial;
render_mode blend_mix, cull_disabled;

varying vec2 world_xz;

void vertex() {
 world_xz = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
 vec2 p = world_xz;
 float waves = sin(p.x * 2.1 + p.y * 0.7 + TIME * 2.3)
             * sin(p.y * 1.6 - p.x * 0.8 + TIME * 1.7);
 float rim = pow(1.0 - abs(dot(NORMAL, VIEW)), 3.0);
 ALBEDO = mix(vec3(0.07, 0.22, 0.30), vec3(0.40, 0.67, 0.76), rim);
 ALBEDO += vec3(0.025 * waves);
 ROUGHNESS = 0.2 + waves * 0.065;
 SPECULAR = 0.8;
 ALPHA = 0.83;
}
