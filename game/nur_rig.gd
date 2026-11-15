extends Node3D

enum Pose { IDLE, WALK, SPRINT, JUMP, MINE, BUILD, PICKUP, INTERACT, DECONSTRUCT, DAMAGE }
var pose := Pose.IDLE
var action_pose := -1
var action_time := 0.0
var action_length := 0.0
var cadence := 0.0
var stride := 0.0
var footstep_ready := false
var was_grounded := true
var landing := 0.0
var just_landed := false
var fall_speed := 0.0
var breathing_time := 0.0
var in_hand_clearance := 0.0
var movement_blend := Vector2.ZERO
var mount: Node3D
var tool: Node3D
var light_mark: MeshInstance3D
var muzzle: Marker3D
var legs: Array[Node3D] = []
var shins: Array[Node3D] = []
var boots: Array[Node3D] = []
var arms: Array[Node3D] = []
var world_arms: Array[Node3D] = []
var world_elbows: Array[Node3D] = []
var finger_joints: Array[Node3D] = []
var chest: Node3D
var eye_bob := 0.0

static func movement_pose(speed:float,grounded:bool,mining:bool,building:bool,action:int) -> int:
 if action>=0:return action
 if mining:return Pose.MINE
 if building:return Pose.BUILD
 if not grounded:return Pose.JUMP
 if speed>6.10:return Pose.SPRINT
 if speed>0.35:return Pose.WALK
 return Pose.IDLE

func create(visuals,camera:Camera3D,body:CharacterBody3D):
 var suit: StandardMaterial3D = visuals.textured_finish(visuals.surface(Color("8a9189"),0.05,0.86),"fabric")
 var joints: StandardMaterial3D = visuals.textured_finish(visuals.surface(Color("33383a"),0.10,0.83),"fabric")
 var hard: StandardMaterial3D = visuals.textured_finish(visuals.surface(Color("a3a595"),0.21,0.57),"metal")
 var band: StandardMaterial3D = visuals.textured_finish(visuals.surface(Color("9f6143"),0.16,0.61),"fabric")
 mount=Node3D.new()
 camera.add_child(mount)
 for side in [-1,1]:
  var arm := Node3D.new()
  arm.position=Vector3(0.325*side,-0.277,-0.25)
  mount.add_child(arm)
  arms.append(arm)
  var sleeve = visuals.ball(arm,Vector3(0,-0.09,0.04),0.092,Vector3(1.08,1.95,0.98),suit)
  sleeve.rotation.x=-0.91
  var forearm = visuals.tube(arm,Vector3(-0.06*side,-0.14,-0.16),0.072,0.34,hard,0.059)
  forearm.rotation=Vector3(1.33,0,0.19*side)
  var cuff = visuals.tube(arm,Vector3(-0.105*side,-0.17,-0.29),0.073,0.07,band)
  cuff.rotation.x=1.35
  for rib in range(3):
   var seam = visuals.tube(arm,Vector3(-0.090*side,-0.16,-0.23-rib*0.025),0.068-rib*0.003,0.012,joints)
   seam.rotation.x=1.35
  visuals.ball(arm,Vector3(-0.13*side,-0.168,-0.34),0.061,Vector3(1.03,0.72,1.1),joints)
  var knuckles = visuals.ball(arm,Vector3(-0.128*side,-0.128,-0.352),0.051,Vector3(1,0.45,1.19),suit)
  knuckles.rotation.y=side*0.27
  var thumb=visuals.ball(arm,Vector3(-0.118*side,-0.146,-0.383),0.025,Vector3(1.25,0.8,0.61),joints)
  thumb.rotation.y=side*0.42
  for index in range(4):
   var finger := Node3D.new()
   arm.add_child(finger)
   finger.position=Vector3(-0.17*side,-0.19+index*0.019,-0.361+index*0.004)
   visuals.ball(finger,Vector3(-0.012*side,0,-0.023),0.017,Vector3(1.67,0.72,0.93),joints)
   visuals.ball(finger,Vector3(-0.025*side,0.004,-0.026),0.012,Vector3(0.86,0.54,1.04),suit)
   if side==-1:finger_joints.append(finger)
  if side==1:
   tool=visuals.item_model("Multi-tool")
   tool.scale=Vector3.ONE*0.45
   tool.position=Vector3(-0.125,-0.416,-0.438)
   arm.add_child(tool)
   muzzle=Marker3D.new()
   muzzle.position=Vector3(0,0.65,-0.696)
   tool.add_child(muzzle)
   light_mark=visuals.box(tool,Vector3(-0.081,0.746,-0.37),Vector3(0.06,0.027,0.09),visuals.surface(Color("f1dbbf"),0.1,0.28,0.9))
   light_mark.hide()
 chest=Node3D.new()
 body.add_child(chest)
 for side in [-1,1]:
  var leg := Node3D.new()
  chest.add_child(leg)
  leg.position=Vector3(side*0.168,0.91,0.062)
  legs.append(leg)
  visuals.ball(leg,Vector3(0,-0.195,0),0.105,Vector3(1.12,2.12,1.08),suit)
  var shin := Node3D.new()
  shin.position=Vector3(0,-0.389,0)
  leg.add_child(shin)
  shins.append(shin)
  visuals.ball(shin,Vector3(0,0,-0.064),0.086,Vector3(1.37,1.02,0.64),band)
  visuals.tube(shin,Vector3(0,-0.163,0.014),0.095,0.31,hard,0.109)
  var boot:=Node3D.new()
  boot.position=Vector3(0,-0.316,0)
  shin.add_child(boot)
  boots.append(boot)
  visuals.ball(boot,Vector3(0,-0.055,-0.083),0.124,Vector3(0.91,0.69,1.59),joints)
  visuals.ball(boot,Vector3(0,-0.014,-0.134),0.112,Vector3(0.96,0.60,1.32),hard)
  visuals.box(boot,Vector3(0,-0.032,-0.065),Vector3(0.193,0.034,0.055),band)
  for cleat in range(5):
   visuals.box(boot,Vector3(0,-0.122,-0.224+cleat*0.075),Vector3(0.197,0.028,0.042),joints)
 tune_layers(mount,true)
 tune_layers(chest,false)

