extends RefCounted

class ResourceVisualDefinition:
 var id: String
 var rarity: String
 var description: String
 var palette: Color
 var shape: String
 var metallic: float
 var roughness: float
 var emission: float
 var harvest_time: float
 var pickup_pitch: float
 var icon_yaw: float

 func _init(item:String,quality:String,detail:String,color:String,geometry:String,metal:float,rough:float,glow:float,seconds:float,pitch:float,angle:float):
  id=item
  rarity=quality
  description=detail
  palette=Color(color)
  shape=geometry
  metallic=metal
  roughness=rough
  emission=glow
  harvest_time=seconds
  pickup_pitch=pitch
  icon_yaw=angle

var resources: Dictionary[String,ResourceVisualDefinition] = {}
var prototypes: Dictionary[String,ArrayMesh] = {}
var materials: Dictionary = {}
var finish_maps: Dictionary = {}
const EQUIPMENT_MODELS = ["Multi-tool","Torch","Suit boots","Helmet","Jetpack"]

func _init():
 register(ResourceVisualDefinition.new("Iron","Common","Gunmetal ore with oxidized veins. Refine it into frames and machinery.","af6646","veined",0.52,0.59,0,0.55,0.84,0.37))
 register(ResourceVisualDefinition.new("Silicon","Common","Brittle volcanic glass. Its refined wafers form control circuits.","506473","shards",0.23,0.23,0,0.70,1.11,0.28))
 register(ResourceVisualDefinition.new("Titanium","Common","Lightweight plates with blue-gray fracture faces. Used in structural parts.","a3bbcb","plates",0.67,0.32,0,0.70,0.98,0.61))
 register(ResourceVisualDefinition.new("Ice","Common","Frosted water ice. Melt it into drinking water or feed a vegetube.","7acfe6","frost",0.10,0.28,0.10,0.55,1.36,0.25))
 register(ResourceVisualDefinition.new("Magnesium","Common","Porous pale mineral with a chalky crust. Used in suit and plant systems.","dfdfc4","porous",0.22,0.79,0,0.70,1.02,0.43))
 register(ResourceVisualDefinition.new("Cobalt","Common","Blue mineral seams in dark host rock. Process them into oxygen capsules and solar cells.","3b6697","prisms",0.38,0.39,0.025,0.65,1.08,0.55))
 register(ResourceVisualDefinition.new("Aluminum","Uncommon","Rounded silver nodules in a dark matrix. Useful in advanced electronics.","dedfd8","silver",0.79,0.29,0,1.10,1.09,0.52))
 register(ResourceVisualDefinition.new("Iridium","Rare","Dense fractured ore with an orange mineral core. Used in heater coils.","ff582b","fractured",0.45,0.63,0.71,1.55,0.72,0.56))
 register(ResourceVisualDefinition.new("Sulfur","Rare","A clump of rough yellow crystals with amber inclusions.","e5bc42","nodules",0.10,0.78,0,1.25,1.29,0.34))
 register(ResourceVisualDefinition.new("Seed","Uncommon","A sealed botanical sample. Install it in a vegetube or craft a food pack.","91cc73","canister",0.18,0.42,0.12,0.50,1.42,0.47))
 register(ResourceVisualDefinition.new("Uranium","Rare","Dense olive mineral found in impact ejecta and the caldera.","789047","fractured",0.25,0.66,0.09,1.48,0.79,0.50))
 register(ResourceVisualDefinition.new("Osmium","Rare","Bluish silver nodules found in the Rainbow Cave.","829bb5","silver",0.74,0.36,0.0,1.53,0.68,0.48))
 register(ResourceVisualDefinition.new("Zeolite","Rare","Pale mineral clusters used as filters. Look in the southwest caves.","e9c6a1","nodules",0.13,0.75,0.0,1.15,1.28,0.39))

func register(spec:ResourceVisualDefinition):
 resources[spec.id]=spec

func surface(color:Color,metal:float=0.1,rough:float=0.45,glow:float=0.0,grain:bool=false) -> StandardMaterial3D:
 var key := "%s/%s/%s/%s/%s"%[color,metal,rough,glow,grain]
 if materials.has(key):return materials[key]
 var mat := StandardMaterial3D.new()
 mat.albedo_color=color
 mat.metallic=metal
 mat.roughness=rough
 mat.vertex_color_use_as_albedo=grain
 if color.a<0.999:
  mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 if glow>0:
  mat.emission_enabled=true
  mat.emission=Color(color,1)
  mat.emission_energy_multiplier=glow
 materials[key]=mat
 return mat

