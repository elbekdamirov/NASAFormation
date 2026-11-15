extends Node

signal intro_finished
signal shot_updated(shot:int,fraction:float)

const SCREEN := Vector2(1600, 900)
const WHITE := Color("fdf3e9")
const WARM := Color("eeb791")
const SHOTS := [
 {"voice":"arrival","location":"01  /  POWERED DESCENT","title":"NASAFormation","cue":"UZBEKISTAN  /  UZ-01",
  "from":Vector3(19,31,38),"to":Vector3(12,4.5,18),"look_from":Vector3(-7,37,-6),"look_to":Vector3(0,1.9,0),"fov":54.0},
 {"voice":"surface","location":"02  /  FIRST STEPS","title":"","cue":"WASD  MOVE   /   MOUSE  LOOK   /   HOLD LEFT CLICK  MINE",
  "from":Vector3(8,3.8,12),"to":Vector3(11,2.7,18),"look_from":Vector3(0,1.4,2.2),"look_to":Vector3(4,1.2,10),"fov":59.0},
 {"voice":"mission","location":"03  /  OUTPOST CONSTRUCTION","title":"","cue":"C  CRAFT   /   B  BUILD   /   P  OUTPOST",
  "from":Vector3(-10,4.9,16),"to":Vector3(-14,3.3,13),"look_from":Vector3(-2,1.3,7),"look_to":Vector3(-4,1.5,8),"fov":61.0},
 {"voice":"weather","location":"04  /  DUST ALERT","title":"","cue":"SOLAR OUTPUT FALLS   /   KEEP RESERVE POWER",
  "from":Vector3(21,9,20),"to":Vector3(14,4.4,11),"look_from":Vector3(-5,1.6,1),"look_to":Vector3(0,1.8,0),"fov":60.0},
 {"voice":"plans","location":"05  /  TERRAFORMATION PREVIEW","title":"","cue":"M  SURVEY MAP   /   J  JOURNAL   /   P  OUTPOST",
  "from":Vector3(124,19,164),"to":Vector3(92,11,149),"look_from":Vector3(102,-1,94),"look_to":Vector3(114,-0.4,92),"fov":56.0}
]

var captions: Dictionary = {}
var player: AudioStreamPlayer
var camera: Camera3D
var layer: CanvasLayer
var screen: Control
var film: Control
var dark: ColorRect
var film_title: Label
var film_cue: Label
var location: Label
var progress: ColorRect
var caption_box: Panel
var caption: Label
var skip_label: Label
var current := ""
var current_priority := 0
var last_objective := -1
var intro_active := false
var shot_index := 0
var clock := 0.0
var duration := 0.0
var enabled := true
var reduced_motion := false
var streams := {}
var suspended_guide := ""
var suspended_priority := 0
var suspended_clock := 0.0

func _ready():
 var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://voice/captions.json"))
 if data is Dictionary:captions=data
 player=AudioStreamPlayer.new()
 player.volume_db=-4.0
 add_child(player)
 camera=Camera3D.new()
 camera.physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 camera.set_cull_mask_value(20,false)
 camera.far=1800
 add_child(camera)
 layer=CanvasLayer.new()
 layer.layer=5
 add_child(layer)
 screen=Control.new()
 screen.mouse_filter=Control.MOUSE_FILTER_IGNORE
 screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 layer.add_child(screen)
 film=Control.new()
 film.mouse_filter=Control.MOUSE_FILTER_IGNORE
 screen.add_child(film)
 make_rect(film,Vector2.ZERO,Vector2(SCREEN.x,96),Color("100e0f"))
 make_rect(film,Vector2(0,769),Vector2(SCREEN.x,131),Color("100e0f"))
 make_rect(film,Vector2(40,94),Vector2(1520,1),Color(1,0.89,0.80,0.27))
 location=make_label(film,Vector2(40,38),Vector2(1160,28),16,WARM)
 film_title=make_label(film,Vector2(62,544),Vector2(1400,104),74,WHITE)
 film_cue=make_label(film,Vector2(67,638),Vector2(1200,28),17,WARM)
 skip_label=make_label(film,Vector2(1250,39),Vector2(310,28),16,WHITE)
 skip_label.text="ESC  /  SPACE   SKIP"
 skip_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 make_rect(film,Vector2(40,872),Vector2(1520,2),Color(1,1,1,0.17))
 progress=make_rect(film,Vector2(40,872),Vector2(0,2),WARM)
 dark=make_rect(film,Vector2.ZERO,SCREEN,Color("100e0f"))
 film.hide()

 caption_box=Panel.new()
 caption_box.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var style:=StyleBoxFlat.new()
 style.bg_color=Color(0.04,0.035,0.036,0.86)
 style.border_color=Color(0.97,0.86,0.77,0.42)
 style.border_width_top=1
 caption_box.add_theme_stylebox_override("panel",style)
 caption_box.size=Vector2(930,75)
 screen.add_child(caption_box)
 var sender:=make_label(caption_box,Vector2(14,6),Vector2(902,19),12,WARM)
 sender.text="MISSION CONTROL"
 sender.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 caption=make_label(caption_box,Vector2(20,25),Vector2(890,44),21,WHITE)
 caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 caption_box.hide()

