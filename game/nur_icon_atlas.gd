extends SubViewport

const CELL := 144
const COLUMNS := 8
var textures: Dictionary[String,AtlasTexture] = {}

func render_models(models:Dictionary):
 var rows := ceili(float(models.size())/COLUMNS)
 size=Vector2i(COLUMNS*CELL,rows*CELL)
 own_world_3d=true
 transparent_bg=true
 msaa_3d=Viewport.MSAA_DISABLED
 render_target_update_mode=SubViewport.UPDATE_ALWAYS
 var camera := Camera3D.new()
 camera.projection=Camera3D.PROJECTION_ORTHOGONAL
 camera.size=rows*2.0
 camera.position=Vector3(0,0,18)
 camera.far=45
 add_child(camera)
 var world_light := WorldEnvironment.new()
 world_light.environment=Environment.new()
 world_light.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 world_light.environment.ambient_light_color=Color("b8cbd9")
 world_light.environment.ambient_light_energy=0.76
 add_child(world_light)
 var key := DirectionalLight3D.new()
 key.rotation_degrees=Vector3(-36,-36,9)
 key.light_color=Color("fff1dc")
 key.light_energy=2.05
 add_child(key)
 var rim := DirectionalLight3D.new()
 rim.rotation_degrees=Vector3(-21,142,0)
 rim.light_color=Color("80bde8")
 rim.light_energy=1.65
 add_child(rim)
 var index := 0
 for id in models:
  var entry: Dictionary = models[id]
  var model: Node3D = entry.node
  var tilt := Node3D.new()
  tilt.rotation=Vector3(float(entry.get("pitch",0.37)),float(entry.get("yaw",-0.49)),0)
  var anchor := Node3D.new()
  var col := index%COLUMNS
  var row := index/COLUMNS
  anchor.position=Vector3((col+0.5-COLUMNS*0.5)*2,(rows*0.5-row-0.5)*2,0)
  add_child(anchor)
  anchor.add_child(tilt)
  var bounds := local_bounds(model,Transform3D.IDENTITY)
  var longest := maxf(bounds.size.x,maxf(bounds.size.y,bounds.size.z))
  var zoom := 1.38/maxf(longest,0.01)
  model.scale=Vector3.ONE*zoom
  model.position=-bounds.get_center()*zoom
  tilt.add_child(model)
  var texture := AtlasTexture.new()
  texture.atlas=get_texture()
  texture.region=Rect2(col*CELL,row*CELL,CELL,CELL)
  texture.filter_clip=true
  textures[id]=texture
  index+=1
 RenderingServer.frame_post_draw.connect(cache_texture,CONNECT_ONE_SHOT)

func cache_texture():
 if DisplayServer.get_name()=="headless":return
 var image:=get_texture().get_image()
 if image==null or image.is_empty():return
 var cached:=ImageTexture.create_from_image(image)
 for texture in textures.values():texture.atlas=cached
 render_target_update_mode=SubViewport.UPDATE_DISABLED
 for child in get_children():child.queue_free()

func local_bounds(node:Node,transform:Transform3D) -> AABB:
 var bounds := AABB()
 if node is Node3D:
  transform *= node.transform
 if node is MeshInstance3D:
  bounds=transform*node.get_aabb()
 for child in node.get_children():
  var sub := local_bounds(child,transform)
  if sub.has_volume():
   bounds=bounds.merge(sub) if bounds.has_volume() else sub
 return bounds

