extends Node

var game:Node
var messages:Array=[]
var labels:Array[Label]=[]
var progress:ProgressBar
var photo:=false
var photo_camera:Camera3D
var old_paused:=false
var elapsed:=0.0
var frames:=0
var worst:=0.0
var rain_audio:AudioStreamPlayer
var lore_nodes:Array[StaticBody3D]=[]
var portrait:SubViewport
var portrait_root:Node3D
var portrait_camera:Camera3D
const LORE = [
 ["Basin survey 01",Vector2(29,-14),"Landing basin", "UZ-01 field log: the red dust coats every seal. Keep a refuge within your oxygen budget. Reliable shelter is the first piece of any ambitious mission."],
 ["The last borehole",Vector2(-83,-60),"Broken highlands", "The abandoned team's drill jammed in fractured strata. Their notes recommend redundant power before adding more equipment. A larger output means nothing during a blackout."],
 ["Shoreline markers",Vector2(142,109),"Dry lakebed", "These survey stakes mark an ancient drainage basin. Liquid water in this miniature simulation is fictional. Today's Mars has a thin atmosphere and cannot support an exposed astronaut."],
 ["Shelter in the dark",Vector2(-122,35),"Cave country", "A sealed archive survived in the rock's shadow. Radiation shielding and reliable food compete for mass and electricity. The choices you make in the storm trial reflect those engineering trade-offs."]
]

class SuitDiagram extends Control:
 var clock:=0.0
 func _draw():
  var ink:=Color("a7d3df")
  draw_circle(Vector2(106,55),34,ink,false,3,true)
  draw_style_box(make_style(),Rect2(65,93,82,112))
  draw_line(Vector2(67,106),Vector2(35,190),ink,15,true)
  draw_line(Vector2(145,106),Vector2(177,190),ink,15,true)
  for x in [82,130]:
   draw_line(Vector2(x,204),Vector2(x,304),ink,21,true)
   draw_line(Vector2(x-7,308),Vector2(x+14,308),ink,14,true)
  draw_rect(Rect2(80,32,52,37),Color("203341"),true)
  draw_rect(Rect2(79,125,54,32),Color("203341"),true)
  for i in range(3):draw_line(Vector2(85,135+i*6),Vector2(124,135+i*6),Color("58bbc6"),2,true)
 func make_style() -> StyleBoxFlat:
  var st:=StyleBoxFlat.new()
  st.bg_color=Color("658a98")
  st.corner_radius_top_left=18
  st.corner_radius_top_right=18
  return st

func setup_lore():
 for i in range(LORE.size()):
  var pt:Vector2=LORE[i][1]
  var body:=StaticBody3D.new()
  body.position=Vector3(pt.x,game.height_at(pt.x,pt.y),pt.y)
  body.collision_layer=2|8
  body.set_meta("lore_id",i)
  game.add_child(body)
  var model:Node3D=game.visuals.item_model("Circuit board")
  model.scale=Vector3.ONE*0.7
  model.rotation.x=-0.35
  body.add_child(model)
  var hit:=CollisionShape3D.new()
  var shape:=BoxShape3D.new()
  shape.size=Vector3(0.65,0.75,0.5)
  hit.shape=shape
  hit.position.y=0.35
  body.add_child(hit)
  var title:=Label3D.new()
  title.text="FIELD ARCHIVE  /  E"
  title.font_size=24
  title.pixel_size=0.005
  title.position.y=1.0
  title.billboard=BaseMaterial3D.BILLBOARD_ENABLED
  title.visibility_range_end=7
  body.add_child(title)
  lore_nodes.append(body)

func collect_lore(index:int) -> bool:
 if index<0 or index>=LORE.size():return false
 var key:="lore:%d"%index
 if game.quest_events.get(key,false):
  game.show_menu("archive")
  return false
 game.quest_events[key]=true
 game.notify("Archive recovered  /  "+LORE[index][0])
 game.play_sound("res://collect.wav")
 game.mark_save()
 game.show_menu("archive")
 return true

