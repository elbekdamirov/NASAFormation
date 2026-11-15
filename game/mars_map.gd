extends Control

const Data=preload("res://nur_data.gd")
const Survey=preload("res://mars_regions.gd")
const LOW:=Color("303c54")
const HIGH:=Color("e2be96")
const EDGE:=Color("e7c49f")
const SITE:=Color("b7ede4")
const CACHE:=Color("ffd29e")
const SIZE:=200

var game
var relief: ImageTexture
var contours:=PackedVector2Array()
var step:=Survey.HALF*2.0/SIZE
var label_font:Font

func _ready():
 label_font=ThemeDB.fallback_font
 build_relief()

func point(x:float,z:float) -> Vector2:
 return (Vector2(x,z)/(Survey.HALF*2.0)+Vector2(0.5,0.5))*size

func build_relief():
 var image:=Image.create_empty(SIZE,SIZE,false,Image.FORMAT_RGB8)
 var height:=PackedFloat32Array()
 height.resize((SIZE+1)*(SIZE+1))
 for y in range(SIZE+1):
  for x in range(SIZE+1):
   height[y*(SIZE+1)+x]=game.height_at(x*step-Survey.HALF,y*step-Survey.HALF)
 var submerged:bool=game.stage_index>=3
 var lake_level:float=game.lake.position.y
 for y in range(SIZE):
  for x in range(SIZE):
   var i:=y*(SIZE+1)+x
   var z:=float(y)*step-Survey.HALF
   var e:=float(x)*step-Survey.HALF
   var h:=height[i]
   var surface:=Vector3(height[i]-height[i+1],step,height[i]-height[i+SIZE+1]).normalized()
   var light:=surface.dot(Vector3(-0.47,0.76,-0.44))
   var height_factor:=smoothstep(-12.0,43.0,h)
   var color:=LOW.lerp(Color("986149"),smoothstep(0.0,0.68,height_factor))
   color=color.lerp(HIGH,smoothstep(0.36,1.0,height_factor))
   var ground:=sin(e*0.062+cos(z*0.071)*1.35)+sin(z*0.042+e*0.018)
   color=color.lerp(Color("ab947d"),smoothstep(-0.8,1.9,ground)*0.26)
   if game.stage_index>=4 and Vector2(e,z).distance_to(Survey.BASIN)<125:
    color=color.lerp(Color("729470"),smoothstep(-1.0,0.95,ground)*0.6)
   color=color.lerp(Color("160d1b"),(1.0-light)*0.53)
   if submerged and Vector2(e,z).distance_to(Vector2(105,100))<49 and h<lake_level:
    color=Color("487984")
   image.set_pixel(x,y,color)
   var bounds:=Vector4(h,height[i+1],height[i+SIZE+2],height[i+SIZE+1])
   if floori(minf(minf(bounds.x,bounds.y),minf(bounds.z,bounds.w))/5.0)!=floori(maxf(maxf(bounds.x,bounds.y),maxf(bounds.z,bounds.w))/5.0):
    trace_cell(Vector2(e,z),bounds)
 relief=ImageTexture.create_from_image(image)
 queue_redraw()

func trace_cell(origin:Vector2,height:Vector4):
 var corners:=[origin,origin+Vector2(step,0),origin+Vector2(step,step),origin+Vector2(0,step)]
 var lowest:=minf(minf(height.x,height.y),minf(height.z,height.w))
 var highest:=maxf(maxf(height.x,height.y),maxf(height.z,height.w))
 for interval in range(floori(lowest/5.0)+1,floori(highest/5.0)+1):
  var level:=interval*5.0
  var intersections:=PackedVector2Array()
  for i in range(4):
   var next:=(i+1)%4
   if (height[i]<level)==(height[next]<level):continue
   var hit:Vector2=corners[i].lerp(corners[next],inverse_lerp(height[i],height[next],level))
   intersections.append(point(hit.x,hit.y))
  contours.append_array(intersections)

