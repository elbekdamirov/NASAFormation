shader_type spatial;

uniform vec4 stone : source_color = vec4(0.52,0.37,0.29,1.0);
uniform float layering = 1.0;
varying vec3 rock_pos;

float grit(vec3 p) {
 vec3 i=floor(p);
 vec3 f=smoothstep(vec3(0.0),vec3(1.0),fract(p));
 vec4 a=fract(sin(vec4(dot(i,vec3(113.7,67.1,21.7)))+vec4(0.0,113.7,67.1,180.8))*43758.5453);
 vec4 b=fract(sin(vec4(dot(i,vec3(113.7,67.1,21.7)))+vec4(21.7,135.4,88.8,202.5))*43758.5453);
 return mix(mix(mix(a.x,a.y,f.x),mix(a.z,a.w,f.x),f.y),mix(mix(b.x,b.y,f.x),mix(b.z,b.w,f.x),f.y),f.z);
}

void vertex() {
 rock_pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
}

void fragment() {
 float wear=grit(rock_pos*2.0);
 float band=rock_pos.y*2.8+rock_pos.x*0.31+rock_pos.z*0.27+wear*0.38;
 float seam=smoothstep(0.59,0.95,sin(band*6.2831));
 float fleck=grit(rock_pos*21.0)-0.5;
 float close_detail=1.0-smoothstep(18.0,95.0,length(VERTEX));
 ALBEDO=stone.rgb*(0.69+wear*0.46-seam*0.23*layering+fleck*0.28*close_detail);
 float bump_height=(wear*0.035-seam*0.013+fleck*0.008)*close_detail;
 vec3 sx=dFdx(VERTEX);
 vec3 sy=dFdy(VERTEX);
 vec3 rx=cross(sy,NORMAL);
 vec3 ry=cross(NORMAL,sx);
 float determinant=dot(sx,rx);
 vec3 gradient=sign(determinant)*(dFdx(bump_height)*rx+dFdy(bump_height)*ry);
 NORMAL=normalize(abs(determinant)*NORMAL-gradient*0.18);
 ROUGHNESS=0.89+fleck*0.13;
}
