extends Node3D
# ARES: native 3D survival. Terrain and geology are explicitly simulated.
const Progression = preload("res://visual_progression.gd")
const Data = preload("res://nur_data.gd")
const Visuals = preload("res://nur_visuals.gd")
const IconAtlas = preload("res://nur_icon_atlas.gd")
const Rig = preload("res://nur_rig.gd")
const HUD = preload("res://nur_hud.gd")
const Audio = preload("res://nur_audio.gd")
const Onboarding = preload("res://nur_onboarding.gd")
const Mars = preload("res://nasa_mission.gd")
const Survey = preload("res://mars_regions.gd")
const HUD_WHITE := Color("fff4e9")
const HUD_SOFT := Color("ecd4c1")
const SAVE = "user://nur-expedition.json"
const SETTINGS = "user://nur-settings.cfg"
const WORLD = Survey.HALF*2.0
const CHUNK = 50.0
const ORES = Data.ORES
const COLORS = Data.COLORS
const REGION_NAMES = Data.REGIONS
const Build = Data.Build
const recipes = Data.BUILDABLES
const BASIN = Vector2(105, 100)
const BASIN_RADIUS = 49.0


var inventory = {}
var equipment = {"Oxygen tank":0,"Backpack":0,"Mining upgrade":0,"Agility boots":0,"T3 Oxygen tank":0,"Jetpack":0,"Air filter":0}
var opened_crates: Dictionary = {}
var discovery_crates: Array[Node3D] = []
var quest_events: Dictionary = {}
var quest_step := 0
var hotbar: Array = ["Oxygen capsule", "Water bottle", "Food pack", "", "", ""]
var selected_slot := 0
var relaxed := false
var challenge := false
var sfx_level := 0.8
var build_rotation := 0
var build_group := "All"
var craft_group := 0
var craft_selected := 0
var craft_quantity := 1
var stack_selected := -1
var preferred_slots: Array = []
var machine: Dictionary = {}
var ti_rate := 0.0
var production_rates := {"Pressure":0.0,"Heat":0.0,"Oxygen":0.0,"Biomass":0.0}
var stage_index := 0
var lake: MeshInstance3D
var greenery: MultiMeshInstance3D
var blossoms: MultiMeshInstance3D
var greenery_positions: Array[Vector3] = []
var tool_beam: MeshInstance3D
var flashlight: SpotLight3D
var mining_target: Node3D
var aim_point := Vector3.ZERO
var dust: GPUParticles3D
var action_notice: Label
var hotbar_labels: Array[Label] = []
var last_low_warning := -30.0
var ground_target := Vector3.INF
var aim_marker: MeshInstance3D
var stars: MultiMeshInstance3D
var waypoint_label: Label
var visuals := Visuals.new()
var icons: SubViewport
var rig: Node3D
var context_card: Control
var context_title: Label
var context_body: Label
var context_icon: TextureRect
var context_prompt: Label
var target_item := ""
var target_unit: Dictionary = {}
var target_kind := "none"
var reticle: Control
var advanced_status: Label
var advanced_panel: Control
var cached_placement := ""
var tool_status: Label
var pickup_icon: TextureRect
var pinned_panel: Control
var pinned_recipe := -1
var build_detail := 0
var starting_up:=true
var polish:Node
var base_fov := 75.0
var invert_y := false
var hud_scale := 1.0
var reduced_motion := false
var volume := 0.78
var radio_enabled := true
var inventory_filter := "All"
var world_fx: GPUParticles3D
var fx_cooldown := 0.0
var beam_material: StandardMaterial3D
var pending_action: Callable
var pending_time := 0.0
var ui_open_frame := -1
var previous_health := 100.0
var verify_spawn := true
var near_machine := 0.0
var sfx_mine: AudioStreamPlayer
var mining_material := ""
var mining_contacts := {}
var mining_fractures := {}
var sfx_machine: AudioStreamPlayer
var effects: Dictionary = {}
var construction_material: ShaderMaterial
var scenery_obstacles: Array[Dictionary] = []

var noise = FastNoiseLite.new()
var detail = FastNoiseLite.new()
var chunks = {}
var deposits = {}
var depleted = {}
var structures = []
var player: CharacterBody3D
var pivot: Node3D
var camera: Camera3D
var astronaut: Node3D
var sun: DirectionalLight3D
var environment: WorldEnvironment
var hud: Control
var overlay: Control
var status_label: Label
var notice_label: Label
var vitals = []
var labels = []
var compass: HUD.CompassTape
var heading_label: Label
var position_label: Label
var objective_rows: Array[Panel] = []
var objective_progress: Label
var visible_objective := -1
var visor_font: SystemFont
var visor_idle: StyleBoxFlat
var visor_active: StyleBoxFlat
var onboarding: Node
var intro_seen := false
var intro_return := ""
var controls_return := "main"
var mission_shield := false
var mission_grow := false
var mission_radio := false
var mission_exposure := 0.0
var mission_harvest := 0.0
var earth_reply_at := -1.0
var earth_reports := 0
var mission_power := {}
var weather_label: Label
var landing_dust: GPUParticles3D
var ground_haze: GPUParticles3D
var cinematic_pod: Node3D
var cinematic_astronaut: Node3D
var cinematic_array: Node3D
var cinematic_turbine: Node3D
var logo: ImageTexture
var map_waypoint := -1
var rain: GPUParticles3D
var survey_deposits: Dictionary = {}
var index_label: Label
var nav_label: Label
var time = 0.0
var oxygen = 100.0
var water = 100.0
var food = 100.0
var health = 100.0
var heat = 0.0
var pressure = 0.0
var biomass = 0.0
var planet_oxygen = 0.0
var safe_position = Vector3(0,0,8)
var yaw = PI
var pitch = -0.12
var sensitivity = 0.0022
var third_person = false
var paused = true
var dead = false
var won = false
var menu = "main"
var selected_build = -1
var build_ghost: Node3D
var target: Node3D
var mine_progress = 0.0
var notice_time = 0.0
var chunk_clock = 0.0
var sim_clock = 0.0
var autosave_clock = 0.0
var power_in = 0.0
var power_out = 0.0
var seed_value = 7319
var rng = RandomNumberGenerator.new()
var quality = 2
var config = ConfigFile.new()
var terrain_material: ShaderMaterial
var mars_halo := Color("7d9cbb")
var sandstone: ShaderMaterial
var volcanic_rock: ShaderMaterial
var surface_tiles: Dictionary = {}
var self_test = false
var render_test := false
var capture_intro := false
var ambience: AudioStreamPlayer
var exploration_music: AudioStreamPlayer
var action_music: AudioStreamPlayer
var music_level := 0.72
var sfx: AudioStreamPlayer

func _ready():
 set_process(false)
 set_physics_process(false)
 var boot:=CanvasLayer.new()
 boot.layer=100
 add_child(boot)
 var shade:=ColorRect.new()
 shade.color=Color("101c28")
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 boot.add_child(shade)
 var boot_text:=label_at(shade,"NASAFormation  /  Preparing surface survey",Vector2(110,360),30)
 await get_tree().process_frame
 self_test = "--self-test" in OS.get_cmdline_user_args()
 render_test = "--render-test" in OS.get_cmdline_user_args()
 capture_intro = "--capture-intro" in OS.get_cmdline_user_args()
 rng.seed = seed_value
 noise.seed = seed_value
 noise.frequency = 0.006
 noise.fractal_octaves = 4
 detail.seed = seed_value + 41
 detail.frequency = 0.035
 reset_supplies()
 load_settings()
 setup_input()
 setup_world()
 boot_text.text="NASAFormation  /  Preparing suit and geology"
 await get_tree().process_frame
 setup_player()
 setup_expedition_world()
 boot_text.text="NASAFormation  /  Preparing equipment atlas"
 await get_tree().process_frame
 setup_icons()
 var artwork:=Image.load_from_file("res://nasaformation.png")
 if artwork and not artwork.is_empty():
  logo=ImageTexture.create_from_image(artwork)
  var small:=artwork.duplicate() as Image
  small.resize(256,256,Image.INTERPOLATE_LANCZOS)
  DisplayServer.set_icon(small)
  # Window icon is supplied as an Image by the branding module.
 setup_hud()
 setup_context_hud()
 polish=load("res://expedition_polish.gd").new()
 add_child(polish)
 polish.initialize(self)
 onboarding=Onboarding.new()
 add_child(onboarding)
 onboarding.set_enabled(radio_enabled)
 onboarding.intro_finished.connect(end_intro)
 onboarding.shot_updated.connect(update_intro_scene)
 if not self_test and not render_test:setup_audio()
 starting_up=false
 boot.queue_free()
 set_process(true)
 set_physics_process(true)
 if self_test:
  run_tests.call_deferred()
  return
 DisplayServer.window_set_title("NASAFormation")
 if render_test or capture_intro or not load_game():
  add_structure(Build.POD, Vector3.ZERO)
 seed_starter_ores()
 restore_survey_deposits()
 update_chunks()
 refresh_grid()
 apply_stage()
 show_menu("main")
 if render_test:run_render_test.call_deferred()
 if capture_intro:
  onboarding.skip_label.hide()
  begin_intro.call_deferred()

func reset_supplies():
 inventory.clear()
 inventory.assign({"Oxygen capsule":2, "Water bottle":2, "Food pack":2})

func structure_key(index:int) -> String:
 return "structure/%d"%index

func setup_icons():
 var models := {}
 for id in ORES:
  models[id]={"node":visuals.item_model(id),"yaw":visuals.resources[id].icon_yaw}
 for recipe in Data.CRAFTS:models[recipe.name]={"node":visuals.item_model(recipe.name)}
 for id in Visuals.EQUIPMENT_MODELS:
  if not models.has(id):models[id]={"node":visuals.item_model(id)}
 for kind in range(recipes.size()):
  var front := 2.68 if kind in [Build.HEATER,Build.HEATER_2] else -0.49
  models[structure_key(kind)]={"node":add_structure(kind,Vector3.ZERO,{},0.0,0,true),"yaw":front,"pitch":-0.35 if kind in [Build.SOLAR,Build.SOLAR_2] else 0.37}
 icons=IconAtlas.new()
 add_child(icons)
 icons.render_models(models)

func icon_texture(id:String) -> Texture2D:
 return icons.textures.get(id) if is_instance_valid(icons) else null

func icon_at(parent:Control,id:String,pos:Vector2,extent:Vector2) -> TextureRect:
 var art := TextureRect.new()
 art.texture=icon_texture(id)
 art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 art.mouse_filter=Control.MOUSE_FILTER_IGNORE
 art.position=pos
 art.size=extent
 parent.add_child(art)
 return art

func setup_context_hud():
 var crosshair := HUD.Reticle.new()
 crosshair.position=Vector2(779,429)
 crosshair.size=Vector2(42,42)
 crosshair.pivot_offset=Vector2(21,21)
 crosshair.mouse_filter=Control.MOUSE_FILTER_IGNORE
 hud.add_child(crosshair)
 reticle=crosshair
 context_card=visor_panel(hud,Vector2(852,470),Vector2(324,139))
 context_card.add_theme_stylebox_override("panel",visor_active)
 context_icon=icon_at(context_card,"",Vector2(6,9),Vector2(64,64))
 context_title=visor_label(context_card,"",Vector2(74,9),18)
 context_body=visor_label(context_card,"",Vector2(74,34),13,HUD_SOFT)
 context_body.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 context_body.size.x=237
 context_prompt=visor_label(context_card,"",Vector2(74,113),13)
 context_card.hide()
 pinned_panel=visor_panel(hud,Vector2(1248,244),Vector2(304,196))
 pinned_panel.hide()
 advanced_panel=panel_at(hud,Vector2(1238,236),Vector2(330,134))
 advanced_status=label_at(advanced_panel,"",Vector2(12,11),14,HUD.TEXT)
 advanced_panel.hide()
 var tool_panel:=visor_panel(hud,Vector2(1327,819),Vector2(216,51))
 icon_at(tool_panel,"Multi-tool",Vector2(4,1),Vector2(43,47))
 tool_status=visor_label(tool_panel,"",Vector2(51,6),13)
 pickup_icon=icon_at(hud,"",Vector2(753,693),Vector2(90,60))
 pickup_icon.hide()
 apply_hud_scale()

func apply_hud_scale():
 if not is_instance_valid(hud):return
 for panel in hud.get_children():
  if not panel is Control:continue
  var rect: Control = panel
  if rect.is_in_group("fixed_hud"):continue
  rect.pivot_offset=Vector2(rect.size.x if rect.position.x>1000 else 0,rect.size.y if rect.position.y>665 else 0)
  if rect.position.x>400 and rect.position.x<1000:rect.pivot_offset.x=rect.size.x/2.0
  if rect==reticle:rect.pivot_offset=rect.size/2.0
  rect.scale=Vector2.ONE*hud_scale

func machine_hint(unit:Dictionary) -> String:
 if has_container(unit.type):
  return "%d stacks stored"%Data.slots(unit.stored)
 if unit.type in [Build.TUBE,Build.TUBE_2] and not unit.seeded:return "Seed slot empty"
 if not unit.online:return "Output paused"
 return output_text(recipes[unit.type])

func has_container(kind:int) -> bool:
 return kind in [Build.STORAGE,Build.RECOVERY,Build.WATER,Build.ORE] or recipes[kind].has("makes")

func update_context_hud():
 if selected_build>=0:
  context_card.hide()
  update_build_panel()
  return
 var state: Dictionary={}
 if target_kind=="resource":
  var spec = visuals.resources[target_item]
  var room := Data.transaction(inventory.duplicate(),{},{target_item:1},max_cargo())
  state=HUD.resource_card(spec,room,spec.harvest_time/(1.35 if equipment["Mining upgrade"] else 1.0))
 elif not target_unit.is_empty():
  var spec:Dictionary=recipes[target_unit.type]
  var state_text:="ONLINE" if target_unit.online else "GRID SHORTAGE" if target_unit.active else "SWITCHED OFF"
  state={"id":structure_key(target_unit.type),"title":spec.name,"body":"%s   ·   %+.2f kW\n%s\n%s"%[state_text,spec.power,spec.desc,machine_hint(target_unit)],"hint":"E  Interact","ok":target_unit.online}
 elif target_kind=="fabricator":
  state={"id":structure_key(Build.CRAFT),"title":"Pod fabricator","body":"Fabricates supplies and suit upgrades.","hint":"E  Open fabricator","ok":true}
 elif target_kind=="cache":
  state={"id":structure_key(Build.STORAGE),"title":"Survey cache","body":"Supplies and field samples from an earlier expedition.","hint":"E  Open cache","ok":true}
  if target==cargo_gate:
   state={"id":"Portable power cell","title":"Sealed cargo compartment","body":"Requires one Portable power cell from the fabricator.","hint":"E  Connect power cell","ok":inventory.get("Portable power cell",0)>0}
  elif target==cargo_cache:
   state={"id":"Osmium","title":"Compartment salvage","body":"Rare metals and emergency supplies.","hint":"E  Recover salvage","ok":true}
 if state.is_empty():
  context_card.hide()
  return
 context_card.show()
 context_icon.texture=icon_texture(state.id)
 context_title.text=state.title
 context_body.text=state.body
 context_prompt.text=state.hint
 context_prompt.modulate=HUD.ACCENT if state.ok else HUD.ALERT
 context_icon.visible=true

var build_hud: Control
var build_hud_status: Label
var build_hud_grid: Label
var build_hud_key := ""
var pinned_key := ""

func update_build_panel():
 var type: int = selected_build
 var spec: Dictionary=recipes[type]
 var status := cached_placement
 var state_key := "%d/%s/%s"%[type,inventory.hash(),spec.at]
 if not is_instance_valid(build_hud) or build_hud_key!=state_key:
  if is_instance_valid(build_hud):build_hud.queue_free()
  build_hud_key=state_key
  build_hud=panel_at(hud,Vector2(1137,244),Vector2(431,499))
  icon_at(build_hud,structure_key(type),Vector2(286,15),Vector2(121,119))
  label_at(build_hud,spec.name,Vector2(16,16),20)
  var description:=label_at(build_hud,spec.desc,Vector2(16,52),14,HUD.SECONDARY)
  description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
  description.size.x=265
  label_at(build_hud,output_text(spec),Vector2(16,109),14,HUD.ACCENT)
  label_at(build_hud,"Unlock  %d Ti"%int(spec.at),Vector2(16,138),13,HUD.SECONDARY)
  requirements(build_hud,spec.cost,Vector2(15,171),401,true)
  build_hud_grid=label_at(build_hud,"",Vector2(16,376),14,HUD.SECONDARY)
  build_hud_status=label_at(build_hud,"",Vector2(16,411),16)
  label_at(build_hud,"LMB BUILD   /   R ROTATE   /   RMB CANCEL",Vector2(16,463),12,HUD.SECONDARY)
  build_hud.pivot_offset=Vector2(431,0)
  build_hud.scale=Vector2.ONE*hud_scale
 build_hud.show()
 build_hud_status.text="✓  Ready to build" if status.is_empty() else "!  "+status
 build_hud_status.modulate=HUD.GOOD if status.is_empty() else HUD.ALERT
 build_hud_grid.text="Grid after build  %.2f supply / %.2f demand kW"%[power_in+maxf(0,spec.power),power_out+maxf(0,-spec.power)]
 pinned_panel.hide()

func update_pinned():
 if not is_instance_valid(pinned_panel):return
 if pinned_recipe<0 or selected_build>=0:
  pinned_panel.hide()
  return
 if advanced_panel.visible:
  pinned_panel.position.y=382.0
 else:
  pinned_panel.position.y=244.0
 pinned_panel.show()
 var spec:Dictionary=recipes[pinned_recipe]
 var missing:=HUD.shortages(inventory,spec.cost)
 var key:="%s/%s"%[pinned_recipe,missing.hash()]
 if key==pinned_key:return
 pinned_key=key
 for child in pinned_panel.get_children():
  pinned_panel.remove_child(child)
  child.queue_free()
 label_at(pinned_panel,spec.name+"  /  PINNED",Vector2(12,10),16,HUD.ACCENT)
 var i:=0
 for item in missing:
  icon_at(pinned_panel,item,Vector2(10,40+i*27),Vector2(31,25))
  label_at(pinned_panel,"%s  ·  need %s"%[item,missing[item]],Vector2(47,44+i*27),13,HUD.ALERT)
  i+=1
 if missing.is_empty():label_at(pinned_panel,"✓  All materials gathered",Vector2(13,52),14,HUD.GOOD)
 pinned_panel.size.y=78+i*27

func animate_machine(unit:Dictionary,dt:float):
 var node:Node3D=unit.node
 var distance:=node.position.distance_to(player.position)
 var rotor:=node.get_node_or_null("Rotor") as Node3D
 if rotor!=null and unit.online:
  if unit.type in [Build.WIND,Build.WIND_2]:rotor.rotation.z+=dt*2.0
  else:
   rotor.rotation.y+=dt*(6.5 if unit.type==Build.DRILL_2 else 4.0)
   if not reduced_motion:rotor.position.y=sin(time*5.2)*0.058
 var lamp:=node.get_node_or_null("StatusLamp") as MeshInstance3D
 if lamp!=null and lamp.visible!=unit.online:lamp.visible=unit.online
 var core:=node.get_node_or_null("HeatCore") as Node3D
 if core!=null:
  var glow:StandardMaterial3D=core.get_child(0).material_override
  var pulse:=0.12*sin(time*4.9) if not reduced_motion else 0.0
  glow.emission_energy_multiplier=(0.78+pulse) if unit.online else 0.0
  glow.albedo_color=Color("bd5e3f") if unit.online else Color("42343b")
  var haze:=node.get_node_or_null("HeatHaze") as MeshInstance3D
  if haze!=null:
   haze.visible=unit.online and quality==2 and not reduced_motion and distance<17
   if haze.visible:haze.material_override.set_shader_parameter("strength",1.0-smoothstep(8.0,17.0,distance))
 var dust_effect:=node.get_node_or_null("WorkDust") as GPUParticles3D
 if dust_effect!=null:
  var working:bool=unit.online and quality>0 and distance<23.0
  if working!=dust_effect.emitting:dust_effect.emitting=working
 var droplets:=node.get_node_or_null("Condensation") as Node3D
 if droplets!=null:
  droplets.visible=unit.online and unit.seeded and quality>0
  if droplets.visible and not reduced_motion:
   for i in range(droplets.get_child_count()):
    droplets.get_child(i).position.y=0.47+fposmod(float(i)*0.401-time*0.15,1.46)
 var gate:=node.get_node_or_null("Gate") as Node3D
 if gate!=null:
  var opened:=node.position.distance_to(player.position)<2.45
  gate.position.y=lerpf(gate.position.y,3.43 if opened else 1.16,minf(1.0,dt*6.5))
 var lid:=node.get_node_or_null("Lid") as Node3D
 if lid!=null:
  var opening:=pending_action.is_valid() and target==node
  lid.rotation.x=lerpf(lid.rotation.x,-1.04 if opening else 0.0,minf(1.0,dt*13.0))
 var readout:=node.get_node_or_null("Readout") as Label3D
 if readout!=null:
  var text:="OFFLINE" if not unit.online else "READY" if unit.type==Build.CRAFT else "%.0f Ti"%terraform_index()
  if readout.text!=text:readout.text=text
 var water_level:=node.get_node_or_null("WaterLevel") as Node3D
 if water_level!=null:
  var fill:=clampf(float(unit.progress)/45.0+float(unit.stored.get("Water bottle",0))*0.22,0.05,1)
  water_level.scale.y=fill
  water_level.position.y=0.42+fill*0.33

func refresh_suit_hud():
 advanced_status.text="PRESSURE  %.1f    +%.2f/s\nTEMPERATURE  %.1f    +%.2f/s\nOXYGEN  %.1f    +%.2f/s\nBIOMASS  %.1f    +%.2f/s"%[
  pressure,production_rates.Pressure,heat,production_rates.Heat,planet_oxygen,production_rates.Oxygen,biomass,production_rates.Biomass
 ]
 status_label.modulate=HUD.GOOD if power_in+0.001>=power_out else HUD.ALERT
 var mode:="BUILD" if selected_build>=0 else "DECONSTRUCT" if rig.pose==Rig.Pose.DECONSTRUCT else "MINING"
 var hint:="R rotate  ·  RMB cancel" if selected_build>=0 else "Hold LMB to extract" if target_kind=="resource" else "F torch   ·   H telemetry"
 tool_status.text="%s   /   TORCH %s\n%s"%[mode,"ON" if flashlight.visible else "OFF",hint]
 if selected_build<0 and is_instance_valid(build_hud):build_hud.hide()
 update_pinned()


func setup_input():
 var bindings = {"forward":KEY_W,"back":KEY_S,"left":KEY_A,"right":KEY_D,"jump":KEY_SPACE,"sprint":KEY_SHIFT,"interact":KEY_E,"inventory":KEY_I,"build":KEY_B,"map":KEY_M,"view":KEY_V,"save":KEY_F5,"dismantle":KEY_DELETE,"journal":KEY_J,"flashlight":KEY_F,"rotate":KEY_R}
 for action in bindings:
  InputMap.add_action(action)
  var event = InputEventKey.new()
  event.physical_keycode = bindings[action]
  InputMap.action_add_event(action,event)
  var logical_event=InputEventKey.new()
  logical_event.keycode=bindings[action]
  InputMap.action_add_event(action,logical_event)
 var inventory_key = InputEventKey.new()
 inventory_key.physical_keycode = KEY_TAB
 InputMap.action_add_event("inventory", inventory_key)
 InputMap.add_action("mine")
 var click = InputEventMouseButton.new()
 click.button_index = MOUSE_BUTTON_LEFT
 InputMap.action_add_event("mine",click)
 InputMap.add_action("craft")
 var craft_key=InputEventKey.new()
 craft_key.physical_keycode=KEY_C
 InputMap.action_add_event("craft",craft_key)
 var craft_shortcut := InputEventKey.new()
 craft_shortcut.keycode=KEY_C
 InputMap.action_add_event("craft",craft_shortcut)

func material(color:Color,metal=0.0,rough=0.85):
 var m = StandardMaterial3D.new()
 m.albedo_color = color
 m.metallic = metal
 m.roughness = rough
 return m

func mesh_node(parent:Node,mesh:Mesh,pos:Vector3,mat:Material):
 var n = MeshInstance3D.new()
 n.mesh = mesh
 n.position = pos
 n.material_override = mat
 parent.add_child(n)
 return n

func box(parent:Node,pos:Vector3,size:Vector3,mat:Material):
 var mesh = BoxMesh.new()
 mesh.size = size
 return mesh_node(parent,mesh,pos,mat)

func cylinder(parent:Node,pos:Vector3,radius:float,length:float,mat:Material,top=-1.0):
 var mesh = CylinderMesh.new()
 mesh.bottom_radius = radius
 mesh.top_radius = radius if top < 0 else top
 mesh.height = length
 mesh.radial_segments = 16
 return mesh_node(parent,mesh,pos,mat)

func sphere(parent:Node,pos:Vector3,radius:float,mat:Material):
 var mesh = SphereMesh.new()
 mesh.radius = radius
 mesh.height = radius*2
 mesh.radial_segments = 20
 mesh.rings = 10
 return mesh_node(parent,mesh,pos,mat)

func setup_world():
 environment = WorldEnvironment.new()
 var env = Environment.new()
 var sky = Sky.new()
 var sky_mat := ShaderMaterial.new()
 sky_mat.shader=preload("res://mars_sky.gdshader")
 var sunset:=Image.load_from_file("res://nasa/curiosity-sunset.jpg")
 if sunset and not sunset.is_empty():
  var x:=roundi(sunset.get_width()*0.37)
  var y:=roundi(sunset.get_height()*0.58)
  mars_halo=sunset.get_pixel(x,y).lightened(0.25)
 sky_mat.set_shader_parameter("twilight_halo",mars_halo)
 var star_image:=Image.load_from_file("res://milky-way.exr")
 if star_image and not star_image.is_empty():
  sky_mat.set_shader_parameter("star_field",ImageTexture.create_from_image(star_image))
 sky.process_mode=Sky.PROCESS_MODE_REALTIME
 sky.sky_material = sky_mat
 env.sky = sky
 env.background_mode = Environment.BG_SKY
 env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color = Color("b2a7a0")
 env.ambient_light_energy = 0.43
 env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
 env.fog_enabled = true
 env.fog_light_color = Color("ba8970")
 env.fog_density = 0.0018
 environment.environment = env
 add_child(environment)
 sun = DirectionalLight3D.new()
 sun.physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 sun.rotation_degrees = Vector3(-24,-38,0)
 sun.light_color = Color("ffe0b1")
 sun.light_energy = 1.0
 sun.shadow_bias=0.08
 sun.shadow_normal_bias=0.45
 sun.shadow_enabled = quality>0
 sun.directional_shadow_max_distance = 140
 add_child(sun)
 # Three layers of broken ridgelines outside the surveyed playable sector.
 for ring in range(3):make_horizon(ring)
 terrain_material=ShaderMaterial.new()
 terrain_material.shader=load("res://terrain.gdshader")
 sandstone=ShaderMaterial.new()
 sandstone.shader=preload("res://sediment_rock.gdshader")
 sandstone.set_shader_parameter("stone",Color("92705b"))
 volcanic_rock=sandstone.duplicate()
 volcanic_rock.set_shader_parameter("stone",Color("65504a"))
 volcanic_rock.set_shader_parameter("layering",0.46)
 if not self_test:
  var extent:=ceili(Survey.HALF/CHUNK)+3
  for z in range(-extent,extent):
   for x in range(-extent,extent):terrain_tile(Vector2i(x,z))

func make_horizon(ring:int):
 var ridge=SurfaceTool.new()
 ridge.begin(Mesh.PRIMITIVE_TRIANGLES)
 var radius:=640.0+ring*175.0
 var profile:=PackedVector3Array()
 for i in range(257):
  var a:=i%256*TAU/256.0
  var variations:=noise.get_noise_2d(cos(a)*radius+1000,sin(a)*radius+ring*301)
  var massif:=pow(absf(sin(a*(3+ring)+ring*1.2)),2.0)
  var teeth:=absf(sin(a*17+ring))*17.0+absf(sin(a*43))*8.0
  var h:=21.0+massif*(40+ring*28)+variations*(68+ring*26)+teeth
  var r:=radius+64*variations+27.0*sin(a*7.0+ring)
  profile.append(Vector3(cos(a)*r,h,sin(a)*r))
 for i in range(256):
  var a:=profile[i]
  var b:=profile[i+1]
  var strips:=[ridge_slope(a,0.0,ring),ridge_slope(b,0.0,ring)]
  for row in range(1,8):
   var fraction:=row/7.0
   var near:=ridge_slope(a,fraction,ring)
   var next:=ridge_slope(b,fraction,ring)
   for point:Vector3 in [strips[0],near,strips[1],strips[1],near,next]:
    var strata:=0.78+0.15*noise.get_noise_3d(point.x,point.y*8,point.z)+0.10*sin(point.y*0.46)
    ridge.set_color(Color(strata,strata*0.94,strata*0.90))
    ridge.add_vertex(point)
   strips=[near,next]
 ridge.index()
 ridge.generate_normals()
 var ridgemat:=visuals.surface(Color("86594d").lerp(Color("695462"),ring*0.30),0.0,0.97,0.0,true)
 ridgemat.cull_mode=BaseMaterial3D.CULL_DISABLED
 mesh_node(self,ridge.commit(),Vector3.ZERO,ridgemat)

func ridge_slope(crest:Vector3,fraction:float,ring:int) -> Vector3:
 var root:=Vector3(crest.x*0.49,-14.0,crest.z*0.49)
 var point:=root.lerp(crest,fraction)
 point.y=lerpf(root.y,crest.y,pow(fraction,1.22))
 var variation:=detail.get_noise_2d(point.x+ring*83,point.z)
 point.y+=variation*43.0*sin(PI*fraction)
 return point

func base_height(x:float,z:float) -> float:
 var distance_from_pod := Vector2(x,z).length()
 var relief := noise.get_noise_2d(x,z) * 21.0 + detail.get_noise_2d(x,z) * 3.0
 var upland := smoothstep(30.0, 145.0, -x - z * 0.25) * 18.0
 var basin_amount := 1.0 - smoothstep(28.0, BASIN_RADIUS + 15.0, Vector2(x,z).distance_to(BASIN))
 return lerpf((relief + upland) * smoothstep(12.0, 42.0, distance_from_pod), -7.0, basin_amount)

func previous_height(x:float,z:float) -> float:
 var point:=Vector2(x,z)
 var mesa:=Vector2((x+139)*0.85,(z-69)*1.15).length()
 var impact:=point.distance_to(Vector2(127,-104))
 var rim:=maxf(0,1.0-absf(impact-29.0)/15.0)
 var valley:=exp(-pow(absf(x+33.0+sin(z*0.032)*9.0)/13.0,2.0))
 var ridges:=19.0*(1.0-smoothstep(18.0,49.0,mesa))
 ridges+=rim*(11.0+detail.get_noise_2d(x,z)*3.0)-8.5*(1.0-smoothstep(8.0,30.0,impact))
 ridges-=valley*7.0*smoothstep(36.0,85.0,-z)
 return base_height(x,z)+ridges

func height_at(x:float,z:float) -> float:
 return previous_height(x,z)+Survey.relief(x,z)

func region_name(x:float,z:float) -> String:
 return Survey.SITES[Survey.nearest(Vector2(x,z))][0]

func region_at(x:float,z:float) -> int:
 if Vector2(x,z).distance_to(BASIN) < 64.0:
  return 2
 return 1 if x < -65.0 or z < -60.0 else 0

func local_ore(x:float,z:float,random:RandomNumberGenerator) -> int:
 var roll := random.randf()
 var site:int=Survey.nearest(Vector2(x,z))
 var favored:String=Survey.SITES[site][2]
 if not favored.is_empty() and roll>0.61 and Vector2(x,z).distance_to(Survey.SITES[site][1])<44:
  var ore:=ORES.find(favored)
  if ore>=0:return ore
 if region_at(x,z) == 1 and roll > 0.69:
  return 6 if roll < 0.83 else 7 if roll < 0.95 else 8
 if region_at(x,z) == 2 and roll > 0.78:
  return 6 if roll < 0.93 else 8
 return random.randi_range(0,5)

func inside_cave_footprint(x:float,z:float) -> bool:
 for i in Survey.CAVES:
  var p:Vector2=Survey.SITES[i][1]
  if absf(p.x-x)<7.5 and z>p.y-(39.0 if i==31 else 27.0) and z<p.y+5.5:return true
 return false


func terrain_tile(key:Vector2i) -> MeshInstance3D:
 var existing:MeshInstance3D=surface_tiles.get(key)
 if existing:return existing
 const STEPS:=20
 const STRIDE:=STEPS+1
 const PADDED:=STRIDE+2
 var cell:=CHUNK/STEPS
 var origin:=Vector2(key)*CHUNK
 var surface:=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 var heights:=PackedFloat32Array()
 heights.resize(PADDED*PADDED)
 for z in range(PADDED):
  for x in range(PADDED):
   var point:=origin+Vector2(x-1,z-1)*cell
   heights[z*PADDED+x]=height_at(point.x,point.y)
 for z in range(STRIDE):
  for x in range(STRIDE):
   var sample:=(z+1)*PADDED+x+1
   var h:=heights[sample]
   var dx:=heights[sample-1]-heights[sample+1]
   var dz:=heights[sample-PADDED]-heights[sample+PADDED]
   surface.set_normal(Vector3(dx,2.0*cell,dz).normalized())
   surface.add_vertex(Vector3(x*cell,h,z*cell))
 for z in range(STEPS):
  for x in range(STEPS):
   var corner:=z*STRIDE+x
   for index in [corner,corner+1,corner+STRIDE,corner+1,corner+STRIDE+1,corner+STRIDE]:
    surface.add_index(index)
 var terrain:=MeshInstance3D.new()
 terrain.name="Surface_%d_%d"%[key.x,key.y]
 terrain.position=Vector3(origin.x,0,origin.y)
 terrain.mesh=surface.commit()
 terrain.material_override=terrain_material
 terrain.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(terrain)
 surface_tiles[key]=terrain
 return terrain