func textured_finish(mat:StandardMaterial3D,finish:String) -> StandardMaterial3D:
 var key := "%s/%s"%[mat.get_instance_id(),finish]
 if materials.has(key):return materials[key]
 var refined:StandardMaterial3D=mat.duplicate()
 var maps:=surface_maps(finish)
 refined.albedo_texture=maps.color
 refined.normal_enabled=true
 refined.normal_texture=maps.normal
 refined.normal_scale=0.66 if finish=="chalk" else 0.36
 refined.roughness_texture=maps.rough
 refined.uv1_triplanar=true
 refined.uv1_triplanar_sharpness=3.0
 refined.uv1_scale=Vector3.ONE*(2.1 if finish=="metal" else 1.65)
 materials[key]=refined
 return refined

func surface_maps(finish:String) -> Dictionary:
 if finish_maps.has(finish):return finish_maps[finish]
 const SIZE:=96
 var noise:=FastNoiseLite.new()
 noise.seed=finish.hash()
 noise.frequency=0.092
 noise.fractal_octaves=4
 var field:=PackedFloat32Array()
 field.resize(SIZE*SIZE)
 for y in range(SIZE):
  for x in range(SIZE):
   var broad:=noise.get_noise_2d(x,y)
   var grain:=noise.get_noise_2d(x*5.63+29,y*6.21-11)
   var ridge:=1.0-absf(noise.get_noise_2d(x*0.38,y*1.3))
   var height:=broad*0.19+grain*0.16+pow(ridge,6.0)*0.13
   match finish:
    "metal":height=broad*0.062+grain*0.034+0.025*sin(y*2.1+broad*0.56)
    "chalk":height= broad*0.14+grain*0.12-pow(clampf(-grain+0.26,0.0,1.0),4)*0.34
    "ice":height=broad*0.096+grain*0.053+pow(ridge,11.0)*0.115
    "glass":height=broad*0.06+grain*0.02+pow(ridge,9.0)*0.054
    "fabric":height=broad*0.07+0.037*sin(x*2.14)*sin(y*2.14)+grain*0.027
   field[y*SIZE+x]=height
 var color:=Image.create_empty(SIZE,SIZE,false,Image.FORMAT_RGB8)
 var normal:=Image.create_empty(SIZE,SIZE,false,Image.FORMAT_RGB8)
 var rough:=Image.create_empty(SIZE,SIZE,false,Image.FORMAT_RGB8)
 for y in range(SIZE):
  for x in range(SIZE):
   var h:=field[y*SIZE+x]
   var brightness:=clampf(0.89+h*(0.77 if finish=="metal" else 1.26),0.48,1.0)
   var dx:=field[y*SIZE+(x+1)%SIZE]-field[y*SIZE+posmod(x-1,SIZE)]
   var dy:=field[((y+1)%SIZE)*SIZE+x]-field[posmod(y-1,SIZE)*SIZE+x]
   var n:=Vector3(-dx*3.0,-dy*3.0,1.0).normalized()
   var variation:=clampf(0.84-h*1.2,0.29,1.0)
   color.set_pixel(x,y,Color(brightness,brightness,brightness))
   normal.set_pixel(x,y,Color(n.x*0.5+0.5,n.y*0.5+0.5,n.z*0.5+0.5))
   rough.set_pixel(x,y,Color(variation,variation,variation))
 color.generate_mipmaps()
 normal.generate_mipmaps(true)
 rough.generate_mipmaps()
 var maps:={"color":ImageTexture.create_from_image(color),"normal":ImageTexture.create_from_image(normal),"rough":ImageTexture.create_from_image(rough)}
 finish_maps[finish]=maps
 return maps

func mesh(parent:Node3D,shape:Mesh,position:Vector3,mat:Material) -> MeshInstance3D:
 var node := MeshInstance3D.new()
 node.mesh=shape
 node.position=position
 node.material_override=mat
 parent.add_child(node)
 return node

func box(parent:Node3D,position:Vector3,extent:Vector3,mat:Material) -> MeshInstance3D:
 var shape := BoxMesh.new()
 shape.size=extent
 return mesh(parent,shape,position,mat)

