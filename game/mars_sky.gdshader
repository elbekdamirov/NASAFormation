shader_type sky;

uniform vec4 zenith : source_color = vec4(0.23,0.14,0.15,1.0);
uniform vec4 horizon : source_color = vec4(0.70,0.40,0.26,1.0);
uniform float night = 0.0;
uniform float twilight = 0.0;
uniform vec4 twilight_halo : source_color = vec4(0.49,0.61,0.73,1.0);
uniform float dust = 0.0;
uniform float weather_time = 0.0;
uniform float rainfall = 0.0;
uniform float clouds = 0.0;
uniform sampler2D star_field : filter_linear, repeat_enable;
uniform vec3 moon_dir = vec3(-0.69,0.43,-0.57);

float hash(vec3 p) { return fract(sin(dot(p,vec3(47.839,113.2,27.537)))*43321.17); }
float cloud_noise(vec3 p){
 vec3 i=floor(p);vec3 f=fract(p);f=f*f*(3.0-2.0*f);
 float a=mix(hash(i),hash(i+vec3(1,0,0)),f.x);
 float b=mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x);
 float c=mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x);
 float d=mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x);
 return mix(mix(a,b,f.y),mix(c,d,f.y),f.z);
}
float wisps(vec3 p){
 return cloud_noise(p)*0.57+cloud_noise(p*2.03+7.1)*0.28+cloud_noise(p*4.07+15.7)*0.15;
}
float ripple(vec2 p) {
 return (sin(p.x+sin(p.y*1.77)) + sin(1.8*p.x-0.8*p.y) + sin(3.5*p.x+2.7*p.y)) / 3.0;
}
void sky() {
 vec3 ray = normalize(EYEDIR);
 float elevation = max(ray.y,0.0);
 vec3 tint = mix(horizon.rgb,zenith.rgb,pow(elevation,0.47));
 if (ray.y < 0.0) tint *= 1.0 - 0.54*smoothstep(0.0,0.42,-ray.y);
 float phase = max(dot(ray,LIGHT0_DIRECTION),0.0);
 if (LIGHT0_ENABLED) {
  tint += vec3(0.53,0.30,0.17)*pow(phase,12.0)*(1.0-twilight)*0.25*(1.0-dust*0.8);
  tint = mix(tint,twilight_halo.rgb,twilight*pow(phase,50.0)*(1.0-dust*0.8));
  tint += vec3(1.0,0.84,0.59)*smoothstep(0.99966,0.99985,phase)*2.0*(1.0-dust*0.88);
 }
 vec2 bands = ray.xz/(0.21+elevation)*vec2(5.8,2.9);
 float veil = ripple(bands+vec2(weather_time*0.006,weather_time*0.002));
 tint += vec3(0.13,0.056,0.021) * (0.3+dust*0.7)*smoothstep(0.12,0.88,veil)*smoothstep(0.015,0.27,elevation);
 float moon = dot(ray,normalize(moon_dir));
 tint += vec3(0.32,0.28,0.28)*smoothstep(0.99979,0.99991,moon)*(0.40+night*0.60)*(1.0-dust*0.85);
 vec3 galactic = normalize(vec3(ray.x, ray.y*0.71-ray.z*0.71, ray.y*0.71+ray.z*0.71));
 vec2 uv = vec2(atan(galactic.z,galactic.x)/6.283185 + 0.42 + weather_time*0.00012, acos(clamp(galactic.y,-1.0,1.0))/3.14159);
 vec3 field = texture(star_field,uv).rgb;
 float clarity = night*night*(1.0-dust)*smoothstep(-0.02,0.13,ray.y)*(1.0-rainfall*0.94);
 tint += pow(max(field,vec3(0.0)),vec3(0.62)) * vec3(1.04,1.04,1.18) * 2.2 * clarity;
 float galactic_band = exp(-15.0*abs(galactic.y));
 vec3 cell = ray*307.0;
 float core = length(fract(cell)-0.5);
 float star = (1.0-smoothstep(0.072,0.22,core))*step(0.53,hash(floor(cell)));
 vec3 finer = ray*565.0;
 star += (1.0-smoothstep(0.045,0.17,length(fract(finer)-0.5)))*step(0.67,hash(floor(finer)))*(0.22+0.78*galactic_band);
 tint += vec3(0.72,0.57,0.45)*clarity*(star*1.45+galactic_band*(0.15+0.07*veil));
 // Drifting high ice veils before terraforming, richer clouds as the world warms.
 vec3 cloud_point=vec3(ray.xz/(0.28+elevation)*3.1,weather_time*0.003);
 cloud_point.xy+=vec2(weather_time*0.006,0.0);
 float mass=wisps(cloud_point);
 float lace=wisps(cloud_point*vec3(1.1,4.2,1.0)+3.9);
 float cloud_cover=smoothstep(0.41,0.70,mass+lace*0.16);
 float cloud_edge=smoothstep(0.42,0.58,mass)-smoothstep(0.58,0.74,mass);
 vec3 cloud_light=mix(vec3(0.83,0.63,0.52),vec3(0.92,0.94,0.96),clouds);
 cloud_light=mix(cloud_light,vec3(0.75,0.54,0.66),twilight*0.35);
 float cloud_mask=(0.24+clouds*0.53)*(1.0-dust)*smoothstep(0.015,0.17,elevation);
 tint=mix(tint,cloud_light,cloud_cover*cloud_mask*(1.0-night*0.90));
 tint+=cloud_light*cloud_edge*pow(phase,6.0)*cloud_mask*0.17*(1.0-night);
 float twilight_arch=exp(-pow((elevation-0.13)*7.0,2.0));
 tint+=vec3(0.08,0.11,0.19)*twilight*twilight_arch*(1.0-dust)*0.5;
 // Gentle color variation in the existing star map; no bright daytime stars.
 tint+=vec3(0.10,0.075,0.14)*galactic_band*clarity*wisps(galactic*11.0)*1.2;
 tint = mix(tint,vec3(0.16,0.21,0.27),rainfall*(0.45+0.36*veil));
 COLOR = tint;
}