func make_chunk(key:Vector2i):
 var root:=Node3D.new()
 root.name="Terrain_%s_%s"%[key.x,key.y]
 add_child(root)
 var terrain:=terrain_tile(key)
 # Terrain collision, independent of ore interaction rays.
 var body = StaticBody3D.new()
 body.collision_layer = 1
 var shape = CollisionShape3D.new()
 body.position=terrain.position
 shape.shape = terrain.mesh.create_trimesh_shape()
 body.add_child(shape)
 root.add_child(body)
 var random = RandomNumberGenerator.new()
 random.seed = seed_value+key.x*73856093+key.y*19349663
 for i in range(20):
  var x = key.x*CHUNK+random.randf()*CHUNK
  var z = key.y*CHUNK+random.randf()*CHUNK
  if Vector2(x,z).length()<12 or absf(x)>Survey.HALF-3 or absf(z)>Survey.HALF-3: continue
  var id = "%s:%s:%s" % [key.x,key.y,i]
  var ore = local_ore(x,z,random)
  if inside_cave_footprint(x,z) or Vector2(x,z).distance_to(Vector2(239,164))<7.5:
   random.randf_range(-0.3,0.3)
   continue
  create_deposit(root,id,Vector3(x,height_at(x,z),z),ore,random)
 for i in range(5):
  var x = key.x*CHUNK+random.randf()*CHUNK
  var z = key.y*CHUNK+random.randf()*CHUNK
  if Vector2(x,z).length()<22: continue
  if inside_cave_footprint(x,z) or Vector2(x,z).distance_to(Vector2(239,164))<10.0:continue
  var radius := random.randf_range(1.1,3.8)
  var rock_height := random.randf_range(0.43,1.20)
  var depth := random.randf_range(0.63,1.17)
  var rock_pos:=Vector3(x,height_at(x,z)-0.18,z)
  var highland:=region_at(x,z)==1
  var stone:=volcanic_rock if highland else sandstone
  var seed_id:=int(random.randi())
  var aspect:=0.66+float(seed_id%63)*0.018
  var rock:=visuals.facet(root,rock_pos,Vector3(radius*aspect,radius*rock_height,radius*depth),stone,seed_id,13)
  rock.rotation.y=float(seed_id%360)*PI/180.0
  var obstacle:=solid_scenery(rock)
  obstacle.set_meta("obstacle",radius*maxf(aspect,depth)*0.85)
 chunks[key] = root

func solid_scenery(visual:MeshInstance3D) -> StaticBody3D:
 var body:=StaticBody3D.new()
 body.transform=visual.transform
 body.collision_layer=8
 body.collision_mask=0
 visual.get_parent().add_child(body)
 var hitbox:=CollisionShape3D.new()
 hitbox.shape=visual.mesh.create_convex_shape(true)
 body.add_child(hitbox)
 return body

func create_deposit(parent:Node,id:String,pos:Vector3,ore:int,random:RandomNumberGenerator):
 var angle := random.randf_range(-0.3, 0.3)
 if float(depleted.get(id, 0)) > time: return
 var node = StaticBody3D.new()
 node.collision_layer = 2 | 8
 node.collision_mask = 0
 node.position = pos
 node.set_meta("ore",ore)
 node.set_meta("deposit_id",id)
 parent.add_child(node)
 var visual := visuals.item_model(ORES[ore],absi(id.hash())%3)
 visual.rotation.y = angle + float(absi(id.hash())%628)*0.01
 var extent := 0.83 + float(absi(id.hash())%34)*0.01
 visual.scale=Vector3.ONE*extent
 node.add_child(visual)
 for i in range(visual.mesh.get_surface_count()):
  var mesh_arrays:Array=visual.mesh.surface_get_arrays(i)
  var points:PackedVector3Array=mesh_arrays[Mesh.ARRAY_VERTEX]
  if points.size()<4:continue
  var shape:=ConvexPolygonShape3D.new()
  for j in range(points.size()):points[j]=visual.transform*points[j]
  shape.points=points
  var collider:=CollisionShape3D.new()
  collider.shape=shape
  node.add_child(collider)
 deposits[id] = node

func create_seed_samples():
 var seed_rng:=RandomNumberGenerator.new()
 seed_rng.seed=13381
 for i in range(3):
  var point:Vector2=Data.CRATE_POINTS[i]+Vector2(3.2,-2.1)
  var pos:=Vector3(point.x,height_at(point.x,point.y),point.y)
  if not depleted.has("sample:"+str(i)):create_deposit(self,"sample:"+str(i),pos,9,seed_rng)

func starter_position(index:int) -> Vector3:
 var a := index * 2.39996
 var radius := 6.0 + (index / 6.0) * 2.35
 var pos := Vector3(cos(a)*radius, 0, sin(a)*radius)
 pos.y = height_at(pos.x,pos.z)
 return pos

func seed_starter_ores():
 var random := RandomNumberGenerator.new()
 random.seed = 25
 for i in range(66):
  create_deposit(self, "starter:%s"%i, starter_position(i), i%6, random)
 create_seed_samples()


func update_chunks():
 var center = Vector2i(floor(player.position.x/CHUNK),floor(player.position.z/CHUNK))
 var radius = 2 if quality>0 else 1
 for z in range(center.y-radius,center.y+radius+1):
  for x in range(center.x-radius,center.x+radius+1):
   var key = Vector2i(x,z)
   if not chunks.has(key): make_chunk(key)
 var remove = []
 for key in chunks:
  if abs(key.x-center.x)>radius+1 or abs(key.y-center.y)>radius+1: remove.append(key)
 for key in remove:
  var root = chunks[key]
  for child in root.get_children():
   if child.has_meta("deposit_id"): deposits.erase(child.get_meta("deposit_id"))
  root.queue_free()
  chunks.erase(key)

func setup_player():
 player = CharacterBody3D.new()
 player.collision_layer = 4
 player.collision_mask = 1 | 8
 add_child(player)
 var collider = CollisionShape3D.new()
 var capsule = CapsuleShape3D.new()
 capsule.radius = 0.36
 capsule.height = 1.8
 collider.shape = capsule
 collider.position.y = 0.9
 player.add_child(collider)
 pivot = Node3D.new()
 pivot.position.y = 1.65
 player.add_child(pivot)
 camera = Camera3D.new()
 camera.fov = base_fov
 camera.far = 1800
 pivot.add_child(camera)
 astronaut = Node3D.new()
 player.add_child(astronaut)
 player.position = Vector3(0,0.2,1.2)
 player.floor_max_angle = deg_to_rad(44.0)
 player.floor_snap_length = 0.26
 player.floor_constant_speed = true
 player.safe_margin = 0.025
 player.max_slides = 6
 setup_tool()
 rig.build_pressure_suit(astronaut,visuals)
 rig.add_world_arms(astronaut,visuals)

func make_lander(parent:Node3D):
 var shell:=visuals.textured_finish(visuals.surface(Color("d6d8d6"),0.34,0.48),"metal")
 var trim:=visuals.textured_finish(visuals.surface(Color("293541"),0.51,0.48),"metal")
 var ceramic:=visuals.surface(Color("087cae"),0.39,0.46)
 var green:=visuals.surface(Color("218349"),0.25,0.51)
 var red:=visuals.surface(Color("b82c37"),0.28,0.48)
 var glass:=visuals.textured_finish(visuals.surface(Color("224858"),0.51,0.21),"glass")
 var light_strip:=emissive(Color("8be6eb"))
 # The hatch is in the +Z sector. Its ramp meets the interior floor at the threshold.
 var edge:=SurfaceTool.new()
 edge.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in range(40):
  var bay:=i<3 or i>=37
  var a:=TAU*i/40
  var b:=TAU*(i+1)/40
  for band in [[0.22,0.67,2.36,2.59,green],[0.67,0.72,2.59,2.60,red],[0.72,2.17,2.60,2.62,shell],[2.17,2.23,2.62,2.61,red],[2.23,2.86,2.61,2.19,ceramic],[2.86,3.29,2.19,1.36,shell]]:
   var lo:=float(band[0])
   var hi:=float(band[1])
   if bay and lo<2.23:continue
   var base:=float(band[2])
   var top:=float(band[3])
   var p:=Vector3(sin(a)*base,lo,cos(a)*base)
   var q:=Vector3(sin(b)*base,lo,cos(b)*base)
   var r:=Vector3(sin(a)*top,hi,cos(a)*top)
   var s:=Vector3(sin(b)*top,hi,cos(b)*top)
   # The shell uses vertex colors so all panels can share a continuous mesh.
   edge.set_color(band[4].albedo_color)
   for point:Vector3 in [p,r,q,q,r,s]:
    edge.set_uv(Vector2(atan2(point.x,point.z)/TAU,point.y/3.29))
    edge.add_vertex(point)
  if bay:continue
  var mid:=(a+b)*0.5
  var wall:=Node3D.new()
  wall.position=Vector3(sin(mid)*2.47,0,cos(mid)*2.47)
  wall.rotation.y=mid
  parent.add_child(wall)
  lander_collider(wall,Vector3(0,1.47,0),Vector3(0.43,2.70,0.18))
  if i%7==0:
   visuals.bevel_box(wall,Vector3(0,1.71,0.18),Vector3(0.48,0.72,0.095),0.09,trim)
   visuals.bevel_box(wall,Vector3(0,1.72,0.235),Vector3(0.36,0.58,0.033),0.07,glass)
 edge.index()
 edge.generate_normals()
 var painted:=visuals.textured_finish(visuals.surface(Color.WHITE,0.29,0.55,0,true),"metal")
 painted.cull_mode=BaseMaterial3D.CULL_DISABLED
 mesh_node(parent,edge.commit(),Vector3.ZERO,painted)
 var hatch_rim:=visuals.bevel_box(parent,Vector3(0,2.42,2.31),Vector3(2.43,0.31,0.46),0.12,trim)
 hatch_rim.rotation.x=0.09
 cylinder(parent,Vector3(0,3.32,0),1.39,0.17,trim,1.24)
 cylinder(parent,Vector3(0,3.47,-0.55),0.35,0.22,ceramic)
 cylinder(parent,Vector3(0,3.88,-0.55),0.035,0.88,trim)
 cylinder(parent,Vector3(0,4.32,-0.55),0.17,0.06,light_strip)
 cylinder(parent,Vector3(0,0.11,0),2.54,0.22,trim)
 var floor_body:=StaticBody3D.new()
 floor_body.collision_layer=8|16
 floor_body.collision_mask=0
 parent.add_child(floor_body)
 var floor_shape:=CollisionShape3D.new()
 var plate:=CylinderShape3D.new()
 plate.radius=2.50
 plate.height=0.20
 floor_shape.shape=plate
 floor_shape.position.y=0.10
 floor_body.add_child(floor_shape)
 box(parent,Vector3(0,2.47,2.34),Vector3(1.66,0.055,0.06),light_strip)
 for side in [-1,1]:
  structure_part(parent,Vector3(side*1.04,1.31,2.17),Vector3(0.22,2.25,0.36),trim)
  box(parent,Vector3(side*0.99,1.57,2.25),Vector3(0.062,0.89,0.036),light_strip)
  visuals.bevel_box(parent,Vector3(side*0.93,1.31,2.02),Vector3(0.19,2.1,0.27),0.07,glass)
  for back in [-1,1]:
   var mount:=Vector3(side*2.00,1.28,back*1.26)
   var foot:=Vector3(side*2.93,0.07,back*1.57)
   var strut:MeshInstance3D=cylinder(parent,(mount+foot)*0.5,0.11,mount.distance_to(foot),trim)
   strut.quaternion=Quaternion(Vector3.UP,(mount-foot).normalized())
   cylinder(parent,foot,0.35,0.13,trim,0.23)
 for i in range(4):
  var angle:=TAU*(i+0.5)/4
  cylinder(parent,Vector3(cos(angle)*1.12,0.18,sin(angle)*1.12),0.30,0.33,trim,0.17)
 var ramp:=Node3D.new()
 ramp.position=Vector3(0,0.070,2.91)
 ramp.rotation.x=0.135
 parent.add_child(ramp)
 structure_part(ramp,Vector3.ZERO,Vector3(1.72,0.10,1.62),trim)
 for i in range(7):
  box(ramp,Vector3(0,0.051,i*0.20-0.65),Vector3(1.58,0.008,0.028),ceramic)
 var insignia:=Label3D.new()
 insignia.text="UZBEKISTAN   /   UZ-01"
 insignia.position=Vector3(0,2.56,2.57)
 insignia.pixel_size=0.0045
 insignia.font_size=28
 insignia.outline_size=4
 insignia.layers=1
 parent.add_child(insignia)
 var console:=StaticBody3D.new()
 console.position=Vector3(-1.22,0.20,-1.47)
 console.collision_layer=2|8
 console.collision_mask=0
 console.set_meta("fabricator",true)
 parent.add_child(console)
 box(console,Vector3(0,0.59,0),Vector3(0.87,1.12,0.36),trim)
 box(console,Vector3(0,1.17,0.06),Vector3(0.60,0.11,0.35),light_strip).rotation_degrees.x=18
 var hit:=CollisionShape3D.new()
 var shape:=BoxShape3D.new()
 shape.size=Vector3(0.87,1.23,0.39)
 hit.shape=shape
 hit.position.y=0.61
 console.add_child(hit)

func lander_collider(parent:Node3D,pos:Vector3,extent:Vector3):
 var body:=StaticBody3D.new()
 body.collision_layer=8
 body.collision_mask=0
 parent.add_child(body)
 var hit:=CollisionShape3D.new()
 var shape:=BoxShape3D.new()
 shape.size=extent
 hit.shape=shape
 hit.position=pos
 body.add_child(hit)

func polish_model(root:Node3D,kind:int):
 var metal:Material=visuals.textured_finish(visuals.surface(Color("596974"),0.65,0.49),"metal")
 var ceramic:Material=visuals.surface(Color("b6b6a2"),0.16,0.69)
 if kind==Build.BEACON:
  visuals.tube(root,Vector3(0,0.09,0),0.40,0.18,metal,0.29,16)
  cylinder(root,Vector3(0,0.72,0),0.06,1.22,metal)
  for y in [1.20,1.33,1.46]:cylinder(root,Vector3(0,y,0),0.14,0.07,emissive(Color("72d4e4")))
  cylinder(root,Vector3(0,1.55,0),0.17,0.08,ceramic,0.05)
 elif kind==Build.BENCH:
  visuals.bevel_box(root,Vector3(0,0.67,0),Vector3(1.8,0.15,0.75),0.07,ceramic)
  for x in [-0.65,0.65]:
   visuals.bevel_box(root,Vector3(x,0.32,0),Vector3(0.12,0.64,0.58),0.03,metal)
  for z in [-0.2,0,0.2]:box(root,Vector3(0,0.754,z),Vector3(1.65,0.015,0.014),metal)
 else:
  visuals.tube(root,Vector3(0,0.26,0),0.40,0.50,metal,0.34,20)
  cylinder(root,Vector3(0,0.53,0),0.35,0.09,ceramic)
  cylinder(root,Vector3(0,0.78,0),0.03,0.45,visuals.surface(Color("4c6b48")))
  for i in range(7):
   var a:=i*2.4
   var leaf:MeshInstance3D=visuals.ball(root,Vector3(sin(a)*0.15,0.66+i*0.06,cos(a)*0.15),0.19,Vector3(1,0.20,0.52),visuals.surface(Color("73975e"),0.05,0.86))
   leaf.rotation=Vector3(0.2,a,0.3)

func add_structure(index:int,pos:Vector3,stored:Dictionary={},progress=0.0,angle=0,preview=false) -> StaticBody3D:
 var node = StaticBody3D.new()
 node.position = pos
 node.collision_layer = 2
 node.collision_mask = 0
 node.set_meta("structure",structures.size())
 node.rotation_degrees.y = angle * 90.0
 if not preview:add_child(node)
 var white:=visuals.textured_finish(visuals.surface(Color("adb2ad"),0.27,0.59),"metal")
 var dark:=visuals.textured_finish(visuals.surface(Color("303b41"),0.37,0.52),"metal")
 var orange:=visuals.textured_finish(visuals.surface(Color("aa693d"),0.20,0.56),"metal")
 var blue:=visuals.textured_finish(visuals.surface(Color("253b57"),0.53,0.23),"glass")
 var meter_mat := emissive(Color("77dacd"))
 var name = recipes[index].name
 var collision_size := Vector3(1.5,2.2,1.5)
 match index:
  Build.BEACON,Build.BENCH,Build.PLANTER:
   collision_size=Vector3(0.8,1.4,0.8) if index!=Build.BENCH else Vector3(1.8,0.85,0.8)
   polish_model(node,index)
  Build.POD:
   collision_size=Vector3(5.2,3.25,5.2)
   make_lander(node)
  Build.RETURN_VEHICLE:
   collision_size=Vector3(2.65,5.4,2.65)
   make_return_model(node)
  Build.HABITAT:
   collision_size = Vector3(4,3,4)
   structure_part(node,Vector3(0,0.13,0),Vector3(4.1,0.26,4.1),dark)
   box(node,Vector3(0,2.85,0),Vector3(4.25,0.3,4.25),white)
   box(node,Vector3(0,3.03,0),Vector3(4.28,0.13,4.28),orange)
   for x in [-1.79,1.79]:
    for z in [-1.79,1.79]:box(node,Vector3(x,2.84,z),Vector3(0.43,0.58,0.45),dark)
   for rail in [-1.5,1.5]:box(node,Vector3(rail,3.1,0),Vector3(0.15,0.1,3.7),white)
   box(node,Vector3(0,0.07,2.37),Vector3(1.4,0.13,0.74),dark)
   for side in range(4):
    var wall := Node3D.new()
    wall.name = "Wall%d"%side
    wall.rotation.y = side * TAU/4
    node.add_child(wall)
    for x in [-1.43,1.43]:
     structure_part(wall,Vector3(x,1.48,1.98),Vector3(1.14,2.55,0.22),white)
    box(wall,Vector3(0,2.66,1.98),Vector3(1.72,0.32,0.24),dark)
    if index == Build.HABITAT or side != 0:
     var infill := Node3D.new()
     infill.name = "Infill"
     wall.add_child(infill)
     structure_part(infill,Vector3(0,1.36,1.98),Vector3(1.72,2.23,0.18),blue)
    box(wall,Vector3(0,2.46,1.86),Vector3(1.42,0.045,0.12),emissive(Color("87e4df")))
    for x in [-1.43,1.43]:
     box(wall,Vector3(x,1.82,2.105),Vector3(0.71,0.65,0.035),dark)
     box(wall,Vector3(x,1.82,2.13),Vector3(0.57,0.50,0.026),blue)
   box(node,Vector3(0,2.98,0),Vector3(1.2,0.08,1.2),emissive(Color("82c2c6")))
  Build.DOOR:
   collision_size = Vector3(1.65,2.55,0.37)
   for x in [-0.78,0.78]:
    structure_part(node,Vector3(x,1.38,0),Vector3(0.14,2.5,0.36),orange)
   box(node,Vector3(0,2.61,0),Vector3(1.7,0.2,0.37),white)
   var gate:=Node3D.new()
   gate.name="Gate"
   gate.position=Vector3(0,1.16,0)
   node.add_child(gate)
   box(gate,Vector3.ZERO,Vector3(1.42,2.28,0.14),dark)
   box(gate,Vector3(0,0.83,0.078),Vector3(0.95,0.085,0.032),meter_mat)
  Build.FOUNDATION:
   collision_size = Vector3(4,0.32,4)
   structure_part(node,Vector3(0,0.16,0),collision_size,dark)
   for x in [-1.7,1.7]:box(node,Vector3(x,0.33,0),Vector3(0.07,0.03,3.55),orange)
  Build.SOLAR, Build.SOLAR_2:
   var width := 2.35 if index == Build.SOLAR else 3.2
   collision_size = Vector3(width,2.25,1.6)
   cylinder(node,Vector3(0,0.78,0),0.13,1.56,white)
   var panel := Node3D.new()
   panel.position.y = 1.67
   panel.rotation_degrees.x = -27
   node.add_child(panel)
   box(panel,Vector3.ZERO,Vector3(width,0.13,1.55),white)
   var columns := 9 if index==Build.SOLAR_2 else 6
   for row in range(2):
    for col in range(columns):
     box(panel,Vector3((float(col)-(columns-1)*0.5)*width/columns,0.08,(row-0.5)*0.7),Vector3(width/columns-0.046,0.05,0.65),blue)
   if index==Build.SOLAR_2:
    for x in [-1.05,1.05]:cylinder(node,Vector3(x,0.51,0),0.10,1.02,dark)
  Build.WIND, Build.WIND_2:
   collision_size = Vector3(1.05,4.9,1.05)
   cylinder(node,Vector3(0,0.12,0),0.44,0.24,dark)
   cylinder(node,Vector3(0,0.46,0),0.26,0.62,orange,0.20)
   cylinder(node,Vector3(0,2,0),0.18,4,white,0.08)
   var rotor := Node3D.new()
   rotor.name = "Rotor"
   rotor.position = Vector3(0,4,-0.2)
   node.add_child(rotor)
   sphere(rotor, Vector3.ZERO, 0.22, orange)
   for blade in range(3):
    var arm = box(rotor,Vector3.ZERO,Vector3(0.15,1.55,0.1),white)
    arm.rotation.z = blade*TAU/3
    arm.position = Vector3(sin(-blade*TAU/3)*0.83,cos(blade*TAU/3)*0.83,0)
   if index==Build.WIND_2:
    rotor.scale=Vector3.ONE*1.38
    box(node,Vector3(0,0.44,0.38),Vector3(0.53,0.68,0.49),blue)
  Build.TUBE, Build.TUBE_2, Build.GRASS:
   cylinder(node,Vector3(0,0.18,0),0.74,0.36,dark)
   var glass = material(Color(0.28,0.78,0.70,0.28),0.1,0.18)
   glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
   cylinder(node,Vector3(0,1.2,0),0.61,1.75,glass)
   cylinder(node,Vector3(0,2.12,0),0.69,0.2,white)
   var sprout := Node3D.new()
   sprout.name = "Sprout"
   sprout.visible = index == Build.GRASS
   node.add_child(sprout)
   cylinder(sprout,Vector3(0,0.98,0),0.055,1.3,material(Color("66a46b")))
   if index!=Build.TUBE:
    for side in [-1,1]:
     cylinder(node,Vector3(side*0.74,0.74,0),0.16,1.04,white)
     box(node,Vector3(side*0.72,1.45,0),Vector3(0.23,0.07,0.55),meter_mat)
   if index==Build.GRASS:
    for side in [-1,1]:
     box(node,Vector3(side*0.66,0.72,0.49),Vector3(0.83,0.13,0.20),orange).rotation.y=0.23*side
     box(node,Vector3(side*0.96,0.71,0.67),Vector3(0.21,0.095,0.12),meter_mat)
   for leaf in range(5):
    var a := leaf*2.4
    var lobe = sphere(sprout,Vector3(cos(a)*0.23,0.66+leaf*0.24,sin(a)*0.23),0.23,material(Color("80bb62")))
    lobe.scale = Vector3(1,0.38,1)
   if not preview and index!=Build.GRASS:
    var drops:=Node3D.new()
    drops.name="Condensation"
    node.add_child(drops)
    drops.hide()
    var moisture:=visuals.surface(Color(0.56,0.94,0.88,0.64),0.06,0.23)
    for i in range(7):
     var azimuth:=i*2.4
     visuals.ball(drops,Vector3(sin(azimuth)*0.596,0.47+(i%4)*0.34,cos(azimuth)*0.596),0.025,Vector3(0.75,1.65,0.75),moisture)
  Build.DRILL,Build.DRILL_2:
   box(node,Vector3(0,0.25,0),Vector3(1.45,0.5,1.45),dark)
   for x in [-0.58,0.58]:cylinder(node,Vector3(x,1.26,0),0.08,1.78,white)
   box(node,Vector3(0,2.15,0),Vector3(1.4,0.38,1.25),orange)
   if index==Build.DRILL_2:
    for side in [-1,1]:
     cylinder(node,Vector3(side*0.58,1.28,0.32),0.17,1.45,orange)
     box(node,Vector3(side*0.56,0.28,0.26),Vector3(0.39,0.32,1.21),dark)
   var auger := Node3D.new()
   auger.name = "Rotor"
   node.add_child(auger)
   cylinder(auger,Vector3(0,1.24,0),0.22,1.39,dark)
   for rib in range(7):
    var fin = box(auger,Vector3(0,0.56+rib*0.19,0),Vector3(0.73,0.06,0.28),white)
    fin.rotation.y = rib*0.6
  Build.HEATER,Build.HEATER_2:
   box(node,Vector3(0,1.1,0.28),Vector3(1.43,2.0,0.94),dark)
   var heat_core:=Node3D.new()
   heat_core.name="HeatCore"
   node.add_child(heat_core)
   var glow_material:=emissive(Color("ff6740"))
   for coil in range(9 if index==Build.HEATER_2 else 7):
    var ring := TorusMesh.new()
    ring.inner_radius = 0.32
    ring.outer_radius = 0.47
    mesh_node(heat_core,ring,Vector3(0,0.36+coil*0.198,-0.19),glow_material)
   for x in [-0.65,0.65]:box(node,Vector3(x,1.05,-0.48),Vector3(0.13,2.01,0.24),orange)
   for rib in range(10):box(node,Vector3(0,0.22+rib*0.18,-0.64),Vector3(1.31,0.036,0.061),dark)
   if index==Build.HEATER_2:cylinder(node,Vector3(0.44,2.16,0.29),0.18,0.64,white)
   if not preview:
    var haze_shader:=ShaderMaterial.new()
    haze_shader.shader=preload("res://nur_heat.gdshader")
    var haze_plane:=QuadMesh.new()
    haze_plane.size=Vector2(1.38,0.85)
    var haze=mesh_node(node,haze_plane,Vector3(0,2.54,-0.45),haze_shader)
    haze.name="HeatHaze"
    haze.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    haze.hide()
  Build.STORAGE,Build.RECOVERY:
   collision_size = Vector3(1.5,0.98,1.1)
   box(node,Vector3(0,0.46,0),collision_size,dark)
   var lid:=Node3D.new()
   lid.name="Lid"
   lid.position=Vector3(0,0.92,-0.51)
   node.add_child(lid)
   box(lid,Vector3(0,0.06,0.51),Vector3(1.56,0.14,1.16),orange)
   box(lid,Vector3(0,0.145,0.81),Vector3(0.56,0.085,0.17),white)
   for band_x in [-0.6,0.6]:box(node,Vector3(band_x,0.51,0.58),Vector3(0.102,0.9,0.05),white)
   box(node,Vector3(0,0.6,-0.56),Vector3(0.46,0.08,0.04),emissive(Color("7dcbc6")))
  Build.CRAFT,Build.TERMINAL:
   collision_size = Vector3(1.6,1.5,1.12)
   box(node,Vector3(0,0.57,0),Vector3(1.4,1.14,0.92),dark)
   box(node,Vector3(0,1.16,0),Vector3(1.6,0.23,1.06),white)
   var screen = box(node,Vector3(0,1.38,0),Vector3(0.97,0.12,0.62),emissive(Color("62acbe")))
   screen.rotation_degrees.x = 26
   var readout:=Label3D.new()
   readout.name="Readout"
   readout.text="READY" if index==Build.CRAFT else "GRID"
   readout.font_size=34
   readout.pixel_size=0.004
   readout.modulate=Color("172f3e")
   readout.position=Vector3(0,1.48,0.05)
   readout.rotation_degrees.x=-62
   node.add_child(readout)
  Build.WATER:
   collision_size=Vector3(1.65,2.12,1.53)
   box(node,Vector3(0,0.13,0),Vector3(1.58,0.26,1.42),dark)
   var intake=cylinder(node,Vector3(0,1.78,0),0.32,0.40,orange,0.73)
   intake.rotation.x=0.25
   cylinder(node,Vector3(0,1.44,0),0.24,0.62,white)
   for x in [-0.42,0.42]:
    cylinder(node,Vector3(x,0.82,0),0.32,1.22,white)
    cylinder(node,Vector3(x,1.36,0),0.33,0.10,dark)
    box(node,Vector3(x,0.75,0.307),Vector3(0.105,0.70,0.058),blue)
   var level=box(node,Vector3(-0.42,0.75,0.345),Vector3(0.06,0.66,0.046),meter_mat)
   level.name="WaterLevel"
   cylinder(node,Vector3(0.15,0.79,0.51),0.069,1.18,orange)
  Build.FOOD, Build.ALGAE, Build.TREE, Build.FILTER:
   collision_size=Vector3(1.62,1.70,1.59)
   var tank:=visuals.bevel_box(node,Vector3(0,0.76,0),Vector3(1.53,1.48,1.38),0.17,dark)
   tank.rotation.y=0.02
   var contents:=emissive(Color("83bf86") if index in [Build.ALGAE,Build.TREE,Build.FOOD] else Color("80cbdc"))
   visuals.bevel_box(node,Vector3(0,0.95,0.706),Vector3(1.25,0.68,0.08),0.10,contents)
   for channel in [-1,0,1]:
    var rail:MeshInstance3D=cylinder(node,Vector3(channel*0.37,0.97,0.764),0.032,0.64,white)
    rail.rotation.z=channel*0.10
   for foot in [-1,1]:
    box(node,Vector3(foot*0.63,0.14,0),Vector3(0.18,0.22,1.49),white)
   var panel:MeshInstance3D=box(node,Vector3(0,1.56,0),Vector3(0.93,0.17,0.74),white)
   panel.rotation.x=-0.11
  Build.ORE:
   collision_size=Vector3(1.7,2.45,1.56)
   box(node,Vector3(0,0.24,0),Vector3(1.61,0.49,1.46),dark)
   for x in [-0.62,0.62]:
    box(node,Vector3(x,1.32,0),Vector3(0.19,1.95,0.81),white)
   box(node,Vector3(0,2.26,0),Vector3(1.56,0.32,1.05),orange)
   var lift:=Node3D.new()
   lift.name="Rotor"
   node.add_child(lift)
   cylinder(lift,Vector3(0,1.25,0),0.30,1.62,dark,0.18)
   for i in range(5):box(lift,Vector3(0,0.61+i*0.26,0),Vector3(0.87,0.07,0.33),white).rotation.y=i*0.83
   box(node,Vector3(0.42,0.65,0.44),Vector3(0.76,0.55,0.73),orange)
   box(node,Vector3(0.42,0.74,0.817),Vector3(0.46,0.072,0.023),meter_mat)
 if index not in [Build.POD,Build.HABITAT,Build.DOOR,Build.FOUNDATION,Build.STORAGE,Build.RECOVERY] and index<Build.BEACON:
  # Shared service fittings make machine scale and construction readable.
  for side in [-1,1]:
   for y in [0.23,0.47]:
    var bolt:MeshInstance3D=visuals.tube(node,Vector3(side*0.55,y,0.66),0.022,0.023,dark,-1,6)
    bolt.rotation.x=PI/2
   for vent in range(4):
    visuals.bevel_box(node,Vector3(side*0.39,0.25+vent*0.047,0.685),Vector3(0.18,0.018,0.018),0.006,dark)
 if index not in [Build.POD,Build.HABITAT,Build.DOOR,Build.FOUNDATION,Build.STORAGE,Build.RECOVERY]:
  var signal_lamp=box(node,Vector3(-0.48,0.34,0.64),Vector3(0.13,0.047,0.051),meter_mat)
  signal_lamp.name="StatusLamp"
 if preview:
  return node
 if index in [Build.DRILL,Build.DRILL_2,Build.ORE]:add_drill_dust(node)
 if index != Build.FOUNDATION:
  var shape := CollisionShape3D.new()
  var cube := BoxShape3D.new()
  cube.size = collision_size
  shape.shape = cube
  shape.position.y = collision_size.y/2
  node.add_child(shape)
  if index not in [Build.HABITAT, Build.POD, Build.DOOR]:
   node.collision_layer = 2 | 8
 else:
  node.collision_layer = 2
  var target_shape := CollisionShape3D.new()
  var thin := BoxShape3D.new()
  thin.size = collision_size
  target_shape.shape = thin
  target_shape.position.y = 0.16
  node.add_child(target_shape)


 var signpost = Label3D.new()
 signpost.visibility_range_end=19.0
 signpost.text = name.to_upper()
 signpost.font_size = 28
 signpost.pixel_size = 0.007
 signpost.position.y = collision_size.y+0.7
 signpost.billboard = BaseMaterial3D.BILLBOARD_ENABLED
 signpost.layers=1<<19
 signpost.modulate = Color("cbdedb")
 signpost.no_depth_test = false
 node.add_child(signpost)
 structures.append({"node":node,"type":index,"stored":stored.duplicate(),"progress":progress,"active":true,"online":true,"seeded":false,"total":0.0,"angle":angle})
 return node

func add_drill_dust(machine_node:Node3D):
 var particles:=GPUParticles3D.new()
 particles.name="WorkDust"
 particles.position=Vector3(0,0.33,0)
 particles.amount=14
 particles.emitting=false
 particles.lifetime=0.60
 var spray:=ParticleProcessMaterial.new()
 spray.emission_shape=ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
 spray.emission_sphere_radius=0.35
 spray.direction=Vector3.UP
 spray.spread=86
 spray.initial_velocity_min=0.8
 spray.initial_velocity_max=2.1
 spray.scale_min=0.35
 spray.scale_max=0.90
 spray.gravity=Vector3(0,-3.5,0)
 particles.process_material=spray
 var grit:=SphereMesh.new()
 grit.radius=0.052
 grit.height=0.104
 grit.radial_segments=5
 grit.rings=3
 grit.material=visuals.surface(Color("ab7d63"),0.09,0.91)
 particles.draw_pass_1=grit
 machine_node.add_child(particles)

func style(bg:Color,border:Color,radius=5):
 var s = StyleBoxFlat.new()
 s.bg_color = bg
 s.border_color = border
 s.set_border_width_all(1)
 s.set_corner_radius_all(radius)
 s.shadow_color=Color(0.02,0.13,0.20,0.3)
 s.shadow_size=3
 s.content_margin_left = 18
 s.content_margin_right = 18
 s.content_margin_top = 12
 s.content_margin_bottom = 12
 if radius==0:
  s.content_margin_left=0;s.content_margin_right=0;s.content_margin_top=0;s.content_margin_bottom=0
  s.set_border_width_all(0)
 return s

func label_at(parent:Control,text:String,pos:Vector2,size:int,color=Color("e6eee9")) -> Label:
 var l = Label.new()
 l.mouse_filter = Control.MOUSE_FILTER_IGNORE
 l.text = text
 l.position = pos
 l.add_theme_font_size_override("font_size",size)
 l.add_theme_constant_override("outline_size",3)
 l.add_theme_color_override("font_outline_color",Color(0.02,0.03,0.04,0.8))
 l.add_theme_color_override("font_color",color)
 parent.add_child(l)
 return l

func panel_at(parent:Control,pos:Vector2,size:Vector2) -> Panel:
 var p = Panel.new()
 p.mouse_filter = Control.MOUSE_FILTER_IGNORE
 p.position = pos
 p.size = size
 p.add_theme_stylebox_override("panel",style(Color(0.057,0.092,0.125,0.94),HUD.LINE,5))
 parent.add_child(p)
 return p

func button_at(parent:Control,text:String,pos:Vector2,button_size:Vector2,callback:Callable,primary=false) -> Button:
 var b := Button.new()
 b.text=text
 b.position=pos
 b.size=button_size
 skin_button(b,primary)
 b.pressed.connect(callback)
 parent.add_child(b)
 return b

func skin_button(button:Button,selected:bool):
 button.add_theme_font_size_override("font_size",16)
 button.add_theme_color_override("font_color",HUD.TEXT)
 button.add_theme_color_override("font_hover_color",HUD.TEXT)
 button.add_theme_color_override("font_pressed_color",HUD.TEXT)
 button.add_theme_color_override("font_disabled_color",HUD.GREY)
 button.add_theme_stylebox_override("normal",style(Color("203b4c") if selected else Color("182834"),HUD.ACCENT if selected else HUD.LINE,4))
 button.add_theme_stylebox_override("hover",style(Color("2a4a5c"),HUD.ACCENT,4))
 button.add_theme_stylebox_override("pressed",style(Color("244b5d"),HUD.ACCENT,4))
 button.add_theme_stylebox_override("focus",style(Color.TRANSPARENT,HUD.ACCENT,4))
 button.add_theme_stylebox_override("disabled",style(Color("18242d"),Color("354c5a"),4))