func toggle_gear(key:String) -> bool:
 if not game.equipment.has(key):return false
 if not game.equipment[key] and not game.quest_events.get("stowed:"+key,false):return false
 if game.equipment[key]:
  if key=="Backpack" and game.Data.slots(game.inventory)>16:
   game.notify("Store cargo before removing the backpack upgrade.")
   return false
  game.equipment[key]=0
  game.quest_events["stowed:"+key]=true
 else:
  game.equipment[key]=1
  game.quest_events.erase("stowed:"+key)
 game.oxygen=minf(game.oxygen,game.max_oxygen())
 game.mark_save()
 return true

func draw_equipment():
 var p:Panel=game.panel_at(game.overlay,Vector2(180,85),Vector2(1240,730))
 game.label_at(p,"ASTRONAUT  /  SUIT SYSTEMS",Vector2(30,22),29)
 var diagram:=SuitDiagram.new()
 diagram.position=Vector2(46,150)
 diagram.size=Vector2(220,340)
 diagram.mouse_filter=Control.MOUSE_FILTER_IGNORE
 p.add_child(diagram)
 game.label_at(p,"UZ-01 SURFACE SUIT",Vector2(32,510),17,Color("91cbd2"))
 game.label_at(p,"Oxygen capacity  %.0f\nBackpack slots  %d\nStowed upgrades remain owned."%[game.max_oxygen(),game.max_cargo()],Vector2(32,552),15)
 var row:=0
 for key in game.equipment:
  var owned:bool=bool(game.equipment[key]) or bool(game.quest_events.get("stowed:"+key,false))
  var name:String={"Oxygen tank":"T1 Oxygen tank","Backpack":"T2 Backpack"}.get(key,key)
  var tile:Panel=game.panel_at(p,Vector2(330+(row%2)*440,99+(row/2)*119),Vector2(420,108))
  game.icon_at(tile,name,Vector2(6,5),Vector2(86,95))
  game.label_at(tile,name,Vector2(104,10),18)
  game.label_at(tile,"INSTALLED" if game.equipment[key] else "STOWED" if owned else "NOT CRAFTED",Vector2(104,36),12,Color("92ccd0"))
  if owned:game.button_at(tile,"Remove" if game.equipment[key] else "Install",Vector2(104,62),Vector2(295,33),func():toggle_gear(key);game.show_menu("equipment"))
  row+=1
 game.button_at(p,"Backpack",Vector2(330,655),Vector2(400,44),func():game.show_menu("inventory"))
 game.button_at(p,"Return",Vector2(770,655),Vector2(420,44),game.resume)

func draw_archive():
 var p:Panel=game.panel_at(game.overlay,Vector2(230,75),Vector2(1140,750))
 game.label_at(p,"FIELD ARCHIVES",Vector2(30,25),30)
 for i in range(LORE.size()):
  var unlocked:bool=game.quest_events.get("lore:%d"%i,false)
  game.label_at(p,LORE[i][0] if unlocked else "UNRECOVERED  /  "+LORE[i][2],Vector2(32,92+i*140),20,Color("94d9d5"))
  var text:Label=game.label_at(p,LORE[i][3] if unlocked else "Explore this region and interact with a field archive. Archives are optional and remain recorded after loading.",Vector2(32,127+i*140),17)
  text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
  text.set_deferred("size",Vector2(1060,90))
 game.button_at(p,"Return",Vector2(800,678),Vector2(300,44),game.resume)

func draw_credits():
 var p:Panel=game.panel_at(game.overlay,Vector2(300,120),Vector2(1000,650))
 game.label_at(p,"NASAFormation  /  CREDITS",Vector2(32,30),30)
 var text:Label=game.label_at(p,"An independent educational Mars survival prototype.\n\nOriginal procedural models, shaders, interface and synthesized effects.\nGodot 4.4.1  /  MIT license. See runtime/Godot-LICENSE.txt.\nNASA reference imagery and science sources are listed in ASSETS.md.\n\nInspired by the survival and terraforming genre, including Miju Games'\nThe Planet Crafter. No proprietary game assets are included.\n\nNASA does not endorse this project. The playable sector, ore economy\nand terraforming outcomes are fictional teaching models.\n\nPhoto mode  /  F8. Fly with WASD and Q/E. F9 saves a PNG.\nExisting saves, mission records and equipment remain compatible.",Vector2(32,112),20)
 text.size=Vector2(930,440)
 game.button_at(p,"Return",Vector2(32,565),Vector2(930,48),func():game.show_menu("main"))

