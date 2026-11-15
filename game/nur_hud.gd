extends RefCounted

const SLATE := Color("17242e")
const LINE := Color("426172")
const TEXT := Color("e6f1f2")
const SECONDARY := Color("afc2ce")
const ACCENT := Color("96ddec")
const GOOD := Color("a8dfbd")
const ALERT := Color("f4a28b")
const GREY := Color("718895")

class Reticle extends Control:
 var kind := "none"
 var progress := 0.0

 func _draw():
  var middle := size/2
  var tint := Color("e5eff0")
  match kind:
   "resource":tint=Color("9deafa")
   "machine":tint=Color("b9dff8")
   "storage":tint=Color("ffd3a0")
   "valid":tint=Color("a5ddb7")
   "invalid":tint=Color("ff9f91")
  var gap := 4.0 if kind=="none" else 6.0
  for offset in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
   draw_line(middle+offset*gap,middle+offset*(gap+4.5),Color("27343c"),3.3,true)
   draw_line(middle+offset*gap,middle+offset*(gap+4.5),tint,1.4,true)
  if progress>0.0:
   draw_arc(middle,15,-PI/2,progress*TAU-PI/2,24,tint,2.0,true)
  elif kind=="storage":
   draw_rect(Rect2(middle-Vector2.ONE*2,Vector2.ONE*4),tint,false,1)
  else:
   draw_circle(middle,1.15,tint)

class SuitIcon extends Control:
 var type := 0

 func _draw():
  var c := Color("fff4e9")
  var x := size.x/2
  var y := size.y/2
  var outline:=PackedVector2Array()
  for i in range(6):
   var angle:=-PI/2+i*TAU/6
   outline.append(Vector2(x,y)+Vector2(cos(angle),sin(angle))*18.0)
  draw_colored_polygon(outline,Color(0.08,0.047,0.043,0.62))
  outline.append(outline[0])
  draw_polyline(outline,Color(0.08,0.05,0.04,0.82),3.4,true)
  draw_polyline(outline,c,1.35,true)
  match type:
   0:
    draw_circle(Vector2(x-4.0,y-2.9),5.1,c,true,-1,true)
    draw_circle(Vector2(x+4.0,y-2.9),5.1,c,true,-1,true)
    draw_colored_polygon(PackedVector2Array([Vector2(x-8,y),Vector2(x,y+9),Vector2(x+8,y)]),c)
   1:
    draw_circle(Vector2(x,y+3.3),6.25,c,true,-1,true)
    draw_colored_polygon(PackedVector2Array([Vector2(x-5.9,y+1.2),Vector2(x,y-10),Vector2(x+5.9,y+1.2)]),c)
    draw_arc(Vector2(x,y+3),3.6,0.1,2.8,12,Color("34241d"),1.5,true)
   2:
    draw_string(ThemeDB.fallback_font,Vector2(x-10.5,y+5),"O₂",HORIZONTAL_ALIGNMENT_LEFT,-1,16,c)

class Gauge extends Control:
 var value := 100.0
 var displayed := 100.0
 var warning := false
 var pulse := 1.0

 func update_fill(dt:float):
  displayed=lerpf(displayed,value,minf(1.0,dt*12.0))
  queue_redraw()

 func _draw():
  var bounds:=Rect2(Vector2.ZERO,size)
  var tint:=Color("fff4e9") if not warning else Color(1.0,0.54,0.42,pulse)
  draw_rect(bounds.grow(1.5),Color(0.08,0.045,0.036,0.75))
  draw_rect(Rect2(Vector2.ONE*2,Vector2((size.x-4)*clampf(displayed/100.0,0,1),size.y-4)),tint)
  draw_rect(bounds,Color(1,0.93,0.88,0.86),false,1.0)

class VisorFrame extends Control:
 func _draw():
  var edge:=Color(1,0.91,0.83,0.49)
  var shade:=Color(0.06,0.035,0.034,0.65)
  for side in [0.0,size.x]:
   var direction:=1.0 if side==0.0 else -1.0
   var points:=PackedVector2Array([Vector2(side+direction*23,0),Vector2(side+direction*7,0),Vector2(side,7),Vector2(side,size.y-7),Vector2(side+direction*7,size.y),Vector2(side+direction*23,size.y)])
   draw_polyline(points,shade,3.4,true)
   draw_polyline(points,edge,1.25,true)