func setup_hud():
 visor_font=SystemFont.new()
 visor_font.font_names=PackedStringArray(["Bahnschrift","Segoe UI"])
 visor_idle=style(Color(0.025,0.065,0.095,0.64),Color(0.40,0.78,0.87,0.64),2)
 visor_active=style(Color(0.04,0.12,0.17,0.82),Color(0.65,0.94,1.0,0.96),2)
 visor_idle.shadow_color=Color(0.05,0.02,0.014,0.5)
 visor_idle.shadow_size=3
 visor_active.shadow_color=Color(0.22,0.72,0.94,0.30)
 visor_active.shadow_size=4
 var layer = CanvasLayer.new()
 add_child(layer)
 hud = Control.new()
 hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
 layer.add_child(hud)
 # Fixed 1600x900 UI is scaled by the project canvas setting.
 var frame:=HUD.VisorFrame.new()
 frame.position=Vector2(25,23)
 frame.size=Vector2(1550,853)
 frame.mouse_filter=Control.MOUSE_FILTER_IGNORE
 frame.add_to_group("fixed_hud")
 hud.add_child(frame)

 var objectives:=Control.new()
 objectives.position=Vector2(42,37)
 objectives.size=Vector2(382,203)
 objectives.mouse_filter=Control.MOUSE_FILTER_IGNORE
 hud.add_child(objectives)
 visor_label(objectives,"First steps",Vector2.ZERO,21)
 var journal:=visor_label(objectives,"J  JOURNAL",Vector2(268,6),12,HUD_SOFT)
 journal.size.x=114
 journal.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 for i in range(5):
  var row:=visor_panel(objectives,Vector2(0,34+i*33),Vector2(382,28))
  var marker:=HUD.ObjectiveMarker.new()
  marker.position=Vector2(9,3)
  marker.size=Vector2(19,22)
  marker.mouse_filter=Control.MOUSE_FILTER_IGNORE
  row.add_child(marker)
  icon_at(row,"",Vector2(36,0),Vector2(34,28))
  visor_label(row,"",Vector2(76,3),16)
  objective_rows.append(row)
 objective_progress=visor_label(objective_rows[0],"",Vector2(309,5),13,HUD_SOFT)
 objective_progress.size.x=61
 objective_progress.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT

 var navigation:=Control.new()
 navigation.position=Vector2(583,32)
 navigation.size=Vector2(434,91)
 navigation.mouse_filter=Control.MOUSE_FILTER_IGNORE
 hud.add_child(navigation)
 compass=HUD.CompassTape.new()
 compass.font=visor_font
 compass.size=Vector2(434,43)
 compass.mouse_filter=Control.MOUSE_FILTER_IGNORE
 navigation.add_child(compass)
 heading_label=visor_label(navigation,"",Vector2(0,45),14)
 heading_label.size.x=434
 heading_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 waypoint_label=visor_label(navigation,"",Vector2(0,67),13,HUD_SOFT)
 waypoint_label.size.x=434
 waypoint_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER

 var index:=Control.new()
 index.position=Vector2(1234,29)
 index.size=Vector2(318,118)
 index.mouse_filter=Control.MOUSE_FILTER_IGNORE
 hud.add_child(index)
 var key:=visor_label(index,"Terraformation Index",Vector2.ZERO,23)
 key.size.x=253
 key.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 index_label=visor_label(index,"0 Ti",Vector2(0,26),28)
 index_label.size.x=253
 index_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 var mark:=HUD.PlanetMark.new()
 mark.position=Vector2(263,5)
 mark.size=Vector2(53,53)
 mark.mouse_filter=Control.MOUSE_FILTER_IGNORE
 index.add_child(mark)
 nav_label=visor_label(index,"",Vector2(0,66),13,HUD_SOFT)
 nav_label.size.x=253
 nav_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 status_label=visor_label(index,"",Vector2(0,86),12,HUD_SOFT)
 status_label.size.x=253
 status_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 weather_label=visor_label(index,"",Vector2(0,106),12,HUD_SOFT)
 weather_label.size.x=253
 weather_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT

 var suit:=Control.new()
 suit.position=Vector2(43,704)
 suit.size=Vector2(292,173)
 suit.mouse_filter=Control.MOUSE_FILTER_IGNORE
 hud.add_child(suit)
 for i in range(3):
  var offset:=Vector2(i*25,i*46)
  var symbol:=HUD.SuitIcon.new()
  symbol.type=i
  symbol.position=offset
  symbol.size=Vector2(37,38)
  symbol.mouse_filter=Control.MOUSE_FILTER_IGNORE
  suit.add_child(symbol)
  var bar:=HUD.Gauge.new()
  bar.position=offset+Vector2(42,12)
  bar.size=Vector2(152,16)
  bar.mouse_filter=Control.MOUSE_FILTER_IGNORE
  suit.add_child(bar)
  vitals.append(bar)
  labels.append(visor_label(suit,"",offset+Vector2(203,10),14))
 position_label=visor_label(suit,"",Vector2(0,145),15,HUD_SOFT)

 notice_label=visor_label(hud,"",Vector2(425,752),16,HUD_WHITE)
 notice_label.size.x=750
 notice_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER

 var hotbar_panel:=Control.new()
 hotbar_panel.position=Vector2(639,804)
 hotbar_panel.size=Vector2(322,75)
 hotbar_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
 hud.add_child(hotbar_panel)
 for i in range(6):
  var slot:=visor_panel(hotbar_panel,Vector2(i*54,0),Vector2(49,45))
  var item_art:=icon_at(slot,"",Vector2(10,3),Vector2(33,34))
  item_art.name="ItemImage"
  var text:=visor_label(slot,"",Vector2(4,1),11)
  hotbar_labels.append(text)
  var count:=visor_label(slot,"",Vector2(1,27),12)
  count.name="Count"
  count.size.x=44
  count.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 var keys:=visor_label(hotbar_panel,"C CRAFT   B BUILD   TAB PACK   Q USE   ESC MENU",Vector2(-104,54),12,HUD_SOFT)
 keys.size.x=530
 keys.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER

 overlay = Control.new()
 overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 layer.add_child(overlay)

func visor_panel(parent:Control,pos:Vector2,extent:Vector2) -> Panel:
 var panel:=panel_at(parent,pos,extent)
 panel.add_theme_stylebox_override("panel",visor_idle)
 return panel

func visor_label(parent:Control,words:String,pos:Vector2,point_size:int,tint:Color=HUD_WHITE) -> Label:
 var label:=label_at(parent,words,pos,point_size,tint)
 label.add_theme_font_override("font",visor_font)
 label.add_theme_constant_override("outline_size",4)
 return label

func clear_overlay():
 for child in overlay.get_children():
  overlay.remove_child(child)
  child.queue_free()

func show_menu(which:String):
 if is_instance_valid(polish) and polish.photo:polish.toggle_photo()
 onboarding.pause_guide()
 clear_overlay()
 action_notice = null
 if which in ["settings","restart"] and menu in ["main","pause"]:
  controls_return=menu
 menu = which
 paused = true
 ui_open_frame=Engine.get_process_frames()
 for action in InputMap.get_actions():
  if Input.is_action_pressed(action):Input.action_release(action)
 mine_progress = 0.0
 mining_target = null
 tool_beam.hide()
 aim_marker.hide()
 pending_action=Callable()
 if is_instance_valid(sfx_mine):sfx_mine.stop()
 if is_instance_valid(sfx_machine):sfx_machine.volume_db=-60
 Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
 overlay.mouse_filter = Control.MOUSE_FILTER_STOP
 var shade = ColorRect.new()
 shade.color = Color(0.01,0.02,0.03,0.59 if which=="craft" else 0.75)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 overlay.add_child(shade)
 hud.visible = false
 match which:
  "main","pause": draw_pause(which=="main")
  "settings": draw_settings()
  "equipment": polish.draw_equipment()
  "archive": polish.draw_archive()
  "credits": polish.draw_credits()
  "inventory": draw_inventory()
  "craft": draw_craft()
  "machine": draw_machine()
  "terraform": draw_terraform()
  "journal": draw_journal()
  "build": draw_build()
  "map": draw_map()
  "return_vehicle": draw_return_vehicle()
  "earth_arrival": draw_earth_arrival()
  "atlas": draw_mars_atlas()
  "nasa_sky": draw_nasa_sky()
  "outpost": draw_outpost()
  "science": draw_science()
  "dead": draw_death()
  "victory": draw_victory()
  "restart": draw_restart()
 if which in ["main","pause","machine","craft","inventory"]:
  action_notice=label_at(overlay,notice_label.text if notice_time>0 else "",Vector2(400,840),18,Color("eed0a9"))
  action_notice.size.x=800
  action_notice.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER

func resume():
 if dead:
  show_menu("dead")
  return
 clear_overlay()
 menu = ""
 paused = false
 hud.visible = true
 overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
 Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
 if not render_test and not self_test:
  onboarding.resume_guide()
  onboarding.guide_objective(quest_step)

func enter_expedition():
 if intro_seen or dead or render_test:
  resume()
 else:
  begin_intro()

func make_intro_cast():
 cinematic_pod=Node3D.new()
 cinematic_pod.physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 add_child(cinematic_pod)
 make_lander(cinematic_pod)
 for child in cinematic_pod.find_children("*","CollisionObject3D",true,false):
  child.collision_layer=0
 var exhaust:=Node3D.new()
 exhaust.name="Exhaust"
 cinematic_pod.add_child(exhaust)
 for point in [Vector2(-1.1,-1.1),Vector2(-1.1,1.1),Vector2(1.1,-1.1),Vector2(1.1,1.1)]:
  cylinder(exhaust,Vector3(point.x,-0.64,point.y),0.015,1.48,emissive(Color("ee7045")),0.22)
  cylinder(exhaust,Vector3(point.x,-0.38,point.y),0.025,0.95,emissive(Color("ffcf85")),0.13)
 cinematic_pod.hide()
 cinematic_astronaut=Node3D.new()
 cinematic_astronaut.physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 add_child(cinematic_astronaut)
 rig.build_pressure_suit(cinematic_astronaut,visuals)
 for side in [-1,1]:
  var leg:=Node3D.new()
  leg.name="Leg%d"%side
  leg.position=Vector3(side*0.15,0.92,0)
  cinematic_astronaut.add_child(leg)
  for piece in rig.legs[(side+1)/2].get_children():
   leg.add_child(piece.duplicate())
  var arm:=Node3D.new()
  arm.name="Arm%d"%side
  arm.position=Vector3(side*0.30,1.41,0)
  cinematic_astronaut.add_child(arm)
  for piece in rig.world_arms[(side+1)/2].get_children():
   arm.add_child(piece.duplicate())
 var ore:=visuals.item_model("Cobalt")
 ore.name="Sample"
 ore.position=Vector3(-0.08,-0.27,-0.38)
 ore.scale=Vector3.ONE*0.26
 ore.hide()
 cinematic_astronaut.get_node("Arm-1").add_child(ore)
 cinematic_astronaut.hide()
 cinematic_array=add_structure(Build.SOLAR,Vector3(-3.4,0,9.6),{},0.0,0,true)
 cinematic_turbine=add_structure(Build.WIND,Vector3(-7.1,0,5.1),{},0.0,0,true)
 cinematic_turbine.physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 add_child(cinematic_array)
 add_child(cinematic_turbine)

func update_intro_scene(shot:int,fraction:float):
 if not is_instance_valid(cinematic_pod):make_intro_cast()
 var landing:=Vector3(0,0,0)
 var descent:=smoothstep(0.0,0.45,fraction)
 cinematic_pod.show()
 cinematic_pod.position=landing+Vector3(-7,37,-6)*(1.0-descent)
 cinematic_pod.rotation_degrees=Vector3(0,0,-12.0*(1.0-descent))
 if shot>0:
  cinematic_pod.position=landing
  cinematic_pod.rotation=Vector3.ZERO
 cinematic_pod.get_node("Exhaust").visible=shot==0 and descent<0.995
 landing_dust.emitting=shot==0 and fraction>0.32 and fraction<0.63
 cinematic_astronaut.visible=shot==1 or shot==2
 cinematic_array.visible=shot>=2
 cinematic_turbine.visible=shot>=2
 if cinematic_turbine.visible:
  cinematic_turbine.get_node("Rotor").rotation.z=fraction*29.0
 if cinematic_astronaut.visible:
  var pace:=smoothstep(0.02,0.68,fraction)
  var trail:=Vector3(0,0,1.6).lerp(Vector3(4,0,10),pace) if shot==1 else Vector3(4,0,10).lerp(Vector3(-5,0,7),pace)
  trail.y=height_at(trail.x,trail.z)+0.16*(1.0-smoothstep(2.1,3.8,trail.z))
  cinematic_astronaut.position=trail
  cinematic_astronaut.rotation.y=PI+0.43 if shot==1 else 1.7
  var pickup:=smoothstep(0.69,0.77,fraction)*(1.0-smoothstep(0.85,0.95,fraction)) if shot==1 else 0.0
  cinematic_astronaut.rotation.x=0.35*pickup
  cinematic_astronaut.get_node("Arm-1/Sample").visible=shot==1 and fraction>0.81
  for side in [-1,1]:
   var swing:float=sin(pace*TAU*6.0)*0.69*side if fraction<0.70 else 0.0
   cinematic_astronaut.get_node("Leg%d"%side).rotation.x=swing
   var arm:Node3D=cinematic_astronaut.get_node("Arm%d"%side)
   arm.rotation.x=-swing*0.85-(1.42*pickup if side==-1 else 0.0)
   if side==-1 and shot==1 and fraction>0.85:arm.rotation.x=-0.9
 var scene_clock:float=164.0 if shot==3 else 125.0 if shot==4 else 3.0+shot*7.0
 if onboarding.reduced_motion:scene_clock=164.0 if shot==3 else 32.0
 var preview:float=0.0
 if shot==4:
  var milestones:=[0.0,430.0,1190.0,2130.0,3500.0]
  var chapter:=mini(int(fraction*5.0),4)
  preview=milestones[chapter]
  scene_clock=125.0 if chapter==2 else 27.0
  if fraction>0.94:scene_clock=266.0
 apply_stage(scene_clock,preview)
 dust.position=onboarding.camera.position+Vector3.DOWN*1.5

func begin_intro(return_menu:String=""):
 intro_return=return_menu
 paused=true
 menu="intro"
 clear_overlay()
 hud.hide()
 rig.mount.hide()
 rig.chest.hide()
 Input.mouse_mode=Input.MOUSE_MODE_HIDDEN if capture_intro else Input.MOUSE_MODE_CAPTURED
 # Replays always visit the landing site, even from a distant save.
 for z in range(-2,5):
  for x in range(-2,5):
   var key:=Vector2i(x,z)
   if not chunks.has(key):make_chunk(key)
 for unit in structures:
  if unit.type==Build.POD:unit.node.hide()
 onboarding.play_intro(reduced_motion)

func end_intro():
 if is_instance_valid(cinematic_pod):cinematic_pod.hide()
 if is_instance_valid(cinematic_astronaut):cinematic_astronaut.hide()
 if is_instance_valid(cinematic_array):cinematic_array.hide()
 if is_instance_valid(cinematic_turbine):cinematic_turbine.hide()
 landing_dust.emitting=false
 for unit in structures:
  if unit.type==Build.POD:unit.node.show()
 apply_stage()
 if capture_intro:
  set_process(false)
  get_tree().quit()
  return
 camera.make_current()
 rig.mount.visible=not third_person
 rig.chest.show()
 if not intro_seen:
  intro_seen=true
  save_game()
 if intro_return.is_empty():
  resume()
 else:
  show_menu(intro_return)

func draw_pause(main:bool):
 var backdrop:=ColorRect.new()
 backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 backdrop.material=ShaderMaterial.new()
 backdrop.material.shader=preload("res://menu_backdrop.gdshader")
 backdrop.mouse_filter=Control.MOUSE_FILTER_IGNORE
 overlay.add_child(backdrop)
 var emblem:=TextureRect.new()
 emblem.texture=logo
 emblem.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 emblem.position=Vector2(148,92)
 emblem.size=Vector2(493,493)
 emblem.name="ExpeditionEmblem"
 emblem.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 emblem.mouse_filter=Control.MOUSE_FILTER_IGNORE
 overlay.add_child(emblem)
 emblem.show()
 label_at(overlay,"UZBEKISTAN  /  MARS SURFACE EXPEDITION",Vector2(153,604),19,Color("efc49e"))
 label_at(overlay,"Build an outpost and keep your crew alive.",Vector2(153,640),22)
 var p = panel_at(overlay,Vector2(1000,170),Vector2(450,570))
 label_at(p,"EXPEDITION CONTROL",Vector2(32,30),22,Color("e3b784"))
 button_at(p,("Continue expedition" if intro_seen else "Start expedition") if main else "Resume expedition",Vector2(32,100),Vector2(386,56),enter_expedition if main else resume,true)
 button_at(p,"New expedition" if main else "Restart expedition",Vector2(32,174),Vector2(386,50),func():show_menu("restart"))
 button_at(p,"Settings",Vector2(32,242),Vector2(386,50),func():show_menu("settings"))
 button_at(p,"Save expedition",Vector2(32,310),Vector2(386,50),func():if save_game():notify("Expedition saved."))
 button_at(p,"Save and exit",Vector2(32,378),Vector2(386,50),func():save_game();get_tree().quit())
 button_at(p,"Replay mission intro",Vector2(32,446),Vector2(386,50),begin_intro.bind("main" if main else "pause"))
 button_at(p,"Mars science and data",Vector2(32,514),Vector2(386,40),func():controls_return=menu;show_menu("science"))
 button_at(overlay,"Credits & licenses",Vector2(153,725),Vector2(310,40),func():show_menu("credits"))
 label_at(overlay,"WASD move  ·  E interact  ·  C craft  ·  B build  ·  J objectives",Vector2(136,795),13,Color("99a8ab"))

func draw_restart():
 var p = panel_at(overlay,Vector2(490,270),Vector2(620,340))
 label_at(p,"RESTART EXPEDITION?",Vector2(30,30),28)
 label_at(p,"Your current save is kept as a backup before restarting.",Vector2(30,95),16)
 button_at(p,"Start a new expedition",Vector2(30,160),Vector2(560,50),new_game,true)
 button_at(p,"Go back",Vector2(30,228),Vector2(560,50),func():show_menu(controls_return))

func draw_settings():
 var p:=panel_at(overlay,Vector2(180,60),Vector2(1240,780))
 label_at(p,"SUIT & DISPLAY SETTINGS",Vector2(30,24),28)
 label_at(p,"CAMERA & ACCESSIBILITY",Vector2(30,75),14,HUD.ACCENT)
 button_at(p,"View: "+("Third person" if third_person else "First person"),Vector2(30,108),Vector2(330,42),func():third_person=not third_person;save_settings();show_menu("settings"))
 button_at(p,"Invert Y: "+("On" if invert_y else "Off"),Vector2(379,108),Vector2(331,42),func():invert_y=not invert_y;save_settings();show_menu("settings"))
 button_at(p,"Reduced motion: "+("On" if reduced_motion else "Off"),Vector2(30,162),Vector2(330,42),func():reduced_motion=not reduced_motion;save_settings();show_menu("settings"))
 button_at(p,"Difficulty: "+("Relaxed" if relaxed else "Challenge" if challenge else "Standard"),Vector2(379,162),Vector2(331,42),func():
  if relaxed:relaxed=false;challenge=false
  elif challenge:challenge=false;relaxed=true
  else:challenge=true
  save_settings()
  show_menu("settings"))
 setup_setting_slider(p,"Field of view  /  %d degrees"%base_fov,225,base_fov,60,100,1,func(v):base_fov=v;save_settings())
 setup_setting_slider(p,"Mouse sensitivity",315,sensitivity,0.0007,0.005,0.0001,func(v):sensitivity=v;save_settings())
 setup_setting_slider(p,"HUD size",405,hud_scale,0.78,1.12,0.02,func(v):hud_scale=v;apply_hud_scale();save_settings())
 setup_setting_slider(p,"Master volume",495,volume,0.0,1.0,0.02,func(v):volume=v;apply_volume();save_settings())
 button_at(p,"Music: "+("On" if music_level>0.0 else "Off"),Vector2(30,585),Vector2(330,42),func():music_level=0.0 if music_level>0.0 else 0.72;save_settings();show_menu("settings"))
 button_at(p,"Mission voice: "+("On" if radio_enabled else "Off"),Vector2(379,585),Vector2(331,42),func():radio_enabled=not radio_enabled;onboarding.set_enabled(radio_enabled);save_settings();show_menu("settings"))
 var info:=panel_at(p,Vector2(750,75),Vector2(455,590))
 label_at(info,"FIELD CONTROLS",Vector2(22,22),20,HUD.ACCENT)
 var keys:=["WASD  /  Move    Mouse  /  Look", "Shift  /  Sprint    Space  /  Jump", "Hold left mouse  /  Mine", "E  /  Interact    F  /  Lamp", "Tab  /  Inventory    C  /  Craft", "B  /  Build    R  /  Rotate preview", "Right mouse  /  Cancel placement", "1–6  /  Select    Q  /  Use supply", "M  /  Planner    J  /  Objectives", "P  /  Outpost    H  /  Telemetry", "Esc  /  Pause    F5  /  Save"]
 for i in range(keys.size()):label_at(info,keys[i],Vector2(22,65+i*35),16,HUD.TEXT)
 button_at(info,"Graphics: "+["Low","Medium","High"][quality],Vector2(22,484),Vector2(410,44),func():
  quality=(quality+1)%3
  polish.apply_quality()
  dust.amount=[40,130,230][quality]
  save_settings()
  show_menu("settings"))
 label_at(info,"Fullscreen  /  Settings save automatically",Vector2(22,550),13,HUD.SECONDARY)
 setup_setting_slider(p,"Sound effects",635,sfx_level,0.0,1.0,0.02,func(v):sfx_level=v;save_settings())
 button_at(p,"Return",Vector2(750,696),Vector2(455,48),func():show_menu(controls_return),true)

func setup_setting_slider(parent:Control,title:String,y:int,value:float,minimum:float,maximum:float,step:float,change:Callable):
 label_at(parent,title,Vector2(30,y),16,HUD.TEXT)
 var slider:=HSlider.new()
 slider.position=Vector2(30,y+29)
 slider.size=Vector2(680,30)
 slider.min_value=minimum
 slider.max_value=maximum
 slider.step=step
 slider.value=value
 slider.value_changed.connect(change)
 parent.add_child(slider)

func max_cargo() -> int:
 return 24 if equipment.Backpack else 16

func max_oxygen() -> float:
 if equipment["T3 Oxygen tank"]:return 200.0
 return 145.0 if equipment["Oxygen tank"] else 100.0

func cost_text(cost:Dictionary) -> String:
 var parts: Array[String] = []
 for item in cost:
  parts.append("%s %s"%[int(cost[item]),item])
 return "  ·  ".join(parts)

func afford(cost:Dictionary) -> bool:
 for item in cost:
  if int(inventory.get(item,0)) < int(cost[item]):return false
 return true

func pay(cost:Dictionary) -> bool:
 return Data.transaction(inventory,cost,{},max_cargo())

func item_color(item:String) -> Color:
 var index := ORES.find(item)
 return COLORS[index] if index>=0 else Color("8fd6e2")

func available_stacks(items:Dictionary) -> Array:
 var result: Array = []
 for item in items:
  var left := int(items[item])
  while left>0:
   var count := mini(left,Data.stack_limit(item))
   result.append({"name":item,"count":count})
   left -= count
 return result

func stack_grid() -> Array:
 var remaining:=inventory.duplicate()
 var result: Array = []
 result.resize(max_cargo())
 for slot in range(mini(preferred_slots.size(),result.size())):
  var entry:Variant=preferred_slots[slot]
  var item:String=entry if entry is String else str(entry.get("name","")) if entry is Dictionary else ""
  var count:int=mini(int(remaining.get(item,0)),Data.stack_limit(item))
  if entry is Dictionary:count=mini(count,maxi(0,int(entry.get("count",0))))
  if count>0:
   result[slot]={"name":item,"count":count}
   remaining[item]-=count
 var entries:=available_stacks(remaining)
 # New pickups may need space occupied by split stacks. Compact without loss.
 if entries.size()>result.count(null):
  result.fill(null)
  entries=available_stacks(inventory)
 for slot in range(result.size()):
  if result[slot]==null and not entries.is_empty():
   result[slot]=entries.pop_front()
 return result

func split_stack(slot:int) -> bool:
 var stacks:=stack_grid()
 if slot<0 or slot>=stacks.size() or stacks[slot]==null or stacks[slot].count<2:return false
 var empty:=stacks.find(null)
 if empty<0:return false
 var half:int=int(stacks[slot].count)/2
 stacks[empty]={"name":stacks[slot].name,"count":half}
 stacks[slot].count-=half
 preferred_slots=stacks.duplicate(true)
 mark_save()
 return true

func inventory_click(slot:int):
 var stacks:=stack_grid()
 if stack_selected>=0 and stack_selected!=slot and stacks[stack_selected]!=null and (stacks[slot]==null or stacks[slot].name==stacks[stack_selected].name):
  move_inventory_stack(stack_selected,slot)
  return
 stack_selected=slot if stacks[slot]!=null else -1
 show_menu("inventory")

func use_item(item:String) -> bool:
 if item not in Data.CONSUMABLES:
  notify("Select a consumable in inventory or on the hotbar.")
  return false
 if not pay({item:1}):
  notify("No "+item.to_lower()+" in your backpack.")
  return false
 match item:
  "Oxygen capsule":oxygen=minf(max_oxygen(),oxygen+60)
  "Water bottle":water=minf(100,water+50)
  "Purified Water":water=minf(100,water+80)
  "Food pack":
   food=minf(100,food+50)
   health=minf(100,health+50)
 notify(item+" used.")
 play_sound("res://collect.wav")
 mark_save()
 return true

func craft_recipe(index:int,quantity:int=1) -> bool:
 if quantity not in [1,5]:return false
 var recipe: Dictionary = Data.CRAFTS[index]
 if recipe.has("gear") and quantity!=1:return false
 var cost:Dictionary=recipe.cost.duplicate()
 for item in cost:cost[item]*=quantity
 if terraform_index()<float(recipe.get("at",0)):
  notify("Blueprint is not unlocked.")
  return false
 if recipe.has("gear"):
  if equipment[recipe.gear] or quest_events.get("stowed:"+str(recipe.gear),false):
   notify("This upgrade is already installed.")
   return false
  if not pay(recipe.cost):
   notify("Missing ingredients.")
   return false
  equipment[recipe.gear]=1
 else:
  if not afford(cost):
   notify("Missing ingredients.")
   return false
  if not Data.transaction(inventory,cost,{recipe.name:quantity},max_cargo()):
   notify("Make room for the crafted item.")
   return false
 quest_events[recipe.name]=true
 notify(recipe.name+(" installed." if recipe.has("gear") else " ×%d added to backpack."%quantity))
 play_sound("res://build.wav")
 mark_save()
 return true

func item_description(item:String) -> String:
 if visuals.resources.has(item):return visuals.resources[item].description
 for recipe in Data.CRAFTS:
  if recipe.name==item:return recipe.desc
 return ""

func inventory_indices(stacks:Array) -> Array[int]:
 var result:Array[int]=[]
 for i in range(stacks.size()):
  var entry:Variant=stacks[i]
  if inventory_filter=="All" or (entry!=null and visuals.resources.has(entry.name)==(inventory_filter=="Materials")):
   result.append(i)
 return result

class StackButton extends Button:
 var slot:int
 var owner_menu:Node
 func _get_drag_data(_position:Vector2) -> Variant:
  var stacks:Array=owner_menu.stack_grid()
  if stacks[slot]==null:return null
  var preview:=TextureRect.new()
  preview.texture=owner_menu.icon_texture(stacks[slot].name)
  preview.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
  preview.custom_minimum_size=Vector2(72,72)
  preview.size=preview.custom_minimum_size
  set_drag_preview(preview)
  return slot
 func _can_drop_data(_position:Vector2,data:Variant) -> bool:return data is int
 func _drop_data(_position:Vector2,data:Variant):owner_menu.move_inventory_stack(int(data),slot)

func move_inventory_stack(from:int,to:int):
 var stacks:=stack_grid()
 if from==to or from<0 or to<0 or from>=stacks.size() or to>=stacks.size() or stacks[from]==null:return
 var picked=stacks[from]
 if stacks[to]!=null and stacks[to].name==picked.name:
  var moved:=mini(int(picked.count),Data.stack_limit(picked.name)-int(stacks[to].count))
  stacks[to].count+=moved
  picked.count-=moved
  if picked.count==0:stacks[from]=null
 else:
  stacks[from]=stacks[to]
  stacks[to]=picked
 preferred_slots=stacks.duplicate(true)
 stack_selected=to
 mark_save()
 show_menu("inventory")

func drop_stack(item:String,count:int):
 if not pay({item:count}):return
 var point:=Vector3(player.position.x+sin(yaw)*-1.6,0,player.position.z-cos(yaw)*1.6)
 point.y=height_at(point.x,point.z)
 add_structure(Build.RECOVERY,point,{item:count})
 refresh_grid()
 notify("Dropped into a recovery crate.",item)
 mark_save()
 show_menu("inventory")

func draw_inventory():
 var stacks:=stack_grid()
 var p:=panel_at(overlay,Vector2(105,77),Vector2(1390,746))
 label_at(p,"BACKPACK",Vector2(30,21),31)
 label_at(p,"%s / %s SLOTS"%[stacks.size()-stacks.count(null),max_cargo()],Vector2(31,64),15,HUD.ACCENT)
 var filters:=["All","Materials","Supplies"]
 for i in range(filters.size()):
  button_at(p,filters[i],Vector2(30+i*162,103),Vector2(150,40),func():inventory_filter=filters[i];show_menu("inventory"),inventory_filter==filters[i])
 var indices:=inventory_indices(stacks)
 for i in range(indices.size()):
  var slot:=indices[i]
  var item:Variant=stacks[slot]
  var pos:=Vector2(30+(i%6)*131,161+(i/6)*106)
  var tile:=StackButton.new()
  tile.owner_menu=self
  tile.slot=slot
  tile.position=pos
  tile.size=Vector2(119,98)
  skin_button(tile,slot==stack_selected)
  tile.pressed.connect(inventory_click.bind(slot))
  p.add_child(tile)
  if item!=null:
   tile.tooltip_text=item_description(item.name)
   icon_at(tile,item.name,Vector2(22,0),Vector2(75,69))
   label_at(tile,item.name,Vector2(6,68),12,HUD.TEXT)
   label_at(tile,"×%s"%item.count,Vector2(84,8),12,HUD.ACCENT)
  else:
   label_at(tile,"%02d"%(slot+1),Vector2(9,7),11,HUD.GREY)
 var selected:Variant=stacks[stack_selected] if stack_selected>=0 and stack_selected<stacks.size() else null
 var info:=panel_at(p,Vector2(840,108),Vector2(515,341))
 if selected!=null:
  var name:String=selected.name
  icon_at(info,name,Vector2(12,13),Vector2(138,137))
  label_at(info,name,Vector2(155,26),24,HUD.TEXT)
  label_at(info,visuals.resources[name].rarity.to_upper() if visuals.resources.has(name) else "CONSUMABLE" if name in Data.CONSUMABLES else "COMPONENT",Vector2(156,60),12,HUD.ACCENT)
  var description:=label_at(info,item_description(name),Vector2(155,86),15,HUD.SECONDARY)
  description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
  description.clip_text=true
  description.set_deferred("size",Vector2(333,58))
  var usable:bool=name in Data.CONSUMABLES
  if usable:
   button_at(info,"Use one",Vector2(17,190),Vector2(225,42),func():use_item(name);show_menu("inventory"),true)
   label_at(info,"ASSIGN TO HOTBAR",Vector2(19,254),13,HUD.SECONDARY)
   for slot in range(6):
    button_at(info,str(slot+1),Vector2(18+slot*78,279),Vector2(67,39),func():hotbar[slot]=name;mark_save();show_menu("inventory"),hotbar[slot]==name)
  if selected.count>1:
   button_at(info,"Split stack",Vector2(260,145),Vector2(233,34),func():
    if not split_stack(stack_selected):notify("A free slot is required to split this stack.")
    show_menu("inventory"))
  button_at(info,"Drop stack",Vector2(260,190),Vector2(233,42),drop_stack.bind(name,selected.count))
 else:
  label_at(info,"Select an item to inspect it.",Vector2(22,25),20,HUD.SECONDARY)
 button_at(p,"Manage suit equipment",Vector2(842,459),Vector2(510,36),func():show_menu("equipment"))
 var gear:=[
  ["T3 Oxygen tank" if equipment["T3 Oxygen tank"] else "T1 Oxygen tank",maxi(equipment["Oxygen tank"],equipment["T3 Oxygen tank"])],
  ["T2 Backpack",equipment.Backpack],["Multi-tool",true],["Torch",true],["Agility boots" if equipment["Agility boots"] else "Suit boots",true],
  ["Helmet",true],["Mining upgrade",equipment["Mining upgrade"]],["Jetpack",equipment.Jetpack],["Air filter",equipment["Air filter"]]
 ]
 for i in range(gear.size()):
  var tile:=panel_at(p,Vector2(841+(i%7)*73,506+(i/7)*79),Vector2(67,74))
  var art:=icon_at(tile,gear[i][0],Vector2(3,2),Vector2(61,62))
  art.tooltip_text=gear[i][0]
  art.mouse_filter=Control.MOUSE_FILTER_STOP
  if not gear[i][1]:art.modulate=Color(0.56,0.63,0.68,0.55)
 label_at(p,"Drag to move or merge. Split from item details. Select supplies to use.",Vector2(30,611),14,HUD.SECONDARY)
 button_at(p,"Craft [C]",Vector2(30,675),Vector2(220,44),func():show_menu("craft"))
 button_at(p,"Return [Tab]",Vector2(1115,675),Vector2(240,44),resume,true)

func requirements(parent:Control,cost:Dictionary,pos:Vector2,width:float,compact:bool=false):
 var i:=0
 for id in cost:
  var own:=int(inventory.get(id,0))
  var count:=int(cost[id])
  var adequate:=own>=count
  var y:=pos.y+i*(38 if compact else 46)
  var row:=panel_at(parent,Vector2(pos.x,y),Vector2(width,34 if compact else 41))
  icon_at(row,id,Vector2(5,0),Vector2(41,34 if compact else 41))
  label_at(row,id,Vector2(50,6),15,HUD.TEXT)
  var tally:=label_at(row,"%s    %d/%d"%["✓" if adequate else "!",own,count],Vector2(width-109,6),15,HUD.GOOD if adequate else HUD.ALERT)
  tally.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
  tally.size.x=90
  i+=1

func craft_lock(recipe:Dictionary,quantity:int=1) -> String:
 if terraform_index()<float(recipe.get("at",0)):return "Unlocks at %d Ti"%int(recipe.at)
 if recipe.has("gear") and (equipment[recipe.gear] or quest_events.get("stowed:"+str(recipe.gear),false)):return "Already owned"
 var cost:Dictionary=recipe.cost.duplicate()
 for item in cost:cost[item]*=quantity
 if not afford(cost):return "Missing ingredients"
 if not recipe.has("gear") and not Data.transaction(inventory.duplicate(),cost,{recipe.name:quantity},max_cargo()):return "Backpack full"
 return ""

