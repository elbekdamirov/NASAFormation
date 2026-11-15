shader_type spatial;
render_mode cull_back;
varying vec3 world_pos;
varying vec3 terrain_normal;
uniform float growth = 0.0;
uniform float wetness = 0.0;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise2(vec2 p){vec2 i=floor(p);vec2 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){
 world_pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
 terrain_normal=normalize(MODEL_NORMAL_MATRIX*NORMAL);
}
void fragment(){
 vec2 p=world_pos.xz;
 float broad=noise2(p*0.065);
 float patches=noise2(p*0.61);
 float gravel=noise2(p*6.5);
 float flecks=noise2(p*28.0);
 float distance_fade=1.0-smoothstep(14.0,85.0,length(VERTEX));
 float band_height=world_pos.y+p.x*0.071+p.y*0.035+noise2(p*0.032)*2.7;
 float erosion=noise2(p*0.38);
 float layers=(sin(band_height*2.8)*0.049+sin(band_height*8.9)*0.016)*(0.55+erosion*0.7);
 float dune=sin(p.x*4.4+p.y*1.7+noise2(p*0.36)*4.4)*0.018;
 float highlands=smoothstep(47.0,109.0,max(-p.x,-p.y));
 float lakebed=1.0-smoothstep(34.0,61.0,distance(p,vec2(105.0,100.0)));
 float slope=1.0-clamp(terrain_normal.y,0.0,1.0);
 vec3 sand=mix(vec3(0.23,0.105,0.072),vec3(0.49,0.25,0.153),broad*0.62+0.20);
 vec3 basalt=mix(vec3(0.14,0.11,0.12),vec3(0.32,0.22,0.21),broad+layers);
 vec3 sediment=mix(vec3(0.24,0.19,0.17),vec3(0.45,0.33,0.27),patches);
 vec3 dust=mix(mix(sand,basalt,clamp(highlands*0.62+slope*1.72,0.0,1.0)),sediment,lakebed*0.63);
 float channels=noise2(vec2(p.x*0.092,p.y*0.035)+vec2(0.0,broad*2.0));
 dust *= 0.86+0.27*smoothstep(0.19,0.85,channels);
 float cover = smoothstep(0.32,0.72,broad) * growth;
 vec3 ground = mix(dust, mix(vec3(0.15,0.23,0.11),vec3(0.36,0.40,0.19),gravel),cover);
 vec2 pebble_cell=floor(p*3.1);
 vec2 pebble_offset=vec2(hash(pebble_cell),hash(pebble_cell+vec2(43.1,17.7)))*0.48+0.26;
 vec2 pebble_shape=(fract(p*3.1)-pebble_offset)*vec2(1.0,1.55);
 float pebble_size=mix(0.06,0.24,hash(pebble_cell+vec2(91.7,11.0)));
 float pebble=(1.0-smoothstep(pebble_size*0.68,pebble_size,length(pebble_shape)))*smoothstep(0.43,0.77,patches);
 float grain=(gravel-0.5)*0.061+(flecks-0.5)*0.025+dune;
 ALBEDO=max(vec3(0.014),ground*(0.82+patches*0.31)+vec3(grain*distance_fade + layers*(0.14+slope*0.95)));
 ALBEDO=mix(ALBEDO,vec3(0.15,0.105,0.083),pebble*distance_fade*0.56);
 ALBEDO*=1.0-wetness*0.23;
 float bump_height=(gravel*0.018+pebble*0.028)*distance_fade;
 vec3 sx=dFdx(VERTEX);
 vec3 sy=dFdy(VERTEX);
 vec3 rx=cross(sy,NORMAL);
 vec3 ry=cross(NORMAL,sx);
 float determinant=dot(sx,rx);
 vec3 gradient=sign(determinant)*(dFdx(bump_height)*rx+dFdy(bump_height)*ry);
 NORMAL=normalize(abs(determinant)*NORMAL-gradient*0.18);
 ROUGHNESS=mix(0.95,0.76,wetness);
}
