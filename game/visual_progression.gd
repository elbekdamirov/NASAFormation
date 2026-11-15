extends RefCounted
# Presentation milestones preserve the existing six mechanical unlock stages.
const NAMES = ["Barren Mars", "Clearing Skies", "Clouds", "Rain", "Surface Water", "Lakes", "Moss & Grass", "Flora", "Breathable World"]
const THRESHOLDS = [0.0, 100.0, 400.0, 700.0, 900.0, 1300.0, 1800.0, 2600.0, 3500.0]

static func stage(ti:float) -> int:
 var result:=0
 for i in range(THRESHOLDS.size()):
  if ti>=THRESHOLDS[i]:result=i
 return result

static func progress(ti:float) -> float:
 var i:=stage(ti)
 if i==THRESHOLDS.size()-1:return 1.0
 return clampf((ti-THRESHOLDS[i])/(THRESHOLDS[i+1]-THRESHOLDS[i]),0.0,1.0)

static func next_label(ti:float) -> String:
 var i:=stage(ti)
 if i==NAMES.size()-1:return "Outdoor oxygen comfort unlocked"
 return "%s  /  %.0f%%  /  %.0f Ti"%[NAMES[i+1],progress(ti)*100.0,THRESHOLDS[i+1]]