func draw_craft():
 var p:=panel_at(overlay,Vector2(125,105),Vector2(1350,685))
 label_at(p,"FABRICATOR",Vector2(32,23),34)
 for tab in range(3):
  button_at(p,["SUPPLIES","EQUIPMENT","COMPONENTS"][tab],Vector2(32+tab*222,93),Vector2(205,45),select_craft_group.bind(tab),craft_group==tab)
 var row:=0
 for i in range(Data.CRAFTS.size()):
  var recipe:Dictionary=Data.CRAFTS[i]
  if recipe.group!=craft_group:continue
  var tile:=button_at(p,"",Vector2(32+(row%3)*259,166+(row/3)*139),Vector2(238,129),func():craft_selected=i;show_menu("craft"),i==craft_selected)
  row+=1
  tile.tooltip_text=recipe.desc
  icon_at(tile,recipe.name,Vector2(8,7),Vector2(100,111))
  label_at(tile,recipe.name,Vector2(107,37),15,HUD.TEXT)
  var locked:=craft_lock(recipe)
  label_at(tile,"READY" if locked.is_empty() else locked.to_upper(),Vector2(107,65),10,HUD.GOOD if locked.is_empty() else HUD.ALERT)
 var detail:=panel_at(p,Vector2(832,88),Vector2(483,494))
 var selected:Dictionary=Data.CRAFTS[craft_selected]
 label_at(detail,selected.name,Vector2(21,20),25)
 icon_at(detail,selected.name,Vector2(327,36),Vector2(132,120))
 var description:=label_at(detail,selected.desc,Vector2(22,62),16,HUD.SECONDARY)
 description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 description.clip_text=true
 description.set_deferred("size",Vector2(280,108))
 var quantity:int=1 if selected.has("gear") else craft_quantity
 var batch_cost:Dictionary=selected.cost.duplicate()
 for item in batch_cost:batch_cost[item]*=quantity
 requirements(detail,batch_cost,Vector2(21,177),440)
 var lock:=craft_lock(selected,quantity)
 if not lock.is_empty():label_at(detail,lock,Vector2(22,342),16,HUD.ALERT)
 if not selected.has("gear"):
  for count in [1,5]:
   button_at(detail,"Batch ×%d"%count,Vector2(22 if count==1 else 245,367),Vector2(215,34),func():craft_quantity=count;show_menu("craft"),craft_quantity==count)
 var action:=button_at(detail,"Craft ×%d"%quantity if lock.is_empty() else lock,Vector2(22,409),Vector2(438,54),func():craft_recipe(craft_selected,quantity);show_menu("craft"),true)
 action.disabled=not lock.is_empty()
 button_at(p,"Backpack [Tab]",Vector2(33,609),Vector2(220,43),func():show_menu("inventory"))
 button_at(p,"Return [C]",Vector2(1057,609),Vector2(258,43),resume)

func select_craft_group(group:int):
 craft_group=group
 for i in range(Data.CRAFTS.size()):
  if Data.CRAFTS[i].group==group:
   craft_selected=i
   break
 show_menu("craft")

func build_lock(index:int) -> String:
 if terraform_index()<float(recipes[index].at):return "Unlocks at %d Ti"%int(recipes[index].at)
 if not afford(recipes[index].cost):return "Missing materials"
 return ""

func output_text(spec:Dictionary) -> String:
 if spec.has("metric"):
  return "%s +%.2f/s%s"%[spec.metric,spec.rate,"  ·  Oxygen +0.40/s" if spec.name=="Grass spreader" else ""]
 if spec.power>0:return "Grid supply +%.2f kW"%spec.power
 if spec.name=="Water collector":return "Water bottle every 45 s"
 if spec.name=="Ore extractor":return "One ore every 40 s"
 if spec.has("makes"):return "%s every %d s"%[spec.makes,int(spec.interval)]
 return "No continuous output"

func pin_recipe(index:int):
 pinned_recipe=-1 if pinned_recipe==index else index
 mark_save()
 update_pinned()
 if menu=="build":show_menu("build")

func choose_blueprint(index:int):
 clear_ghost()
 selected_build=index
 build_rotation=0
 resume()
 notify("Aim at level ground. R rotates and right-click cancels.")

func draw_build():
 var p:=panel_at(overlay,Vector2(90,55),Vector2(1420,795))
 label_at(p,"CONSTRUCTION BLUEPRINTS",Vector2(28,20),29)
 var groups:=["All","Base","Power","Terraforming","Industry","Decorations"]
 for i in range(groups.size()):
  button_at(p,groups[i],Vector2(30+i*132,83),Vector2(123,41),func():build_group=groups[i];show_menu("build"),build_group==groups[i])
 var list_view:=ScrollContainer.new()
 list_view.position=Vector2(30,144)
 list_view.size=Vector2(795,548)
 list_view.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 p.add_child(list_view)
 var grid:=GridContainer.new()
 grid.columns=3
 grid.add_theme_constant_override("h_separation",10)
 grid.add_theme_constant_override("v_separation",10)
 list_view.add_child(grid)
 for index in range(Build.HABITAT,recipes.size()):
  if index==Build.RECOVERY:continue
  var spec:Dictionary=recipes[index]
  if build_group!="All" and spec.group!=build_group:continue
  var tile:=Button.new()
  tile.custom_minimum_size=Vector2(252,158)
  skin_button(tile,index==build_detail)
  tile.tooltip_text=spec.desc
  tile.pressed.connect(func():build_detail=index;show_menu("build"))
  grid.add_child(tile)
  icon_at(tile,structure_key(index),Vector2(65,2),Vector2(122,107))
  label_at(tile,spec.name,Vector2(10,106),16)
  var lock:=build_lock(index)
  label_at(tile,"AVAILABLE" if lock.is_empty() else lock,Vector2(12,131),12,HUD.GOOD if lock.is_empty() else HUD.ALERT)
 var detail:=panel_at(p,Vector2(853,82),Vector2(536,610))
 var index:=clampi(build_detail,Build.HABITAT,recipes.size()-1)
 var spec:Dictionary=recipes[index]
 label_at(detail,spec.name,Vector2(20,19),27)
 icon_at(detail,structure_key(index),Vector2(320,38),Vector2(192,167))
 var description:=label_at(detail,spec.desc,Vector2(20,70),16,HUD.SECONDARY)
 description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 description.size.x=292
 label_at(detail,"%+.2f kW   ·   %s"%[spec.power,output_text(spec)],Vector2(20,147),15,HUD.ACCENT)
 requirements(detail,spec.cost,Vector2(20,207),496,true)
 var lock:=build_lock(index)
 label_at(detail,"Ready to place" if lock.is_empty() else lock,Vector2(21,438),17,HUD.GOOD if lock.is_empty() else HUD.ALERT)
 var place:=button_at(detail,"Preview placement",Vector2(20,481),Vector2(496,49),choose_blueprint.bind(index),true)
 place.disabled=not lock.is_empty()
 button_at(detail,"Unpin recipe" if pinned_recipe==index else "Pin requirements",Vector2(20,545),Vector2(496,40),pin_recipe.bind(index))
 button_at(p,"Return [B]",Vector2(1142,720),Vector2(247,45),resume)

func draw_machine():
 if machine.is_empty():
  show_menu("pause")
  return
 var spec: Dictionary = recipes[machine.type]
 var p = panel_at(overlay,Vector2(240,105),Vector2(1120,690))
 label_at(p,spec.name.to_upper(),Vector2(30,22),30)
 label_at(p,spec.desc,Vector2(30,70),16)
 icon_at(p,structure_key(int(machine.type)),Vector2(836,0),Vector2(246,201))
 var status := "ONLINE" if machine.online else "OFFLINE · GRID SHORTAGE" if machine.active else "SWITCHED OFF"
 label_at(p,"%s   /   %+.2f kW   /   %.2f cumulative output"%[status,spec.power,machine.total],Vector2(30,110),17,Color("9bd9d6"))
 if machine.type not in [Build.STORAGE,Build.RECOVERY,Build.POD,Build.HABITAT,Build.DOOR,Build.FOUNDATION]:
  button_at(p,"Switch off" if machine.active else "Switch on",Vector2(30,154),Vector2(260,45),func():machine.active=not machine.active;refresh_grid();mark_save();show_menu("machine"))
 if machine.type in [Build.TUBE,Build.TUBE_2]:
  label_at(p,"SEED INSTALLED" if machine.seeded else "EMPTY GROWTH CHAMBER",Vector2(30,250),20)
  button_at(p,"Remove seed" if machine.seeded else "Insert seed",Vector2(30,295),Vector2(260,45),func():toggle_seed();show_menu("machine"),true)
 if has_container(machine.type):
  label_at(p,"BACKPACK",Vector2(30,210),17)
  label_at(p,"CONTAINER  /  %s slots used"%Data.slots(machine.stored),Vector2(568,210),17)
  storage_list(p,Vector2(30,244),inventory,true,machine.type==Build.STORAGE)
  storage_list(p,Vector2(568,244),machine.stored,false,true)
 if machine.type == Build.TERMINAL and machine.online:
  button_at(p,"View terraforming metrics",Vector2(30,250),Vector2(370,49),func():show_menu("terraform"),true)
 if machine.type == Build.CRAFT and machine.online:
  button_at(p,"Open fabricator",Vector2(30,250),Vector2(370,49),func():show_menu("craft"),true)
 button_at(p,"Close",Vector2(845,622),Vector2(242,43),resume,true)

func storage_list(parent:Control,pos:Vector2,items:Dictionary,to_storage:bool,enabled:bool):
 var scroll := ScrollContainer.new()
 scroll.position = pos
 scroll.size = Vector2(515,350)
 parent.add_child(scroll)
 var list := VBoxContainer.new()
 list.custom_minimum_size.x = 470
 scroll.add_child(list)
 for item in available_stacks(items):
  var b := Button.new()
  b.text = "%s × %s   %s"%[item.name,item.count,"→ Store" if to_storage and enabled else "← Take" if enabled else ""]
  b.icon=icon_texture(item.name)
  b.expand_icon=true
  b.add_theme_constant_override("icon_max_width",30)
  b.disabled = not enabled
  b.custom_minimum_size.y = 40
  b.pressed.connect(transfer_stack.bind(item.name,item.count,to_storage))
  if enabled:b.gui_input.connect(quick_transfer.bind(item.name,item.count,to_storage))
  list.add_child(b)

func quick_transfer(event:InputEvent,item:String,count:int,to_storage:bool):
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and event.shift_pressed:
  get_viewport().set_input_as_handled()
  transfer_stack(item,int((inventory if to_storage else machine.stored).get(item,count)),to_storage)

func toggle_seed() -> bool:
 if machine.seeded:
  if not Data.transaction(inventory,{},{"Seed":1},max_cargo()):
   notify("Make room before removing the seed.")
   return false
 else:
  if not pay({"Seed":1}):
   notify("Find a seed in a survey cache.")
   return false
  quest_events.seeded=true
 machine.seeded=not machine.seeded
 refresh_grid()
 apply_stage()
 mark_save()
 return true

func draw_terraform():
 var p = panel_at(overlay,Vector2(300,105),Vector2(1000,690))
 var index := terraform_index()
 var next := mini(stage_index+1,5)
 label_at(p,"TERRAFORMING TERMINAL",Vector2(34,24),29)
 label_at(p,"%s   ·   %.1f Ti   ·   +%.2f Ti/s"%[Data.STAGES[stage_index],index,ti_rate],Vector2(34,78),24,Color("9adbd9"))
 label_at(p,"BIOSPHERE  /  "+Progression.NAMES[Progression.stage(index)],Vector2(34,118),17,HUD.ACCENT)
 label_at(p,Progression.next_label(index),Vector2(34,147),16)
 var metrics := stats()
 for i in range(Data.METRICS.size()):
  var metric: String = Data.METRICS[i]
  label_at(p,"%s   %.2f   ·   +%.2f/s"%[metric,metrics[metric],production_rates[metric]],Vector2(34,189+i*88),20)
  var meter := ProgressBar.new()
  meter.position = Vector2(34,225+i*88)
  meter.size = Vector2(917,16)
  meter.max_value = maxf(1.0,float(Data.THRESHOLDS[next])/2)
  meter.value = metrics[metric]
  meter.show_percentage = false
  p.add_child(meter)
 button_at(p,"Return",Vector2(687,604),Vector2(265,45),resume,true)


func salvage_phase() -> int:
 return int(quest_events.get("salvage_phase",0))

func salvage_elapsed() -> float:
 return maxf(0,time-float(quest_events.get("salvage_start",time)))

func dust_strength() -> float:
 if salvage_phase() in [1,2,3,4]:
  return smoothstep(365.0,420.0,salvage_elapsed())*(1.0-smoothstep(495.0,550.0,salvage_elapsed()))
 return Mars.dust(time)

func salvage_message() -> String:
 match salvage_phase():
  1:
   return "Visit South Freight Wreck and recover a circuit board."
  2:
   return "Return to UZ-01. Open Outpost Control [P] inside the pod."
  3:
   return "Prepare the outpost. The reserve test opens at storm peak." if salvage_elapsed()<420 else "Choose one system to run on the storm reserve [P]."
  4:
   return "Reserve trial   ·   %ds remaining"%ceili(maxf(0,75.0-time+float(quest_events.get("salvage_trial",time))))
  5:
   return "Completed   ·   "+str(quest_events.get("salvage_result","Reserve tested"))
 return "Recover wreck salvage and test one system on limited power."

func start_salvage():
 if salvage_phase()!=0:return
 quest_events.salvage_phase=1
 quest_events.salvage_start=time
 mark_save()
 resume()
 salvage_announce("A dust front is approaching. Find a circuit board at South Freight Wreck.","salvage_start")

func salvage_announce(message:String,voice:String):
 notify(message)
 if not self_test and not render_test:onboarding.alert(voice)

func at_landing_pod() -> bool:
 for unit in structures:
  if unit.type!=Build.POD:continue
  var local:Vector3=unit.node.to_local(player.position)
  return absf(local.x)<1.9 and absf(local.z)<1.9 and local.y>=-0.1 and local.y<2.55
 return false

func install_salvage():
 if salvage_phase()!=2 or not at_landing_pod():return
 if not pay({"Circuit board":1}):
  notify("Fabricate a replacement circuit board with 2 Silicon and 1 Aluminum.")
  return
 quest_events.salvage_phase=3
 mark_save()
 show_menu("outpost")

func choose_salvage_power(system:String):
 if salvage_phase()!=3 or salvage_elapsed()<420.0 or not at_landing_pod() or system not in ["shield","food","radio"]:return
 quest_events.salvage_choice=system
 quest_events.salvage_trial=time
 quest_events.salvage_phase=4
 if system=="radio" and earth_reply_at<0:
  earth_reply_at=time+Mars.EARTH_ROUND_TRIP
 refresh_grid()
 mark_save()
 resume()
 salvage_announce("Reserve connected. Watch what your choice keeps running.","salvage_trial")

func advance_salvage():
 var phase:=salvage_phase()
 if phase in [1,2,3] and salvage_elapsed()>=420.0 and not quest_events.get("salvage_peak",false):
  quest_events.salvage_peak=true
  salvage_announce("Dust front at peak. Solar generation drops. The reserve trial is available.","dust_warning")
 if phase==1:
  var wreck:Vector2=Data.CRATE_POINTS[6]
  var arrived:=wreck.distance_to(Vector2(player.position.x,player.position.z))<12.0
  if (arrived or quest_events.get("salvage_visited",false)) and float(inventory.get("Circuit board",0))>=1:
   quest_events.salvage_phase=2
   mark_save()
   salvage_announce("Circuit board recovered. Return to the capsule and press P inside.","salvage_return")
  elif arrived and opened_crates.has("6") and not quest_events.get("salvage_visited",false):
   quest_events.salvage_visited=true
   notify("Cache already emptied. Craft a replacement circuit board at the pod.")
   mark_save()
 elif phase==4 and time-float(quest_events.get("salvage_trial",time))>=75.0:
  var results:={"shield":"Shelter shielding stayed powered. Food and radio waited.","food":"Food growth continued. Shielding and radio waited.","radio":"Earth answered. Food and shielding waited."}
  quest_events.salvage_result=results[quest_events.salvage_choice]
  quest_events.salvage_phase=5
  refresh_grid()
  mark_save()
  salvage_announce(str(quest_events.salvage_result),"salvage_done")

func nasa_picture(parent:Control,path:String,pos:Vector2,extent:Vector2):
 var source:=Image.load_from_file("res://nasa/"+path)
 if not source or source.is_empty():return
 var picture:=TextureRect.new()
 picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 picture.texture=ImageTexture.create_from_image(source)
 picture.position=pos
 picture.size=extent
 picture.mouse_filter=Control.MOUSE_FILTER_IGNORE
 parent.add_child(picture)

func draw_mars_atlas():
 var p:=panel_at(overlay,Vector2(154,100),Vector2(1292,700))
 label_at(p,"MARS ORBITAL ATLAS",Vector2(39,22),34)
 label_at(p,"MGS MOLA / Mars Express HRSC  ·  NASA/JPL Mars Trek",Vector2(39,77),18,HUD.ACCENT)
 nasa_picture(p,"mola-west.jpg",Vector2(176,108),Vector2(470,470))
 nasa_picture(p,"mola-east.jpg",Vector2(646,108),Vector2(470,470))
 label_at(p,"Blue marks lower terrain. Warm colors mark higher terrain. Survey waypoints belong to the simulated landing sector.",Vector2(43,590),17)
 button_at(p,"Curiosity sky reference",Vector2(43,625),Vector2(325,48),func():show_menu("nasa_sky"))
 button_at(p,"Surface survey",Vector2(922,625),Vector2(325,48),func():show_menu("map"),true)

func draw_nasa_sky():
 var p:=panel_at(overlay,Vector2(271,58),Vector2(1058,789))
 label_at(p,"GALE CRATER AT SUNSET",Vector2(40,24),34)
 nasa_picture(p,"curiosity-sunset.jpg",Vector2(41,76),Vector2(970,586))
 label_at(p,"Curiosity Mastcam  ·  15 April 2015  ·  NASA/JPL-Caltech/MSSS  ·  PIA19401",Vector2(41,683),16)
 button_at(p,"Return to atlas",Vector2(740,726),Vector2(263,43),func():show_menu("atlas"),true)

func draw_outpost():
 var p:=panel_at(overlay,Vector2(294,115),Vector2(1012,670))
 label_at(p,"OUTPOST CONTROL",Vector2(36,23),34)
 label_at(p,"Sol %d  ·  %s local time  ·  %.2f kW generated / %.2f kW requested"%[Mars.sol(time),Mars.local_clock(time),power_in,power_out],Vector2(37,78),19,HUD.ACCENT)
 label_at(p,"The training reserve can run one system at a time." if salvage_phase() in [3,4] else "These systems use power before your terraforming machines.",Vector2(37,114),18)
 if salvage_phase()==2 and at_landing_pod():
  button_at(p,"Install recovered board",Vector2(38,586),Vector2(430,47),install_salvage,true)
 if salvage_phase() in [3,4]:
  label_at(p,"STORM RESERVE  ·  1.05 kW  ·  "+salvage_message(),Vector2(37,140),16,HUD.ACCENT)
 var rows:=[
  ["Shelter shielding","0.80 kW · lowers radiation exposure while you are indoors.",mission_shield,"shield"],
  ["Food grow lights","0.90 kW · grows food packs. Collect them before your supplies run low.",mission_grow,"food"],
  ["Earth radio","0.55 kW · sends a report. A reply takes time even with power.",mission_radio,"radio"]
 ]
 for i in range(rows.size()):
  var row:Array=rows[i]
  var y:=173+i*99
  label_at(p,row[0],Vector2(38,y),21)
  label_at(p,row[1],Vector2(38,y+31),15,HUD.SECONDARY)
  var status:="Off" if not row[2] else "Powered" if mission_power.get(row[3],false) else "Waiting for power"
  if salvage_phase()==3:
   button_at(p,"Route reserve power",Vector2(738,y),Vector2(231,49),choose_salvage_power.bind(row[3]),true).disabled=not at_landing_pod() or salvage_elapsed()<420.0
  elif salvage_phase()==4:
   label_at(p,"On reserve" if mission_power.get(row[3],false) else "Waiting",Vector2(738,y+10),17)
  else:
   button_at(p,status,Vector2(738,y),Vector2(231,49),toggle_outpost.bind(row[3]),row[2])
 var radiation:="Radiation risk %.0f / 100   ·   "%mission_exposure
 radiation+= "Solar storm · go indoors" if Mars.solar(time)>0.15 else "Dust storm · solar panels make less power" if dust_strength()>0.15 else "Weather clear"
 label_at(p,radiation,Vector2(38,478),17,HUD.ACCENT)
 button_at(p,"Collect food (%d%%)"%roundi(mission_harvest*100),Vector2(38,522),Vector2(279,46),collect_outpost_food).disabled=mission_harvest<1.0
 var radio_text:="Send report"
 if earth_reply_at>=0:
  radio_text="Reply in %ds"%ceili(maxf(0,earth_reply_at-time)) if earth_reply_at>time else "Restore radio power"
 elif earth_reports>0:radio_text="Send report (%d replies)"%earth_reports
 button_at(p,radio_text,Vector2(330,522),Vector2(300,46),send_earth_report).disabled=earth_reply_at>=0 or not mission_power.get("radio",false)
 button_at(p,"Return [P]",Vector2(739,588),Vector2(229,46),resume,true)

func toggle_outpost(system:String):
 match system:
  "shield":mission_shield=not mission_shield
  "food":mission_grow=not mission_grow
  "radio":mission_radio=not mission_radio
 refresh_grid()
 mark_save()
 show_menu("outpost")

func collect_outpost_food():
 if mission_harvest<1.0:return
 if Data.transaction(inventory,{},{"Food pack":1},max_cargo()):
  mission_harvest=0.0
  mark_save()
  show_menu("outpost")

func send_earth_report():
 if not mission_power.get("radio",false) or earth_reply_at>=0.0:return
 earth_reply_at=time+Mars.EARTH_ROUND_TRIP
 mark_save()
 resume()
 notify("Report sent. Earth will reply after a round trip at light speed.")

func simulate_outpost(dt:float,inside:bool):
 if mission_power.get("food",false):
  mission_harvest=minf(1.0,mission_harvest+dt/70.0)
 if earth_reply_at>=0 and time>=earth_reply_at and mission_power.get("radio",false):
  earth_reply_at=-1
  earth_reports+=1
  notify("Earth reply received. During dust storms, keep a backup power source.")
  mark_save()
 var shielded:bool=mission_power.get("shield",false)
 var previous:=mission_exposure
 var change:=Mars.exposure_per_second(time,inside,shielded)
 if inside and shielded:change-=0.33
 mission_exposure=clampf(mission_exposure+change*dt,0,100)
 if mission_exposure>=65.0:health=maxf(1.0 if relaxed else 0.0,health-dt*(0.65 if inside else 1.45)*(0.3 if relaxed else 1.0))
 if previous<65.0 and mission_exposure>=65.0:notify("High radiation exposure. Use powered shielding and stay inside.")
 for event in [["dust",Mars.DUST_START,Mars.DUST_END],["solar",75.0,166.0]]:
  var key:="%s/%d"%[event[0],Mars.sol(time)]
  var phase:=fposmod(time,Mars.SOL_SECONDS)
  if event[0]=="solar" and Mars.sol(time)%2==1:continue
  if event[0]=="dust" and salvage_phase() in [1,2,3,4]:continue
  if phase>=float(event[1]) and phase<float(event[2]) and not quest_events.has(key):
   quest_events[key]=true
   var dusty:bool=event[0]=="dust"
   notify("Dust storm approaching. Solar output will drop." if dusty else "Solar storm. Get indoors and power your shielding.")
   if not self_test and not render_test:onboarding.alert("dust_warning" if dusty else "solar_warning")

func draw_science():
 var p:=panel_at(overlay,Vector2(266,103),Vector2(1068,699))
 label_at(p,"MARS SCIENCE & DATA",Vector2(38,27),32)
 var topics:=[
  ["Mars time and air","One sol lasts 24 h 39 m 35 s on Mars. Here, one sol lasts six minutes.\nMean-radius pressure is 6.36 mbar, or less than 1% of Earth's.","https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html"],
  ["Dust and solar power","A 2018 dust storm darkened the sky around solar-powered Opportunity.\nThe game reduces solar output during simulated dust storms.","https://science.nasa.gov/solar-system/planets/mars/10-things-massive-dust-storm-on-mars/"],
  ["Radiation and shelter","Curiosity measured 8,100 micrograys in the May 2024 solar event.\nThe recoverable radiation risk meter uses game units.","https://www.jpl.nasa.gov/news/nasa-watches-mars-light-up-during-epic-solar-storm/"],
  ["Earth radio delay","NASA reports 3 to 22 minutes each way. Our expedition models\n14 minutes each way and compresses the wait with the sol clock.","https://science.nasa.gov/blog/speaking-percys-language-how-to-talk-so-perseverance-will-listen/"]
 ]
 for i in range(topics.size()):
  var entry:Array=topics[i]
  var y:=92+123*i
  label_at(p,entry[0],Vector2(38,y),22,HUD.ACCENT)
  label_at(p,entry[1],Vector2(38,y+32),17)
  button_at(p,"NASA source",Vector2(833,y+23),Vector2(190,42),func():OS.shell_open(entry[2]))
 label_at(p,"Historical observations  ·  Simulated terrain and weather schedule",Vector2(37,623),15,HUD.SECONDARY)
 button_at(p,"Curiosity terrain reference",Vector2(37,647),Vector2(260,35),func():OS.shell_open("https://science.nasa.gov/resource/farewell-to-murray-buttes-image-4/"))
 button_at(p,"Back",Vector2(833,614),Vector2(190,45),func():show_menu(controls_return),true)

func walk_speed() -> float:
 return 5.0*(1.18 if equipment["Agility boots"] else 1.0)

func outdoor_oxygen_rate() -> float:
 if terraform_index()>=3500.0:return 0.0
 return 0.40*(0.28 if relaxed else 1.35 if challenge else 1.0)*(0.7 if equipment["Air filter"] else 1.0)

func flooded_ground(point:Vector3) -> bool:
 return lake.visible and Vector2(point.x,point.z).distance_to(BASIN)<BASIN_RADIUS and point.y<lake.position.y-0.30

func trip_basin_route(start:Vector2,end:Vector2) -> PackedVector2Array:
 if not lake.visible:return PackedVector2Array()
 var radius:=BASIN_RADIUS+7.0
 if start.distance_to(BASIN)<radius or end.distance_to(BASIN)<radius:return PackedVector2Array()
 var chord:=end-start
 if chord.length_squared()<1.0:return PackedVector2Array()
 var closest:=start+chord*clampf((BASIN-start).dot(chord)/chord.length_squared(),0,1)
 if closest.distance_to(BASIN)>=BASIN_RADIUS:return PackedVector2Array()
 var a:=(start-BASIN).angle()
 var b:=(end-BASIN).angle()
 var turn:=wrapf(b-a,-PI,PI)
 var route:=PackedVector2Array([start])
 for i in range(13):route.append(BASIN+Vector2.from_angle(a+turn*i/12.0)*radius)
 route.append(end)
 return route

func survey_trip_metres(start:Vector2,end:Vector2) -> float:
 var route:=trip_basin_route(start,end)
 if route.is_empty():route=PackedVector2Array([start,end])
 var length:=0.0
 for i in range(1,route.size()):
  var a:=route[i-1]
  var b:=route[i]
  var pieces:=maxi(1,ceili(a.distance_to(b)/12.0))
  var previous:=Vector3(a.x,height_at(a.x,a.y),a.y)
  for j in range(1,pieces+1):
   var sample:=a.lerp(b,float(j)/pieces)
   var current:=Vector3(sample.x,height_at(sample.x,sample.y),sample.y)
   length+=current.distance_to(previous)*(1.0/0.38 if flooded_ground(current) else 1.0)
   previous=current
 return length

func forecast_text() -> String:
 if salvage_phase() in [1,2,3,4]:
  var elapsed:=salvage_elapsed()
  if elapsed<365:return "Mission dust front in "+clock_span(365-elapsed)
  if elapsed<550:return "Mission dust front passes in "+clock_span(550-elapsed)
  return "Mission front passed"
 var phase:=fposmod(time,Mars.SOL_SECONDS)
 if phase>=Mars.DUST_START and phase<Mars.DUST_END:return "Dust window ends in "+clock_span(Mars.DUST_END-phase)
 return "Next dust window in "+clock_span(fposmod(Mars.DUST_START-phase,Mars.SOL_SECONDS))

func clock_span(seconds:float) -> String:
 var ticks:=ceili(seconds)
 return "%d:%02d"%[ticks/60,ticks%60]

func draw_expedition_planner(p:Control):
 var origin:=Vector2(player.position.x,player.position.z)
 var destination:=Vector2.ZERO
 var title:="UZ-01"
 if map_waypoint>=0:
  destination=Survey.SITES[map_waypoint][1]
  title=Survey.SITES[map_waypoint][0]
 elif salvage_phase()==1:
  destination=Data.CRATE_POINTS[6]
  title="South Freight Wreck"
 var path:=survey_trip_metres(origin,destination)
 var seconds:=2.0*path/walk_speed()
 if path<1.0:seconds=0.0
 var needed:=ceilf((seconds*1.20+20.0)*outdoor_oxygen_rate()) if path>1.0 else 0.0
 var enough:bool=oxygen>=needed
 label_at(p,"EXPEDITION PLANNER",Vector2(710,238),25,HUD.ACCENT)
 label_at(p,title+"   /   %d m direct"%roundi(origin.distance_to(destination)),Vector2(710,280),19)
 label_at(p,"Return to your current position   ·   ~%s walking"%clock_span(seconds),Vector2(710,315),16)
 label_at(p,"O₂ estimate  %.0f  /  %.0f now  /  %.0f tank"%[needed,oxygen,max_oxygen()],Vector2(710,347),19,HUD.GOOD if enough else HUD.ALERT)
 label_at(p,("Includes 20 seconds for stops and a 20% travel margin." if enough else "Oxygen may run short. Refill or carry a capsule."),Vector2(710,378),15,HUD.SECONDARY if enough else HUD.ALERT)
 var shelters: Array[Dictionary]=[]
 for unit in structures:
  if unit.type not in [Build.POD,Build.HABITAT]:continue
  var place:Vector3=unit.node.position
  shelters.append({"name":"UZ-01" if unit.type==Build.POD else "Habitat (%d E, %d N)"%[roundi(place.x),roundi(-place.z)],"distance":destination.distance_to(Vector2(place.x,place.z))})
 shelters.sort_custom(func(a,b):return a.distance<b.distance)
 label_at(p,"SHELTERS NEAR DESTINATION",Vector2(710,418),14,HUD.ACCENT)
 for i in range(mini(shelters.size(),2)):
  label_at(p,"%s   ·   %.0f m"%[shelters[i].name,shelters[i].distance],Vector2(710,442+24*i),16)
 var dust_eta:float=365.0-salvage_elapsed() if salvage_phase() in [1,2,3,4] else fposmod(Mars.DUST_START-fposmod(time,Mars.SOL_SECONDS),Mars.SOL_SECONDS)
 var dust_risk:=dust_strength()>0.08 or (dust_eta>=0 and seconds+20.0>=dust_eta)
 label_at(p,forecast_text()+"   /   active time",Vector2(710,502),17,HUD.ALERT if dust_risk else HUD.ACCENT)
 var solar_phase:=fposmod(time,Mars.SOL_SECONDS)
 var next_solar:float=(360.0 if Mars.sol(time)%2==1 else 0.0)+75.0-solar_phase
 if next_solar<0:next_solar+=720.0
 label_at(p,"Solar storm active" if Mars.solar(time)>0.08 else "Next solar window in "+clock_span(next_solar),Vector2(710,529),16,HUD.SECONDARY)
 label_at(p,("Basin crossing flooded. Follow the higher rim." if lake.visible else "Basin crossing is dry.")+"   Ice branch: "+("open" if cave_thawed() else "35 Heat"),Vector2(710,558),14,HUD.SECONDARY)

func draw_map():
 var p:=panel_at(overlay,Vector2(150,61),Vector2(1300,778))
 label_at(p,"MARS  /  SURFACE SURVEY",Vector2(32,19),30)
 label_at(p,"800 × 800 m   ·   5 m contours   ·   Click a region to set a waypoint",Vector2(34,64),15,HUD.SECONDARY)
 var map:=preload("res://mars_map.gd").new()
 map.game=self
 map.position=Vector2(33,108)
 map.size=Vector2(625,625)
 p.add_child(map)
 label_at(p,"SOL %d   /   %s LOCAL"%[Mars.sol(time),Mars.local_clock(time)],Vector2(710,108),21,HUD.ACCENT)
 label_at(p,"%d m E   /   %d m N   /   %d m elevation"%[roundi(player.position.x),roundi(-player.position.z),roundi(player.position.y)],Vector2(710,151),20)
 label_at(p,region_name(player.position.x,player.position.z),Vector2(710,194),18,HUD.SECONDARY)
 draw_expedition_planner(p)
 label_at(p,"Procedural terrain survey",Vector2(710,624),14,HUD.SECONDARY)
 button_at(p,"NASA orbital atlas",Vector2(1017,618),Vector2(228,42),func():show_menu("atlas"))
 if map_waypoint>=0:
  button_at(p,"Clear waypoint",Vector2(1080,281),Vector2(166,34),func():map_waypoint=-1;mark_save();show_menu("map"))
 button_at(p,"Return [M]",Vector2(710,681),Vector2(535,50),resume,true)

const OBJECTIVES = [
 "Look around, walk, and mine 3 iron.",
 "Mine 2 cobalt and craft an oxygen capsule.",
 "Build a wind turbine.",
 "Build a T1 drill and produce pressure.",
 "Build a habitat, attach a door, and step inside.",
 "Recover a seed and install it in a vegetube.",
 "Build solar power and a heater.",
 "Reach Thin Atmosphere and then Blue Haze.",
 "Fill the basin, grow vegetation, and reach Living Planet."
]

const VISOR_OBJECTIVES := [
 ["Mine 3 iron", "Iron"],
 ["Mine cobalt and craft a capsule", "Oxygen capsule"],
 ["Build a wind turbine", Build.WIND],
 ["Build a T1 pressure drill", Build.DRILL],
 ["Build and enter a habitat", Build.HABITAT],
 ["Install a seed in a vegetube", Build.TUBE],
 ["Build solar power and a heater", Build.HEATER],
 ["Reach Blue Haze", Build.TERMINAL],
 ["Reach Living Planet", Build.GRASS],
 ["Living Planet achieved", Build.GRASS]
]