func tube(parent:Node3D,position:Vector3,radius:float,height:float,mat:Material,top:float=-1,faces:int=12) -> MeshInstance3D:
 var shape := CylinderMesh.new()
 shape.bottom_radius=radius
 shape.top_radius=top if top>=0 else radius
 shape.height=height
 shape.radial_segments=faces
 return mesh(parent,shape,position,mat)

func ball(parent:Node3D,position:Vector3,radius:float,scale:Vector3,mat:Material) -> MeshInstance3D:
 var shape := SphereMesh.new()
 shape.radius=radius
 shape.height=radius*2
 shape.radial_segments=12
 shape.rings=6
 var node := mesh(parent,shape,position,mat)
 node.scale=scale
 return node

func facet(parent:Node3D,offset:Vector3,extent:Vector3,mat:Material,seed_value:int,sides:int=7,spire:bool=false) -> MeshInstance3D:
 var rng := RandomNumberGenerator.new()
 rng.seed=seed_value
 var st := SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 st.set_smooth_group(-1)
 var lower: Array[Vector3] = []
 var upper: Array[Vector3] = []
 var shoulder: Array[Vector3] = []
 for i in range(sides):
  var a := TAU*i/sides
  var r := rng.randf_range(0.74,1.16)
  lower.push_back(Vector3(cos(a)*r,-rng.randf_range(0.23,0.46),sin(a)*r))
  upper.push_back(Vector3(cos(a)*r*rng.randf_range(0.64,0.98),rng.randf_range(0.14,0.47),sin(a)*r*rng.randf_range(0.70,1.03)))
  var middle:=lower[i].lerp(upper[i],rng.randf_range(0.37,0.62))
  middle.x*=rng.randf_range(0.90,1.1)
  middle.z*=rng.randf_range(0.90,1.1)
  shoulder.append(middle)
 var top := Vector3(rng.randf_range(-0.27,0.28),1.24 if spire else 0.57,rng.randf_range(-0.2,0.24))
 var bottom := Vector3(0,-0.51,0)
 for i in range(sides):
  var j := (i+1)%sides
  for tri in [[lower[i],lower[j],shoulder[i]],[shoulder[i],lower[j],shoulder[j]],[shoulder[i],shoulder[j],upper[i]],[upper[i],shoulder[j],upper[j]],[top,upper[i],upper[j]],[bottom,lower[j],lower[i]]]:
   var shade := rng.randf_range(0.79,1.0)
   for p in tri:
    st.set_color(Color(shade,shade,shade))
    st.add_vertex(p*extent)
 st.generate_normals()
 return mesh(parent,st.commit(),offset,mat)

func prism(parent:Node3D,offset:Vector3,radius:float,height:float,body_mat:Material,tip_mat:Material,seed_value:int) -> Node3D:
 var root:=Node3D.new()
 root.position=offset
 parent.add_child(root)
 var noise:=RandomNumberGenerator.new()
 noise.seed=seed_value
 var base:Array[Vector3]=[]
 var shoulder:Array[Vector3]=[]
 var cap:Array[Vector3]=[]
 for i in range(6):
  var angle:=i*TAU/6
  var r:=radius*noise.randf_range(0.87,1.10)
  var axis:=Vector3(cos(angle),0,sin(angle))
  base.append(axis*r*1.06)
  shoulder.append(axis*r+Vector3(0,height*noise.randf_range(0.61,0.77),0))
  cap.append(axis*r*0.30+Vector3(radius*0.20,height*noise.randf_range(0.90,1.04),-radius*0.17))
 for band in range(2):
  var st:=SurfaceTool.new()
  st.begin(Mesh.PRIMITIVE_TRIANGLES)
  st.set_smooth_group(-1)
  var lower:=base if band==0 else shoulder
  var upper:=shoulder if band==0 else cap
  for i in range(6):
   var j:=(i+1)%6
   var tint:=noise.randf_range(0.66,1.0)
   for point in [lower[i],upper[i],lower[j],upper[i],upper[j],lower[j]]:
    st.set_color(Color(tint,tint,tint))
    st.add_vertex(point)
   var center:=Vector3(0,0,0) if band==0 else Vector3(radius*0.16,height,-radius*0.15)
   var close:= [center,lower[j],lower[i]] if band==0 else [center,upper[i],upper[j]]
   for point in close:
    st.set_color(Color(tint,tint,tint))
    st.add_vertex(point)
  st.generate_normals()
  mesh(root,st.commit(),Vector3.ZERO,body_mat if band==0 else tip_mat)
 return root