func footstep_kind() -> String:
 if game.flooded_ground(game.player.position):return "step_water"
 for unit in game.structures:
  if unit.type in [game.Build.POD,game.Build.HABITAT,game.Build.FOUNDATION] and unit.node.position.distance_to(game.player.position)<2.7:return "step_metal"
 return "step_stone" if game.region_at(game.player.position.x,game.player.position.z)==1 else "step_dust"

func update_audio():
 if not game.self_test and not game.render_test and rain_audio==null:
  rain_audio=AudioStreamPlayer.new()
  rain_audio.stream=game.Audio.synthesize("rain")
  rain_audio.volume_db=-80
  add_child(rain_audio)
  rain_audio.play()
 var gain:float=linear_to_db(maxf(0.00001,game.sfx_level))
 if is_instance_valid(game.sfx_mine):game.sfx_mine.volume_db=-13+gain
 if is_instance_valid(game.ambience):game.ambience.volume_db=-24+gain
 if game.sfx_level<=0.001 and is_instance_valid(game.sfx_machine):game.sfx_machine.volume_db=-80
 if rain_audio!=null:
  var rain:float=game.Mars.rain_strength(game.time,game.terraform_index()) if not game.paused else 0.0
  rain_audio.volume_db=linear_to_db(maxf(0.00001,rain*game.sfx_level*0.26))

func test_systems():
 var gear:Dictionary=game.equipment.duplicate(true)
 var events:Dictionary=game.quest_events.duplicate(true)
 var cargo:Dictionary=game.inventory.duplicate(true)
 game.equipment["Oxygen tank"]=1
 game.check(toggle_gear("Oxygen tank") and game.equipment["Oxygen tank"]==0 and game.quest_events.get("stowed:Oxygen tank"),"Suit removal retains ownership in versioned quest state")
 game.check(game.craft_lock(game.Data.CRAFTS[3])=="Already owned","Stowed gear cannot be crafted and paid for twice")
 game.check(toggle_gear("Oxygen tank") and game.max_oxygen()==145,"Stowed oxygen upgrade can be installed again")
 game.equipment.Backpack=1
 game.inventory={"Iron":340}
 game.check(not toggle_gear("Backpack") and game.equipment.Backpack==1,"Backpack removal protects cargo above base capacity")
 game.inventory=cargo
 game.equipment=gear
 game.quest_events=events
 var was_paused:bool=game.paused
 toggle_photo()
 game.check(photo and game.paused and photo_camera.current and not game.hud.visible,"Photo camera freezes survival and hides the HUD")
 var escape:=InputEventKey.new()
 escape.keycode=KEY_ESCAPE
 escape.pressed=true
 game.check(handle_input(escape) and not photo and game.paused==was_paused,"Photo Escape restores the prior simulation state")
 game.show_menu("archive")
 game.check(collect_lore(0) and not collect_lore(0),"A field archive records exactly once")
 var encoded:Dictionary=game.capture_save()
 game.check(encoded.events.get("lore:0",false),"Collected lore is included in campaign persistence")
 game.quest_events=events
 messages.clear()
 for i in range(6):push_message("Notice %d"%i)
 game.check(messages.size()==3 and messages[0].text=="Notice 5","Notifications retain only the three most recent messages")
 game.show_menu("equipment")
 game.show_menu("credits")