func update_objectives():
 var progress_text:=""
 if quest_step==0:
  progress_text="%d / 3"%mini(3,int(quest_events.get("Iron",0)))
 elif quest_step==1 and int(quest_events.get("Cobalt",0))<2:
  progress_text="%d / 2"%int(quest_events.get("Cobalt",0))
 objective_progress.text=progress_text
 if visible_objective==quest_step:return
 visible_objective=quest_step
 for i in range(objective_rows.size()):
  var row:=objective_rows[i]
  var step:=quest_step+i
  row.visible=step<VISOR_OBJECTIVES.size()
  if not row.visible:continue
  var objective: Array = VISOR_OBJECTIVES[step]
  var marker:=row.get_child(0) as HUD.ObjectiveMarker
  marker.active=i==0
  marker.queue_redraw()
  row.add_theme_stylebox_override("panel",visor_active if i==0 else visor_idle)
  var art:=row.get_child(1) as TextureRect
  var item: Variant = objective[1]
  art.texture=icon_texture(structure_key(item) if item is int else item)
  var label:=row.get_child(2) as Label
  label.text=objective[0]
  row.modulate.a=1.0 if i==0 else 0.82

func advance_quest():
 var reached := [
  bool(quest_events.get("moved",false)) and bool(quest_events.get("looked",false)) and int(quest_events.get("Iron",0))>=3,
  int(quest_events.get("Cobalt",0))>=2 and bool(quest_events.get("Oxygen capsule",false)),
  bool(quest_events.get("Wind turbine",false)),
  bool(quest_events.get("T1 Pressure drill",false)) and pressure>0,
  bool(quest_events.get("refuge",false)),
  bool(quest_events.get("seeded",false)),
  (bool(quest_events.get("T1 Solar array",false)) or bool(quest_events.get("T2 Solar array",false))) and heat>0,
  terraform_index()>=400,
  terraform_index()>=3500
 ]
 var previous := quest_step
 while quest_step<reached.size() and reached[quest_step]:
  quest_step+=1
 if quest_step>previous:
  mark_save()
  if not paused and not self_test and not render_test:onboarding.guide_objective(quest_step)
  if quest_step<OBJECTIVES.size():notify("Objective complete  /  "+OBJECTIVES[quest_step])

func return_vehicle() -> Node3D:
 for unit in structures:
  if unit.type==Build.RETURN_VEHICLE:return unit.node
 return null

func return_ready() -> bool:
 return terraform_index()>=3500 and is_instance_valid(return_vehicle())

func return_status() -> String:
 if quest_events.get("earth_returned",false):return "Earth reached"
 if terraform_index()<3500:return "Unlocks at Living Planet   ·   3500 Ti"
 if not is_instance_valid(return_vehicle()):return "Build an Earth return vehicle [B]"
 if not quest_events.get("return_stocked",false):return "Load the crew supplies"
 if quest_events.get("return_clearance",false):return "Earth clearance received"
 if quest_events.has("launch_reply"):return "Awaiting Earth   ·   "+clock_span(maxf(0,float(quest_events.launch_reply)-time))
 return "Power the radio and request clearance"

func stock_return_vehicle():
 if not return_ready() or quest_events.get("return_stocked",false):return
 if not pay(Data.RETURN_SUPPLIES):
  notify("The backpack is missing supplies on the crew manifest.")
  return
 quest_events.return_stocked=true
 mark_save()
 show_menu("return_vehicle")

func request_launch():
 if not return_ready() or not quest_events.get("return_stocked",false) or quest_events.has("launch_reply") or quest_events.get("return_clearance",false) or not mission_power.get("radio",false):return
 quest_events.launch_reply=time+Mars.EARTH_ROUND_TRIP
 mark_save()
 resume()
 notify("Launch request sent. Earth needs a round trip to answer.")

func tick_launch_reply():
 if quest_events.has("launch_reply") and time>=float(quest_events.launch_reply) and mission_power.get("radio",false):
  quest_events.erase("launch_reply")
  quest_events.return_clearance=true
  mark_save()
  notify("Earth clearance received. Board the return vehicle when the dust clears.")

func can_board() -> bool:
 var craft:=return_vehicle()
 return return_ready() and quest_events.get("return_stocked",false) and quest_events.get("return_clearance",false) and not quest_events.get("earth_returned",false) and dust_strength()<0.35 and player.position.distance_to(craft.position)<5.0

func draw_return_vehicle():
 var p:=panel_at(overlay,Vector2(395,161),Vector2(810,580))
 label_at(p,"EARTH RETURN VEHICLE",Vector2(36,28),35)
 label_at(p,return_status(),Vector2(36,82),21,HUD.ACCENT)
 requirements(p,Data.RETURN_SUPPLIES,Vector2(36,133),480)
 button_at(p,"Load crew supplies",Vector2(35,328),Vector2(355,47),stock_return_vehicle).disabled=not return_ready() or quest_events.get("return_stocked",false)
 button_at(p,"Request Earth clearance",Vector2(419,328),Vector2(355,47),request_launch).disabled=not quest_events.get("return_stocked",false) or quest_events.has("launch_reply") or quest_events.get("return_clearance",false) or not mission_power.get("radio",false)
 label_at(p,"Keep the Earth radio powered [P]. Wait outside this menu for the reply.",Vector2(36,400),16,HUD.SECONDARY)
 var craft:=return_vehicle()
 var launch_hint:="Board and launch"
 if dust_strength()>=0.35:launch_hint="Wait for dust to clear"
 elif craft and player.position.distance_to(craft.position)>=5.0:launch_hint="Approach the vehicle to board"
 button_at(p,launch_hint,Vector2(35,455),Vector2(355,46),board_for_earth,true).disabled=not can_board()
 button_at(p,"Return to surface",Vector2(419,455),Vector2(355,46),resume)

func make_return_model(node:Node3D):
 var shell:=visuals.textured_finish(visuals.surface(Color("dbd3c1"),0.42,0.44),"metal")
 var ceramic:=visuals.surface(Color("227087"),0.36,0.45)
 var steel:=visuals.surface(Color("47434a"),0.55,0.6)
 cylinder(node,Vector3(0,2.4,0),1.05,3.7,shell,1.02)
 cylinder(node,Vector3(0,4.83,0),1.02,1.23,shell,0.12)
 cylinder(node,Vector3(0,3.72,0),1.06,0.31,ceramic,1.055)
 cylinder(node,Vector3(0,1.00,0),1.09,0.4,ceramic,1.08)
 for i in range(4):
  var a:=Vector2.from_angle(i*TAU/4)
  cylinder(node,Vector3(a.x*0.58,0.42,a.y*0.58),0.23,0.76,steel,0.14)
  var fin:MeshInstance3D=box(node,Vector3(a.x*1.0,0.92,a.y*1.0),Vector3(0.11,1.35,1.02),steel)
  fin.rotation.y=i*TAU/4+PI/2
 var window:=visuals.bevel_box(node,Vector3(0,4.11,0.98),Vector3(0.54,0.35,0.14),0.10,steel)
 window.rotation.x=-0.15

var departure_camera:Camera3D
var departure_model:Node3D
var departure_origin:Vector3
var departure_time:=0.0

func board_for_earth():
 if not can_board():return
 var craft:=return_vehicle()
 quest_events.earth_returned=true
 if not save_game() and not render_test and not self_test:
  quest_events.erase("earth_returned")
  return
 show_menu("departure")
 clear_overlay()
 label_at(overlay,"MARS DEPARTURE   /   UZ RETURN VEHICLE",Vector2(55,36),19,HUD.TEXT)
 label_at(overlay,"Esc or Space to skip",Vector2(1304,835),16,HUD.SECONDARY)
 departure_origin=craft.global_position
 departure_time=0.0
 departure_model=Node3D.new()
 add_child(departure_model)
 make_return_model(departure_model)
 departure_model.position=departure_origin
 var flame:MeshInstance3D=cylinder(departure_model,Vector3(0,-1.4,0),0.035,2.95,emissive(Color("ffae64")),0.52)
 flame.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ignition:=OmniLight3D.new()
 ignition.light_color=Color("ffbc83")
 ignition.light_energy=3.4
 ignition.omni_range=22.0
 ignition.position=Vector3(0,0.3,2.1)
 departure_model.add_child(ignition)
 departure_camera=Camera3D.new()
 add_child(departure_camera)
 departure_camera.position=departure_origin+Vector3(8,3.8,14)
 departure_camera.make_current()
 craft.hide()

func animate_departure(dt:float):
 if not is_instance_valid(departure_model):return
 departure_time+=dt
 departure_model.position.y=departure_origin.y+departure_time*departure_time*0.98
 departure_camera.look_at(departure_model.position+Vector3.UP*2.4)
 if departure_time>=5.0:finish_departure()

func finish_departure():
 if is_instance_valid(departure_model):departure_model.queue_free()
 departure_model=null
 if is_instance_valid(departure_camera):departure_camera.queue_free()
 departure_camera=null
 camera.make_current()
 var craft:=return_vehicle()
 if craft:craft.show()
 show_menu("earth_arrival")

func draw_earth_arrival():
 var p:=panel_at(overlay,Vector2(265,57),Vector2(1070,786))
 label_at(p,"EARTH ARRIVAL",Vector2(39,24),35,HUD.ACCENT)
 nasa_picture(p,"earth.jpg",Vector2(220,87),Vector2(630,558))
 label_at(p,"Arrival sequence illustration   ·   Apollo 17 Blue Marble, NASA JSC",Vector2(40,660),15,HUD.SECONDARY)
 button_at(p,"Continue managing the Mars outpost",Vector2(39,711),Vector2(990,47),resume,true)

func draw_journal():
 var p = panel_at(overlay,Vector2(270,90),Vector2(1060,720))
 label_at(p,"EXPEDITION JOURNAL",Vector2(35,26),31)
 for i in range(OBJECTIVES.size()):
  var mark := "✓" if i<quest_step and not quest_events.get("skipped",false) else "›" if i==quest_step else "·"
  label_at(p,"%s   %s"%[mark,OBJECTIVES[i]],Vector2(36,104+i*51),19,Color("98dcd5") if i==quest_step else Color("c2ced1"))
 button_at(p,"Field archives",Vector2(35,540),Vector2(235,32),func():show_menu("archive"))
 button_at(p,"Skip tutorial",Vector2(35,638),Vector2(235,45),func():quest_events.skipped=true;quest_step=8;mark_save();show_menu("journal"))
 label_at(p,"STORM SALVAGE  /  "+salvage_message(),Vector2(36,578),17,HUD.ACCENT)
 label_at(p,"RETURN TO EARTH  /  "+return_status(),Vector2(36,604),16,HUD.SECONDARY)
 if salvage_phase()==0:
  button_at(p,"Accept storm salvage",Vector2(285,638),Vector2(330,45),start_salvage,true)
 if return_ready():
  button_at(p,"Return manifest",Vector2(617,638),Vector2(149,45),func():show_menu("return_vehicle"))
 button_at(p,"Return [J]",Vector2(770,638),Vector2(250,45),resume,true)


func draw_death():
 var p = panel_at(overlay,Vector2(470,230),Vector2(660,430))
 label_at(p,"SIGNAL LOST",Vector2(35,30),39,Color("e7a088"))
 var cause = "Oxygen depleted" if oxygen<=0 else "Dehydration" if water<=0 else "Starvation" if food<=0 else "Radiation emergency"
 label_at(p,cause,Vector2(35,95),23)
 label_at(p,"Half your cargo remains in a recovery crate at your last position.",Vector2(35,155),15)
 button_at(p,"Respawn at habitat",Vector2(35,228),Vector2(590,55),respawn,true)
 button_at(p,"Main menu",Vector2(35,302),Vector2(590,48),func():show_menu("main"))

func draw_victory():
 var p = panel_at(overlay,Vector2(430,180),Vector2(740,530))
 label_at(p,"LIVING PLANET",Vector2(35,40),48,Color("a2ead4"))
 label_at(p,"Your outpost can sustain a living ecosystem.",Vector2(35,124),24)
 label_at(p,"SURFACE TIME     %.1f minutes\nTERRAFORM INDEX     %.0f Ti\nSTRUCTURES       %s"%[time/60,terraform_index(),structures.size()],Vector2(35,200),19)
 button_at(p,"Continue exploring your outpost",Vector2(35,382),Vector2(670,55),resume,true)
 button_at(p,"Save and exit",Vector2(35,454),Vector2(670,44),func():save_game();get_tree().quit())

func _input(event):
 if starting_up:return
 if is_instance_valid(polish) and polish.handle_input(event):
  get_viewport().set_input_as_handled()
  return
 if menu=="departure":
  if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ESCAPE,KEY_SPACE]:finish_departure()
  return
 if is_instance_valid(onboarding) and onboarding.intro_active:
  if capture_intro:return
  if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ESCAPE,KEY_SPACE]:
   get_viewport().set_input_as_handled()
   onboarding.finish_intro()
  return
 if event is InputEventKey and event.pressed:
  if event.echo:return
  if event.keycode==KEY_H and not paused:
   advanced_panel.visible=not advanced_panel.visible
   return
  if event.keycode==KEY_F11:
   DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
   return
  if event.keycode==KEY_ESCAPE:
   get_viewport().set_input_as_handled()
   if dead:show_menu("dead")
   elif selected_build>=0:selected_build=-1;clear_ghost()
   elif paused and menu=="main":enter_expedition()
   elif paused and menu in ["atlas","nasa_sky"]:show_menu("map" if menu=="atlas" else "atlas")
   elif paused and menu in ["settings","restart","science"]:show_menu(controls_return)
   elif paused and menu in ["pause","victory"]:resume()
   elif paused:
    pending_action=Callable()
    resume()
   else:show_menu("pause")
   return
 if dead or menu in ["main","victory","restart"]:return
 if event is InputEventKey and event.pressed and event.keycode==KEY_P:
  get_viewport().set_input_as_handled()
  if menu=="outpost":resume()
  elif not paused:show_menu("outpost")
  return
 if event is InputEventMouseMotion and not paused and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
  if render_test:return
  quest_events.looked = true
  yaw -= event.relative.x*sensitivity
  pitch = clamp(pitch-event.relative.y*sensitivity*(-1.0 if invert_y else 1.0),-1.15,0.85)
 if event.is_action_pressed("inventory"):
  get_viewport().set_input_as_handled()
  if menu=="inventory":resume()
  else:show_menu("inventory")
  return
 if event.is_action_pressed("craft"):
  play_effect("click")
  get_viewport().set_input_as_handled()
  if menu=="craft":resume()
  else:show_menu("craft")
  return
 if event.is_action_pressed("build"):
  get_viewport().set_input_as_handled()
  if menu=="build":resume()
  else:show_menu("build")
  return
 if event.is_action_pressed("map"):
  get_viewport().set_input_as_handled()
  if menu=="map":resume()
  else:show_menu("map")
  return
 if event.is_action_pressed("save"):
  if save_game():notify("Expedition saved.")
  return
 if event.is_action_pressed("journal"):
  get_viewport().set_input_as_handled()
  if menu=="journal":resume()
  else:show_menu("journal")
  return
 if paused:return
 if event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_6:
   selected_slot = int(event.physical_keycode-KEY_1)
   return
  if event.physical_keycode==KEY_Q:
   use_item(hotbar[selected_slot])
   return
 if event.is_action_pressed("rotate") and selected_build>=0:
  build_rotation=(build_rotation+1)%4
  ground_target=Vector3.INF
  return
 if event.is_action_pressed("flashlight"):
  flashlight.visible=not flashlight.visible
  return
 if event.is_action_pressed("view"):third_person=not third_person
 if event.is_action_pressed("interact") and not pending_action.is_valid():interact()
 if event.is_action_pressed("dismantle"):dismantle()
 if event is InputEventMouseButton and event.pressed:
  if event.button_index==MOUSE_BUTTON_RIGHT:selected_build=-1;clear_ghost()
  elif event.button_index==MOUSE_BUTTON_LEFT and selected_build>=0 and Engine.get_process_frames()>ui_open_frame:place_building()

func _physics_process(dt):
 if self_test:return
 if verify_spawn:
  verify_spawn=false
  resolve_player_spawn()
 pivot.rotation = Vector3(pitch,yaw,0)
 astronaut.visible = third_person and not onboarding.intro_active
 if paused or dead:
  update_camera()
  return
 var move := Input.get_vector("left","right","forward","back")
 var direction := Basis(Vector3.UP,yaw)*Vector3(move.x,0,move.y)
 var grounded := player.is_on_floor()
 var speed:=walk_speed()*(1.65 if Input.is_action_pressed("sprint") else 1.0)
 if flooded_ground(player.position):speed*=0.38
 var desired := Vector2(direction.x,direction.z)*speed
 var horizontal := Vector2(player.velocity.x,player.velocity.z)
 var acceleration := 11.0 if not grounded else 30.0 if desired.is_zero_approx() else 23.0
 horizontal=horizontal.move_toward(desired,acceleration*dt)
 player.velocity.x=horizontal.x
 player.velocity.z=horizontal.y
 if not grounded:
  player.velocity.y=maxf(player.velocity.y-12*dt,-30.0)
 else:
  player.velocity.y=5.5 if Input.is_action_just_pressed("jump") else -0.1
 if not grounded and equipment.Jetpack and oxygen>5.0 and Input.is_action_pressed("jump"):
  player.velocity.y=move_toward(player.velocity.y,4.2,dt*20.0)
  oxygen=maxf(0,oxygen-dt*2.0)
 rig.track_vertical_speed(player.velocity.y)
 player.move_and_slide()
 player.position.x = clampf(player.position.x,-Survey.HALF+2,Survey.HALF-2)
 player.position.z = clampf(player.position.z,-Survey.HALF+2,Survey.HALF-2)
 if player.position.y < height_at(player.position.x,player.position.z)-4:
  player.position.y = height_at(player.position.x,player.position.z)+0.4
  resolve_player_spawn()
 if direction.length()>0.1:
  quest_events.moved = true


 var travel := player.get_real_velocity()
 var facing:float=atan2(-travel.x,-travel.z) if third_person and Vector2(travel.x,travel.z).length()>0.28 else yaw
 astronaut.rotation.y=lerp_angle(astronaut.rotation.y,facing,1.0-exp(-9.0*dt))
 update_camera()
 update_target(dt)
 update_rig(dt)

func update_camera():
 camera.position=Vector3(0.65,0.5,4.8) if third_person else Vector3.ZERO
 if not third_person:return
 var boom:=PhysicsRayQueryParameters3D.create(pivot.global_position,camera.global_position,1|8)
 var wall:=get_world_3d().direct_space_state.intersect_ray(boom)
 if not wall.is_empty():
  camera.global_position=wall.position+(pivot.global_position-wall.position).normalized()*0.25

func resolve_player_spawn():
 var capsule: CollisionShape3D = player.get_child(0)
 var query:=PhysicsShapeQueryParameters3D.new()
 query.shape=capsule.shape
 query.collision_mask=8
 query.margin=0.02
 var origin:=player.global_position
 query.transform=Transform3D(Basis.IDENTITY,origin+capsule.position+Vector3.UP*0.06)
 var space:=get_world_3d().direct_space_state
 var overlaps:=space.intersect_shape(query)
 var blocked:=false
 for hit in overlaps:
  # Low floors and platform decks can touch the capsule feet.
  if (hit.collider.collision_layer & 16)==0:blocked=true
 if not blocked:
  player.reset_physics_interpolation()
  return
 for ring in range(1,12):
  for direction in range(12):
   var horizontal := Vector3.FORWARD.rotated(Vector3.UP,direction*TAU/12)*ring*0.55
   var point:=origin+horizontal
   if absf(point.x)>Survey.HALF-2 or absf(point.z)>Survey.HALF-2:continue
   point.y=maxf(origin.y,height_at(point.x,point.z)+0.11)
   query.transform=Transform3D(Basis.IDENTITY,point+capsule.position+Vector3.UP*0.06)
   if space.intersect_shape(query,1).is_empty():
    player.global_position=point
    player.velocity=Vector3.ZERO
    player.reset_physics_interpolation()
    return
 player.global_position=Vector3(0,0.34,1.2)
 player.velocity=Vector3.ZERO
 player.reset_physics_interpolation()

func _process(dt):
 dt=minf(dt,0.1)
 if is_instance_valid(polish):polish.update_audio()
 if menu=="departure":animate_departure(dt)
 if self_test:return
 onboarding.tick(dt,not paused and not dead)
 update_score(dt)
 if onboarding.intro_active:return
 if not paused and not dead:
  dt = minf(dt,0.1)
  time+=dt
  if pending_action.is_valid():
   pending_time-=dt
   if pending_time<=0:
    var action:=pending_action
    pending_action=Callable()
    action.call()
  notice_time=max(0,notice_time-dt)
  chunk_clock+=dt
  sim_clock+=dt
  autosave_clock+=dt
  if chunk_clock>1.5:
   chunk_clock=0
   update_chunks()
  if sim_clock>=0.25:
   simulate(sim_clock)
   sim_clock=0
  if autosave_clock>25:
   autosave_clock=0
   save_game()
  near_machine=0.0
  for s in structures:
   animate_machine(s,dt)
   if s.online and absf(recipes[s.type].power)>0.0:
    near_machine=maxf(near_machine,1.0-clampf(s.node.position.distance_to(player.position)/14.0,0.0,1.0))
  if is_instance_valid(sfx_machine):sfx_machine.volume_db=linear_to_db(maxf(0.001,near_machine*0.11*sfx_level))


  if selected_build>=0:update_ghost()
 if not paused:apply_stage()
 update_hud(dt)
 if not paused:update_context_hud()

func stats() -> Dictionary:
 return {"Pressure":pressure,"Heat":heat,"Oxygen":planet_oxygen,"Biomass":biomass}

func terraform_index() -> float:
 return Data.terraform_index(stats())

func refresh_grid():
 power_in = 0.0
 power_out = 0.0
 ti_rate = 0.0
 for metric in Data.METRICS:production_rates[metric]=0.0
 for unit in structures:
  var watts: float = recipes[unit.type].power
  if unit.type in [Build.SOLAR,Build.SOLAR_2]:watts*=1.0-0.82*dust_strength()
  if unit.active:
   power_in += maxf(0,watts)
   power_out += maxf(0,-watts)
 var remaining: float = power_in
 mission_power.clear()
 var trial:=salvage_phase()==4
 var reserved:=str(quest_events.get("salvage_choice",""))
 for system in [["shield",mission_shield,Mars.SHIELD_KW],["food",mission_grow,Mars.GREENHOUSE_W],["radio",mission_radio,Mars.RADIO_W]]:
  if trial:
   mission_power[system[0]]=trial and reserved==system[0] and float(system[2])<=1.05
   continue
  if not system[1]:continue
  var demand:float=system[2]
  power_out+=demand
  var supplied:=remaining+0.00001>=demand
  mission_power[system[0]]=supplied
  if supplied:remaining-=demand
 for unit in structures:
  var spec: Dictionary = recipes[unit.type]
  var demand := maxf(0,-spec.power)
  var has_seed: bool = unit.type not in [Build.TUBE,Build.TUBE_2] or unit.seeded
  unit.online = unit.active and remaining+0.00001 >= demand
  if not unit.online:
   continue
  remaining -= demand
  if has_seed and spec.has("metric"):
   production_rates[spec.metric] += float(spec.rate)
   ti_rate += float(spec.rate) * (3.0 if spec.metric == "Biomass" else 2.0)
  if unit.type == Build.GRASS:
   production_rates.Oxygen += 0.4
   ti_rate += 0.8

func update_habitat_walls():
 for room in structures:
  if room.type!=Build.HABITAT:continue
  for side in range(4):
   var orientation: int = (side+int(room.angle))%4
   var position: Vector3 = room.node.position+Vector3.BACK.rotated(Vector3.UP,orientation*PI/2.0)*2.0
   var infill: Node3D = room.node.get_node("Wall%d/Infill"%side)
   var has_entrance := false
   for door in structures:
    if door.type==Build.DOOR and door.node.position.distance_to(position)<0.25:
     has_entrance = true
     break
   infill.visible = not has_entrance
   infill.get_child(1).collision_layer = 0 if has_entrance else 8

func simulate(dt:float):
 dt = clampf(dt,0.0,0.5)
 refresh_grid()
 for unit in structures:
  if not unit.online:
   continue
  var spec: Dictionary = recipes[unit.type]
  if spec.has("metric") and (unit.type not in [Build.TUBE,Build.TUBE_2] or unit.seeded):
   var output: float = float(spec.rate) * dt
   match spec.metric:
    "Pressure": pressure += output
    "Heat": heat += output
    "Oxygen": planet_oxygen += output
    "Biomass":
     biomass += output
     planet_oxygen += 0.4 * dt
   unit.total += output
  if unit.type in [Build.WATER,Build.ORE] or spec.has("makes"):
   var interval:float=spec.get("interval",45.0 if unit.type == Build.WATER else 40.0)
   unit.progress = minf(interval,unit.progress+dt)
   if unit.progress >= interval:
    var item: String = spec.get("makes","Water bottle") if unit.type!=Build.ORE else ORES[rng.randi_range(0,5)]
    if Data.transaction(unit.stored,{}, {item:1},12):
     unit.progress = 0.0
     unit.total += 1.0
 var refuge := false
 for unit in structures:
  if unit.type not in [Build.POD,Build.HABITAT]:
   continue
  var local: Vector3 = unit.node.to_local(player.global_position)
  if absf(local.x)<1.9 and absf(local.z)<1.9 and local.y>=-0.1 and local.y<2.55:
   refuge = true
   safe_position = unit.node.position + Vector3(0,0.34,0)
   if unit.type == Build.HABITAT: quest_events.refuge = true
   break
 if not capture_intro:
  simulate_outpost(dt,refuge)
  advance_salvage()
  tick_launch_reply()
 var drain := 0.28 if relaxed else 1.35 if challenge else 1.0
 oxygen = minf(max_oxygen(),oxygen+dt*25) if refuge or terraform_index()>=3500.0 else maxf(0,oxygen-dt*outdoor_oxygen_rate())
 water = maxf(0,water-dt*0.115*drain)
 food = maxf(0,food-dt*0.08*drain)
 if oxygen <= 0 or water <= 0 or food <= 0:
  health = maxf(0,health-dt*(6.0 if oxygen<=0 else 2.0)*drain)
 if health <= 0:
  die()
  return
 if minf(oxygen/max_oxygen(),minf(water/100.0,food/100.0)) < 0.20 and time-last_low_warning > 22.0:
  last_low_warning = time
  var warning := "LOW OXYGEN · Return to a refuge or use a capsule."
  if oxygen/max_oxygen()>=0.20:
   warning = "LOW HYDRATION · Use a water bottle." if water<20 else "LOW NUTRITION · Use a food pack."
  notify(warning)
  if not self_test and not render_test and not paused:
   onboarding.alert("low_air" if oxygen/max_oxygen()<0.20 else "low_water" if water<20 else "low_food")
  play_effect("breath")
 var next_stage := Data.stage(terraform_index())
 var visual_stage:=Progression.stage(terraform_index())
 if visual_stage>int(quest_events.get("visual_stage",0)):
  quest_events.visual_stage=visual_stage
  notify("BIOSPHERE MILESTONE  /  "+Progression.NAMES[visual_stage])
  play_sound("res://build.wav")
  mark_save()
 if next_stage > stage_index:
  stage_index = next_stage
  notify("NEW TERRAFORMING STAGE  /  "+Data.STAGES[stage_index])
  mark_save()
 if stage_index == 5 and not won:
  won = true
  advance_quest()
  save_game()
  show_menu("victory")
 advance_quest()
 update_deposits()

func update_deposits():
 var ready: Array[String] = []
 for id in depleted:
  if not id.begins_with("sample:") and time >= float(depleted[id]):
   ready.append(id)
 for id in ready:
  depleted.erase(id)
  if survey_deposits.has(id):
   var site:Dictionary=survey_deposits[id]
   var offset:=Vector3(rng.randf_range(-0.28,0.28),0,rng.randf_range(-0.20,0.20))
   var point:Vector3=site.position+offset
   point.y=height_at(point.x,point.z)
   create_deposit(self,id,point,site.ore,rng)
  elif id.begins_with("starter:"):
   var index := int(id.split(":")[1])
   create_deposit(self,id,starter_position(index),index%6,rng)
  else:
   var parts := id.split(":")
   if parts.size()!=3:continue
   var key := Vector2i(int(parts[0]),int(parts[1]))
   if chunks.has(key):
    var root: Node3D = chunks[key]
    for child in root.get_children():
     if child.has_meta("deposit_id"):deposits.erase(child.get_meta("deposit_id"))
    remove_child(root)
    root.queue_free()
    chunks.erase(key)


func ray_hit(mask=2,distance=11.0) -> Dictionary:
 var origin=camera.global_position
 var end=origin-camera.global_basis.z*distance
 var query=PhysicsRayQueryParameters3D.create(origin,end,mask)
 return get_world_3d().direct_space_state.intersect_ray(query)

func target_from_hits(hit:Dictionary,occlusion:Dictionary,eye:Vector3) -> Node3D:
 if hit.is_empty() or eye.distance_to(Vector3(hit.position))>3.5:return null
 var collider:Node3D=hit.collider
 if not occlusion.is_empty() and Vector3(occlusion.position).distance_to(eye)+0.025<Vector3(hit.position).distance_to(eye):
  if not occlusion.collider.has_meta("structure_owner") or occlusion.collider.get_meta("structure_owner")!=collider:return null
 if collider.has_meta("structure_owner"):collider=collider.get_meta("structure_owner")
 return collider if (collider.collision_layer & 2)!=0 else null

func update_target(dt:float):
 var eye:=player.global_position+Vector3.UP*1.53
 var reach:=8.5 if third_person else 3.5
 var hit:=ray_hit(1|2|8,reach)
 var obstruction:Dictionary={}
 if third_person and not hit.is_empty():
  var query:=PhysicsRayQueryParameters3D.create(eye,hit.position,1|8)
  obstruction=get_world_3d().direct_space_state.intersect_ray(query)
 target=target_from_hits(hit,obstruction,eye)
 if not hit.is_empty():aim_point=hit.position
 if is_instance_valid(target) and target.has_meta("structure"):
  var unit:Dictionary=structures[int(target.get_meta("structure"))]
  if unit.type in [Build.POD,Build.HABITAT]:
   var local:Vector3=unit.node.to_local(player.position)
   if absf(local.x)<2.01 and absf(local.z)<2.01:target=null
 target_item=""
 target_unit={}
 target_kind="none"
 if is_instance_valid(target):
  if target.has_meta("lore_id"):target_kind="cache"
  elif target.has_meta("ore"):
   target_item=ORES[int(target.get_meta("ore"))]
   target_kind="resource"
  elif target.has_meta("survey_object"):target_kind="cache"
  elif target.has_meta("fabricator"):target_kind="fabricator"
  elif target.has_meta("structure"):
   target_unit=structures[int(target.get_meta("structure"))]
   target_kind="storage" if has_container(target_unit.type) else "machine"
  elif target.has_meta("loot"):target_kind="cache"
 var wanted:Node3D=target if target_kind=="resource" else null
 if wanted!=mining_target or not Input.is_action_pressed("mine"):mine_progress=0.0
 mining_target=wanted
 var duration:=1.0
 if is_instance_valid(wanted):
  duration=float(visuals.resources[target_item].harvest_time)/(1.35 if equipment["Mining upgrade"] else 1.0)
  if Input.is_action_pressed("mine") and selected_build<0 and Engine.get_process_frames()>ui_open_frame:
   mine_progress+=dt
   if mine_progress>=duration:
    mine(wanted)
    mine_progress=0.0
 if selected_build>=0:
  var ground:=ray_hit(1|16|8,14.0)
  if not ground.is_empty() and (ground.collider.collision_layer & (1|16))==0:
   var door_hit:bool=selected_build==Build.DOOR and ground.collider.has_meta("structure_owner")
   if not door_hit:ground={}
  ground_target=build_position(ground)
  cached_placement=placement_status(ground_target,selected_build,build_rotation)
 reticle.progress=clampf(mine_progress/duration,0,1)
 reticle.kind=target_kind if selected_build<0 else "valid" if cached_placement.is_empty() else "invalid"
 reticle.queue_redraw()
 aim_marker.visible=is_instance_valid(wanted) and selected_build<0
 if aim_marker.visible:aim_marker.position=wanted.position+Vector3.UP*0.08

func mine(node:Node3D) -> bool:
 if not is_instance_valid(node) or node.is_queued_for_deletion():
  return false
 var item: String = ORES[int(node.get_meta("ore"))]
 var id: String = node.get_meta("deposit_id")
 if not deposits.has(id) or not Data.transaction(inventory,{}, {item:1}, max_cargo()):
  notify("Backpack full. Store some materials to make room.")
  return false
 quest_events[item] = int(quest_events.get(item,0)) + 1
 var delay := rng.randf_range(65,105) if ORES.find(item) < 6 else rng.randf_range(125,185)
 depleted[id] = time + delay
 deposits.erase(id)
 node.collision_layer=0
 node.queue_free()
 target = null
 rig.action(Rig.Pose.PICKUP,0.35)
 sparks_at(aim_point,visuals.resources[item].palette,true)
 if is_instance_valid(sfx_mine):
  sfx_mine.stop()
  sfx.pitch_scale=0.96+float(absi(id.hash())%9)*0.01
  sfx.stream=mining_fractures[mining_sound_material(item)]
  sfx.play()
 notify("+1 "+item,item)
 mark_save()
 return true

func interact():
 if is_instance_valid(target) and target.has_meta("lore_id"):
  polish.collect_lore(int(target.get_meta("lore_id")))
  return
 if not is_instance_valid(target):
  return
 if target.has_meta("survey_object"):
  use_survey_object(str(target.get_meta("survey_object")))
  return
 if target.has_meta("loot"):
  var id := int(target.get_meta("loot"))
  if opened_crates.has(str(id)):
   return
  if not Data.transaction(inventory,{},Data.CRATE_ITEMS[id],max_cargo()):
   notify("Make room in your backpack before opening this cache.")
   return
  opened_crates[str(id)] = true
  target.hide()
  target.collision_layer = 0
  rig.action(Rig.Pose.PICKUP,0.4)
  notify("Survey cache recovered  /  "+cost_text(Data.CRATE_ITEMS[id]),"Seed")
  play_sound("res://collect.wav")
  mark_save()
  return
 if target.has_meta("fabricator"):
  cue_interaction(show_menu.bind("craft"))
  return
 if not target.has_meta("structure"):
  return
 var unit: Dictionary = structures[int(target.get_meta("structure"))]
 cue_interaction(open_machine.bind(unit))

func cue_interaction(callback:Callable):
 if self_test:callback.call()
 else:
  rig.action(Rig.Pose.INTERACT,0.22)
  play_effect("click")
  pending_action=callback
  pending_time=0.14

func open_machine(unit:Dictionary):
 if unit.type==Build.BEACON:
  map_waypoint=-1
  quest_events["beacon_waypoint"]=[unit.node.position.x,unit.node.position.z]
  notify("Survey beacon marked on the compass.")
  mark_save()
  return
 if not is_instance_valid(unit.node):return
 if unit.type==Build.RETURN_VEHICLE:
  show_menu("return_vehicle")
  return
 machine=unit
 if machine.type == Build.CRAFT and machine.online:
  show_menu("craft")
 elif machine.type == Build.TERMINAL and machine.online:
  show_menu("terraform")
 else:
  show_menu("machine")

func transfer_stack(item:String,amount:int,to_storage:bool):
 if machine.is_empty() or amount<=0:
  return
 var source: Dictionary = inventory if to_storage else machine.stored
 var destination: Dictionary = machine.stored if to_storage else inventory
 var capacity := (24 if machine.type in [Build.STORAGE,Build.RECOVERY] else 12) if to_storage else max_cargo()
 amount = mini(amount,int(source.get(item,0)))
 if amount<=0 or not Data.transaction(destination,{}, {item:amount},capacity):
  notify("Destination inventory has no room for that stack.")
  return
 source[item] -= amount
 mark_save()
 show_menu("machine")


