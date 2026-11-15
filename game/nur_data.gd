extends RefCounted

const TITLE = "NASAFormation"
const ORES = ["Iron", "Silicon", "Titanium", "Ice", "Magnesium", "Cobalt", "Aluminum", "Iridium", "Sulfur", "Seed", "Uranium", "Osmium", "Zeolite"]
const CONSUMABLES = ["Oxygen capsule","Water bottle","Food pack","Purified Water"]
const COMPONENTS = ["Circuit board","Survey alloy","Portable power cell"]
const RETURN_SUPPLIES = {"Oxygen capsule":3,"Water bottle":3,"Food pack":3}
const COLORS = [Color("ae9789"), Color("e8c9a8"), Color("b0c4ce"), Color("87dcf1"), Color("d6d8bd"), Color("377de2"), Color("dfedf5"), Color("ff6943"), Color("eac94b"), Color("98c872"), Color("789047"), Color("829bb5"), Color("e9c6a1")]
const REGIONS = ["Landing Flats", "Serrated Highlands", "Silent Basin"]
const STAGES = ["Barren", "Thin Atmosphere", "Blue Haze", "Liquid Water", "First Green", "Living Planet"]
const THRESHOLDS = [0, 100, 400, 900, 1800, 3500]
const METRICS = ["Pressure", "Heat", "Oxygen", "Biomass"]
const CRATE_POINTS = [Vector2(22, -4), Vector2(-42, -37), Vector2(-99, -65), Vector2(58, -92), Vector2(109, 100), Vector2(-262,-125), Vector2(-37,154), Vector2(247,155)]
const CRATE_ITEMS = [
 {"Seed":2,"Iridium":1,"Oxygen capsule":1},
 {"Iron":5,"Silicon":3,"Cobalt":3,"Water bottle":2},
 {"Iridium":5,"Aluminum":4,"Sulfur":2},
 {"Seed":3,"Magnesium":3,"Food pack":2},
 {"Aluminum":5,"Seed":2,"Water bottle":2},
 {"Circuit board":1,"Water bottle":1,"Aluminum":3},
 {"Iridium":2,"Circuit board":1,"Oxygen capsule":1},
 {"Osmium":2,"Zeolite":2,"Water bottle":1}
]
const CRAFTS = [
 {"name":"Oxygen capsule","cost":{"Cobalt":2},"group":0,"desc":"Carry a reserve of 60 oxygen."},
 {"name":"Water bottle","cost":{"Ice":1},"group":0,"desc":"Restores 50 hydration."},
 {"name":"Food pack","cost":{"Seed":1,"Ice":1},"group":0,"desc":"Restores 50 nutrition and health."},
 {"name":"T1 Oxygen tank","cost":{"Cobalt":2,"Iron":1,"Magnesium":1},"group":1,"gear":"Oxygen tank","desc":"Raises oxygen capacity to 145."},
 {"name":"T2 Backpack","cost":{"Iron":2,"Titanium":1,"Silicon":1},"group":1,"gear":"Backpack","desc":"Expands your backpack to 24 slots."},
 {"name":"Mining upgrade","cost":{"Aluminum":1,"Silicon":1,"Magnesium":1},"group":1,"gear":"Mining upgrade","desc":"Increases your mining speed by 35%."},
 {"name":"Agility boots","cost":{"Titanium":2,"Silicon":1,"Magnesium":1},"group":1,"gear":"Agility boots","desc":"Walk and sprint 18% faster."},
 {"name":"T3 Oxygen tank","cost":{"Osmium":1,"Cobalt":3,"Aluminum":1},"group":1,"gear":"T3 Oxygen tank","at":900,"desc":"Raises oxygen capacity to 200."},
 {"name":"Jetpack","cost":{"Circuit board":1,"Iridium":2,"Titanium":3},"group":1,"gear":"Jetpack","at":400,"desc":"Hold Space in the air to boost. The boost consumes suit oxygen."},
 {"name":"Air filter","cost":{"Zeolite":1,"Aluminum":1,"Circuit board":1},"group":1,"gear":"Air filter","at":1800,"desc":"Reduces outdoor oxygen drain by 30%."},
 {"name":"Purified Water","cost":{"Water bottle":1,"Zeolite":1},"group":0,"at":400,"desc":"Restores 80 hydration."},
 {"name":"Circuit board","cost":{"Silicon":2,"Aluminum":1},"group":2,"desc":"Control electronics for advanced machines and equipment."},
 {"name":"Survey alloy","cost":{"Iron":1,"Titanium":1,"Osmium":1},"group":2,"desc":"Corrosion-resistant frame material for advanced buildings."},
 {"name":"Portable power cell","cost":{"Cobalt":2,"Silicon":1},"group":2,"desc":"Powers the sealed compartment at East Survey Wreck."}
]