func bevel_box(parent:Node3D,position:Vector3,extent:Vector3,corner:float,mat:Material) -> MeshInstance3D:
 var x:=extent.x/2
 var y:=extent.y/2
 var z:=extent.z/2
 var c:=minf(corner,minf(x,y)*0.91)
 var profile:=PackedVector2Array([Vector2(x-c,y),Vector2(-x+c,y),Vector2(-x,y-c),Vector2(-x,-y+c),Vector2(-x+c,-y),Vector2(x-c,-y),Vector2(x,-y+c),Vector2(x,y-c)])
 var st:=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 st.set_smooth_group(-1)
 for i in range(profile.size()):
  var a:=profile[i]
  var b:=profile[(i+1)%profile.size()]
  var back_a:=Vector3(a.x,a.y,z)
  var back_b:=Vector3(b.x,b.y,z)
  var front_a:=Vector3(a.x,a.y,-z)
  var front_b:=Vector3(b.x,b.y,-z)
  for point in [Vector3(0,0,z),back_b,back_a,Vector3(0,0,-z),front_a,front_b,back_a,back_b,front_a,back_b,front_b,front_a]:
   st.add_vertex(point)
 st.generate_normals()
 return mesh(parent,st.commit(),position,mat)

func ore_model(id:String,variant:int=0) -> Node3D:
 var spec: ResourceVisualDefinition = resources[id]
 var model := Node3D.new()
 var color := spec.palette
 var seed_value := (int(id.hash())+variant*7919) & 65535
 var dark := textured_finish(surface(Color("343035").lerp(color,0.14),spec.metallic*0.61,0.82,0,true),"stone")
 var finish := "chalk" if spec.shape in ["porous","nodules"] else "ice" if spec.shape=="frost" else "glass" if spec.shape in ["prisms","shards"] else "metal"
 var stone := textured_finish(surface(color.darkened(0.19),spec.metallic,spec.roughness,spec.emission*0.72,true),finish)
 var shine := textured_finish(surface(color.lightened(0.26),spec.metallic,spec.roughness*0.75,spec.emission*0.68,true),finish)
 match spec.shape:
  "veined":
   facet(model,Vector3(0,0.22,0),Vector3(0.72,0.59,0.60),dark,seed_value,11)
   for i in range(8):
    var a := i*2.39
    var line := facet(model,Vector3(cos(a)*0.38,0.28+(i%3)*0.09,sin(a)*0.40),Vector3(0.17,0.037,0.23),stone,seed_value+i,6)
    line.rotation=Vector3(0.35+i*0.19,a,0.35)
   for i in range(11):
    var a := i*2.39
    ball(model,Vector3(cos(a)*0.45,0.25+(i%4)*0.095,sin(a)*0.46),0.032,Vector3(1,0.55,1),shine)
  "plates":
   facet(model,Vector3(0,0.10,0),Vector3(0.62,0.38,0.54),dark,seed_value)
   for i in range(5):
    var p := facet(model,Vector3((i-2)*0.21,0.3+i*0.078,sin(i)*0.20),Vector3(0.29,0.14,0.43),stone if i%2 else shine,seed_value+i+2,5)
    p.rotation=Vector3(-0.2,i*0.61,0.42+i*0.11)
  "prisms":
   facet(model,Vector3(0,0.18,0),Vector3(0.64,0.49,0.55),dark,seed_value,12)
   for i in range(9):
    var a:=i*2.39996
    var patch:=facet(model,Vector3(cos(a)*0.37,0.27+(i%4)*0.062,sin(a)*0.35),Vector3(0.13,0.15+(i%3)*0.096,0.115),shine if i%3==0 else stone,seed_value+i+21,9)
    patch.rotation=Vector3(sin(a)*0.73,a,cos(a)*0.63)
  "shards","frost":
   facet(model,Vector3(0,0.10,0),Vector3(0.62,0.32,0.54),dark,seed_value,6)
   var tips := textured_finish(surface(Color(color.lightened(0.45),0.72),0.10,0.26,0.06,true),finish)
   var count := 6 if spec.shape=="shards" else 4 if spec.shape=="frost" else 8
   for i in range(count):
    var a := i*2.39
    var h := 0.23+(i%5)*0.082
    var fragment := prism(model,Vector3(cos(a)*0.32,0.19,sin(a)*0.30),0.103+(i%3)*0.031,h*1.75,stone,tips if spec.shape!="shards" else shine,seed_value+i+11)
    fragment.rotation=Vector3(0.24*cos(a),a,0.29*sin(a))
    if spec.shape=="shards":
     ball(fragment,Vector3(0,h*0.73,0.11),0.023,Vector3(1,0.42,1),shine)
  "porous":
   facet(model,Vector3(0,0.23,0),Vector3(0.70,0.60,0.55),stone,seed_value,13)
   for i in range(15):
    var a := i*2.39
    var radius := 0.27+(i%3)*0.092
    var pos := Vector3(cos(a)*radius,0.37+(i%4)*0.069,sin(a)*radius)
    ball(model,pos,0.055+(i%3)*0.017,Vector3(1,0.3,0.8),dark if i%4 else shine)
  "silver":
   facet(model,Vector3(0,0.17,0),Vector3(0.66,0.44,0.53),dark,seed_value)
   for i in range(6):
    var a := i*2.39
    ball(model,Vector3(cos(a)*0.35,0.31+(i%3)*0.12,sin(a)*0.33),0.22,Vector3(1.3,0.54,0.86),stone)
  "fractured":
   ball(model,Vector3(0,0.25,0),0.52,Vector3(1,0.61,0.91),stone)
   for i in range(7):
    var a := i*TAU/7
    var segment := facet(model,Vector3(cos(a)*0.36,0.30+(i%2)*0.14,sin(a)*0.35),Vector3(0.23,0.51,0.29),dark,seed_value+i,5)
    segment.rotation=Vector3(0.09*sin(a),a,-0.29*cos(a))
  "nodules":
   facet(model,Vector3(0,0.10,0),Vector3(0.67,0.37,0.53),dark,seed_value)
   for i in range(10):
    var a := i*2.39
    var pos := Vector3(cos(a)*(0.29+(i%3)*0.06),0.23+(i%4)*0.10,sin(a)*0.36)
    facet(model,pos,Vector3(0.21,0.22,0.25),stone if i%4 else shine,seed_value+i,8)
  "canister":
   var glass := surface(Color(0.48,0.82,0.64,0.59),0.13,0.19)
   tube(model,Vector3(0,0.52,0),0.24,0.61,glass)
   for height in [0.17,0.86]:
    tube(model,Vector3(0,height,0),0.29,0.15,dark)
   tube(model,Vector3(0,0.48,0),0.086,0.35,stone,0.02,7)
   ball(model,Vector3(0.06,0.58,0.05),0.15,Vector3(1,0.42,0.64),shine)
   box(model,Vector3(0,0.32,0.287),Vector3(0.27,0.07,0.042),shine)
 return model