class CompassTape extends Control:
 var heading := 0.0
 var font: Font

 func set_heading(value:float):
  if is_equal_approx(heading,value):return
  heading=value
  queue_redraw()

 func _draw():
  var edge:=Color(1,0.94,0.89,0.68)
  var light:=Color("fff4e9")
  var back:=Color(0.10,0.064,0.049,0.30)
  var points:=PackedVector2Array([Vector2(0,7),Vector2(8,0),Vector2(size.x-8,0),Vector2(size.x,7),Vector2(size.x,36),Vector2(size.x-8,43),Vector2(8,43),Vector2(0,36)])
  draw_colored_polygon(points,back)
  var closed:=points.duplicate()
  closed.append(points[0])
  draw_polyline(closed,edge,1.0,true)
  var directions:=["N","NE","E","SE","S","SW","W","NW"]
  var middle:=size.x/2
  var tick_origin:=int(floor(heading/7.5))
  for i in range(tick_origin-8,tick_origin+9):
   var x:=middle+(i*7.5-heading)*3.7
   if x<12 or x>size.x-12:continue
   var major:=i%6==0
   draw_line(Vector2(x,5),Vector2(x,16 if major else 10),edge,1.35,true)
   if major and font:
    var text: String = directions[posmod(i/6,8)]
    var width:=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,16).x
    draw_string_outline(font,Vector2(x-width/2,35),text,HORIZONTAL_ALIGNMENT_LEFT,-1,16,3,Color("201310"))
    draw_string(font,Vector2(x-width/2,35),text,HORIZONTAL_ALIGNMENT_LEFT,-1,16,light)
  draw_colored_polygon(PackedVector2Array([Vector2(middle-5,-4),Vector2(middle+5,-4),Vector2(middle,3)]),light)

class ObjectiveMarker extends Control:
 var active := false

 func _draw():
  var center:=size/2
  var tint:=Color("fff4e9") if active else Color("dfc6b4")
  var points:=PackedVector2Array([center-Vector2(0,6),center+Vector2(5,0),center+Vector2(0,6),center-Vector2(5,0)])
  if active:
   draw_colored_polygon(points,tint)
  else:
   points.append(points[0])
   draw_polyline(points,tint,1.4,true)

class PlanetMark extends Control:
 func _draw():
  var c:=size*0.5
  var tint:=Color("fff4e9")
  var outline:=Color("2d1c17")
  draw_arc(c,19,0,TAU,48,outline,3.5,true)
  draw_arc(c,19,0,TAU,48,tint,1.4,true)
  var ellipse:=PackedVector2Array()
  for i in range(33):
   var angle:=float(i)*TAU/32.0
   ellipse.append(c+Vector2(cos(angle)*9,sin(angle)*19))
  draw_polyline(ellipse,tint,1.2,true)
  for offset in [-8,0,8]:
   var width:=sqrt(19.0*19.0-offset*offset)
   draw_line(c+Vector2(-width,offset),c+Vector2(width,offset),tint,1.2,true)
  draw_arc(c,25,-2.64,0.45,28,tint,1.45,true)
  draw_arc(c,25,0.6,3.58,28,tint,1.45,true)

static func shortages(inventory:Dictionary,cost:Dictionary) -> Dictionary:
 var missing := {}
 for id in cost:
  var amount := int(cost[id])-int(inventory.get(id,0))
  if amount>0:missing[id]=amount
 return missing

static func resource_card(spec,has_space:bool,seconds:float) -> Dictionary:
 return {
  "title":spec.id,
  "body":spec.rarity.to_upper()+" MINERAL   •   %.2f s\n%s"%[seconds,spec.description],
  "hint":"Hold LMB to mine" if has_space else "Backpack full · Free a slot",
  "id":spec.id,
  "kind":"resource",
  "ok":has_space
 }