enum Build { POD, HABITAT, DOOR, FOUNDATION, STORAGE, CRAFT, WIND, SOLAR, SOLAR_2, DRILL, DRILL_2, HEATER, HEATER_2, TUBE, TUBE_2, GRASS, WATER, ORE, TERMINAL, RECOVERY, FOOD, ALGAE, TREE, WIND_2, FILTER, RETURN_VEHICLE, BEACON, BENCH, PLANTER }
const BUILDABLES = [
 {"name":"Landing pod","cost":{},"power":0.0,"at":-1,"group":"Base","desc":"Sealed emergency refuge."},
 {"name":"Habitat","cost":{"Iron":2,"Titanium":1},"power":0.0,"at":0,"group":"Base","desc":"Sealed room with an oxygen refill. Snap a door to a wall."},
 {"name":"Habitat door","cost":{"Iron":1,"Silicon":1,"Titanium":1},"power":0.0,"at":0,"group":"Base","desc":"Snaps to a habitat wall. Allows entry."},
 {"name":"Foundation","cost":{"Iron":1},"power":0.0,"at":0,"group":"Base","desc":"A level surface on the construction grid."},
 {"name":"Storage crate","cost":{"Iron":2},"power":0.0,"at":0,"group":"Base","desc":"24 slots. Transfer stacks with E."},
 {"name":"Craft station","cost":{"Iron":1,"Silicon":1},"power":-0.5,"at":0,"group":"Base","desc":"A powered station for supplies and equipment."},
 {"name":"Wind turbine","cost":{"Iron":1},"power":1.2,"at":0,"group":"Power","desc":"Continuous 1.2 kW generation."},
 {"name":"T1 Solar array","cost":{"Iron":1,"Cobalt":2,"Silicon":1},"power":6.5,"at":0,"group":"Power","desc":"6.5 kW from an integrated solar buffer."},
 {"name":"T2 Solar array","cost":{"Iron":1,"Cobalt":2,"Silicon":1,"Magnesium":1,"Aluminum":1},"power":19.5,"at":400,"group":"Power","desc":"19.5 kW from an integrated solar buffer."},
 {"name":"T1 Pressure drill","cost":{"Iron":1,"Titanium":1},"power":-0.5,"at":0,"group":"Terraforming","metric":"Pressure","rate":0.2,"desc":"Increases atmospheric pressure by 0.2/s."},
 {"name":"T2 Pressure drill","cost":{"Iron":1,"Titanium":2},"power":-5.0,"at":400,"group":"Terraforming","metric":"Pressure","rate":1.5,"desc":"Increases atmospheric pressure by 1.5/s."},
 {"name":"T1 Heater","cost":{"Iridium":1,"Iron":1,"Silicon":1},"power":-1.0,"at":100,"group":"Terraforming","metric":"Heat","rate":0.3,"desc":"Increases heat by 0.3/s."},
 {"name":"T2 Heater","cost":{"Iridium":2,"Iron":1,"Silicon":1,"Titanium":1,"Aluminum":1},"power":-3.5,"at":1800,"group":"Terraforming","metric":"Heat","rate":4.5,"desc":"Increases heat by 4.5/s."},
 {"name":"T1 Vegetube","cost":{"Iron":1,"Ice":1,"Magnesium":1},"power":-0.35,"at":0,"group":"Terraforming","metric":"Oxygen","rate":0.15,"desc":"Produces 0.15 oxygen/s once a seed is installed."},
 {"name":"T2 Vegetube","cost":{"Iron":1,"Ice":2,"Magnesium":1,"Silicon":1},"power":-1.25,"at":900,"group":"Terraforming","metric":"Oxygen","rate":1.2,"desc":"Produces 1.2 oxygen/s once a seed is installed."},
 {"name":"Grass spreader","cost":{"Seed":1,"Aluminum":1,"Magnesium":1,"Water bottle":1},"power":-3.0,"at":1800,"group":"Terraforming","metric":"Biomass","rate":0.3,"desc":"Produces 0.3 biomass and 0.4 oxygen per second."},
 {"name":"Water collector","cost":{"Iron":2,"Silicon":1,"Aluminum":1},"power":-2.0,"at":900,"group":"Industry","desc":"Stores one bottle every 45 seconds."},
 {"name":"Ore extractor","cost":{"Titanium":2,"Aluminum":1,"Iridium":1,"Silicon":1},"power":-8.0,"at":1800,"group":"Industry","desc":"Stores one basic ore every 40 seconds."},
 {"name":"Terraform terminal","cost":{"Iron":1,"Cobalt":1,"Silicon":1},"power":-0.4,"at":100,"group":"Industry","desc":"Display production rates and milestone progress."},
 {"name":"Recovery crate","cost":{},"power":0.0,"at":-1,"group":"Base","desc":"Recover dropped supplies."},
 {"name":"Food grower","cost":{"Iron":2,"Ice":1,"Seed":1},"power":-0.9,"at":100,"group":"Industry","makes":"Food pack","interval":55.0,"desc":"Grows a food pack every 55 powered seconds."},
 {"name":"Algae cultivator","cost":{"Zeolite":1,"Seed":1,"Aluminum":2},"power":-2.7,"at":900,"group":"Terraforming","metric":"Biomass","rate":2.4,"desc":"Cultivates algae in a sealed water tank. Adds 2.4 biomass per second."},
 {"name":"Tree spreader","cost":{"Survey alloy":1,"Seed":2,"Water bottle":1},"power":-5.0,"at":1800,"group":"Terraforming","metric":"Oxygen","rate":3.8,"desc":"Propagates hardy woodland. Adds 3.8 oxygen per second."},
 {"name":"Highland wind turbine","cost":{"Survey alloy":1,"Osmium":1,"Circuit board":1},"power":8.2,"at":400,"group":"Power","desc":"Generates 8.2 kW in clear air and dust storms."},
 {"name":"Water purifier","cost":{"Zeolite":2,"Circuit board":1,"Titanium":1},"power":-2.4,"at":900,"group":"Industry","makes":"Purified Water","interval":55.0,"desc":"Filters condensed water. Stores one purified bottle every 55 powered seconds."},
 {"name":"Earth return vehicle","cost":{"Survey alloy":2,"Circuit board":1,"Titanium":3,"Iridium":2},"power":0.0,"at":3500,"group":"Industry","desc":"Build on clear ground. Load the crew manifest, obtain Earth clearance, and board."},
 {"name":"Survey beacon","cost":{"Iron":1,"Silicon":1,"Cobalt":1},"power":0.0,"at":0,"group":"Decorations","desc":"A luminous route marker. E sets a compass destination to its location."},
 {"name":"Expedition bench","cost":{"Iron":2,"Titanium":1},"power":0.0,"at":100,"group":"Decorations","desc":"A durable rest platform and an architectural landmark for your outpost."},
 {"name":"Botanical planter","cost":{"Iron":1,"Seed":1,"Ice":1},"power":0.0,"at":1800,"group":"Decorations","desc":"A sealed ornamental plant display. Grows as the biosphere matures."}
]

static func stack_limit(item: String) -> int:
 if item == "Seed" or item in CONSUMABLES:
  return 10
 return 20

static func slots(items: Dictionary) -> int:
 var used := 0
 for item in items:
  used += ceili(float(items[item]) / stack_limit(item))
 return used

static func transaction(items: Dictionary, cost: Dictionary, output: Dictionary, capacity: int) -> bool:
 var next := items.duplicate()
 for item in cost:
  if int(cost[item]) <= 0 or int(next.get(item, 0)) < int(cost[item]):
   return false
  next[item] -= int(cost[item])
 for item in output:
  if int(output[item]) <= 0:
   return false
  next[item] = int(next.get(item, 0)) + int(output[item])
 if slots(next) > capacity:
  return false
 items.assign(next)
 return true

static func terraform_index(stats: Dictionary) -> float:
 # Each track uses fictional units. Weights normalize output for a short campaign.
 return stats.Pressure * 2.0 + stats.Heat * 2.0 + stats.Oxygen * 2.0 + stats.Biomass * 3.0

static func stage(index: float) -> int:
 for step in range(THRESHOLDS.size() - 1, -1, -1):
  if index >= THRESHOLDS[step]:
   return step
 return 0