func item_model(id:String,variant:int=0) -> Node3D:
 if resources.has(id):
  var key:=id+":"+str(posmod(variant,3))
  if not prototypes.has(key):prototypes[key]=combine_ore(ore_model(id,posmod(variant,3)))
  var instance := MeshInstance3D.new()
  instance.mesh=prototypes[key]
  return instance
 var model := Node3D.new()
 var frame := textured_finish(surface(Color("34424a"),0.56,0.48),"metal")
 var ceramic := textured_finish(surface(Color("adb1aa"),0.27,0.43),"metal")
 var accent := surface(Color("72bbc4"),0.28,0.37,0.19)
 var orange := textured_finish(surface(Color("b47849"),0.32,0.48),"metal")
 match id:
  "Oxygen capsule","Water bottle","Purified Water","T1 Oxygen tank","T3 Oxygen tank":
   var width := 0.34 if id=="T3 Oxygen tank" else 0.29 if id=="T1 Oxygen tank" else 0.23
   var tint := surface(Color("466cc3") if id=="Water bottle" else Color("90cfda") if id=="Purified Water" else Color("319eaa"),0.32,0.31)
   tube(model,Vector3(0,0.59,0),width,0.79,tint)
   for h in [0.22,0.90]:
    tube(model,Vector3(0,h,0),width+0.024,0.12,ceramic)
   tube(model,Vector3(0,1.02,0),width*0.63,0.22,frame)
   box(model,Vector3(0,0.59,width),Vector3(width*1.26,0.43,0.025),accent)
   if id in ["T1 Oxygen tank","T3 Oxygen tank"]:box(model,Vector3(0,0.58,-0.25),Vector3(0.64,0.82,0.16),frame)
  "Food pack":
   box(model,Vector3(0,0.48,0),Vector3(0.78,0.81,0.19),orange)
   box(model,Vector3(0,0.54,0.10),Vector3(0.62,0.48,0.023),frame)
   ball(model,Vector3(0,0.55,0.12),0.16,Vector3(1,0.72,0.14),surface(Color("a3bf68")))
   for h in [0.14,0.85]:box(model,Vector3(0,h,0.10),Vector3(0.7,0.045,0.033),ceramic)
  "T2 Backpack","Jetpack":
   box(model,Vector3(0,0.54,0),Vector3(0.68,0.92,0.40),frame)
   box(model,Vector3(0,0.56,0.22),Vector3(0.58,0.64,0.16),ceramic)
   for x in [-0.37,0.37]:
    tube(model,Vector3(x,0.53,0),0.114,0.84,orange)
    tube(model,Vector3(x,0.13,0),0.079,0.13,frame)
   box(model,Vector3(0,0.65,0.312),Vector3(0.28,0.14,0.022),accent)
  "Portable power cell":
   bevel_box(model,Vector3(0,0.53,0),Vector3(0.49,0.91,0.45),0.09,frame)
   for x in [-0.13,0.13]:tube(model,Vector3(x,1.0,0),0.053,0.11,ceramic)
   box(model,Vector3(0,0.57,0.234),Vector3(0.22,0.35,0.04),accent)
  "Mining upgrade","Circuit board":
   box(model,Vector3(0,0.5,0),Vector3(0.75,0.82,0.12),surface(Color("526d61")))
   box(model,Vector3(0,0.5,0.085),Vector3(0.46,0.39,0.085),frame)
   for i in range(6):
    for x in [-0.31,0.31]:
     box(model,Vector3(x,0.26+i*0.088,0.071),Vector3(0.21,0.037,0.031),orange)
   box(model,Vector3(0,0.5,0.135),Vector3(0.24,0.19,0.027),accent)
  "Survey alloy":
   for n in range(3):
    bevel_box(model,Vector3(0,0.22+n*0.15,0),Vector3(0.84-n*0.13,0.12,0.46),0.053,ceramic).rotation.y=0.18*n
  "Air filter":
   for x in [-0.21,0.21]:
    tube(model,Vector3(x,0.53,0),0.19,0.53,ceramic)
    for y in [0.29,0.75]:tube(model,Vector3(x,y,0),0.21,0.07,frame)
   box(model,Vector3(0,0.55,0.17),Vector3(0.60,0.18,0.11),accent)
  "Multi-tool":
   tool_body(model,frame,ceramic,orange,accent)
  "Torch":
   tube(model,Vector3(0,0.51,0),0.16,0.76,frame)
   tube(model,Vector3(0,0.91,0),0.24,0.22,orange)
   tube(model,Vector3(0,1.035,0),0.202,0.047,accent)
   for h in [0.30,0.42,0.54,0.66]:tube(model,Vector3(0,h,0),0.177,0.03,ceramic)
  "Suit boots","Agility boots":
   for x in [-0.27,0.27]:
    for h in [0.14,0.23]:box(model,Vector3(x,h,0.09),Vector3(0.43,0.105,0.64),frame)
    box(model,Vector3(x,0.38,0.01),Vector3(0.38,0.34,0.53),ceramic)
    box(model,Vector3(x,0.51,0.08),Vector3(0.39,0.10,0.22),orange)
  "Helmet":
   ball(model,Vector3(0,0.63,0),0.49,Vector3(1,1,0.89),ceramic)
   ball(model,Vector3(0,0.66,0.32),0.39,Vector3(1,0.76,0.48),frame)
   for x in [-0.43,0.43]:box(model,Vector3(x,0.59,0.03),Vector3(0.091,0.31,0.31),orange)
 return model

