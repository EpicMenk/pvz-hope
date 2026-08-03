@tool
extends Node2D

## Drop each limb's source image into its matching slot below, then
## press the button to rename the underlying files to match.
@export var UpperHandLeft : Texture2D
@export var LowerHandLeft : Texture2D
@export var HandLeft : Texture2D
@export var LowerLegLeft : Texture2D
@export var UpperLegLeft : Texture2D
@export var BackFeetLeft : Texture2D
@export var FrontFeetLeft : Texture2D
@export var LowerLegRight : Texture2D
@export var UpperLegRight : Texture2D
@export var BackFeetRight : Texture2D
@export var FrontFeetRight : Texture2D
@export var Torso : Texture2D
@export var LowerHandRight : Texture2D
@export var UpperHandRight : Texture2D
@export var HandRight : Texture2D
@export var Jaw : Texture2D
@export var Head : Texture2D
@export var EyeLeft : Texture2D
@export var EyeRight : Texture2D

@export_tool_button("Rename Limbs") var rename_action : Callable = renameLimbs


func _buildLimbDictionary() -> Dictionary:
	return {
		"UpperHandLeft": UpperHandLeft,
		"LowerHandLeft": LowerHandLeft,
		"HandLeft": HandLeft,
		"LowerLegLeft": LowerLegLeft,
		"UpperLegLeft": UpperLegLeft,
		"BackFeetLeft": BackFeetLeft,
		"FrontFeetLeft": FrontFeetLeft,
		"LowerLegRight": LowerLegRight,
		"UpperLegRight": UpperLegRight,
		"BackFeetRight": BackFeetRight,
		"FrontFeetRight": FrontFeetRight,
		"Torso": Torso,
		"LowerHandRight": LowerHandRight,
		"UpperHandRight": UpperHandRight,
		"HandRight": HandRight,
		"Jaw": Jaw,
		"Head": Head,
		"EyeLeft": EyeLeft,
		"EyeRight": EyeRight,
	}


func renameLimbs():
	if not Engine.is_editor_hint():
		return

	var limbTextures := _buildLimbDictionary()
	var renamed_count := 0
	var skipped : Array[String] = []

	for limb_name in limbTextures:
		var texture : Texture2D = limbTextures[limb_name]
		if texture == null:
			skipped.append(limb_name)
			continue
		if _renameOne(limb_name, texture):
			renamed_count += 1

	if not skipped.is_empty():
		push_warning("No texture assigned for: " + ", ".join(skipped))

	print("Renamed ", renamed_count, " limb texture(s).")

	var fs := EditorInterface.get_resource_filesystem()
	if not fs.is_scanning():
		fs.scan()


func _renameOne(limb_name: String, texture: Texture2D) -> bool:
	var old_path := texture.resource_path
	if old_path.is_empty():
		push_warning("Texture for '" + limb_name + "' has no resource_path — is it an imported file?")
		return false

	var dir_path := old_path.get_base_dir()
	var extension := old_path.get_extension()
	var old_filename := old_path.get_file()
	var new_filename := limb_name + "." + extension

	if old_filename == new_filename:
		return false

	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_error("Could not open directory: " + dir_path)
		return false

	if dir.file_exists(new_filename):
		push_error("Cannot rename '" + old_filename + "' -> '" + new_filename + "' — a file with that name already exists.")
		return false

	var err := dir.rename(old_filename, new_filename)
	if err != OK:
		push_error("Failed to rename '" + old_filename + "' -> '" + new_filename + "' (error " + str(err) + ")")
		return false

	print("Renamed: ", old_filename, " -> ", new_filename)
	return true
