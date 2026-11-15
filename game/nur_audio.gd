extends RefCounted

const RATE := 22050

static func mining(material_kind:String, fracture:bool) -> AudioStreamWAV:
 var frequency:=float({"rock":190.0,"metal":310.0,"ice":720.0,"sample":420.0}[material_kind])
 var seconds:=0.38 if fracture else 0.8
 var count:=roundi(RATE*seconds)
 var pcm:=PackedByteArray()
 pcm.resize(count*2)
 var rng:=RandomNumberGenerator.new()
 rng.seed=("fracture" if fracture else "contact").hash()+material_kind.hash()
 var low:=0.0
 var body:=0.0
 for i in range(count):
  var t:=float(i)/RATE
  var noise:=rng.randf_range(-1,1)
  low=lerpf(low,noise,0.065)
  body=lerpf(body,noise,0.32)
  var grit:=body-low
  var edge:=noise-body
  var value:=0.0
  if fracture:
   var snap:=exp(-t*56.0)
   var second:=maxf(0,t-0.023)
   var shards:=exp(-t*12.0)*(0.53+0.47*sin(t*TAU*34.0))
   var ring:=sin(t*TAU*frequency)*exp(-t*23.0)
   value=0.49*grit*snap+0.27*edge*snap+0.21*ring+0.31*grit*shards
   if t>0.023:value+=0.22*edge*exp(-second*68.0)
   value*=smoothstep(0,0.0015,t)*(1.0-smoothstep(0.22,seconds,t))
  else:
   var motor:=sin(t*TAU*125.0+0.32*sin(t*TAU*10.0))
   var pulse:=0.55+0.45*pow(0.5+0.5*cos(t*TAU*25.0),3.0)
   var chatter:=sin(t*TAU*frequency)
   value=(0.32*grit+0.12*edge+0.068*chatter)*pulse+0.08*motor
   value*=smoothstep(0,0.012,t)*(1.0-smoothstep(seconds-0.012,seconds,t))
  pcm.encode_s16(i*2,roundi(clampf(value,-1,1)*32767))
 var clip:=AudioStreamWAV.new()
 clip.format=AudioStreamWAV.FORMAT_16_BITS
 clip.mix_rate=RATE
 clip.data=pcm
 if not fracture:
  clip.loop_mode=AudioStreamWAV.LOOP_FORWARD
  clip.loop_end=count
 return clip

static func synthesize(effect:String) -> AudioStreamWAV:
 var seconds := 1.0
 match effect:
  "step_stone","step_dust","step_metal","step_water":seconds=0.28
  "click":seconds=0.13
  "breath":seconds=0.76
 var count := roundi(RATE*seconds)
 var bytes := PackedByteArray()
 bytes.resize(count*2)
 var random := RandomNumberGenerator.new()
 random.seed=effect.hash()
 var soft := 0.0
 for i in range(count):
  var t := float(i)/RATE
  var n := random.randf_range(-1.0,1.0)
  soft=lerpf(soft,n,0.10)
  var sample := 0.0
  match effect:
   "step_water":
    sample=(soft*0.75+n*0.12)*exp(-t*11.0)*sin(minf(1.0,t/0.06)*PI*0.5)
   "step_metal":
    sample=(soft*0.5+sin(t*TAU*430)*0.16+sin(t*TAU*710)*0.09)*exp(-t*24.0)
   "step_stone":
    sample=(soft*0.79+n*0.17+0.17*sin(t*TAU*97))*exp(-t*24.0)
   "step_dust":
    sample=(soft*0.72+0.19*sin(t*TAU*67))*exp(-t*16.0)*smoothstep(0.0,0.02,t)
   "click":
    sample=(0.5*sin(t*TAU*390.0)+0.24*sin(t*TAU*780.0))*exp(-t*31.0)
   "rain":
    sample=(soft*0.6+n*0.08)*(0.85+0.15*sin(t*TAU*7.0))
   "machine":
    sample=(0.34*sin(t*TAU*51.0)+0.13*sin(t*TAU*103.0))*(0.72+0.28*cos(t*TAU*4.0))
   "breath":
    sample=soft*0.73*pow(sin(PI*t/seconds),2.0)*(1.0+0.3*sin(t*TAU*3.0))
  bytes.encode_s16(i*2,roundi(clampf(sample,-1.0,1.0)*30000.0))
 var sound := AudioStreamWAV.new()
 sound.format=AudioStreamWAV.FORMAT_16_BITS
 sound.mix_rate=RATE
 sound.data=bytes
 if effect in ["machine","rain"]:
  sound.loop_mode=AudioStreamWAV.LOOP_FORWARD
  sound.loop_end=count
 return sound