func _draw():
 if not relief:return
 draw_texture_rect(relief,Rect2(Vector2.ZERO,size),false)
 if not contours.is_empty():draw_multiline(contours,Color(1,0.87,0.72,0.17),1.0,false)
 for n in range(1,8):
  var coord:=size.x*n/8.0
  draw_line(Vector2(coord,0),Vector2(coord,size.y),Color(1,0.9,0.8,0.21),1)
  draw_line(Vector2(0,coord),Vector2(size.x,coord),Color(1,0.9,0.8,0.21),1)
  if n%2==0:
   draw_string(label_font,Vector2(coord+4,size.y-7),str(n*100-400),HORIZONTAL_ALIGNMENT_LEFT,-1,11,EDGE)
   draw_string(label_font,Vector2(6,coord-5),str(400-n*100),HORIZONTAL_ALIGNMENT_LEFT,-1,11,EDGE)
 draw_rect(Rect2(Vector2.ZERO,size),EDGE,false,1.2)
 if game.salvage_phase() in [1,2]:
  var salvage:Vector2=Data.CRATE_POINTS[6]
  var wreck:=point(salvage.x,salvage.y)
  draw_dashed_line(point(0,0),wreck,Color("ffc186"),2.0,7.0)
  draw_arc(wreck,12,0,TAU,24,Color("ffc186"),2.0,true)
 caption(Vector2(size.x-38,32),"N",EDGE)
 draw_line(Vector2(size.x-34,47),Vector2(size.x-34,76),EDGE,2,true)
 draw_colored_polygon(PackedVector2Array([Vector2(size.x-34,43),Vector2(size.x-40,56),Vector2(size.x-29,56)]),EDGE)
 draw_line(Vector2(size.x-111,size.y-34),Vector2(size.x-111+size.x*0.125,size.y-34),EDGE,2,true)
 caption(Vector2(size.x-110,size.y-40),"100 m",EDGE)
 for i in range(1,Survey.SITES.size()):
  var site:Array=Survey.SITES[i]
  var at:=point(site[1].x,site[1].y)
  var selected:bool=game.map_waypoint==i
  var color:=SITE if selected else EDGE
  draw_circle(at,4.0 if i in Survey.CAVES else 2.5,color)
  if selected:draw_arc(at,11,0,TAU,22,color,2.0,true)
  var label_width:=label_font.get_string_size(site[0],HORIZONTAL_ALIGNMENT_LEFT,-1,11).x
  var label_x:=clampf(at.x+4,8.0,size.x-label_width-8.0)
  caption(Vector2(label_x,at.y-6),site[0],color,11)
 for i in range(Data.CRATE_POINTS.size()):
  if game.opened_crates.has(str(i)):continue
  var p:=point(Data.CRATE_POINTS[i].x,Data.CRATE_POINTS[i].y)
  draw_colored_polygon(PackedVector2Array([p-Vector2(0,5),p+Vector2(5,0),p+Vector2(0,5),p-Vector2(5,0)]),CACHE)
 for unit in game.structures:
  var pos:Vector3=unit.node.position
  var p:=point(pos.x,pos.z)
  match int(unit.type):
   Data.Build.POD:
    draw_rect(Rect2(p-Vector2.ONE*4.5,Vector2.ONE*9.0),SITE)
    caption(p+Vector2(10,-7),"UZ-01",SITE)
   Data.Build.HABITAT:
    draw_line(p-Vector2(5,0),p+Vector2(5,0),SITE,2.0)
    draw_line(p-Vector2(0,5),p+Vector2(0,5),SITE,2.0)
   Data.Build.RECOVERY:draw_circle(p,4,Color("ffa18a"))
 var position:Vector3=game.player.position
 if game.map_waypoint>=0:
  var site:Vector2=Survey.SITES[game.map_waypoint][1]
  var origin:=Vector2(position.x,position.z)
  var route:PackedVector2Array=game.trip_basin_route(origin,site)
  if route.is_empty():route=PackedVector2Array([origin,site])
  for i in range(1,route.size()):
   draw_dashed_line(point(route[i-1].x,route[i-1].y),point(route[i].x,route[i].y),Color("84c9dc"),1.7,7.0)
 if game.lake.visible:
  var east_rim:=point(161,100)
  caption(east_rim+Vector2(5,13),"High rim",SITE,11)
 var astronaut:=point(position.x,position.z)
 var heading:float=game.yaw
 var tip:=Vector2(-sin(heading),-cos(heading))
 draw_arc(astronaut,11,0,TAU,28,SITE,1.5,true)
 draw_colored_polygon(PackedVector2Array([astronaut+tip*8,astronaut+tip.rotated(2.3)*5,astronaut+tip.rotated(-2.3)*5]),Color.WHITE)

func _gui_input(event:InputEvent):
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
  var world:Vector2=(event.position/size-Vector2(0.5,0.5))*Survey.HALF*2.0
  game.map_waypoint=Survey.nearest(world)
  game.mark_save()
  game.show_menu("map")
  accept_event()

func caption(at:Vector2,value:String,tint:Color,point_size:int=14):
 draw_string_outline(label_font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,point_size,4,Color("211820"))
 draw_string(label_font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,point_size,tint)
