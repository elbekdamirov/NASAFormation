extends RefCounted

const SOL_SECONDS := 360.0
const START_HOUR := 8.0
const DUST_START := 128.0
const DUST_END := 227.0
const SHIELD_KW := 0.8
const GREENHOUSE_W := 0.9
const RADIO_W := 0.55
const EARTH_ROUND_TRIP := 14.0 / 1440.0 * SOL_SECONDS * 2.0

static func sol(t:float) -> int:
 return floori(t/SOL_SECONDS)+1

static func local_clock(t:float) -> String:
 var minutes:=int(fposmod(t/SOL_SECONDS*1440.0+START_HOUR*60.0,1440.0))
 return "%02d:%02d"%[minutes/60,minutes%60]

static func dust(t:float) -> float:
 var phase:=fposmod(t,SOL_SECONDS)
 return smoothstep(DUST_START,DUST_START+15.0,phase)*(1.0-smoothstep(DUST_END-18.0,DUST_END,phase))

static func solar(t:float) -> float:
 var phase:=fposmod(t,SOL_SECONDS)
 if sol(t)%2==1:return 0.0
 return smoothstep(75.0,88.0,phase)*(1.0-smoothstep(151.0,166.0,phase))

static func rain_strength(t:float,index:float) -> float:
 var phase:=fposmod(t,SOL_SECONDS)
 return smoothstep(700,1400,index)*smoothstep(95,108,phase)*(1.0-smoothstep(150,171,phase))

static func sun_height(t:float) -> float:
 return sin((t/SOL_SECONDS+START_HOUR/24.0-0.25)*TAU)

static func exposure_per_second(t:float,inside:bool,shielded:bool) -> float:
 return (0.035+solar(t)*1.5)*(0.11 if shielded and inside else 0.48 if inside else 1.0)
