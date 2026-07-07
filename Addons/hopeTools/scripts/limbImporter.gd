@tool
extends Node
class_name limbImporter

@export_dir var spriteFolder := ""
@export var _parent : Node2D
@export_tool_button("Importing Limbs") var importButton := importLimbs
@export_tool_button("Build Hiarchy") var buildButton := buildHiarchy
@export_tool_button("scene tree") var tree := func(): _parent.print_tree_pretty()
var isImported : bool = false
const PARENTS := {
	"UpperHandLeft" : "Torso" ,
	"LowerHandLeft" : "UpperHandLeft",
	"HandLeft" : "LowerHandLeft",
	"Head" : "Torso",
	"Jaw" : "Head",
	"EyeLeft" : "Head",
	"EyeRight" : "Head",
	"UpperHandRight" : "Torso" , 
	"LowerHandRight" : "UpperHandRight",
	"HandRight" : "LowerHandRight",
	"LowerLegRight" : "UpperLegRight",
	"BackFeetRight" : "LowerLegRight",
	"FrontFeetRight" : "BackFeetRight",
	"LowerLegLeft" : "UpperLegLeft",
	"BackFeetLeft" : "LowerLegLeft",
	"FrontFeetLeft" : "BackFeetLeft"
}

const SHOW_BEHIND_PARENT ={
	"Jaw" : true,
	
}

var limbs: Dictionary


func buildHiarchy():
	if isImported == false:
		return
	for limb in PARENTS:
		if !limbs.has(limb):
			push_warning("Missing limb: " + limb)
			continue
		if !limbs.has(PARENTS[limb]):
			push_warning("Missing parent: " + PARENTS[limb])
			continue
		limbs[limb].reparent(limbs[PARENTS[limb]])
		showBehindParent()
		reorder()

func showBehindParent():
	for limb in SHOW_BEHIND_PARENT:
		if limbs.has(limb):
			limbs[limb].show_behind_parent = SHOW_BEHIND_PARENT[limb]

func reorder():
	_parent.move_child(limbs["UpperLegLeft"], 0)
	_parent.move_child(limbs["UpperLegRight"], 1)
	_parent.move_child(limbs["Torso"], 2)

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
		var limbName := file.get_basename().strip_edges()
		if _parent.has_node(limbName):
			limbs[limbName] = _parent.get_node(limbName)
			continue
		var sprite := Sprite2D.new()
		sprite.name = file.get_basename()
		sprite.texture = load(spriteFolder.path_join(file))
		_parent.add_child(sprite)
		sprite.owner = get_tree().edited_scene_root
		limbs[sprite.name] = sprite
	dir.list_dir_end()
	isImported = true