func tune_layers(root:Node,first_person:bool):
 if root is MeshInstance3D:
  root.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  if first_person:
   var source: Material = root.material_override
   if source is StandardMaterial3D:
    var mat: StandardMaterial3D = source.duplicate()
    mat.no_depth_test=true
    mat.albedo_color=mat.albedo_color.darkened(0.16)
    root.material_override=mat
 for child in root.get_children():tune_layers(child,first_person)

func action(which:int,duration:float):
 action_pose=which
 action_length=duration
 action_time=duration

func build_pressure_suit(model:Node3D,visuals):
 var fabric=visuals.textured_finish(visuals.surface(Color("c2c4bb"),0.05,0.74),"fabric")
 var hard=visuals.textured_finish(visuals.surface(Color("d3d3c5"),0.22,0.48),"metal")
 var joints=visuals.textured_finish(visuals.surface(Color("343947"),0.07,0.71),"fabric")
 var trim=visuals.surface(Color("b87946"),0.38,0.46)
 var bezel=visuals.surface(Color("27313b"),0.43,0.31)
 var gold=visuals.surface(Color("785246"),0.40,0.19)
 var blue=visuals.surface(Color("137faf"),0.22,0.54)
 var green=visuals.surface(Color("29814f"),0.17,0.58)
 var red=visuals.surface(Color("a83239"),0.19,0.53)
 visuals.ball(model,Vector3(0,1.17,0),0.34,Vector3(0.91,1.15,0.57),fabric)
 visuals.ball(model,Vector3(0,0.98,0.014),0.24,Vector3(1.05,0.49,0.78),joints)
 visuals.bevel_box(model,Vector3(0,1.28,-0.188),Vector3(0.47,0.30,0.13),0.069,hard)
 var panel=visuals.bevel_box(model,Vector3(0,1.23,-0.263),Vector3(0.23,0.080,0.031),0.019,bezel)
 for i in range(4):
  visuals.box(panel,Vector3(-0.072+i*0.049,0,-0.022),Vector3(0.022,0.023,0.016),blue if i<3 else trim)
 var patch_image:=Image.new()
 if patch_image.load_svg_from_string(FileAccess.get_file_as_string("res://uzbekistan-patch.svg"))==OK:
  var patch_material:=StandardMaterial3D.new()
  patch_material.albedo_texture=ImageTexture.create_from_image(patch_image)
  patch_material.roughness=0.82
  patch_material.cull_mode=BaseMaterial3D.CULL_DISABLED
  var patch_mesh:=QuadMesh.new()
  patch_mesh.size=Vector2(0.184,0.092)
  var patch:MeshInstance3D=visuals.mesh(model,patch_mesh,Vector3(0.09,1.34,-0.275),patch_material)
  patch.rotation.y=PI
 visuals.tube(model,Vector3(0,1.49,0),0.19,0.09,bezel)
 visuals.tube(model,Vector3(0,1.527,0),0.20,0.033,trim)
 visuals.ball(model,Vector3(0,1.72,0),0.235,Vector3(1.05,1.08,1.00),hard)
 visuals.ball(model,Vector3(0,1.723,-0.135),0.207,Vector3(1.05,0.77,0.63),bezel)
 visuals.ball(model,Vector3(0,1.735,-0.153),0.197,Vector3(1.03,0.69,0.65),gold)
 var reflection=visuals.ball(model,Vector3(0,1.795,-0.225),0.13,Vector3(1.34,0.12,0.44),visuals.surface(Color("b28661"),0.53,0.26))
 reflection.rotation.x=-0.35
 for side in [-1,1]:
  var joint=visuals.tube(model,Vector3(side*0.219,1.70,0.025),0.076,0.057,bezel)
  joint.rotation.z=PI/2.0
  visuals.bevel_box(model,Vector3(side*0.204,1.25,0.18),Vector3(0.090,0.38,0.088),0.028,joints)
  visuals.bevel_box(model,Vector3(side*0.247,1.06,0.275),Vector3(0.124,0.42,0.14),0.034,trim)
 visuals.bevel_box(model,Vector3(0,1.23,0.267),Vector3(0.46,0.66,0.29),0.072,hard)
 visuals.bevel_box(model,Vector3(0,1.23,0.413),Vector3(0.34,0.42,0.066),0.04,bezel)
 for i in range(6):
  visuals.box(model,Vector3(0,1.067+i*0.058,0.459),Vector3(0.265,0.018,0.025),joints)

