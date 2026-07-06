@tool
extends Node
class_name limbImporter

@export_dir var spriteFolder := ""
@export var parent : Node2D
@export_tool_button("Importing Limbs") var importButton := importLimbs





func importLimbs():
	var dir := DirAccess.open(spriteFolder)
	if dir == null:
		push_error("can't find the directory brotato")
		return 
	dir.list_dir_begin()
	
	while true:
		var file := dir.get_next()
		if file == "":
			break
		if !file.ends_with(".png"):
			continue
		var limbName := file.get_basename()
		if parent.has_node(limbName):
			continue
		var sprite := Sprite2D.new()
		sprite.name = file.get_basename()
		sprite.texture = load(spriteFolder.path_join(file))
		parent.add_child(sprite)
		sprite.owner = get_tree().edited_scene_root
	dir.list_dir_end()
	print("importing from:" , spriteFolder)