func profile_rendered_session():
 var original:Vector3=game.player.position
 game.resume()
 Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
 var begin:=Time.get_ticks_usec()
 var costs:Array[float]=[]
 for i in range(180):
  var at:=Time.get_ticks_usec()
  game.yaw+=0.004
  await RenderingServer.frame_post_draw
  costs.append((Time.get_ticks_usec()-at)/1000.0)
 costs.sort()
 var seconds:float=(Time.get_ticks_usec()-begin)/1000000.0
 var baseline:=int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
 for i in range(30):
  for page in ["inventory","craft","equipment","archive","map","settings"]:game.show_menu(page)
  game.resume()
  await game.get_tree().process_frame
 await game.get_tree().process_frame
 var after:=int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
 var report:="GPU %s\n1080p rendered sample: %d frames / %.2fs = %.1f FPS\np50 %.2fms / p95 %.2fms / max %.2fms\n30 cycles of six menus: nodes %d -> %d\nShort local sample includes terrain and UI work; no cross-hardware 60 FPS guarantee."%[RenderingServer.get_video_adapter_name(),costs.size(),seconds,costs.size()/seconds,costs[90],costs[171],costs[-1],baseline,after]
 var original_quality:int=game.quality
 for profile in [0,1,2]:
  game.quality=profile
  apply_quality()
  for warm in range(15):await RenderingServer.frame_post_draw
  var start:=Time.get_ticks_usec()
  for sample in range(90):await RenderingServer.frame_post_draw
  var duration:float=(Time.get_ticks_usec()-start)/1000000.0
  report+="\n%s quality / 1080p output / 90 frames: %.1f FPS"%[["Low","Medium","High"][profile],90.0/duration]
 game.quality=original_quality
 apply_quality()
 print(report)
 var file:=FileAccess.open("user://upgrade-performance.txt",FileAccess.WRITE)
 file.store_string(report)
 game.check(after<=baseline+20,"Repeated menu creation and disposal has bounded node count")
 game.player.position=original

func initialize(owner_game:Node):
 game=owner_game
 for i in range(3):
  var label:Label=game.label_at(game.hud,"",Vector2(520,145+i*27),16,Color("b9e3e5"))
  label.size=Vector2(560,25)
  label.clip_text=true
  label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  labels.append(label)
 progress=ProgressBar.new()
 progress.position=Vector2(1250,157)
 progress.size=Vector2(280,7)
 progress.step=0.001
 progress.max_value=1
 progress.show_percentage=false
 progress.mouse_filter=Control.MOUSE_FILTER_IGNORE
 game.hud.add_child(progress)
 setup_lore()
 apply_quality()

func apply_quality():
 game.sun.shadow_enabled=game.quality>0
 game.sun.directional_shadow_max_distance=[45.0,75.0,110.0][game.quality]
 game.get_viewport().scaling_3d_scale=[0.65,0.82,1.0][game.quality]
 game.get_viewport().msaa_3d=Viewport.MSAA_2X if game.quality==2 else Viewport.MSAA_DISABLED

func setup_portrait():
 portrait=SubViewport.new()
 portrait.size=Vector2i(600,740)
 portrait.own_world_3d=true
 portrait.transparent_bg=true
 portrait.render_target_update_mode=SubViewport.UPDATE_DISABLED
 add_child(portrait)
 portrait_root=Node3D.new()
 portrait.add_child(portrait_root)
 var rig:Node3D=game.Rig.new()
 rig.build_pressure_suit(portrait_root,game.visuals)
 rig.add_world_arms(portrait_root,game.visuals)
 var fabric:Material=game.visuals.surface(Color("adb4ae"),0.1,0.8)
 var boot:Material=game.visuals.surface(Color("313b48"),0.1,0.83)
 for side in [-1,1]:
  game.visuals.ball(portrait_root,Vector3(side*0.15,0.64,0),0.13,Vector3(1,2.6,1),fabric)
  game.visuals.ball(portrait_root,Vector3(side*0.15,0.24,-0.03),0.11,Vector3(1,1.8,1),fabric)
  game.visuals.bevel_box(portrait_root,Vector3(side*0.15,0.08,-0.07),Vector3(0.23,0.16,0.36),0.04,boot)
 rig.free()
 portrait_root.rotation.y=0.3
 portrait_camera=Camera3D.new()
 portrait_camera.position=Vector3(0.0,1.15,-3.1)
 portrait.add_child(portrait_camera)
 portrait_camera.look_at(Vector3(0,1.0,0))
 portrait_camera.fov=40
 for entry in [[Vector3(-28,160,0),Color("f3c193"),2.4],[Vector3(-18,-35,0),Color("62bfcf"),2.0]]:
  var lamp:=DirectionalLight3D.new()
  lamp.rotation_degrees=entry[0]
  lamp.light_color=entry[1]
  lamp.light_energy=entry[2]
  portrait.add_child(lamp)
 var mark:=Image.new()
 if mark.load_svg_from_string(FileAccess.get_file_as_string("res://app-mark.svg"))==OK:DisplayServer.set_icon(mark)