func add_world_arms(astronaut:Node3D,visuals):
 var fabric:Material=visuals.surface(Color("9b9c8e"),0.1,0.78)
 var joint:Material=visuals.surface(Color("303b40"),0.16,0.65)
 var cuff:Material=visuals.surface(Color("a57d59"),0.28,0.48)
 for side in [-1,1]:
  var shoulder:=Node3D.new()
  shoulder.position=Vector3(0.30*side,1.41,0)
  astronaut.add_child(shoulder)
  world_arms.append(shoulder)
  visuals.ball(shoulder,Vector3(0,-0.137,0),0.10,Vector3(1,1.75,1),fabric)
  visuals.ball(shoulder,Vector3(0,-0.01,0),0.115,Vector3(0.95,0.83,1.04),fabric)
  var elbow:=Node3D.new()
  elbow.position.y=-0.27
  shoulder.add_child(elbow)
  world_elbows.append(elbow)
  visuals.tube(elbow,Vector3(0,-0.12,0),0.073,0.24,fabric,0.084)
  visuals.tube(elbow,Vector3(0,-0.23,0),0.078,0.037,cuff)
  visuals.ball(elbow,Vector3(0,-0.28,0),0.071,Vector3(0.83,1,0.68),joint)

func track_vertical_speed(speed:float):
 fall_speed=maxf(fall_speed,-speed)