func make_rect(parent:Control,pos:Vector2,extent:Vector2,tint:Color) -> ColorRect:
 var rect:=ColorRect.new()
 rect.position=pos
 rect.size=extent
 rect.color=tint
 rect.mouse_filter=Control.MOUSE_FILTER_IGNORE
 parent.add_child(rect)
 return rect

func make_label(parent:Control,pos:Vector2,extent:Vector2,point_size:int,tint:Color) -> Label:
 var label:=Label.new()
 label.position=pos
 label.size=extent
 label.mouse_filter=Control.MOUSE_FILTER_IGNORE
 label.add_theme_font_size_override("font_size",point_size)
 label.add_theme_color_override("font_color",tint)
 label.add_theme_color_override("font_outline_color",Color("100e0f"))
 label.add_theme_constant_override("outline_size",4)
 parent.add_child(label)
 return label

func play_intro(calm:bool):
 if not intro_active and not current.is_empty():
  suspended_guide=current
  suspended_priority=current_priority
  suspended_clock=clock
 reduced_motion=calm
 intro_active=true
 caption_box.position=Vector2(335,785)
 film.show()
 camera.make_current()
 open_shot(0)

func open_shot(index:int):
 shot_index=index
 var shot: Dictionary = SHOTS[index]
 location.text=shot.location
 film_title.text=shot.title
 film_cue.text=shot.cue
 start_line(shot.voice)
 update_shot()
 refresh_caption()

func finish_intro():
 if not intro_active:return
 intro_active=false
 film.hide()
 stop_line()
 intro_finished.emit()

func reset_guide():
 last_objective=-1
 suspended_guide=""
 if not intro_active:stop_line()

func guide_objective(step:int):
 if not enabled or intro_active:return
 if step==last_objective:
  if not suspended_guide.is_empty() and current.is_empty():
   start_line(suspended_guide,suspended_priority,suspended_clock)
   suspended_guide=""
  return
 suspended_guide=""
 last_objective=step
 if captions.has("step_%d"%step):
  start_line("step_%d"%step)

func alert(key:String):
 if not enabled or intro_active or current_priority==1:return
 if current.begins_with("step_"):
  suspended_guide=current
  suspended_priority=current_priority
  suspended_clock=clock
 start_line(key,1)

func pause_guide():
 if intro_active:return
 player.stream_paused=true
 caption_box.hide()

func resume_guide():
 if intro_active or not enabled:return
 player.stream_paused=false
 refresh_caption()

func set_enabled(value:bool):
 enabled=value
 if not enabled:
  reset_guide()
  if intro_active:player.stop()
 elif intro_active and player.stream:
  player.play(clock)

func stop_line():
 current=""
 current_priority=0
 player.stop()
 caption_box.hide()

func start_line(key:String,priority:int=0,offset:float=0.0):
 current=key
 current_priority=priority
 clock=offset
 player.stop()
 player.stream_paused=false
 if not streams.has(key):
  var path:="res://voice/%s.wav"%key
  var stream:AudioStreamWAV
  if FileAccess.file_exists(path):
   stream=AudioStreamWAV.load_from_file(ProjectSettings.globalize_path(path))
  streams[key]=stream
 player.stream=streams[key]
 var cues: Array = captions.get(key,[])
 duration=player.stream.get_length() if player.stream else (float(cues.back().at)+4.0 if not cues.is_empty() else 4.0)
 if player.stream and enabled:player.play(offset)
 if not intro_active:caption_box.position=Vector2(335,665)
 refresh_caption()

func tick(dt:float,running:bool):
 if current.is_empty() or (not intro_active and not running):return
 clock+=dt
 if intro_active:
  if clock>=duration:
   if shot_index+1==SHOTS.size():
    finish_intro()
    return
   open_shot(shot_index+1)
  update_shot()
  refresh_caption()
 elif clock>=duration:
  stop_line()
 else:
  refresh_caption()

func update_shot():
 var shot: Dictionary = SHOTS[shot_index]
 var fraction:=clampf(clock/duration,0,1)
 var adjusted:=smoothstep(0.0,0.49,fraction) if shot_index==0 else smoothstep(0,1,fraction)
 var blend:=0.72 if reduced_motion else adjusted
 camera.position=shot.from.lerp(shot.to,blend)
 camera.look_at(shot.look_from.lerp(shot.look_to,blend))
 camera.fov=shot.fov
 dark.color.a=1.0-minf(smoothstep(0,0.55,clock),smoothstep(0,0.55,duration-clock))
 film_title.modulate.a=smoothstep(0.4,2.3,clock)*(1.0-smoothstep(duration-4.0,duration-1.0,clock))
 film_cue.modulate.a=film_title.modulate.a
 if shot_index==4:
  var preview:="BARREN" if fraction<0.22 else "BLUE HAZE" if fraction<0.44 else "LIQUID WATER" if fraction<0.66 else "FIRST GREEN" if fraction<0.85 else "LIVING PLANET"
  location.text="05  /  TERRAFORMATION PREVIEW   ·   "+preview
 progress.size.x=1520.0*(shot_index+fraction)/SHOTS.size()
 shot_updated.emit(shot_index,fraction)

func refresh_caption():
 if current.is_empty():return
 var cues: Array = captions.get(current,[])
 if cues.is_empty():
  caption_box.hide()
  return
 for i in range(cues.size()-1,-1,-1):
  if clock>=float(cues[i].at):
   caption.text=cues[i].text
   break
 caption_box.show()