func show_portrait():
 var art:=TextureRect.new()
 art.position=Vector2(220,120)
 art.size=Vector2(490,605)
 art.texture=portrait.get_texture()
 art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 art.mouse_filter=Control.MOUSE_FILTER_IGNORE
 game.overlay.add_child(art)
 portrait.render_target_update_mode=SubViewport.UPDATE_ALWAYS
 game.label_at(game.overlay,"NASAFormation",Vector2(145,67),48,Color("ebf0e8"))
 game.label_at(game.overlay,"MAKE MARS HABITABLE",Vector2(148,125),15,Color("70c6d5"))

func push_message(message:String):
 messages.push_front({"text":message,"age":0.0})
 if messages.size()>3:messages.resize(3)

func _process(dt:float):
 if not is_instance_valid(game):return
 elapsed+=dt
 frames+=1
 worst=maxf(worst,dt)
 if portrait!=null:
  var shown:bool=game.menu in ["main","pause"]
  portrait.render_target_update_mode=SubViewport.UPDATE_ALWAYS if shown else SubViewport.UPDATE_DISABLED
  if shown and not game.reduced_motion:portrait_root.rotation.y=0.28+sin(elapsed*0.22)*0.06
 game.notice_label.hide()
 if not game.paused:
  for entry in messages:entry.age+=dt
 messages=messages.filter(func(entry):return entry.age<5.0)
 for i in range(labels.size()):
  labels[i].text=messages[i].text if i<messages.size() else ""
  labels[i].modulate.a=clampf(5.0-float(messages[i].age),0,1) if i<messages.size() else 0.0
 progress.value=lerpf(progress.value,game.Progression.progress(game.terraform_index()),1.0-exp(-dt*6.0))
 if photo:
  var movement:=Vector3.ZERO
  if Input.is_physical_key_pressed(KEY_W):movement.z-=1
  if Input.is_physical_key_pressed(KEY_S):movement.z+=1
  if Input.is_physical_key_pressed(KEY_A):movement.x-=1
  if Input.is_physical_key_pressed(KEY_D):movement.x+=1
  if Input.is_physical_key_pressed(KEY_E):movement.y+=1
  if Input.is_physical_key_pressed(KEY_Q):movement.y-=1
  photo_camera.position+=photo_camera.basis*movement.limit_length()*dt*(18.0 if Input.is_physical_key_pressed(KEY_SHIFT) else 5.0)

func handle_input(event:InputEvent) -> bool:
 if photo and event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
  toggle_photo()
  return true
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode==KEY_F8 and (photo or not game.paused):
   toggle_photo()
   return true
  elif event.keycode==KEY_F9 and photo:
   var path:="user://NASAFormation-photo-%d.png"%Time.get_unix_time_from_system()
   get_viewport().get_texture().get_image().save_png(path)
   game.notify("Photo saved  /  "+ProjectSettings.globalize_path(path))
   get_viewport().set_input_as_handled()
 if photo and event is InputEventMouseMotion:
  photo_camera.rotation.y-=event.relative.x*game.sensitivity
  photo_camera.rotation.x=clampf(photo_camera.rotation.x-event.relative.y*game.sensitivity,-1.5,1.5)
 return photo

func toggle_photo():
 photo=not photo
 if photo:
  old_paused=game.paused
  game.paused=true
  game.hud.hide()
  for action in InputMap.get_actions():Input.action_release(action)
  game.tool_beam.hide()
  game.rig.mount.hide()
  if is_instance_valid(game.build_ghost):game.build_ghost.hide()
  photo_camera=Camera3D.new()
  game.add_child(photo_camera)
  photo_camera.global_transform=game.camera.global_transform
  photo_camera.fov=game.camera.fov
  photo_camera.current=true
 else:
  photo_camera.queue_free()
  game.camera.current=true
  game.paused=old_paused
  game.hud.show()
  game.rig.mount.visible=not game.third_person
  Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
  game.notify("Photo mode closed  /  F8 camera, F9 capture")

func _exit_tree():
 if elapsed>0:
  print("NASAFORMATION SESSION SAMPLE: %.1f average FPS, %.1f ms longest frame, %d frames. Includes loading and menus; not a hardware benchmark."%[frames/elapsed,worst*1000,frames])

