extends RefCounted

const HALF := 400.0
const BASIN := Vector2(105,100)
# Survey names, map positions and the mineral each terrain pocket favors.
const SITES := [
 ["Landing Flats",Vector2(0,0),""],["Aluminum Hills",Vector2(72,-54),"Aluminum"],
 ["Ancient Survey Ruins",Vector2(-268,-130),""],["Shard Gate",Vector2(-102,-63),"Iridium"],
 ["Mesa Overlook",Vector2(-156,70),""],["Basin Beach",Vector2(93,151),""],
 ["Southern Cascades",Vector2(72,289),"Ice"],["Sinkhole",Vector2(-168,204),""],
 ["Central Plateau",Vector2(-52,-75),""],["Cracked Spires",Vector2(122,20),"Iridium"],
 ["Western Dunes",Vector2(-221,-243),"Silicon"],["Gate Desert",Vector2(267,-173),""],
 ["Grand Rift",Vector2(33,-247),"Magnesium"],["North Grasslands",Vector2(-80,-313),"Seed"],
 ["Serrated Highlands",Vector2(-313,-270),"Aluminum"],["Iridium Mine",Vector2(-232,-6),"Iridium"],
 ["Labyrinth Canyons",Vector2(150,-230),"Magnesium"],["Hidden Oasis",Vector2(-341,-43),"Seed"],
 ["Verdant Dunes",Vector2(310,125),"Seed"],["Impact Rim",Vector2(127,-104),""],
 ["Meteor Field",Vector2(190,68),"Uranium"],["Fungal Gulch",Vector2(-29,216),""],
 ["Rainbow Cave",Vector2(-189,-327),"Osmium"],["Sand Falls",Vector2(-178,-99),"Silicon"],
 ["Steep Hill",Vector2(-48,80),""],["Sulfur Fields",Vector2(-104,-22),"Sulfur"],
 ["Red Falls",Vector2(178,-317),"Iron"],["Toxic Grotto",Vector2(300,247),"Sulfur"],
 ["Ember Caldera",Vector2(216,309),"Uranium"],["Eastern Wasteland",Vector2(309,0),""],
 ["Silent Basin",BASIN,""],["Zeolite Cave",Vector2(-116,144),"Zeolite"],
 ["Basalt Lava Tube",Vector2(237,32),"Osmium"],["Ejecta Cavern",Vector2(217,-80),"Uranium"],
 ["South Freight Wreck",Vector2(-44,150),""],["East Survey Wreck",Vector2(240,151),""]
]
const CAVES := [15,22,27,31,32,33]

static func nearest(point:Vector2) -> int:
 var best:=INF
 var found:=0
 for i in range(SITES.size()):
  var distance:=point.distance_squared_to(SITES[i][1])
  if distance<best:
   found=i
   best=distance
 return found

static func relief(x:float,z:float) -> float:
 var p:=Vector2(x,z)
 if p.length()<78.0:return 0.0
 var dunes:=sin(x*0.085+sin(z*0.023)*1.5)*4.0
 var rift:float=exp(-pow((x-27.0-sin(z*0.026)*9.0)/14.0,2.0))*(1.0-smoothstep(72,154,absf(z+231.0)))
 var mesas:=25.0*(1.0-smoothstep(19,60,p.distance_to(Vector2(-313,-270))))
 var volcano:=31.0*(1.0-smoothstep(15,68,p.distance_to(Vector2(216,309))))
 volcano-=13.0*(1.0-smoothstep(4,21,p.distance_to(Vector2(216,309))))
 var canyons:=sin(x*0.12+sin(z*0.065)*1.2)*7.0*(1.0-smoothstep(26,92,p.distance_to(Vector2(150,-230))))
 return mesas+volcano-rift*16.0+canyons+dunes*(1.0-smoothstep(37,125,p.distance_to(Vector2(-221,-243))))
