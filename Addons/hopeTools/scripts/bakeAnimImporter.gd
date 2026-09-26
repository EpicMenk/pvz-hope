@tool
extends Node
class_name bakeAnimImporter

@export var sprite : AnimatedSprite2D
@export var sheetsAndData : Dictionary [Texture2D , animMetaData]
@export_tool_button("Import") var importButton := importPart
@export_tool_button("test") var test : Callable = func(): print("hello")



func importPart():
	if sprite == null:
		push_error("Needs an AnimatedSprite2D lil bro")
		return
	
	
	if sheetsAndData.is_empty():
		push_error("Needs to fill in the dictionary blud")
		return
	
	if sprite.sprite_frames == null:
		sprite.sprite_frames = SpriteFrames.new()
	
	for sheet in sheetsAndData:
		var meta : animMetaData = sheetsAndData[sheet]
		var animName : String = sheet.resource_path.get_file().get_basename()
		
		if sprite.sprite_frames.has_animation("default"):
			sprite.sprite_frames.remove_animation("default")
		
		if sprite.sprite_frames.has_animation(animName):
			sprite.sprite_frames.remove_animation(animName)
		sprite.sprite_frames.add_animation(animName)
		sprite.sprite_frames.set_animation_speed(animName, meta.fps)
		
		for i in meta.framesCount:
			var col : int = i % meta.columns
			@warning_ignore("integer_division")
			var row : int = i / meta.columns
		
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(
				col * meta.frameSize.x,
				row * meta.frameSize.y,
				meta.frameSize.x,
				meta.frameSize.y
			)
			
			sprite.sprite_frames.add_frame(animName, atlas)
		sprite.position = meta.layerOffset
		print(sprite.position, meta.layerOffset)