func build_position(hit:Dictionary) -> Vector3:
 if hit.is_empty():return Vector3.INF
 var pos: Vector3 = hit.position
 if selected_build == Build.DOOR:
  var nearest := 3.4
  var snapped := Vector3.INF
  var direction := Vector3.BACK.rotated(Vector3.UP,build_rotation*PI/2.0)
  for unit in structures:
   if unit.type != Build.HABITAT:continue
   var candidate: Vector3 = unit.node.position + direction * 2.0
   var distance := candidate.distance_to(pos)
   if distance < nearest:
    snapped = candidate
    nearest = distance
  return snapped
 if selected_build in [Build.FOUNDATION,Build.HABITAT]:
  pos.x = snappedf(pos.x,2.0)
  pos.z = snappedf(pos.z,2.0)
 if hit.collider.collision_layer & 16 == 0 or selected_build == Build.FOUNDATION:
  pos.y = height_at(pos.x,pos.z)
 return pos

func footprint(type:int) -> Vector2:
 if type==Build.RETURN_VEHICLE:return Vector2(1.50,1.50)
 if type in [Build.POD,Build.HABITAT,Build.FOUNDATION]:
  return Vector2(2.05,2.05)
 if type in [Build.SOLAR,Build.SOLAR_2]:
  return Vector2(1.18 if type==Build.SOLAR else 1.6,0.82)
 if type == Build.DOOR:return Vector2(0.83,0.19)
 return Vector2(0.84,0.84)

func valid_build(pos:Vector3,type:int,angle:int) -> bool:
 return placement_status(pos,type,angle).is_empty()

func placement_status(pos:Vector3,type:int,angle:int) -> String:
 if not pos.is_finite() or type<=Build.POD or type>=recipes.size() or type==Build.RECOVERY:
  return "Aim at a construction surface"
 if type==Build.RETURN_VEHICLE and is_instance_valid(return_vehicle()):return "Return vehicle already built"
 if terraform_index()<float(recipes[type].at) or not afford(recipes[type].cost):
  return "Blueprint is locked or missing materials"
 var xy := Vector2(pos.x,pos.z)
 var radius := footprint(type)
 if angle%2:radius = Vector2(radius.y,radius.x)
 if absf(pos.x)+radius.x>=WORLD/2 or absf(pos.z)+radius.y>=WORLD/2:
  return "Outside the survey boundary"
 if xy.distance_to(BASIN)<BASIN_RADIUS+2.0 or pos.distance_to(player.position)>14.0:
  return "Lake basin or beyond build range"
 var offset := Vector2(player.position.x-pos.x,player.position.z-pos.z)
 if absf(offset.x)<radius.x+0.38 and absf(offset.y)<radius.y+0.38:
  return "Move out of the blueprint"
 if type == Build.DOOR:
  var supported := false
  var wall_normal := Vector3.BACK.rotated(Vector3.UP,angle*PI/2.0)
  for unit in structures:
   if unit.type==Build.HABITAT and (unit.node.position+wall_normal*2.0).distance_to(pos)<0.25:
    supported = true
    break
  if not supported:return "Attach to a habitat wall"
 else:
  for edge in [Vector2(-radius.x,-radius.y),Vector2(radius.x,-radius.y),Vector2(-radius.x,radius.y),radius]:
   if absf(pos.y-height_at(pos.x+edge.x,pos.z+edge.y))>0.55:
    return "Ground is too steep"
 for unit in structures:
  if type == Build.DOOR and unit.type == Build.HABITAT:continue
  if unit.type == Build.FOUNDATION and type != Build.FOUNDATION and pos.y>=unit.node.position.y+0.30:
   var relative:Vector3=pos-unit.node.position
   if absf(relative.x)+radius.x<=2.05 and absf(relative.z)+radius.y<=2.05:continue
  var other := footprint(unit.type)
  if int(unit.angle)%2:other=Vector2(other.y,other.x)
  var separation: Vector3 = unit.node.position-pos
  if absf(separation.x)<radius.x+other.x-0.06 and absf(separation.z)<radius.y+other.y-0.06:
   return "Overlaps another structure"
 if type!=Build.DOOR:
  var center:=Vector2i(floori(pos.x/CHUNK),floori(pos.z/CHUNK))
  for x in range(center.x-1,center.x+2):
   for z in range(center.y-1,center.y+2):
    var key:=Vector2i(x,z)
    if not chunks.has(key):continue
    for feature in chunks[key].get_children():
     if not feature.has_meta("obstacle"):continue
     var delta:Vector3=feature.position-pos
     if absf(delta.x)<radius.x+feature.get_meta("obstacle") and absf(delta.z)<radius.y+feature.get_meta("obstacle"):return "Overlaps a rock or landmark"
  for feature in scenery_obstacles:
   var delta:Vector3=feature.position-pos
   if absf(delta.x)<radius.x+float(feature.radius) and absf(delta.z)<radius.y+float(feature.radius):
    return "Overlaps a rock or landmark"
  for mineral in deposits.values():
   if not is_instance_valid(mineral) or mineral.is_queued_for_deletion():continue
   var delta:Vector3=mineral.position-pos
   if absf(delta.x)<radius.x+0.34 and absf(delta.z)<radius.y+0.34:
    return "Mine the obstructing deposit"
 return ""

func update_ghost():
 if not is_instance_valid(build_ghost):
  build_ghost = add_structure(selected_build,Vector3.ZERO,{},0.0,0,true)
  add_child(build_ghost)
  construction_material=ShaderMaterial.new()
  construction_material.shader=preload("res://nur_hologram.gdshader")
  apply_ghost_material(build_ghost)
 build_ghost.visible = ground_target.is_finite()
 if build_ghost.visible:
  build_ghost.position = ground_target
  build_ghost.rotation_degrees.y = build_rotation * 90
  var tint:=Color(0.22,0.94,0.64,0.62) if cached_placement.is_empty() else Color(1,0.24,0.18,0.62)
  construction_material.set_shader_parameter("tint",tint)
  construction_material.set_shader_parameter("animation",0.0 if reduced_motion else 1.0)

func apply_ghost_material(node:Node):
 if node is CollisionObject3D:
  node.collision_layer=0
  node.collision_mask=0
 if node is MeshInstance3D:
  node.material_override=construction_material
  node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 if node is Label3D:node.hide()
 for part in node.get_children():apply_ghost_material(part)

func clear_ghost():
 if is_instance_valid(build_ghost):
  build_ghost.queue_free()
 build_ghost = null
 ground_target = Vector3.INF

func place_building():
 var failure:=placement_status(ground_target,selected_build,build_rotation)
 if not failure.is_empty():
  notify(failure)
  return
 var blueprint: Dictionary = recipes[selected_build]
 if not pay(blueprint.cost):return
 aim_point=ground_target
 rig.action(Rig.Pose.BUILD,0.45)
 sparks_at(ground_target+Vector3.UP*0.4,HUD.ACCENT,true)
 add_structure(selected_build,ground_target,{},0.0,build_rotation)
 update_habitat_walls()
 quest_events[blueprint.name] = true
 selected_build = -1
 clear_ghost()
 refresh_grid()
 last_green_count=-1
 apply_stage()
 play_sound("res://build.wav")
 notify(blueprint.name+" constructed.")
 mark_save()

func dismantle():
 if not is_instance_valid(target) or not target.has_meta("structure"):return
 var index := int(target.get_meta("structure"))
 var unit: Dictionary = structures[index]
 if unit.type==Build.RETURN_VEHICLE and quest_events.get("return_stocked",false):
  notify("The crew manifest is loaded. This vehicle is committed to the return mission.")
  return
 if unit.type == Build.POD:
  notify("The landing pod is your permanent refuge.")
  return
 if unit.type in [Build.HABITAT,Build.FOUNDATION]:
  for other in structures:
   if other==unit:continue
   var offset: Vector3 = other.node.position-unit.node.position
   if unit.type==Build.HABITAT and other.type==Build.DOOR and Vector2(offset.x,offset.z).length()<2.3:
    notify("Dismantle the attached door first.")
    return
   if unit.type==Build.FOUNDATION and absf(offset.x)<2 and absf(offset.z)<2 and offset.y>0.25 and offset.y<0.5:
    notify("Dismantle the structure above this foundation first.")
    return
 var refund: Dictionary = recipes[unit.type].cost.duplicate()
 for item in unit.stored:
  refund[item] = int(refund.get(item,0)) + int(unit.stored[item])
 if unit.seeded:refund.Seed = int(refund.get("Seed",0))+1
 for item in refund.keys():
  if int(refund[item])<=0:refund.erase(item)
 if not Data.transaction(inventory,{},refund,max_cargo()):
  notify("Make backpack space for the refund.")
  return
 rig.action(Rig.Pose.DECONSTRUCT,0.42)
 sparks_at(aim_point,HUD.ALERT,true)
 play_effect("click")
 unit.node.queue_free()
 structures.remove_at(index)
 update_habitat_walls()
 for i in range(structures.size()):structures[i].node.set_meta("structure",i)
 machine = {}
 target = null
 refresh_grid()
 last_green_count=-1
 apply_stage()
 notify("Structure dismantled. Materials returned.")
 mark_save()


func die():
 if dead:return
 dead=true
 var dropped={}
 for ore in inventory.keys():
  if ore=="Seed":continue
  var amount=int(floor(float(inventory[ore])/2))
  inventory[ore]-=amount
  if amount>0:dropped[ore]=amount
 if not dropped.is_empty():add_structure(Build.RECOVERY,Vector3(player.position.x,height_at(player.position.x,player.position.z),player.position.z),dropped)
 if not self_test:save_game()
 show_menu("dead")

func respawn():
 dead=false
 oxygen=max_oxygen()
 water=100
 food=100
 health=100
 mission_exposure=minf(mission_exposure,25)
 player.position=safe_position+Vector3(0,0.3,0)
 player.velocity=Vector3.ZERO
 verify_spawn=true
 update_chunks()
 resume()
 notify("Respawned. Your recovery crate is marked on the map.")

func update_hud(dt:float=0.016):
 if not is_instance_valid(hud):return
 vitals[0].value=food
 vitals[1].value=water
 vitals[2].value=oxygen/max_oxygen()*100
 labels[0].text="FOOD"
 labels[1].text="WATER"
 labels[2].text="%.0f / %.0f"%[oxygen,max_oxygen()]
 for i in range(3):
  var warning:bool=vitals[i].value<20
  var flash:=0.84+0.16*sin(time*7.0) if warning and not reduced_motion else 1.0
  vitals[i].warning=warning
  vitals[i].pulse=flash
  vitals[i].update_fill(dt)
  labels[i].modulate=HUD.ALERT if warning else Color.WHITE
  if warning:labels[i].text="!  "+labels[i].text
 var heading:=fposmod(rad_to_deg(-yaw),360)
 compass.set_heading(heading)
 heading_label.text="%03d°"%int(heading)
 position_label.text="%d:%d:%d   ·   SOL %d   %s"%[roundi(player.position.x),roundi(player.position.y),roundi(player.position.z),Mars.sol(time),Mars.local_clock(time)]
 if health<99.5:position_label.text+="   ·   SUIT %.0f%%"%health
 var ti := terraform_index()
 var waypoint := Vector2.ZERO
 var destination := "LANDING POD"
 if quest_step==5 and not opened_crates.has("0"):
  waypoint=Data.CRATE_POINTS[0]
  destination="SEED CACHE"
 elif quest_step>=6 and quest_step<8 and not opened_crates.has("2"):
  waypoint=Data.CRATE_POINTS[2]
  destination="HIGHLAND CACHE"
 if quest_events.get("beacon_waypoint") is Array and map_waypoint<0:
  waypoint=Vector2(quest_events.beacon_waypoint[0],quest_events.beacon_waypoint[1])
  destination="SURVEY BEACON"
 if map_waypoint>=0:
  waypoint=Survey.SITES[map_waypoint][1]
  destination=Survey.SITES[map_waypoint][0].to_upper()
 if salvage_phase() in [1,2]:
  waypoint=Data.CRATE_POINTS[6] if salvage_phase()==1 else Vector2.ZERO
  destination="FREIGHT WRECK" if salvage_phase()==1 else "UZ-01"
 var offset := waypoint-Vector2(player.position.x,player.position.z)
 var bearing := fposmod(rad_to_deg(atan2(offset.x,-offset.y)),360)
 waypoint_label.text="%s   ·   %03d°   ·   %.0f m"%[destination,int(bearing),offset.length()] if offset.length()>3 else ""
 index_label.text=("%.2f" if ti>0.0 and ti<100.0 else "%.0f")%ti+" Ti"
 nav_label.text="%s   /   %s"%[Progression.NAMES[Progression.stage(ti)],region_name(player.position.x,player.position.z)]
 status_label.text="%+.1f kW available   ·   +%.2f Ti/s"%[power_in-power_out,ti_rate]
 status_label.visible=power_in>0.0 or power_out>0.0
 weather_label.text=("SOLAR STORM" if Mars.solar(time)>0.15 else "RAIN" if Mars.rain_strength(time,ti)>0.15 else "DUST STORM" if Mars.dust(time)>0.15 else "BREATHABLE AIR" if ti>=3500.0 else "THIN CO₂ AIR")+"   ·   P OUTPOST"
 weather_label.modulate=HUD.ALERT if maxf(Mars.solar(time),dust_strength())>0.15 else Color.WHITE
 if salvage_phase() in [1,2,3,4]:
  var remaining:=ceili(420.0-salvage_elapsed())
  weather_label.text=("STORM PEAK IN %d:%02d"%[remaining/60,remaining%60] if remaining>0 else "STORM DEADLINE PASSED")+"  ·  J JOURNAL"
 update_objectives()
 for i in range(hotbar_labels.size()):
  var name: String = hotbar[i]
  hotbar_labels[i].text=str(i+1)
  var tile:=hotbar_labels[i].get_parent() as Panel
  var art:TextureRect=tile.get_node("ItemImage")
  var count:Label=tile.get_node("Count")
  art.texture=icon_texture(name)
  count.text="×%d"%int(inventory.get(name,0)) if not name.is_empty() else ""
  var slot_style:=visor_active if selected_slot==i else visor_idle
  if tile.get_theme_stylebox("panel")!=slot_style:tile.add_theme_stylebox_override("panel",slot_style)
  tile.modulate.a=1.0 if selected_slot==i else 0.76 if not name.is_empty() else 0.40
 refresh_suit_hud()
 if notice_time<=0:
  notice_label.text=""
  pickup_icon.hide()


func notify(text:String,icon_id:String=""):
 if is_instance_valid(polish):polish.push_message(text)
 notice_label.text=text
 if is_instance_valid(pickup_icon):
  pickup_icon.texture=icon_texture(icon_id)
  pickup_icon.visible=not icon_id.is_empty()
 if is_instance_valid(action_notice):action_notice.text=text
 notice_time=5

func save_settings():
 config.set_value("display","fullscreen",DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN)
 config.set_value("input","sensitivity",sensitivity)
 config.set_value("input","invert_y",invert_y)
 config.set_value("display","fov",base_fov)
 config.set_value("game","relaxed",relaxed)
 config.set_value("game","challenge",challenge)
 config.set_value("audio","sfx",sfx_level)
 config.set_value("display","quality",quality)
 config.set_value("display","third_person",third_person)
 config.set_value("display","hud_scale",hud_scale)
 config.set_value("display","reduced_motion",reduced_motion)
 config.set_value("audio","volume",volume)
 config.set_value("audio","music",music_level)
 config.set_value("audio","mission_voice",radio_enabled)
 config.save(SETTINGS)

func load_settings():
 if config.load(SETTINGS)==OK:
  sensitivity=clampf(float(config.get_value("input","sensitivity",0.0022)),0.0007,0.005)
  invert_y=bool(config.get_value("input","invert_y",false))
  base_fov=clampf(float(config.get_value("display","fov",75.0)),60.0,100.0)
  quality=clampi(int(config.get_value("display","quality",2)),0,2)
  third_person=bool(config.get_value("display","third_person",false))
  relaxed=bool(config.get_value("game","relaxed",false))
  challenge=bool(config.get_value("game","challenge",false)) and not relaxed
  sfx_level=clampf(float(config.get_value("audio","sfx",0.8)),0,1)
  hud_scale=clampf(float(config.get_value("display","hud_scale",1.0)),0.78,1.12)
  reduced_motion=bool(config.get_value("display","reduced_motion",false))
  volume=clampf(float(config.get_value("audio","volume",0.78)),0,1)
  music_level=clampf(float(config.get_value("audio","music",0.72)),0.0,1.0)
  radio_enabled=bool(config.get_value("audio","mission_voice",true))
  DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func vector_data(v:Vector3) -> Array:
 return [v.x,v.y,v.z]

func data_vector(values:Array) -> Vector3:
 return Vector3(float(values[0]),float(values[1]),float(values[2]))

func saved_world_position(values:Array,data:Dictionary) -> Vector3:
 var pos:=data_vector(values)
 if not data.get("survey_terrain",false):
  var old_height:=previous_height(pos.x,pos.z) if data.get("mars_terrain",false) else base_height(pos.x,pos.z)
  pos.y+=height_at(pos.x,pos.z)-old_height
 return pos

func mark_save():
 autosave_clock = maxf(autosave_clock,24.25)

func capture_save() -> Dictionary:
 var buildings: Array = []
 for unit in structures:
  buildings.append({"type":unit.type,"position":vector_data(unit.node.position),"stored":unit.stored.duplicate(),"progress":unit.progress,"active":unit.active,"seeded":unit.seeded,"total":unit.total,"angle":unit.angle})
 return {
  "version":2,"seed":seed_value,"position":vector_data(player.position),"refuge":vector_data(safe_position),
  "time":time,"oxygen":oxygen,"water":water,"food":food,"health":health,"terraform":stats(),
  "inventory":inventory.duplicate(),"equipment":equipment.duplicate(),"hotbar":hotbar.duplicate(),"layout":preferred_slots.duplicate(),"slot":selected_slot,
  "depleted":depleted.duplicate(),"buildings":buildings,"opened":opened_crates.duplicate(),"events":quest_events.duplicate(),"quest":quest_step,
  "dead":dead,"won":won,"yaw":yaw,"pitch":pitch,"relaxed":relaxed,"challenge":challenge,"pin":pinned_recipe,"intro_seen":intro_seen,
  "mars_terrain":true,"survey_terrain":true,"waypoint":map_waypoint,"outpost":{"shield":mission_shield,"grow":mission_grow,"radio":mission_radio,"exposure":mission_exposure,"harvest":mission_harvest,"reply":earth_reply_at,"reports":earth_reports}
 }

func save_game(path:String=SAVE) -> bool:
 if ((self_test or render_test or capture_intro) and path==SAVE) or not is_instance_valid(player) or structures.is_empty():return false
 var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
 if not file:
  notify("Save failed. Check access to the game folder.")
  return false
 file.store_string(JSON.stringify(capture_save()))
 file.close()
 if FileAccess.file_exists(path) and not read_save(path).is_empty():
  DirAccess.copy_absolute(path,path+".bak")
 if DirAccess.rename_absolute(path+".tmp",path)!=OK:
  notify("Save failed. Your previous save is available.")
  return false
 return true

func numeric(value:Variant,low:float,high:float) -> bool:
 return (value is int or value is float) and is_finite(float(value)) and float(value)>=low and float(value)<=high

func valid_vector(value:Variant) -> bool:
 return value is Array and value.size()==3 and numeric(value[0],-Survey.HALF-1,Survey.HALF+1) and numeric(value[1],-95,140) and numeric(value[2],-Survey.HALF-1,Survey.HALF+1)

func valid_items(items:Variant) -> bool:
 if not items is Dictionary:return false
 for item in items:
  if item not in ORES and item not in Data.CONSUMABLES and item not in Data.COMPONENTS:return false
  if not numeric(items[item],0,10000) or int(items[item])!=float(items[item]):return false
 return true

func migrate_save(data:Dictionary) -> Dictionary:
 if data.get("version")==1 and data.has("terraform"):
  data.version=2
  data["layout"]=[]
  data["slot"]=0
 return data

func decode_save(raw:Variant) -> Dictionary:
 if not raw is Dictionary:return {}
 var data := migrate_save(raw.duplicate(true))
 if data.get("version")!=2 or data.get("seed")!=seed_value:return {}
 if not valid_vector(data.get("position")) or not valid_vector(data.get("refuge")):return {}
 for stat in ["time","water","food","health","oxygen","yaw","pitch"]:
  if not numeric(data.get(stat),-1000000000,1000000000):return {}
 if not data.get("terraform") is Dictionary:return {}
 for metric in Data.METRICS:
  if not numeric(data.terraform.get(metric),0,10000000):return {}
 if not valid_items(data.get("inventory")) or not data.get("equipment") is Dictionary:return {}
 if Data.slots(data.inventory)>(24 if data.equipment.get("Backpack",0)==1 else 16):return {}
 if not data.get("buildings") is Array or data.buildings.is_empty() or data.buildings.size()>1500:return {}
 var has_pod := false
 for unit in data.buildings:
  if not unit is Dictionary or not numeric(unit.get("type"),0,recipes.size()-1) or not valid_vector(unit.get("position")):return {}
  if int(unit.type)!=float(unit.type) or not numeric(unit.get("angle",0),0,3) or not numeric(unit.get("total",0),0,1000000000):return {}
  if not valid_items(unit.get("stored")) or not numeric(unit.get("progress"),0,10000):return {}
  if unit.type==Build.POD:has_pod=true
 if not has_pod:return {}
 var layout:Variant=data.get("layout",[])
 if not layout is Array:return {}
 for entry in layout:
  if entry==null or entry is String:continue
  if not entry is Dictionary or not entry.get("name") is String or not numeric(entry.get("count"),1,20):return {}
  if int(entry.count)!=float(entry.count):return {}
 for key in data.equipment:
  if not numeric(data.equipment[key],0,1):return {}
 for field in ["opened","events","depleted"]:
  if not data.get(field) is Dictionary:return {}
 for key in data.depleted:
  if not numeric(data.depleted[key],0,1000000000):return {}
 return data

func read_save(path:String) -> Dictionary:
 var file := FileAccess.open(path,FileAccess.READ)
 if not file:return {}
 var parser := JSON.new()
 if parser.parse(file.get_as_text())!=OK:return {}
 return decode_save(parser.data)

func load_game(path:String=SAVE) -> bool:
 var data := read_save(path)
 if data.is_empty():
  data = read_save(path+".bak")
  if not data.is_empty():notify("Recovered the last good expedition save.")
 if data.is_empty():
  if FileAccess.file_exists(path):notify("The save is unreadable. A new expedition is ready.")
  return false
 player.position=saved_world_position(data.position,data)
 verify_spawn=true
 safe_position=saved_world_position(data.refuge,data)
 time=maxf(0,float(data.time))
 intro_seen=bool(data.get("intro_seen",time>0.0))
 map_waypoint=clampi(int(data.get("waypoint",-1)),-1,Survey.SITES.size()-1)
 var outpost:Variant=data.get("outpost",{})
 if outpost is Dictionary:
  mission_shield=bool(outpost.get("shield",false))
  mission_grow=bool(outpost.get("grow",false))
  mission_radio=bool(outpost.get("radio",false))
  mission_exposure=clampf(float(outpost.get("exposure",0)),0,100)
  mission_harvest=clampf(float(outpost.get("harvest",0)),0,1)
  earth_reply_at=clampf(float(outpost.get("reply",-1)),-1,1000000000)
  earth_reports=clampi(int(outpost.get("reports",0)),0,1000000)
 for key in equipment:equipment[key]=1 if data.equipment.get(key,0)==1 else 0
 oxygen=clampf(data.oxygen,0,max_oxygen())
 water=clampf(data.water,0,100)
 food=clampf(data.food,0,100)
 health=clampf(data.health,0,100)
 pressure=data.terraform.Pressure
 heat=data.terraform.Heat
 planet_oxygen=data.terraform.Oxygen
 biomass=data.terraform.Biomass
 inventory.assign(data.inventory)
 depleted.assign(data.depleted)
 opened_crates.assign(data.opened)
 quest_events.assign(data.events)
 sync_exploration_gates()
 quest_step=clampi(int(data.get("quest",0)),0,OBJECTIVES.size())
 dead=bool(data.get("dead",false))
 won=bool(data.get("won",false)) and terraform_index()>=3500
 yaw=float(data.yaw)
 pitch=clampf(data.pitch,-1.15,0.85)
 relaxed=bool(data.get("relaxed",relaxed))
 challenge=bool(data.get("challenge",false)) and not relaxed
 var saved_bar: Variant = data.get("hotbar")
 if saved_bar is Array and saved_bar.size()==6:
  for i in range(6):
   if saved_bar[i] is String and (saved_bar[i].is_empty() or saved_bar[i] in Data.CONSUMABLES):hotbar[i]=saved_bar[i]
 selected_slot=clampi(int(data.get("slot",0)),0,5)
 var pin:Variant=data.get("pin",-1)
 pinned_recipe=int(pin) if numeric(pin,Build.HABITAT,recipes.size()-1) and int(pin)!=Build.RECOVERY else -1
 if data.get("layout") is Array:preferred_slots=data.layout.slice(0,24)
 for unit in data.buildings:
  add_structure(int(unit.type),saved_world_position(unit.position,data),unit.stored,float(unit.progress),int(unit.get("angle",0))%4)
  var restored: Dictionary = structures.back()
  restored.active=bool(unit.get("active",true))
  restored.seeded=bool(unit.get("seeded",false))
  restored.total=float(unit.get("total",0))
 for i in range(discovery_crates.size()):
  if opened_crates.has(str(i)):
   discovery_crates[i].hide()
   discovery_crates[i].collision_layer=0
 stage_index=Data.stage(terraform_index())
 update_habitat_walls()
 return true

func new_game():
 if FileAccess.file_exists(SAVE):DirAccess.copy_absolute(SAVE,SAVE+".before-restart")
 for unit in structures:unit.node.queue_free()
 structures.clear()
 for node in deposits.values():
  if is_instance_valid(node) and node.get_parent()==self:node.queue_free()
 deposits.clear()
 for root in chunks.values():
  remove_child(root)
  root.queue_free()
 chunks.clear()
 depleted.clear()
 opened_crates.clear()
 quest_events.clear()
 sync_exploration_gates()
 for crate in discovery_crates:
  crate.show()
  crate.collision_layer=2 | 8
 reset_supplies()
 for key in equipment:equipment[key]=0
 preferred_slots.clear()
 hotbar=["Oxygen capsule","Water bottle","Food pack","","",""]
 selected_slot=0
 stack_selected=-1
 selected_build=-1
 clear_ghost()
 machine={}
 quest_step=0
 intro_seen=false
 onboarding.reset_guide()
 pinned_recipe=-1
 pending_action=Callable()
 stage_index=0
 last_green_count=-1
 last_low_warning=-30.0
 time=0
 mission_shield=false
 map_waypoint=-1
 mission_grow=false
 mission_radio=false
 mission_exposure=0
 mission_harvest=0
 earth_reply_at=-1
 earth_reports=0
 pressure=0
 heat=0
 planet_oxygen=0
 biomass=0
 oxygen=100
 water=100
 food=100
 health=100
 yaw=PI
 pitch=-0.12
 dead=false
 won=false
 player.position=Vector3(0,0.26,1.2)
 verify_spawn=true
 player.velocity=Vector3.ZERO
 safe_position=player.position
 add_structure(Build.POD,Vector3.ZERO)
 seed_starter_ores()
 restore_survey_deposits()
 update_chunks()
 refresh_grid()
 apply_stage()
 save_game()
 enter_expedition()


func _notification(what):
 if what==NOTIFICATION_WM_CLOSE_REQUEST:
  if capture_intro:return
  save_game()
  get_tree().quit()
 if what==NOTIFICATION_APPLICATION_FOCUS_OUT and not paused and not self_test and not render_test:show_menu("pause")

var passed := 0
var failures := 0

func check(condition:bool,label:String):
 if condition:
  passed+=1
  print("PASS ",label)
 else:
  failures+=1
  push_error("FAIL "+label)

func render_snapshot(name:String):
 await RenderingServer.frame_post_draw
 await RenderingServer.frame_post_draw
 var image:=get_viewport().get_texture().get_image()
 var result:=image.save_png("user://nur-v2-"+name+".png")
 check(result==OK,"Render snapshot "+name)

func run_render_test():
 DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
 DisplayServer.window_set_size(Vector2i(1366,768))
 await RenderingServer.frame_post_draw
 await test_onboarding()
 await test_fullscreen_menu_layout()
 var atlas:AtlasTexture=icon_texture("Cobalt")
 var image:Image=atlas.atlas.get_image()
 var rendered:=0
 for id in icons.textures:
  var thumb:AtlasTexture=icons.textures[id]
  var tile:=image.get_region(Rect2i(thumb.region))
  if tile.get_used_rect().has_area():rendered+=1
 check(rendered==icons.textures.size(),"All %d thumbnail renders contain pixels"%icons.textures.size())
 check(image.save_png("user://nur-v2-atlas.png")==OK,"Render snapshot atlas")
 inventory.merge({"Iron":3,"Silicon":2,"Cobalt":2,"Magnesium":1,"Ice":1,"Titanium":2,"Seed":1},true)
 pressure=51.0
 stage_index=Data.stage(terraform_index())
 show_menu("inventory")
 await render_snapshot("inventory-1366")
 show_menu("craft")
 craft_group=1
 craft_selected=3
 show_menu("craft")
 await render_snapshot("craft-1366")
 build_detail=Build.HEATER
 build_group="Terraforming"
 show_menu("build")
 pin_recipe(Build.HEATER)
 check(pinned_panel.visible and HUD.shortages(inventory,recipes[Build.HEATER].cost)=={"Iridium":1},"Heater pins its live material shortage")
 await render_snapshot("heater-1366")
 DisplayServer.window_set_size(Vector2i(1920,1080))
 player.position=Vector3(15,height_at(15,0)+0.1,0)
 yaw=0
 pitch=-0.29
 var cobalt_pos:=Vector3(15,height_at(15,-2.7),-2.7)
 var visuals_rng:=RandomNumberGenerator.new()
 create_deposit(self,"render:cobalt",cobalt_pos,5,visuals_rng)
 resume()
 Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
 yaw=-0.0
 await get_tree().create_timer(0.24).timeout
 point_camera_at(cobalt_pos+Vector3.UP*0.53)
 await get_tree().physics_frame
 await get_tree().physics_frame
 await render_snapshot("surface-1920")
 Input.action_press("mine")
 var mine_deadline:float=time+3.0
 while deposits.has("render:cobalt") and time<mine_deadline:
  # Keep the test deposit centered while resizing and waiting for the live ray.
  point_camera_at(cobalt_pos+Vector3.UP*0.53)
  await get_tree().physics_frame
 Input.action_release("mine")
 check(not deposits.has("render:cobalt") and inventory.Cobalt==3,"Live physics ray extracts cobalt once")
 await render_snapshot("pickup-1920")
 inventory.Iridium=1
 update_pinned()
 check(HUD.shortages(inventory,recipes[Build.HEATER].cost).is_empty(),"Pinned heater becomes affordable when iridium is collected")
 var candidate:=Vector3.INF
 for angle in range(18):
  for distance in range(4,10):
   var direction:=Vector3.FORWARD.rotated(Vector3.UP,angle*TAU/18)
   var test_point:=player.position+direction*distance
   test_point.y=height_at(test_point.x,test_point.z)
   if valid_build(test_point,Build.HEATER,0):
    candidate=test_point
    break
  if candidate.is_finite():break
 check(candidate.is_finite(),"A clear heater site is available near the test location")
 if candidate.is_finite():
  choose_blueprint(Build.HEATER)
  Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
  ground_target=candidate
  cached_placement=placement_status(candidate,Build.HEATER,0)
  update_ghost()
  check(build_ghost.visible and cached_placement.is_empty(),"Build preview displays the heater on valid terrain")
  var iron_before:int=inventory.Iron
  var silicon_before:int=inventory.Silicon
  place_building()
  check(inventory.Iridium==0 and inventory.Iron==iron_before-1 and inventory.Silicon==silicon_before-1 and structures.back().type==Build.HEATER,"Heater placement spends exactly the live recipe")
  var heater:Dictionary=structures.back()
  add_structure(Build.WIND,candidate+Vector3(3,0,0))
  refresh_grid()
  var before:float=heat
  simulate(0.5)
  animate_machine(heater,0.016)
  check(heater.online and heat>before and heater.node.get_node("StatusLamp").visible,"Powered heater emits heat and lights its status lamp")
  point_camera_at(candidate+Vector3.UP*1.45)
  await get_tree().physics_frame
  await render_snapshot("heater-online-1920")
  heater.active=false
  before=heat
  simulate(0.5)
  animate_machine(heater,0.016)
  check(not heater.online and heat==before and not heater.node.get_node("StatusLamp").visible,"Heater stops generating heat when disabled")
 await test_live_rock_collision()
 await test_lander_hatch()
 rig.action(Rig.Pose.JUMP,0.25)
 pitch=-1.0
 await render_snapshot("suit-1920")
 show_menu("map")
 await render_snapshot("relief-map-1920")
 show_menu("outpost")
 await render_snapshot("outpost-1920")
 await test_survey_cave()
 await test_survey_cave(32,"Osmium")
 await test_survey_cave(33,"Uranium")
 for cache_id in [6,7]:
  target=discovery_crates[cache_id]
  var loot:Dictionary=Data.CRATE_ITEMS[cache_id]
  var item:String=loot.keys()[0]
  var before:int=inventory.get(item,0)
  interact()
  interact()
  check(int(inventory.get(item,0))==before+int(loot[item]) and opened_crates.has(str(cache_id)),"Wreck cache %d grants its salvage once"%cache_id)
 await test_distant_terrain()
 await test_storm_salvage()
 await test_expansion_phases()
 polish.test_systems()
 show_menu("equipment")
 await render_snapshot("final-equipment")
 DisplayServer.window_set_size(Vector2i(1366,768))
 await render_snapshot("final-equipment-1366")
 show_menu("settings")
 await render_snapshot("final-settings-1366")
 DisplayServer.window_set_size(Vector2i(1920,1080))
 show_menu("archive")
 await render_snapshot("final-archives")
 show_menu("main")
 await render_snapshot("final-title")
 await polish.profile_rendered_session()
 show_menu("settings")
 await render_snapshot("upgrade-settings-1920")
 DisplayServer.window_set_size(Vector2i(1366,768))
 await render_snapshot("upgrade-settings-1366")
 inventory={"Iron":19,"Cobalt":6,"Circuit board":1}
 preferred_slots=[]
 split_stack(0)
 stack_selected=0
 show_menu("inventory")
 await render_snapshot("upgrade-split-inventory-1366")
 inventory.Cobalt=12
 craft_group=0
 craft_selected=0
 craft_quantity=5
 show_menu("craft")
 await render_snapshot("upgrade-batch-craft-1366")
 resume()
 player.position=Vector3(70,height_at(70,160)+0.15,160)
 point_camera_at(Vector3(105,-3,100))
 paused=true
 clear_overlay()
 hud.hide()
 for i in range(Progression.NAMES.size()):
  apply_stage(125.0,Progression.THRESHOLDS[i]+1.0)
  await render_snapshot("upgrade-stage-%02d"%i)
 point_camera_at(player.position+Vector3(0,18,-32))
 for sky_time in [0.0,150.0,230.0]:
  apply_stage(sky_time,0.0)
  await get_tree().create_timer(2.0).timeout
  await render_snapshot("restored-sky-%d"%sky_time)
 show_menu("inventory")
 print("NASAFORMATION RENDER TEST: %s passed, %s failed"%[passed,failures])
 get_tree().quit(0 if failures==0 else 1)