func tool_body(model:Node3D,frame:Material,ceramic:Material,orange:Material,accent:Material):
 var rubber:=surface(Color("242a2a"),0.09,0.85)
 var steel:=textured_finish(surface(Color("717c83"),0.70,0.30),"metal")
 var lens:=textured_finish(surface(Color(0.28,0.71,0.76,0.83),0.31,0.20,0.27),"glass")
 bevel_box(model,Vector3(0,0.64,-0.024),Vector3(0.335,0.28,0.82),0.057,frame)
 bevel_box(model,Vector3(0,0.765,0.070),Vector3(0.327,0.112,0.666),0.032,ceramic)
 bevel_box(model,Vector3(0,0.598,0.383),Vector3(0.281,0.223,0.109),0.036,rubber)
 var grip:=Node3D.new()
 grip.position=Vector3(0,0.487,0.169)
 grip.rotation.x=-0.22
 model.add_child(grip)
 bevel_box(grip,Vector3(0,-0.168,0),Vector3(0.205,0.377,0.243),0.038,rubber)
 for rib in range(6):
  bevel_box(grip,Vector3(0,-0.042-rib*0.048,0.097),Vector3(0.212,0.019,0.062),0.006,frame)
 bevel_box(grip,Vector3(0,-0.358,0),Vector3(0.226,0.082,0.238),0.024,ceramic)
 var trigger:=bevel_box(grip,Vector3(0,0.016,-0.128),Vector3(0.088,0.076,0.075),0.014,orange)
 trigger.rotation.x=0.31
 for x in [-1.0,1.0]:
  bevel_box(model,Vector3(0.169*x,0.659,-0.114),Vector3(0.060,0.152,0.48),0.024,orange)
  for port in range(6):
   var vent:=box(model,Vector3(0.201*x,0.665,-0.307+port*0.056),Vector3(0.013,0.052,0.025),rubber)
   vent.rotation.x=0.29
  for z in [-0.345,0.284]:
   var screw:=tube(model,Vector3(0.175*x,0.741,z),0.021,0.025,steel,-1,10)
   screw.rotation.z=PI/2
   box(model,Vector3(0.190*x,0.741,z),Vector3(0.006,0.004,0.028),rubber).rotation.x=0.37
 for ring in [Vector2(-0.443,0.145),Vector2(-0.518,0.128),Vector2(-0.591,0.143),Vector2(-0.642,0.106)]:
  var collar:=tube(model,Vector3(0,0.65,ring.x),ring.y,0.075,steel if ring.y>0.13 else frame,-1,20)
  collar.rotation.x=PI/2
 var socket:=tube(model,Vector3(0,0.65,-0.674),0.079,0.022,rubber,-1,20)
 socket.rotation.x=PI/2
 var emitter:=tube(model,Vector3(0,0.65,-0.688),0.052,0.013,lens,-1,20)
 emitter.rotation.x=PI/2
 bevel_box(model,Vector3(0,0.828,0.122),Vector3(0.205,0.020,0.213),0.008,rubber)
 box(model,Vector3(0,0.840,0.12),Vector3(0.168,0.006,0.169),surface(Color("15343b"),0.21,0.37,0.12))
 for i in range(4):
  box(model,Vector3(-0.057+i*0.038,0.846,0.145),Vector3(0.021,0.0035,0.053),accent)
 box(model,Vector3(0,0.846,0.075),Vector3(0.113,0.0035,0.014),accent)
 for i in range(5):
  box(model,Vector3(0,0.797,-0.211+i*0.032),Vector3(0.126,0.010,0.014),frame)

func combine_ore(model:Node3D) -> ArrayMesh:
 var batches := {}
 append_surfaces(model,Transform3D.IDENTITY,batches)
 var combined := ArrayMesh.new()
 for material in batches:
  var batch: SurfaceTool = batches[material]
  batch.set_material(material)
  batch.commit(combined)
 model.free()
 return combined

func append_surfaces(node:Node3D,parent_transform:Transform3D,batches:Dictionary):
 var transform:=parent_transform*node.transform
 if node is MeshInstance3D:
  var mat:Material=node.material_override
  if not batches.has(mat):batches[mat]=SurfaceTool.new()
  var batch:SurfaceTool=batches[mat]
  var raw:ArrayMesh
  if node.mesh is ArrayMesh:
   raw=node.mesh
  else:
   raw=ArrayMesh.new()
   raw.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,node.mesh.get_mesh_arrays())
  batch.append_from(raw,0,transform)
 for child in node.get_children():
  if child is Node3D:append_surfaces(child,transform,batches)
