shader_type canvas_item;
void fragment(){
 vec2 p=UV;
 float glow=exp(-4.3*length((p-vec2(0.25,0.57))*vec2(1.15,0.85)));
 vec3 color=mix(vec3(0.018,0.035,0.056),vec3(0.18,0.087,0.05),glow);
 float grid=(1.0-smoothstep(0.0,0.018,abs(fract(p.x*32.0)-0.5)))*(1.0-smoothstep(0.0,0.018,abs(fract(p.y*18.0)-0.5)));
 color+=vec3(0.08,0.24,0.30)*grid*0.20;
 COLOR=vec4(color,0.88);
}