func test_onboarding():
 var starting_time:float=time
 var starting_oxygen:float=oxygen
 var starting_position:Vector3=player.position
 begin_intro()
 check(onboarding.intro_active and onboarding.camera.current and not hud.visible,"Starting an expedition opens the cinematic instead of moving the player")
 await get_tree().create_timer(2.8).timeout
 await render_snapshot("intro-arrival-1366")
 check(FileAccess.file_exists("res://voice/arrival.wav") and onboarding.player.stream!=null,"The first cinematic shot has bundled narration")
 for shot in range(1,Onboarding.SHOTS.size()):
  onboarding.tick(onboarding.duration,true)
  check(onboarding.shot_index==shot and onboarding.player.stream!=null,"Cinematic shot %d has bundled narration"%(shot+1))
  if shot==2:
   await get_tree().create_timer(0.8).timeout
   await render_snapshot("intro-pod-1366")
  if shot==3:
   await get_tree().create_timer(0.8).timeout
   await render_snapshot("intro-dust-1366")
  if shot==4:
   onboarding.tick(onboarding.duration*0.53,true)
   await get_tree().create_timer(0.50).timeout
   check(lake.visible and rain.emitting,"Intro previews a filled lake and rain without changing the expedition")
   await render_snapshot("intro-terraform-1366")
 var skip:=InputEventKey.new()
 skip.keycode=KEY_ESCAPE
 skip.pressed=true
 _input(skip)
 check(not paused and not onboarding.intro_active and camera.current and hud.visible and intro_seen,"Escape returns to the player camera and marks the intro as seen")
 check(is_equal_approx(time,starting_time) and oxygen==starting_oxygen and player.position.is_equal_approx(starting_position),"The cinematic uses no survival time, oxygen, or movement")
 show_menu("pause")
 begin_intro("pause")
 onboarding.finish_intro()
 check(menu=="pause" and camera.current,"Replaying the intro returns to the pause menu")
 resume()
 for step in range(OBJECTIVES.size()):
  onboarding.guide_objective(step)
  check(onboarding.player.stream!=null and onboarding.caption_box.visible,"Objective %d has audio and subtitles"%(step+1))
 onboarding.alert("low_air")
 check(onboarding.current=="low_air" and onboarding.player.stream!=null,"A low oxygen warning can interrupt guidance")
 show_menu("main")
 check(onboarding.player.stream_paused and not onboarding.caption_box.visible,"Pausing hides captions and pauses the mission voice")
 onboarding.reset_guide()

func test_fullscreen_menu_layout():
 DisplayServer.window_set_size(Vector2i(1440,900))
 show_menu("main")
 await get_tree().process_frame
 var emblem:=overlay.get_node("ExpeditionEmblem") as TextureRect
 check(emblem.size.is_equal_approx(Vector2(493,493)) and emblem.texture!=null,"Logo stays fully inside its intended frame at 16:10")
 check(get_window().content_scale_aspect==Window.CONTENT_SCALE_ASPECT_IGNORE,"The viewport fills non-16:9 displays")
 await render_snapshot("menu-16x10")
 DisplayServer.window_set_size(Vector2i(1366,768))


func point_camera_at(point:Vector3):
 var vector:=point-camera.global_position
 yaw=atan2(-vector.x,-vector.z)
 pitch=atan2(vector.y,Vector2(vector.x,vector.z).length())

func test_lander_hatch():
 var entrance:=Vector3(0,0.04,4.05)
 player.position=entrance
 player.velocity=Vector3.ZERO
 player.reset_physics_interpolation()
 yaw=0
 await get_tree().physics_frame
 await get_tree().physics_frame
 Input.action_press("forward")
 for i in range(48):await get_tree().physics_frame
 Input.action_release("forward")
 check(player.position.z<1.75 and player.position.y>=0.19 and player.is_on_floor(),"Walk up the UZ-01 ramp and enter without jumping")
 oxygen=58
 simulate(0.5)
 check(oxygen>58,"UZ-01 refills oxygen after walking through its hatch")

func test_expansion_phases():
 var a:=BASIN+Vector2(0,-70)
 var b:=BASIN+Vector2(0,70)
 lake.hide()
 var dry:=survey_trip_metres(a,b)
 check(trip_basin_route(a,b).is_empty(),"Dry route crosses the basin before the lake forms")
 apply_stage(12,1400)
 check(flooded_ground(Vector3(BASIN.x,-7,BASIN.y)) and trip_basin_route(a,b).size()>3 and survey_trip_metres(a,b)>dry,"Flooded crossing recommends a longer dry rim route")
 var before_o2:=outdoor_oxygen_rate()/walk_speed()
 equipment["Air filter"]=1
 equipment["Agility boots"]=1
 check(outdoor_oxygen_rate()/walk_speed()<before_o2*0.70,"The planner shares the suit drain and walking speed used by movement")
 equipment["Air filter"]=0
 equipment["Agility boots"]=0
 apply_stage()

 heat=0
 sync_exploration_gates()
 check(ice_gate.visible and ice_gate.collision_layer==8,"The cold cave branch has solid ice")
 heat=CAVE_WARMTH
 sync_exploration_gates()
 check(not ice_gate.visible and ice_gate.collision_layer==0 and survey_deposits.has("survey:31:6"),"Warming opens the ice branch and reveals rare ore")
 var spawn:=Vector2(239,172.7)
 player.position=Vector3(spawn.x,height_at(spawn.x,spawn.y)+0.20,spawn.y)
 player.velocity=Vector3.ZERO
 player.reset_physics_interpolation()
 yaw=0.0
 pitch=-0.12
 update_chunks()
 resume()
 Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
 await get_tree().physics_frame
 Input.action_press("forward")
 for i in range(95):await get_tree().physics_frame
 Input.action_release("forward")
 check(player.position.z<169.0 and player.position.z>162.2,"Astronaut walks into the wreck bay and stops at the unpowered hatch")
 inventory["Portable power cell"]=1
 target=cargo_gate
 interact()
 check(cargo_gate.collision_layer==0 and int(inventory.get("Portable power cell",0))==0,"The hatch opens after spending a single power cell")
 inventory.erase("Osmium")
 target=cargo_cache
 interact()
 interact()
 check(int(inventory.get("Osmium",0))==2 and quest_events.cargo_claimed and decode_save(capture_save()).events.cargo_unlocked,"Compartment loot is awarded once and its open state is saved")
 await render_snapshot("east-wreck-bay")

 pressure=1751
 won=true
 time=0.0
 var craft:=add_structure(Build.RETURN_VEHICLE,Vector3(15,0,6))
 player.position=Vector3(15,0.2,9)
 player.reset_physics_interpolation()
 inventory.merge(Data.RETURN_SUPPLIES,true)
 stock_return_vehicle()
 mission_power["radio"]=true
 request_launch()
 tick_launch_reply()
 check(not can_board(),"Boarding stays locked before the round-trip delay")
 time=Mars.EARTH_ROUND_TRIP
 mission_power["radio"]=false
 tick_launch_reply()
 check(not can_board(),"The launch reply waits for radio power")
 mission_power["radio"]=true
 tick_launch_reply()
 check(can_board(),"Powered radio delivers clearance after the delay")
 board_for_earth()
 check(menu=="departure" and is_instance_valid(departure_model),"Boarding starts the animated departure")
 await render_snapshot("earth-return-launch")
 finish_departure()
 check(menu=="earth_arrival" and decode_save(capture_save()).events.earth_returned,"Earth arrival sets a save-compatible completion flag")
 await render_snapshot("earth-arrival")
 craft.show()

func test_storm_salvage():
 quest_events.clear()
 inventory.clear()
 opened_crates.erase("6")
 var origin:float=time
 start_salvage()
 var wreck:Vector2=Data.CRATE_POINTS[6]
 player.position=Vector3(wreck.x,height_at(wreck.x,wreck.y)+0.05,wreck.y)
 target=discovery_crates[6]
 interact()
 advance_salvage()
 check(salvage_phase()==2 and inventory.get("Circuit board",0)==1,"Storm salvage advances after visiting the wreck and collecting the board")
 player.position=Vector3(0,0.25,1)
 install_salvage()
 check(salvage_phase()==3 and inventory.get("Circuit board",0)==0,"Returning to UZ-01 installs the board once")
 var saved:=decode_save(capture_save())
 check(not saved.is_empty() and saved.events.salvage_phase==3 and saved.events.salvage_start==origin,"Storm mission phase and active countdown are included in the save")
 choose_salvage_power("shield")
 check(salvage_phase()==3,"Reserve choice waits for storm peak")
 for system in ["shield","food","radio"]:
  time=origin+565.0
  quest_events.salvage_phase=3
  choose_salvage_power(system)
  var online:=0
  for powered in mission_power.values():
   if powered:online+=1
  check(salvage_phase()==4 and online==1 and mission_power.get(system,false),"Late arrival can reserve power for %s alone"%system)
  time+=75.0
  simulate_outpost(75.0,true)
  advance_salvage()
  check(salvage_phase()==5 and not str(quest_events.salvage_result).is_empty(),"Reserve trial completes with a consequence for %s"%system)
 show_menu("atlas")
 await render_snapshot("nasa-orbital-atlas")
 show_menu("nasa_sky")
 await render_snapshot("nasa-curiosity-sky")

func test_distant_terrain():
 var old_quality:int=quality
 quality=0
 player.position=Vector3(-116,height_at(-116,158)+1,158)
 player.velocity=Vector3.ZERO
 player.reset_physics_interpolation()
 update_chunks()
 yaw=-0.55
 pitch=-0.14
 await get_tree().physics_frame
 var key:=Vector2i(0,0)
 check(not chunks.has(key) and is_instance_valid(surface_tiles.get(key)) and surface_tiles[key].visible,"The landing valley still draws after its gameplay chunk unloads on Low")
 var adjacent:=Vector2i(1,0)
 var left:PackedVector3Array=surface_tiles[key].mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
 var right:PackedVector3Array=surface_tiles[adjacent].mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
 var joined:=true
 for row in range(21):
  joined=joined and (left[row*21+20]+surface_tiles[key].position).is_equal_approx(right[row*21]+surface_tiles[adjacent].position)
 check(joined,"Adjacent terrain tiles share every edge vertex")
 await render_snapshot("zeolite-to-landing-valley-low")
 quality=old_quality

func test_survey_cave(site_index:int=15,ore:String="Iridium"):
 var site:Vector2=Survey.SITES[site_index][1]
 player.position=Vector3(site.x,height_at(site.x,site.y+4.8)+0.1,site.y+4.8)
 player.velocity=Vector3.ZERO
 player.reset_physics_interpolation()
 yaw=0.0
 pitch=-0.18
 update_chunks()
 resume()
 Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
 await get_tree().physics_frame
 await get_tree().physics_frame
 Input.action_press("forward")
 for frame in range(115):await get_tree().physics_frame
 Input.action_release("forward")
 var sample:Node3D=deposits.get("survey:%d:2"%site_index)
 check(player.position.z<site.y-1.1 and is_instance_valid(sample) and ORES[sample.get_meta("ore")]==ore,"%s has a walk-in passage and %s"%[Survey.SITES[site_index][0],ore])
 await render_snapshot("cave-%d"%site_index)

func test_live_rock_collision():
 var ore:=Vector3(11,height_at(11,1),1)
 player.position=ore+Vector3(0,0.2,2.4)
 player.velocity=Vector3.ZERO
 player.reset_physics_interpolation()
 yaw=0
 pitch=-0.22
 var random:=RandomNumberGenerator.new()
 random.seed=663
 create_deposit(self,"render:solid_ore",ore,0,random)
 await get_tree().physics_frame
 await get_tree().physics_frame
 var initial_z:=player.position.z
 Input.action_press("forward")
 for frame in range(42):await get_tree().physics_frame
 Input.action_release("forward")
 check(player.position.z<initial_z-0.48 and player.position.z>ore.z+0.53,"Walking stops against a mineable deposit")
 check(rig.pose in [Rig.Pose.IDLE,Rig.Pose.WALK],"Animation uses resolved movement at obstacles")
 player.position=ore+Vector3.UP*0.11
 verify_spawn=true
 await get_tree().physics_frame
 await get_tree().physics_frame
 check(Vector2(player.position.x-ore.x,player.position.z-ore.z).length()>0.60,"Saved positions inside a deposit recover to clear ground")
 var stone:=visuals.textured_finish(visuals.surface(Color("61534f"),0.05,0.9,0,true),"stone")
 var rock:=visuals.facet(self,Vector3(-6,0.22,0),Vector3(1.39,1.89,1.34),stone,6777,12)
 var obstacle:=solid_scenery(rock)
 player.position=Vector3(-6,0.12,3.4)
 player.velocity=Vector3.ZERO
 player.reset_physics_interpolation()
 await get_tree().physics_frame
 await get_tree().physics_frame
 Input.action_press("sprint")
 Input.action_press("forward")
 await get_tree().create_timer(0.77).timeout
 Input.action_release("sprint")
 Input.action_release("forward")
 check(player.position.z>0.75 and player.position.z<2.45,"Sprinting stops at the visible boulder")
 await render_snapshot("boulder-1920")
 obstacle.queue_free()
 rock.queue_free()
 player.position=Vector3(-9,0.15,4.4)
 player.velocity=Vector3.ZERO
 player.reset_physics_interpolation()
 await get_tree().create_timer(0.20).timeout
 Input.action_press("jump")
 await get_tree().physics_frame
 await get_tree().physics_frame
 Input.action_release("jump")
 await get_tree().create_timer(0.22).timeout
 check(rig.pose==Rig.Pose.JUMP and player.position.y>0.70,"Jump enters the airborne pose with real upward movement")
 await get_tree().create_timer(0.93).timeout
 check(player.is_on_floor() and rig.pose==Rig.Pose.IDLE,"Landing returns to the grounded idle pose")

func test_outpost_tradeoffs():
 var solar_array:=add_structure(Build.SOLAR,Vector3(25,0,24))
 time=0.0
 mission_shield=true
 mission_grow=true
 mission_radio=true
 refresh_grid()
 var clear_power:float=power_in
 check(mission_power.get("radio",false) and mission_power.get("food",false),"Clear skies supply food and radio when the solar array has enough power")
 time=170.0
 refresh_grid()
 check(power_in<clear_power*0.20 and mission_power.get("shield",false) and not mission_power.get("food",false),"Dust lowers solar output and forces a life-support power choice")
 simulate_outpost(10.0,true)
 check(mission_harvest==0.0,"The greenhouse stops growing when it loses power")
 time=0.0
 refresh_grid()
 simulate_outpost(70.0,true)
 check(mission_harvest==1.0,"Powered grow lights produce a harvest")
 earth_reply_at=Mars.EARTH_ROUND_TRIP
 simulate_outpost(0.5,true)
 check(earth_reports==0,"Earth does not reply before both signal legs have elapsed")
 time=earth_reply_at
 simulate_outpost(0.5,true)
 check(earth_reports==1 and earth_reply_at<0.0,"Earth acknowledges the report after the round-trip delay")
 structures.pop_back()
 solar_array.free()
 time=0.0
 mission_shield=false
 mission_grow=false
 mission_radio=false
 mission_exposure=0.0
 mission_harvest=0.0
 earth_reports=0
 quest_events.clear()
 notice_label.text=""
 notice_time=0
 refresh_grid()

func test_expansion_recipes():
 var before_inventory:=inventory.duplicate()
 inventory.merge({"Titanium":4,"Magnesium":2,"Silicon":4,"Aluminum":2,"Iridium":2},true)
 check(craft_recipe(6) and equipment["Agility boots"]==1,"Agility boots consume materials and install on the suit")
 check(not craft_recipe(8),"A jetpack recipe stays locked before Blue Haze")
 check(craft_recipe(11) and inventory.get("Circuit board",0)==1,"The components tab crafts a circuit board")
 inventory=before_inventory
 equipment["Agility boots"]=0
 quest_events.clear()
 notice_label.text=""
 var generator:=add_structure(Build.WIND_2,Vector3(31,0,24))
 var grower:=add_structure(Build.FOOD,Vector3(33,0,24))
 var purifier:=add_structure(Build.FILTER,Vector3(35,0,24))
 structures[1].progress=54.8
 structures[2].progress=54.8
 simulate(0.25)
 check(structures[1].stored.get("Food pack",0)==1 and structures[2].stored.get("Purified Water",0)==1,"New powered machines store food and purified water")
 for node in [purifier,grower,generator]:
  structures.pop_back()
  node.free()
 refresh_grid()

func test_final_upgrade():
 polish.test_systems()
 var saved_inventory:=inventory.duplicate(true)
 var saved_layout:=preferred_slots.duplicate(true)
 inventory={"Iron":19,"Cobalt":6}
 preferred_slots=[]
 check(split_stack(0),"Inventory splits a stack into an empty slot")
 var grid:=stack_grid()
 var total:=0
 for entry in grid:
  if entry!=null:total+=entry.count
 check(total==25 and inventory.Iron==19 and grid[0].count==10,"Odd split preserves item totals")
 move_inventory_stack(2,0)
 check(stack_grid()[0].count==19 and inventory.Iron==19,"Stack merging preserves the aggregate inventory")
 preferred_slots=["Cobalt","Iron"]
 check(stack_grid()[0].name=="Cobalt","Legacy string layouts remain compatible")
 inventory={"Iron":320}
 preferred_slots=[]
 check(not split_stack(0),"Split rejects a full inventory without losing items")
 inventory={"Iron":19,"Cobalt":6}
 preferred_slots=[]
 split_stack(0)
 var encoded:=capture_save()
 if encoded.buildings.is_empty():encoded.buildings=[{"type":Build.POD,"position":[0,0,0],"stored":{},"progress":0.0}]
 check(not decode_save(encoded).is_empty() and decode_save(encoded).layout[0].count==10,"Split counts survive save decoding")
 var broken:=encoded.duplicate(true)
 broken.layout=[{"name":"Iron","count":"broken"}]
 check(decode_save(broken).is_empty(),"Malformed optional stack counts are rejected safely")
 var old:=encoded.duplicate(true)
 old.version=1
 decode_save(old)
 check(old.version==1,"Save migration does not mutate the caller's source data")
 inventory=saved_inventory
 preferred_slots=saved_layout
 var before_batch:=inventory.duplicate(true)
 inventory={"Cobalt":12}
 check(craft_recipe(0,5) and inventory.Cobalt==2 and inventory["Oxygen capsule"]==5,"Batch crafting spends five recipes in one transaction")
 var before_failure:=inventory.duplicate(true)
 check(not craft_recipe(0,5) and inventory==before_failure,"An unaffordable batch leaves inventory unchanged")
 check(not craft_recipe(0,0) and not craft_recipe(3,5),"Invalid quantities and equipment batches are rejected")
 inventory=before_batch
 var stages_ok:=true
 for i in range(Progression.THRESHOLDS.size()):
  stages_ok=stages_ok and Progression.stage(Progression.THRESHOLDS[i])==i
  if i>0:stages_ok=stages_ok and Progression.stage(Progression.THRESHOLDS[i]-0.01)==i-1
 check(stages_ok and Progression.progress(3500)==1.0,"Nine visual milestones have precise monotonic boundaries")
 check(Progression.progress(250)==0.5 and Mars.rain_strength(125,600)==0 and Mars.rain_strength(125,1000)>0,"Visual progress and fictional rain interpolate gradually")
 Input.action_press("mine")
 Input.action_press("forward")
 show_menu("inventory")
 check(not Input.is_action_pressed("mine") and not Input.is_action_pressed("forward"),"Modal entry releases held movement and mining")
 var saved_fov:=base_fov
 var saved_invert:=invert_y
 base_fov=92
 invert_y=true
 save_settings()
 base_fov=75
 invert_y=false
 load_settings()
 check(base_fov==92 and invert_y,"FOV and inverted mouse persist in settings")
 base_fov=saved_fov
 invert_y=saved_invert
 save_settings()

func run_tests():
 test_final_upgrade()
 var ice_contact:=Audio.mining("ice",false)
 var metal_contact:=Audio.mining("metal",false)
 var ice_break:=Audio.mining("ice",true)
 check(ice_contact.loop_mode==AudioStreamWAV.LOOP_FORWARD and ice_break.loop_mode==AudioStreamWAV.LOOP_DISABLED and ice_contact.data!=metal_contact.data and ice_break.get_length()>0.3,"Mining contact loops by material and fracture plays once")
 check(Mars.sol(Mars.SOL_SECONDS)==2 and Mars.local_clock(Mars.SOL_SECONDS)=="08:00","Sol clock rolls over after six active minutes")
 check(Mars.dust(168.0)>0.99 and Mars.dust(0.0)==0.0 and Mars.solar(460.0)>0.95,"Dust and solar events follow independent sol schedules")
 check(Mars.exposure_per_second(460.0,true,true)<Mars.exposure_per_second(460.0,false,false)*0.15,"Powered shielding reduces storm exposure inside shelter")
 check(Mars.rain_strength(125,0)==0 and Mars.rain_strength(125,1800)>0.95 and Mars.rain_strength(200,3500)==0,"Rain is a late-stage event with a separate weather window")
 check(Survey.SITES.size()==36 and Survey.CAVES.size()==6 and valid_vector([309,20,-273]),"The expanded survey and faraway saves are supported")
 test_expansion_recipes()
 test_outpost_tradeoffs()
 var catalog_valid:=visuals.resources.size()==ORES.size()
 for id in ORES:
  catalog_valid=catalog_valid and visuals.resources.has(id) and icon_texture(id)!=null
 for recipe in Data.CRAFTS:
  catalog_valid=catalog_valid and icon_texture(recipe.name)!=null
  for item in recipe.cost:catalog_valid=catalog_valid and icon_texture(item)!=null
 for index in range(recipes.size()):
  catalog_valid=catalog_valid and icon_texture(structure_key(index))!=null
  for item in recipes[index].cost:catalog_valid=catalog_valid and icon_texture(item)!=null
 check(catalog_valid,"Every item, machine and recipe ingredient resolves to a thumbnail")
 var heater:Dictionary=recipes[Build.HEATER]
 var shortage:=HUD.shortages({"Iron":3,"Silicon":2},heater.cost)
 check(shortage=={"Iridium":1} and HUD.shortages({"Iron":3,"Silicon":2,"Iridium":1},heater.cost).is_empty(),"Pinned heater shortages update from inventory")
 check(output_text(heater)=="Heat +0.30/s" and float(heater.power)==-1.0,"Heater tooltip uses the live balance data")
 var cobalt_card:=HUD.resource_card(visuals.resources.Cobalt,true,0.65)
 check(cobalt_card.id=="Cobalt" and cobalt_card.body.contains("0.65 s") and cobalt_card.hint=="Hold LMB to mine","Cobalt card displays the right identity and harvest duration")
 check(HUD.resource_card(visuals.resources.Cobalt,false,0.65).hint.contains("Backpack full"),"Target card warns about full cargo")
 check(Rig.movement_pose(0.0,true,false,false,-1)==Rig.Pose.IDLE and Rig.movement_pose(5.0,true,false,false,-1)==Rig.Pose.WALK,"Rig transitions between idle and walk")
 check(Rig.movement_pose(8.2,true,false,false,-1)==Rig.Pose.SPRINT and Rig.movement_pose(1.0,false,false,false,-1)==Rig.Pose.JUMP,"Rig selects sprint and airborne poses")
 check(Rig.movement_pose(1.0,true,true,false,-1)==Rig.Pose.MINE and Rig.movement_pose(0.0,true,false,false,Rig.Pose.INTERACT)==Rig.Pose.INTERACT,"Mining and interaction override walking")
 var resource_body:=StaticBody3D.new()
 resource_body.collision_layer=2
 add_child(resource_body)
 var wall:=StaticBody3D.new()
 wall.collision_layer=8
 add_child(wall)
 var visible_hit:={"collider":resource_body,"position":Vector3(0,0,-2)}
 var wall_hit:={"collider":wall,"position":Vector3(0,0,-1)}
 check(target_from_hits(visible_hit,{},Vector3.ZERO)==resource_body and target_from_hits(visible_hit,wall_hit,Vector3.ZERO)==null,"Ray target respects a nearer wall")
 check(target_from_hits({"collider":resource_body,"position":Vector3(0,0,-4)}, {},Vector3.ZERO)==null,"Ray target is limited to 3.5 metres")
 resource_body.queue_free()
 wall.queue_free()
 var items := {"Iron":20}
 check(not Data.transaction(items,{"Iron":1},{"Water bottle":1},1) and items=={"Iron":20},"Full backpack rolls back an atomic craft")
 check(not Data.transaction(items,{"Iron":-1},{},16) and items.Iron==20,"Negative costs cannot create resources")
 check(Data.transaction(items,{"Iron":20},{"Water bottle":1},1) and items["Water bottle"]==1,"A craft can reuse a freed slot")
 inventory.Cobalt=2
 inventory["Oxygen capsule"]=0
 check(craft_recipe(0) and inventory.Cobalt==0 and inventory["Oxygen capsule"]==1,"Craft oxygen capsule with exact ingredients")
 oxygen=10
 check(use_item("Oxygen capsule") and oxygen==70,"Consume a capsule and restore 60 oxygen")
 inventory.assign({"Iron":3,"Titanium":1,"Silicon":1})
 check(craft_recipe(4) and max_cargo()==24,"Backpack upgrade increases slots")
 add_structure(Build.POD,Vector3.ZERO)
 add_structure(Build.DRILL,Vector3(5,0,0))
 add_structure(Build.TUBE,Vector3(8,0,0))
 player.position=Vector3(0,0,1)
 refresh_grid()
 simulate(0.5)
 check(not structures[1].online and pressure==0,"Drill produces nothing during a power shortage")
 add_structure(Build.WIND,Vector3(-5,0,0))
 simulate(0.5)
 check(structures[1].online and pressure>0 and planet_oxygen==0,"Power returns and an unseeded vegetube produces zero oxygen")
 machine=structures[2]
 inventory.Seed=1
 check(toggle_seed() and inventory.Seed==0 and machine.seeded,"Installing a seed consumes one seed")
 simulate(0.5)
 check(planet_oxygen>0 and terraform_index()>0,"Seeded vegetube and drill increase TI")
 structures[1].active=false
 var previous: float = pressure
 simulate(0.5)
 check(pressure==previous and not structures[1].online,"Switched-off machine produces nothing")
 check(Data.stage(99.9)==0 and Data.stage(100)==1 and Data.stage(900)==3 and Data.stage(3500)==5,"Campaign thresholds unlock at the correct TI")
 inventory.Iron=10
 check(not valid_build(Vector3(0,0,0),Build.WIND,0) and inventory.Iron==10,"Invalid placement leaves inventory untouched")
 check(valid_build(Vector3(0,0,6),Build.WIND,0),"Flat clear ground accepts a turbine preview")
 check(not valid_build(Vector3(0,0,6),Build.DRILL_2,0),"Placement rejects locked machinery")
 selected_build=Build.WIND
 ground_target=Vector3(0,0,6)
 place_building()
 check(structures.size()==5 and inventory.Iron==9 and absf(power_in-2.4)<0.001,"Placement spends the exact cost and updates the grid")
 var random := RandomNumberGenerator.new()
 create_deposit(self,"test",Vector3(1,0,3),0,random)
 var deposit: Node3D=deposits.test
 check(mine(deposit) and not mine(deposit) and inventory.Iron==10,"Each deposit transfers one item per spawn")
 oxygen=0
 player.position=Vector3(20,0,10)
 var before: float = health
 simulate(0.5)
 check(not dead and health<before,"Zero oxygen causes damage over time")
 player.position=Vector3(0,0.35,0.5)
 simulate(0.5)
 check(oxygen>0,"The unpowered pod refills oxygen")
 pressure=460
 stage_index=Data.stage(terraform_index())
 apply_stage()
 check(lake.visible and stage_index==3,"Liquid Water reveals the 3D lake")
 pressure=1750
 simulate(0.5)
 apply_stage()
 check(greenery.multimesh.visible_instance_count>0 and stage_index==5 and won and menu=="victory","Living Planet displays vegetation and opens the victory screen")
 var stored := capture_save()
 var previous_save := stored.duplicate(true)
 previous_save.erase("pin")
 check(not decode_save(previous_save).is_empty(),"Existing version 2 saves load without a pin field")
 previous_save.version=1
 check(decode_save(previous_save).get("version")==2,"Earlier save version migrates")
 var decoded := decode_save(JSON.parse_string(JSON.stringify(stored)))
 check(not decoded.is_empty() and decoded.buildings.size()==5 and decoded.terraform.Pressure==1750,"Versioned save round-trips world and TI")
 check(decode_save({"version":2,"seed":seed_value}).is_empty() and decode_save(null).is_empty(),"Corrupt saves are rejected")
 target=discovery_crates[0]
 interact()
 var seed_count := int(inventory.get("Seed",0))
 interact()
 check(seed_count>=2 and inventory.Seed==seed_count and opened_crates.has("0"),"A discovery cache awards its loot once")
 show_menu("craft")
 show_menu("inventory")
 show_menu("build")
 show_menu("map")
 show_menu("settings")
 show_menu("journal")
 show_menu("terraform")
 show_menu("machine")
 show_menu("victory")
 clear_overlay()
 var path := "user://nur-self-test-%s.json"%Time.get_ticks_usec()
 check(save_game(path),"Save writes the expedition to disk")
 inventory.Iron+=1
 check(save_game(path),"Saving again replaces the file and retains a backup")
 var corrupt := FileAccess.open(path,FileAccess.WRITE)
 corrupt.store_string("truncated save")
 corrupt.close()
 for unit in structures:unit.node.queue_free()
 structures.clear()
 check(load_game(path) and pressure==1750 and inventory.Iron==10 and structures[2].seeded and opened_crates.has("0"),"Reload recovers the previous save with position, stations, seeds and loot")
 DirAccess.remove_absolute(path)
 DirAccess.remove_absolute(path+".bak")
 machine.clear()
 structures.clear()
 target=null
 mining_target=null
 await get_tree().process_frame
 print("NASAFORMATION SELF TEST: %s passed, %s failed"%[passed,failures])
 get_tree().quit(0 if failures==0 else 1)


func setup_audio():
 exploration_music=load_music("traverse")
 action_music=load_music("response")
 ambience=AudioStreamPlayer.new()
 ambience.stream=load("res://wind.wav")
 ambience.volume_db=-24
 add_child(ambience)
 ambience.play()
 sfx=AudioStreamPlayer.new()
 sfx.volume_db=-13
 add_child(sfx)
 for effect in ["step_dust","step_stone","step_metal","step_water","click","machine","breath"]:
  effects[effect]=Audio.synthesize(effect)
 for kind in ["rock","metal","ice","sample"]:
  mining_contacts[kind]=Audio.mining(kind,false)
  mining_fractures[kind]=Audio.mining(kind,true)
 sfx_mine=AudioStreamPlayer.new()
 sfx_mine.volume_db=-13
 add_child(sfx_mine)
 sfx_machine=AudioStreamPlayer.new()
 sfx_machine.stream=effects.machine
 sfx_machine.volume_db=-60
 add_child(sfx_machine)
 sfx_machine.play()
 apply_volume()

func mining_sound_material(item:String) -> String:
 if item=="Ice":return "ice"
 if item=="Seed":return "sample"
 if item in ["Iron","Titanium","Cobalt","Aluminum","Osmium","Iridium","Uranium"]:return "metal"
 return "rock"

func load_music(stem:String) -> AudioStreamPlayer:
 var track:=AudioStreamPlayer.new()
 var sound:=AudioStreamOggVorbis.load_from_file(ProjectSettings.globalize_path("res://music/"+stem+".ogg"))
 if sound:sound.loop=true
 track.stream=sound
 track.volume_db=-60
 add_child(track)
 if sound:track.play()
 return track

func update_score(dt:float):
 if not is_instance_valid(exploration_music):return
 var danger:=maxf(dust_strength(),Mars.solar(time)) if not paused else 0.0
 if not paused and oxygen/max_oxygen()<0.22:danger=maxf(danger,0.7)
 if not paused and rig.pose in [Rig.Pose.SPRINT,Rig.Pose.MINE]:danger=maxf(danger,0.4)
 if onboarding.intro_active:danger=0.95 if onboarding.shot_index in [0,3] else 0.38
 var duck:=0.57 if onboarding.player.playing and not onboarding.player.stream_paused else 1.0
 var smooth:=1.0-exp(-2.1*dt)
 var base:=linear_to_db(maxf(0.001,music_level*duck*lerpf(0.61,0.42,danger)))
 var percussion:=linear_to_db(maxf(0.001,music_level*duck*0.88*danger))
 exploration_music.volume_db=lerpf(exploration_music.volume_db,base,smooth)
 action_music.volume_db=lerpf(action_music.volume_db,percussion,smooth)

func apply_volume():
 AudioServer.set_bus_mute(0,volume<=0.0)
 AudioServer.set_bus_volume_db(0,linear_to_db(maxf(0.001,volume)))

func play_sound(path:String,pitch_scale:float=1.0):
 if not is_instance_valid(sfx):return
 sfx.volume_db=linear_to_db(maxf(0.00001,sfx_level))
 sfx.pitch_scale=pitch_scale
 sfx.stream=load(path)
 sfx.play()

func play_effect(name:String):
 if not is_instance_valid(sfx) or not effects.has(name):return
 if name.begins_with("step") and sfx.playing:return
 sfx.volume_db=linear_to_db(maxf(0.00001,sfx_level))
 sfx.pitch_scale=1.0
 sfx.stream=effects[name]
 sfx.play()

func emissive(color:Color) -> StandardMaterial3D:
 var surface: StandardMaterial3D = material(color,0.15,0.45)
 surface.emission_enabled = true
 surface.emission = color
 surface.emission_energy_multiplier = 0.52
 return surface

func structure_part(parent:Node3D,pos:Vector3,extent:Vector3,surface:Material):
 box(parent,pos,extent,surface)
 var body := StaticBody3D.new()
 body.collision_layer = 8 | (16 if extent.y <= 0.32 else 0)
 body.collision_mask = 0
 body.position = pos
 var ancestor := parent
 while ancestor!=null and ancestor!=self and not ancestor.has_meta("structure"):
  ancestor=ancestor.get_parent()
 if ancestor!=null and ancestor.has_meta("structure"):body.set_meta("structure_owner",ancestor)
 parent.add_child(body)
 var collider := CollisionShape3D.new()
 var shape := BoxShape3D.new()
 shape.size = extent
 collider.shape = shape
 body.add_child(collider)