func update(dt:float,velocity:Vector3,grounded:bool,mining:bool,building:bool,first_person:bool,yaw:float,world_yaw:float,reduce_motion:bool,torch:bool,clearance:float):
 var speed := Vector2(velocity.x,velocity.z).length()
 just_landed=grounded and not was_grounded and fall_speed>2.0
 if grounded:
  if just_landed:landing=clampf(fall_speed*0.012,0.035,0.13)
  fall_speed=0.0
 was_grounded=grounded
 landing=lerpf(landing,0,blend(dt,13))
 action_time=maxf(0,action_time-dt)
 if action_time<=0.0:action_pose=-1
 pose=movement_pose(speed,grounded,mining,building,action_pose)
 var envelope := sin(PI*action_time/maxf(action_length,0.001)) if action_pose>=0 else 0.0
 var last_step := floori(cadence/PI)
 var step_rate:=lerpf(1.55,2.9,smoothstep(0.35,8.25,speed))
 if grounded and speed>0.35:cadence+=dt*step_rate*PI
 footstep_ready=grounded and speed>0.45 and floori(cadence/PI)>last_step
 stride=lerpf(stride,clampf(speed/8.1,0,1) if grounded else 0.0,blend(dt,9))
 var facing:=Basis(Vector3.UP,yaw).inverse()*velocity
 movement_blend=movement_blend.lerp(Vector2(facing.x,facing.z)/8.25,blend(dt,8))
 var wave := sin(cadence)
 var desired_bob := 0.0 if reduce_motion else stride*(cos(2*cadence)*0.012)-landing*0.22
 eye_bob=lerpf(eye_bob,desired_bob,blend(dt,13))
 breathing_time+=dt
 var breathing := 0.003*sin(breathing_time*TAU*0.30)
 mount.visible=first_person
 chest.visible=true
 chest.rotation.y=yaw if first_person else world_yaw
 light_mark.visible=torch
 var arm_position := Vector3(wave*stride*0.014-movement_blend.x*0.011,breathing+wave*stride*0.008,0)
 var arm_angles := Vector3(wave*stride*0.044,-movement_blend.x*0.08,wave*stride*0.027)
 match pose:
  Pose.SPRINT:
   arm_position+=Vector3(0.02,-0.044,0.027)
   arm_angles+=Vector3(0.16,0.13,-0.09)
  Pose.JUMP:
   arm_position.y+=0.024
   arm_angles.x+=clampf(-velocity.y*0.012,-0.08,0.08)
  Pose.MINE:
   arm_position+=Vector3(-0.043,0.069,-0.047)
   arm_angles+=Vector3(-0.10,0.10,0.005*sin(breathing_time*34))
  Pose.BUILD:
   arm_position+=Vector3(-0.025,0.083,-0.032)
   arm_angles+=Vector3(-0.12,-0.17,-0.13)
  Pose.DECONSTRUCT:
   arm_position+=Vector3(-0.04,0.073,-0.04)*envelope
   arm_angles.z+=0.2*envelope
  Pose.PICKUP:
   arm_position+=Vector3(-0.027,0.024,-0.08)*envelope
  Pose.INTERACT:
   arm_position+=Vector3(-0.077,0.044,-0.17)*envelope
  Pose.DAMAGE:arm_angles.x+=0.17*envelope
 in_hand_clearance=lerpf(in_hand_clearance,clearance,blend(dt,12))
 arm_position+=Vector3(0.025,-0.15,0.19)*in_hand_clearance
 arm_angles.x+=in_hand_clearance*0.21
 mount.position=mount.position.lerp(arm_position,blend(dt,12))
 mount.rotation=mount.rotation.lerp(arm_angles,blend(dt,12))
 var reach := (envelope if pose in [Pose.PICKUP,Pose.INTERACT] else 0.0)
 var close:=smoothstep(0.32,0.61,1.0-action_time/maxf(action_length,0.01))*reach
 var run:=smoothstep(5.4,8.2,speed)
 arms[0].position.z=lerpf(arms[0].position.z,-0.25-0.24*reach-0.055*wave*run,blend(dt,16))
 arms[0].rotation.x=lerpf(arms[0].rotation.x,-0.42*reach+0.29*wave*run,blend(dt,15))
 for finger in finger_joints:
  finger.rotation.x=lerpf(finger.rotation.x,-0.97*close-0.18,blend(dt,25))
 for i in range(2):
  var swing := wave*(1 if i==0 else -1)*stride
  var forward := 1.0-absf(movement_blend.x)*0.38
  var angle := swing*0.64*forward if grounded else (0.38 if i==0 else -0.20)
  legs[i].rotation.x=lerpf(legs[i].rotation.x,angle-landing*1.2,blend(dt,13))
  legs[i].rotation.z=lerpf(legs[i].rotation.z,movement_blend.x*(0.16+absf(swing)*0.12),blend(dt,13))
  shins[i].rotation.x=lerpf(shins[i].rotation.x,maxf(0,-swing)*0.69+(0.38 if not grounded else landing*1.5),blend(dt,14))
  boots[i].rotation.x=lerpf(boots[i].rotation.x,clampf(-legs[i].rotation.x-shins[i].rotation.x,-0.27,0.22),blend(dt,14))
  world_arms[i].rotation.x=lerpf(world_arms[i].rotation.x,-swing*(0.69+run*0.42)-0.51*(1.0 if mining or building else 0.0)-(0.88*reach if i==0 else 0.0),blend(dt,13))
  world_elbows[i].rotation.x=lerpf(world_elbows[i].rotation.x,-0.22-absf(swing)*0.29-0.62*run-0.56*close,blend(dt,13))

func blend(dt:float,rate:float) -> float:
 return 1.0-exp(-rate*dt)
func _exit_tree():
 if is_instance_valid(mount):mount.queue_free()
 if is_instance_valid(chest):chest.queue_free()

