extends SceneTree

func _init():
 var art:=Image.new()
 var result:=art.load_svg_from_string(FileAccess.get_file_as_string("res://app-mark.svg"))
 if result!=OK:quit(1);return
 result=art.save_png("res://app-mark.png")
 quit(0 if result==OK else 1)