func setup_tool():
 rig=Rig.new()
 add_child(rig)
 rig.create(visuals,camera,player)
 beam_material=emissive(Color("8deee9"))
 beam_material.no_depth_test=false
 tool_beam=cylinder(self,Vector3.ZERO,0.011,1,beam_material)
 tool_beam.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 tool_beam.hide()
 var outline:=TorusMesh.new()
 outline.inner_radius=0.73
 outline.outer_radius=0.745
 outline.rings=28
 outline.ring_segments=7
 aim_marker=mesh_node(self,outline,Vector3.ZERO,emissive(Color("70c8dc")))
 aim_marker.hide()
 flashlight=SpotLight3D.new()
 flashlight.spot_range=32
 flashlight.spot_angle=32
 flashlight.light_energy=2.4
 flashlight.light_color=Color("f5e0c8")
 flashlight.hide()
 camera.add_child(flashlight)
 world_fx=GPUParticles3D.new()
 world_fx.one_shot=true
 world_fx.amount=20
 world_fx.lifetime=0.37
 world_fx.explosiveness=0.96
 world_fx.emitting=false
 var spread:=ParticleProcessMaterial.new()
 spread.direction=Vector3.UP
 spread.spread=83
 spread.initial_velocity_min=1.8
 spread.initial_velocity_max=5.3
 spread.gravity=Vector3(0,-8,0)
 spread.scale_min=0.25
 spread.scale_max=1.0
 world_fx.process_material=spread
 var spark:=BoxMesh.new()
 spark.size=Vector3(0.038,0.028,0.085)
 spark.material=emissive(Color("f5b17d"))
 world_fx.draw_pass_1=spark
 add_child(world_fx)

func sparks_at(point:Vector3,color:Color,burst:bool=false):
 if quality==0 or reduced_motion:return
 world_fx.position=point
 world_fx.amount=27 if burst else 9
 world_fx.draw_pass_1.material.albedo_color=color
 world_fx.draw_pass_1.material.emission=color
 world_fx.restart()
 world_fx.emitting=true

func update_rig(dt:float):
 var mining:=mine_progress>0.0 and is_instance_valid(mining_target)
 if health<previous_health-0.4:
  rig.action(Rig.Pose.DAMAGE,0.35)
 previous_health=health
 var tight:=0.0
 if not third_person:
  var muzzle_path:=PhysicsRayQueryParameters3D.create(pivot.global_position,pivot.to_global(Vector3(0.27,-0.27,-0.91)),1|8)
  var obstruction:=get_world_3d().direct_space_state.intersect_ray(muzzle_path)
  if not obstruction.is_empty():tight=1.0-pivot.global_position.distance_to(obstruction.position)/0.98
 rig.update(dt,player.get_real_velocity(),player.is_on_floor(),mining,selected_build>=0,not third_person,yaw,astronaut.rotation.y,reduced_motion,flashlight.visible,clampf(tight,0.0,1.0))
 pivot.position.y=1.65+rig.eye_bob
 var sprint:bool=rig.pose==Rig.Pose.SPRINT
 camera.fov=lerpf(camera.fov,base_fov+4.0 if sprint and not reduced_motion else base_fov,minf(1,dt*4.5))
 if rig.footstep_ready or rig.just_landed:play_effect(polish.footstep_kind())
 var action_beam:bool=rig.action_pose in [Rig.Pose.BUILD,Rig.Pose.DECONSTRUCT] and rig.action_time>0 and aim_point.is_finite()
 var placement_beam:=selected_build>=0 and ground_target.is_finite()
 tool_beam.visible=(mining or action_beam or placement_beam) and not third_person
 if tool_beam.visible:
  var origin:Vector3=rig.muzzle.global_position
  var goal:=ground_target if placement_beam else aim_point
  var direction:=goal-origin
  if direction.length()>0.01:
   tool_beam.position=origin+direction/2
   tool_beam.quaternion=Quaternion(Vector3.UP,direction.normalized())
   tool_beam.scale=Vector3(0.63, direction.length(),0.63) if placement_beam else Vector3(1,direction.length(),1)
   var color:=HUD.ALERT if rig.action_pose==Rig.Pose.DECONSTRUCT else HUD.ACCENT if placement_beam else Color("c1fcf6")
   beam_material.albedo_color=color
   beam_material.emission=color
  fx_cooldown-=dt
  if mining and fx_cooldown<=0:
   var mineral: String=ORES[int(mining_target.get_meta("ore"))]
   sparks_at(aim_point,visuals.resources[mineral].palette.lightened(0.32))
   fx_cooldown=0.16
 if is_instance_valid(sfx_mine):
  if mining:
   var kind:=mining_sound_material(ORES[int(mining_target.get_meta("ore"))])
   if not sfx_mine.playing or kind!=mining_material:
    mining_material=kind
    sfx_mine.stream=mining_contacts[kind]
    sfx_mine.play()
  elif sfx_mine.playing:sfx_mine.stop()

func restore_survey_deposits():
 var random:=RandomNumberGenerator.new()
 random.seed=51491
 for id in survey_deposits:
  if deposits.has(id) or float(depleted.get(id,0))>time:continue
  var site:Dictionary=survey_deposits[id]
  create_deposit(self,id,site.position,site.ore,random)

const CAVE_WARMTH := 35.0
const COMPARTMENT_LOOT := {"Osmium":2,"Circuit board":1,"Oxygen capsule":1}
var ice_gate: StaticBody3D
var cargo_gate: StaticBody3D
var cargo_cache: StaticBody3D

func cave_thawed() -> bool:
 return heat>=CAVE_WARMTH

func sync_exploration_gates():
 if is_instance_valid(ice_gate):
  ice_gate.visible=not cave_thawed()
  ice_gate.collision_layer=0 if cave_thawed() else 8
 if is_instance_valid(cargo_gate):
  cargo_gate.visible=not quest_events.get("cargo_unlocked",false)
  cargo_gate.collision_layer=0 if not cargo_gate.visible else 2|8
 if is_instance_valid(cargo_cache):
  cargo_cache.visible=not quest_events.get("cargo_claimed",false)
  cargo_cache.collision_layer=2|8 if cargo_cache.visible else 0

func survey_object(at:Vector3,extent:Vector3,surface:Material,kind:String) -> StaticBody3D:
 var body:=StaticBody3D.new()
 body.position=at
 body.collision_layer=2|8
 body.collision_mask=0
 body.set_meta("survey_object",kind)
 add_child(body)
 box(body,Vector3.ZERO,extent,surface)
 var collider:=CollisionShape3D.new()
 var shape:=BoxShape3D.new()
 shape.size=extent
 collider.shape=shape
 body.add_child(collider)
 return body

func use_survey_object(kind:String):
 match kind:
  "cargo_hatch":
   if quest_events.get("cargo_unlocked",false):return
   if not pay({"Portable power cell":1}):
    notify("Craft a Portable power cell in the Components tab.")
    return
   quest_events.cargo_unlocked=true
   sync_exploration_gates()
   play_sound("res://build.wav")
   notify("Cargo compartment powered and open.")
  "cargo_cache":
   if not quest_events.get("cargo_unlocked",false) or quest_events.get("cargo_claimed",false):return
   if not Data.transaction(inventory,{},COMPARTMENT_LOOT,max_cargo()):
    notify("Free some backpack slots before collecting the salvage.")
    return
   quest_events.cargo_claimed=true
   sync_exploration_gates()
   notify("Compartment salvage recovered.")
 mark_save()

func build_wreck_cargo_bay():
 var anchor:=Vector2(239,161)
 var floor_y:=height_at(anchor.x,anchor.y)
 var steel:=visuals.textured_finish(visuals.surface(Color("766e66"),0.52,0.7),"metal")
 var ribs:=visuals.surface(Color("353b42"),0.55,0.52)
 var stripe:=emissive(Color("efaa70"))
 for side in [-1,1]:
  for bay in range(4):
   var z:=anchor.y+bay*2.4
   var x:float=anchor.x+side*2.0
   var ground:=height_at(x,z)
   var panel:=visuals.bevel_box(self,Vector3(x,ground+1.42,z),Vector3(0.32,3.0,2.51),0.11,steel)
   solid_scenery(panel)
   var seam:MeshInstance3D=box(self,Vector3(x-side*0.20,ground+1.8,z),Vector3(0.07,0.09,1.81),ribs)
   seam.rotation.z=side*0.15
   box(self,Vector3(x-side*0.27,ground+1.90,z),Vector3(0.08,0.05,0.57),stripe)
 for bay in range(4):
  var z:=anchor.y+bay*2.4
  box(self,Vector3(anchor.x,height_at(anchor.x,z)+3.05,z),Vector3(4.12,0.28,2.53),steel)
  if bay%2==0:
   var lamp:=OmniLight3D.new()
   lamp.light_color=Color("ffc991")
   lamp.light_energy=0.47
   lamp.omni_range=5.1
   lamp.position=Vector3(anchor.x,height_at(anchor.x,z)+2.24,z)
   add_child(lamp)
 var hatch_z:=anchor.y+1.15
 var y:=height_at(anchor.x,hatch_z)
 cargo_gate=survey_object(Vector3(anchor.x,y+1.4,hatch_z),Vector3(3.98,3.2,0.29),ribs,"cargo_hatch")
 box(cargo_gate,Vector3(0.72,0,0.18),Vector3(0.25,0.37,0.12),stripe)
 var rear_z:=anchor.y-1.28
 var bulkhead:MeshInstance3D=box(self,Vector3(anchor.x,floor_y+1.45,rear_z),Vector3(4.1,3.15,0.36),steel)
 solid_scenery(bulkhead)
 var cache_z:=anchor.y-0.22
 cargo_cache=survey_object(Vector3(anchor.x,height_at(anchor.x,cache_z)+0.4,cache_z),Vector3(1.3,0.8,0.75),steel,"cargo_cache")
 box(cargo_cache,Vector3(0,0.18,0.40),Vector3(0.72,0.05,0.05),stripe)

func make_survey_landmarks():
 var stone:=sandstone
 var basalt:=volcanic_rock
 var teal:=emissive(Color("548187"))
 var light_gold:=emissive(Color("c88362"))
 var random:=RandomNumberGenerator.new()
 random.seed=47715
 for cave in Survey.CAVES:
  var site:Vector2=Survey.SITES[cave][1]
  var root:=Node3D.new()
  root.position=Vector3(site.x,height_at(site.x,site.y),site.y)
  add_child(root)
  for segment in range(9 if cave==31 else 6):
   var z:float=-segment*4.0
   var underside:=height_at(site.x,site.y+z)-root.position.y
   for side in [-1,1]:
    var shoulder:=4.7+0.43*sin(segment*1.9+side+cave)
    var wall:=visuals.facet(root,Vector3(side*shoulder,underside+2.03,z),Vector3(2.45,5.0+0.34*sin(segment*1.8),3.7),basalt,int(random.randi()),15)
    wall.rotation.y=0.17*sin(segment+side)
    solid_scenery(wall)
   var roof:=visuals.facet(root,Vector3(0.32*sin(segment),underside+4.35+0.2*cos(segment*1.7),z),Vector3(6.5,2.17,3.8),stone,int(random.randi()),16)
   roof.rotation.y=0.20*cos(segment*1.7+cave)
   solid_scenery(roof)
   if segment%3==0:cylinder(root,Vector3(2.8,underside+0.32,z),0.05,0.62,teal,0.04)
   if segment%2==0 and (cave<32 or segment>0):
    var ore:=ORES.find(Survey.SITES[cave][2])
    var x:float=site.x-1.3
    survey_deposits["survey:%d:%d"%[cave,segment]]={"position":Vector3(x,height_at(x,site.y+z),site.y+z),"ore":ORES.find("Osmium") if cave==31 and segment>=6 else ore}
  var length:=36.0 if cave==31 else 24.0
  var end_z:=site.y-length
  var cap:=visuals.facet(root,Vector3(0,height_at(site.x,end_z)-root.position.y+1.4,-length),Vector3(5.9,4.5,5.5),basalt,int(random.randi()),14)
  solid_scenery(cap)
  if cave==31:
   var ice_z:=site.y-22.0
   ice_gate=survey_object(Vector3(site.x,height_at(site.x,ice_z)+1.75,ice_z),Vector3(7.2,4.25,1.40),visuals.surface(Color("87bec8"),0.1,0.40),"ice_gate")
   ice_gate.collision_layer=8
  var lamp:=OmniLight3D.new()
  lamp.position=Vector3(0,2.7,-8)
  lamp.light_color=Color("a9dbe6") if cave in [22,32] else Color("d3af6d") if cave==33 else Color("ed9a71")
  lamp.omni_range=13
  lamp.light_energy=0.45
  root.add_child(lamp)
 for site_index in [2,9,12,20,26,28]:
  var site:Vector2=Survey.SITES[site_index][1]
  for n in range(7):
   var angle:=n*TAU/7.0
   var x:float=site.x+sin(angle)*15.0
   var z:float=site.y+cos(angle)*12.0
   var h:=height_at(x,z)
   var pillar:=visuals.facet(self,Vector3(x,h+0.85,z),Vector3(2.0,4.3+n*0.41,2.2),stone if n%2 else basalt,3290+site_index*19+n,9,true)
   solid_scenery(pillar)
   if n==0:cylinder(self,Vector3(x,h+4.1,z),0.18,0.43,light_gold,0.06)

func setup_expedition_world():
 make_survey_landmarks()
 make_survey_wreck()
 make_survey_wreck(Vector2(-44,150),-57.0,1.16)
 make_survey_wreck(Vector2(240,151),115.0,0.77)
 build_wreck_cargo_bay()
 var steel: Material = material(Color("39414c"),0.48,0.76)
 var shard: Material = material(Color("466d79"),0.15,0.3)
 var arch := Vector3(-96,height_at(-96,-57),-57)
 for i in range(13):
  var angle := i*PI/12
  var pos := arch+Vector3(cos(angle)*7.5,sin(angle)*10.0-0.4,0)
  var fragment:=visuals.facet(self,pos,Vector3(2.35,3.8+sin(i*1.3)*0.44,2.45),sandstone,3089+i*41,17)
  fragment.rotation.z=angle-PI/2
  fragment.rotation.y=sin(i*2.39)*0.32
  var arch_body:=solid_scenery(fragment)
  arch_body.set_meta("obstacle",2.2)
  scenery_obstacles.append({"position":pos,"radius":2.2})
 for i in range(11):
  var x := -111.0+i*2.5
  var z := -48.0+sin(i*4.2)*3
  var crystal = cylinder(self,Vector3(x,height_at(x,z)+0.9,z),0.56,2.7+sin(i)*1.4,shard,0.05)
  crystal.rotation.z = sin(i*2.0)*0.35
  solid_scenery(crystal)
  scenery_obstacles.append({"position":crystal.position,"radius":0.60})
 make_survey_relay(Vector3(58,height_at(58,-94),-94),steel)
 var alcove := Vector3(-43,height_at(-43,-41),-41)
 for i in range(5):
  var canopy:=visuals.facet(self,alcove+Vector3((i-2)*2.4,2.1,-0.6+sin(i)*0.5),Vector3(2.25,4.7+sin(i)*0.85,3.4),sandstone,919+i*381,15)
  solid_scenery(canopy)
  scenery_obstacles.append({"position":canopy.position,"radius":1.9})
 for i in range(Data.CRATE_POINTS.size()):
  var point: Vector2 = Data.CRATE_POINTS[i]
  var body := StaticBody3D.new()
  body.position = Vector3(point.x,height_at(point.x,point.y),point.y)
  body.collision_layer = 2 | 8
  body.collision_mask = 0
  body.set_meta("loot",i)
  add_child(body)
  discovery_crates.append(body)
  box(body,Vector3(0,0.46,0),Vector3(1.5,0.9,0.9),steel)
  box(body,Vector3(0,0.93,0),Vector3(1.54,0.12,0.94),material(Color("c9a37b")))
  box(body,Vector3(0,0.63,0.47),Vector3(0.55,0.086,0.04),emissive(Color("f1d1a4")))
  var collision := CollisionShape3D.new()
  var shape := BoxShape3D.new()
  shape.size = Vector3(1.5,1.02,0.92)
  collision.position.y = 0.51
  collision.shape = shape
  body.add_child(collision)
  var marker = cylinder(body,Vector3(0,1.48,0),0.09,0.68,emissive(Color("f5c68a")),0.01)
  marker.rotation_degrees.z = 15
 var probe:=Vector3(132,height_at(132,53),53)
 var hull:=visuals.facet(self,probe+Vector3.UP*0.73,Vector3(1.24,0.78,1.65),visuals.surface(Color("8e8176"),0.52,0.61,0,true),6163,8)
 hull.rotation.z=-0.44
 cylinder(self,probe+Vector3(0.75,1.17,0.46),0.09,1.66,steel).rotation.z=0.91
 box(self,probe+Vector3(-0.64,0.85,0.97),Vector3(0.44,0.15,0.035),emissive(Color("93c0bb")))
 add_scenery_obstacle(probe+Vector3.UP*0.33,1.15)
 var beacon:=Label3D.new()
 beacon.position=probe+Vector3.UP*1.86
 beacon.billboard=BaseMaterial3D.BILLBOARD_ENABLED
 beacon.layers=1<<19
 beacon.pixel_size=0.004
 beacon.font_size=32
 beacon.text="SURVEY PROBE 04\nLAKE BASIN · LAST SIGNAL LOST"
 beacon.modulate=HUD.SECONDARY
 beacon.visibility_range_end=10
 add_child(beacon)
 var water_mesh := CylinderMesh.new()
 water_mesh.top_radius = BASIN_RADIUS
 water_mesh.bottom_radius = BASIN_RADIUS
 water_mesh.height = 0.02
 water_mesh.radial_segments = 96
 var surface := ShaderMaterial.new()
 surface.shader = preload("res://basin.gdshader")
 lake = mesh_node(self,water_mesh,Vector3(BASIN.x,-7,BASIN.y),surface)
 lake.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 lake.hide()
 make_greenery()
 make_dust()
 make_stars()

func make_survey_relay(at:Vector3,steel:Material):
 var white:=visuals.textured_finish(visuals.surface(Color("b6ac9c"),0.35,0.48),"metal")
 box(self,at+Vector3.UP*0.24,Vector3(1.8,0.48,1.7),steel)
 box(self,at+Vector3(0.47,0.78,-0.30),Vector3(0.76,0.70,0.59),white)
 for side in [-1,1]:
  var foot:=at+Vector3(side*0.76,0.40,0)
  var top:=at+Vector3(0,2.86,0)
  var brace:MeshInstance3D=cylinder(self,(foot+top)*0.5,0.055,foot.distance_to(top),steel)
  brace.quaternion=Quaternion(Vector3.UP,(top-foot).normalized())
 cylinder(self,at+Vector3.UP*1.62,0.15,2.94,steel,0.125)
 var head:=Node3D.new()
 add_child(head)
 head.position=at+Vector3.UP*3.25
 head.rotation_degrees=Vector3(-36,24,0)
 var mesh:=SurfaceTool.new()
 mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
 const DISH_RADIUS:=1.63
 for ring in range(10):
  var a:=DISH_RADIUS*ring/10.0
  var b:=DISH_RADIUS*(ring+1)/10.0
  for slice in range(48):
   var h:=slice*TAU/48.0
   var j:=(slice+1)*TAU/48.0
   var p:=Vector3(cos(h)*a,sin(h)*a,a*a*0.23)
   var q:=Vector3(cos(j)*a,sin(j)*a,a*a*0.23)
   var r:=Vector3(cos(h)*b,sin(h)*b,b*b*0.23)
   var s:=Vector3(cos(j)*b,sin(j)*b,b*b*0.23)
   for point in [p,r,s,p,s,q]:mesh.add_vertex(point)
 mesh.index()
 mesh.generate_normals()
 var reflector:=white.duplicate() as StandardMaterial3D
 reflector.cull_mode=BaseMaterial3D.CULL_DISABLED
 mesh_node(head,mesh.commit(),Vector3.ZERO,reflector)
 var focus:=Vector3(0,0,1.07)
 for i in range(3):
  var angle:=i*TAU/3
  var point:=Vector3(cos(angle),sin(angle),0)*DISH_RADIUS*0.81
  point.z=0.40
  var arm:MeshInstance3D=cylinder(head,(point+focus)*0.5,0.025,point.distance_to(focus),steel)
  arm.quaternion=Quaternion(Vector3.UP,(focus-point).normalized())
 var receiver:MeshInstance3D=cylinder(head,focus,0.09,0.29,white)
 receiver.rotation.x=PI/2.0
 add_scenery_obstacle(at+Vector3.UP*0.49,0.75)

func make_survey_wreck(site:=Vector2(-270,-130),heading:float=32.0,scale_factor:float=1.0):
 var origin:=Vector3(site.x,height_at(site.x,site.y),site.y)
 var hull:=visuals.textured_finish(visuals.surface(Color("8a8073"),0.46,0.65),"metal")
 var charred:=visuals.textured_finish(visuals.surface(Color("3e3437"),0.26,0.88),"metal")
 var beacon_glow:=emissive(Color("d39557"))
 var fuselage:MeshInstance3D=cylinder(self,origin+Vector3.UP*1.45*scale_factor,2.15*scale_factor,7.4*scale_factor,hull,1.65*scale_factor)
 fuselage.rotation_degrees=Vector3(79,heading,-13)
 solid_scenery(fuselage)
 scenery_obstacles.append({"position":origin,"radius":4.0})
 var forward:=Vector3.FORWARD.rotated(Vector3.UP,deg_to_rad(heading))
 for i in range(3):
  var at:=origin+(forward*(1.1+i*0.87)+Vector3.UP*(2.75+i*0.10))*scale_factor
  var window:=visuals.bevel_box(self,at,Vector3(1.83,0.31,0.65),0.12,charred)
  window.rotation.y=deg_to_rad(heading)
 for side in [-1,1]:
  var x:float=origin.x+side*4.7
  var z:float=origin.z+side*0.8
  var panel:=visuals.bevel_box(self,Vector3(x,height_at(x,z)+0.27,z),Vector3(3.2,0.47,1.4),0.17,charred)
  panel.rotation_degrees=Vector3(6*side,30*side,10)
  box(panel,Vector3(0,0.25,0),Vector3(1.45,0.05,0.10),beacon_glow)

func add_scenery_obstacle(position:Vector3,radius:float):
 scenery_obstacles.append({"position":position,"radius":radius})
 var body:=StaticBody3D.new()
 body.position=position
 body.collision_layer=8
 body.collision_mask=0
 add_child(body)
 var shape:=SphereShape3D.new()
 shape.radius=radius
 var collision:=CollisionShape3D.new()
 collision.shape=shape
 body.add_child(collision)

func make_stars():
 stars = MultiMeshInstance3D.new()
 var volume := MultiMesh.new()
 var point := SphereMesh.new()
 point.radius = 0.26
 point.height = 0.52
 point.radial_segments = 4
 point.rings = 2
 var glow := StandardMaterial3D.new()
 glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 glow.disable_fog = true
 glow.albedo_color = Color("d7dfec")
 point.material = glow
 volume.transform_format = MultiMesh.TRANSFORM_3D
 volume.mesh = point
 volume.instance_count = 340
 for i in range(volume.instance_count):
  var angle := i*2.39996
  var y := lerpf(0.13,1.0,float(i)/volume.instance_count)
  var radial := sqrt(1.0-y*y)
  volume.set_instance_transform(i,Transform3D(Basis.IDENTITY,Vector3(cos(angle)*radial,y,sin(angle)*radial)*600))
 stars.multimesh = volume
 stars.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(stars)

func make_dust():
 dust = GPUParticles3D.new()
 dust.physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 dust.position = Vector3(0,2.5,0)
 dust.amount = 230 if quality==2 else 130 if quality==1 else 40
 dust.lifetime = 5
 dust.preprocess=3.5
 var wind := ParticleProcessMaterial.new()
 wind.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
 wind.emission_box_extents = Vector3(17,2.2,16)
 wind.direction = Vector3(1,0.04,-0.24)
 wind.spread = 20
 wind.initial_velocity_min = 0.7
 wind.initial_velocity_max = 2.8
 wind.gravity = Vector3.ZERO
 wind.scale_min = 0.09
 wind.scale_max = 0.40
 dust.process_material = wind
 var speck := SphereMesh.new()
 speck.radius = 0.1
 speck.height = 0.2
 speck.radial_segments = 4
 speck.rings = 2
 speck.material = material(Color("b98166"))
 dust.draw_pass_1 = speck
 dust.visibility_aabb=AABB(Vector3(-50,-14,-42),Vector3(150,33,84))
 add_child(dust)
 landing_dust=GPUParticles3D.new()
 landing_dust.physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 landing_dust.emitting=false
 landing_dust.amount=quality*58+36
 landing_dust.lifetime=2.25
 landing_dust.visibility_aabb=AABB(Vector3(-25,-3,-25),Vector3(50,17,50))
 var exhaust:=ParticleProcessMaterial.new()
 exhaust.emission_shape=ParticleProcessMaterial.EMISSION_SHAPE_RING
 exhaust.emission_ring_radius=2.4
 exhaust.emission_ring_inner_radius=0.4
 exhaust.emission_ring_axis=Vector3.UP
 exhaust.emission_ring_height=0.24
 exhaust.direction=Vector3.UP
 exhaust.spread=75.0
 exhaust.initial_velocity_min=2.0
 exhaust.initial_velocity_max=8.0
 exhaust.gravity=Vector3(0,-2.4,0)
 exhaust.scale_min=0.4
 exhaust.scale_max=1.7
 landing_dust.process_material=exhaust
 var cloud:=QuadMesh.new()
 cloud.size=Vector2(1.15,1.15)
 var texture:=GradientTexture2D.new()
 var gradient:=Gradient.new()
 gradient.colors=PackedColorArray([Color(0.87,0.53,0.33,0.32),Color(0.72,0.42,0.26,0)])
 texture.gradient=gradient
 texture.fill=GradientTexture2D.FILL_RADIAL
 texture.fill_from=Vector2(0.5,0.5)
 texture.fill_to=Vector2(1,0.5)
 var haze:=StandardMaterial3D.new()
 haze.albedo_texture=texture
 haze.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 haze.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 haze.billboard_mode=BaseMaterial3D.BILLBOARD_ENABLED
 cloud.material=haze
 landing_dust.draw_pass_1=cloud
 add_child(landing_dust)
 ground_haze=GPUParticles3D.new()
 ground_haze.physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 ground_haze.amount=quality*30+32
 ground_haze.lifetime=4.2
 ground_haze.emitting=false
 ground_haze.visibility_aabb=dust.visibility_aabb
 var drift:=ParticleProcessMaterial.new()
 drift.emission_shape=ParticleProcessMaterial.EMISSION_SHAPE_BOX
 drift.emission_box_extents=Vector3(21,1.1,19)
 drift.direction=Vector3(1,0.02,-0.3)
 drift.spread=17
 drift.initial_velocity_min=3.5
 drift.initial_velocity_max=9.0
 drift.gravity=Vector3.ZERO
 drift.scale_min=1.6
 drift.scale_max=4.9
 ground_haze.process_material=drift
 ground_haze.draw_pass_1=cloud
 add_child(ground_haze)
 rain=GPUParticles3D.new()
 rain.physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 rain.amount=quality*340+350
 rain.lifetime=1.3
 rain.emitting=false
 rain.visibility_aabb=AABB(Vector3(-28,-23,-28),Vector3(56,46,56))
 var fall:=ParticleProcessMaterial.new()
 fall.emission_shape=ParticleProcessMaterial.EMISSION_SHAPE_BOX
 fall.emission_box_extents=Vector3(15,4,15)
 fall.direction=Vector3(0.19,-1,0.04)
 fall.spread=3.5
 fall.initial_velocity_min=10.0
 fall.initial_velocity_max=14.0
 fall.gravity=Vector3(0,-5,0)
 rain.process_material=fall
 var streak:=BoxMesh.new()
 streak.size=Vector3(0.017,0.33,0.017)
 var drop:=StandardMaterial3D.new()
 drop.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 drop.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 drop.albedo_color=Color(0.67,0.78,0.86,0.53)
 streak.material=drop
 rain.draw_pass_1=streak
 add_child(rain)

func make_greenery():
 greenery = MultiMeshInstance3D.new()
 var volume := MultiMesh.new()
 var foliage: StandardMaterial3D = material(Color.WHITE)
 foliage.vertex_color_use_as_albedo=true
 var trunk:StandardMaterial3D=material(Color("5f4a31"),0.03,0.93)
 var tree:=Node3D.new()
 visuals.tube(tree,Vector3(0,0.31,0),0.052,0.63,trunk,0.033,6)
 for branch in range(5):
  var a:=TAU*branch/5.0
  var height:=0.5+0.075*(branch%3)
  var end:=Vector3(cos(a)*0.22,height,sin(a)*0.22)
  visuals.ball(tree,end,0.21,Vector3(1.37,0.80,1.20),foliage)
 visuals.ball(tree,Vector3(0,0.73,0),0.25,Vector3(1.2,1.0,0.95),foliage)
 var leaves:=visuals.combine_ore(tree)
 volume.transform_format = MultiMesh.TRANSFORM_3D
 volume.use_colors = true
 volume.mesh = leaves
 volume.instance_count = 620
 volume.visible_instance_count = 0
 greenery.multimesh = volume
 add_child(greenery)
 blossoms=MultiMeshInstance3D.new()
 var flower_mesh:=SphereMesh.new()
 flower_mesh.radius=0.3
 flower_mesh.height=0.18
 flower_mesh.radial_segments=6
 flower_mesh.rings=3
 var petal:StandardMaterial3D=material(Color.WHITE,0.04,0.81)
 petal.vertex_color_use_as_albedo=true
 flower_mesh.material=petal
 var flower_batch:=MultiMesh.new()
 flower_batch.transform_format=MultiMesh.TRANSFORM_3D
 flower_batch.use_colors=true
 flower_batch.mesh=flower_mesh
 flower_batch.instance_count=volume.instance_count
 flower_batch.visible_instance_count=0
 blossoms.multimesh=flower_batch
 add_child(blossoms)
 var random := RandomNumberGenerator.new()
 random.seed = seed_value+9527
 for i in range(volume.instance_count):
  var x := random.randf_range(-177,177)
  var z := random.randf_range(-177,177)
  if i<290:
   var a:=random.randf()*TAU
   var rim:=random.randf_range(51,74)
   x=BASIN.x+sin(a)*rim
   z=BASIN.y+cos(a)*rim
  greenery_positions.append(Vector3(x,height_at(x,z),z))
  volume.set_instance_color(i,Color("5a7851").lerp(Color("a1a866"),random.randf()))
  flower_batch.set_instance_color(i,Color("d9a85f").lerp(Color("dcb7d5"),random.randf()))

var last_green_count := -1

func apply_stage(weather_clock:float=-1.0,preview_index:float=-1.0):
 if is_instance_valid(ice_gate) and ice_gate.visible==cave_thawed():sync_exploration_gates()
 var ti := terraform_index() if preview_index<0.0 else preview_index
 var atmosphere := smoothstep(20.0,1450.0,ti)
 var green := smoothstep(1450.0,3500.0,ti)
 var local_time:float=time if weather_clock<0.0 else weather_clock
 var sun_height:=Mars.sun_height(local_time)
 var rainfall:=Mars.rain_strength(local_time,ti)
 var storm:=(dust_strength() if weather_clock<0.0 else Mars.dust(local_time))*(1.0-rainfall)
 var sun_up:=smoothstep(-0.19,0.30,sun_height)
 var daylight:=lerpf(0.12,1.0,sun_up)*(1.0-storm*0.50)
 var twilight:=(1.0-smoothstep(0.0,0.46,absf(sun_height)))*(1.0-storm)
 stars.visible=sun_up<0.49 and storm<0.2
 stars.position=player.position
 var sky:=environment.environment.sky.sky_material as ShaderMaterial
 var overhead:=Color("171b28").lerp(Color("9b706a").lerp(Color("39638e"),atmosphere),sun_up)
 var horizon:=Color("292934").lerp(Color("dba084").lerp(Color("b4cadb"),atmosphere),sun_up)
 horizon=horizon.lerp(Color("a86443"),storm*0.55)
 sky.set_shader_parameter("zenith",overhead)
 sky.set_shader_parameter("horizon",horizon)
 sky.set_shader_parameter("twilight",twilight)
 sky.set_shader_parameter("night",1.0-sun_up)
 sky.set_shader_parameter("dust",storm)
 sky.set_shader_parameter("rainfall",rainfall)
 sky.set_shader_parameter("clouds",smoothstep(300,900,ti))
 sky.set_shader_parameter("weather_time",local_time)
 environment.environment.fog_sky_affect=clampf(0.10+storm*0.66+rainfall*0.35,0,0.95)
 environment.environment.fog_light_color=horizon.darkened(0.13)
 environment.environment.fog_density=lerpf(0.0024,0.0015,atmosphere)+0.022*storm+0.008*rainfall
 environment.environment.ambient_light_energy=lerpf(0.12,0.48,sun_up)
 sun.light_energy=daylight*1.17*(1.0-0.38*rainfall)
 sun.rotation_degrees=Vector3(-sun_height*64,-53+local_time/Mars.SOL_SECONDS*360,0)
 terrain_material.set_shader_parameter("growth",green)
 terrain_material.set_shader_parameter("wetness",rainfall)
 var weather_origin:Vector3=onboarding.camera.position if onboarding.intro_active else player.position
 rain.position=weather_origin+Vector3.UP*8.0
 rain.emitting=rainfall>0.08
 rain.amount_ratio=rainfall
 lake.visible=ti>=900
 lake.position.y=lerpf(-6.55,-3.5,smoothstep(900.0,2400.0,ti))
 dust.position = player.position+Vector3.UP*1.4
 ground_haze.position=player.position+Vector3.UP*0.28
 ground_haze.emitting=storm>0.12 and quality>0
 ground_haze.amount_ratio=storm*0.63
 dust.amount_ratio = lerpf(0.38,1,storm)*(1.0-atmosphere*0.52)
 var wind:=dust.process_material as ParticleProcessMaterial
 wind.initial_velocity_max=2.8+storm*7.0
 var count := int(620*smoothstep(1799.0,3500.0,ti))
 if count!=last_green_count:
  last_green_count=count
  greenery.multimesh.visible_instance_count=count
  blossoms.multimesh.visible_instance_count=count
  for i in range(count):
   var pos := greenery_positions[i]
   var blocked := Vector2(pos.x,pos.z).distance_to(BASIN)<BASIN_RADIUS or pos.length()<5
   for unit in structures:
    if unit.node.position.distance_to(pos)<4:
     blocked=true
     break
   # Young plants grow into their silhouettes; woodland follows the Flora milestone.
   var maturity:=smoothstep(1799.0+float(i)*1.5,2250.0+float(i)*1.7,ti)
   var extent := Vector3(1.2,1.12,1.2)*lerpf(0.12,1.0,maturity) if i%4 else Vector3(3.2,4.8,3.2)*smoothstep(2500.0+float(i)*0.55,3500.0,ti)
   var basis := Basis.IDENTITY.scaled(extent if not blocked else Vector3.ZERO)
   greenery.multimesh.set_instance_transform(i,Transform3D(basis,pos))
   var bloom:=Basis.IDENTITY.scaled(Vector3.ONE if not blocked and i%9!=0 and i%3==0 else Vector3.ZERO)
   blossoms.multimesh.set_instance_transform(i,Transform3D(bloom,pos+Vector3(0.24,0.38,0.15)))
 for unit in structures:
  if unit.type in [Build.TUBE,Build.TUBE_2]:
   unit.node.get_node("Sprout").visible=unit.seeded





