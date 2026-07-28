extends Node2D

@export var output_dir : String = "res://BakedFrames/"
@export var target_fps : float = 24.0
@export var animations_to_bake : Array[String] = []
@export var capture_size : Vector2i = Vector2i(128, 128)

@onready var viewport : SubViewport = %SubViewport
@onready var rig_container : Node2D = %Node2D

var _anim_player : AnimationPlayer

func _ready():
	viewport.size = capture_size
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	_anim_player = _find_animation_player(rig_container)
	if _anim_player == null:
		push_error("No AnimationPlayer found under RigContainer.")
		return

	var anim_list := animations_to_bake
	if anim_list.is_empty():
		anim_list.assign(_anim_player.get_animation_list())

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))

	for anim_name in anim_list:
		await _bake_animation(anim_name)

	print("Baking complete! Check: ", output_dir)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found:
			return found
	return null

func _bake_animation(anim_name: String):
	var animation := _anim_player.get_animation(anim_name)
	var frame_interval := 1.0 / target_fps
	var frame_count := int(animation.length / frame_interval) + 1

	# Roughly-square grid instead of one long strip — safer for mobile
	# max-texture-size limits on animations with lots of frames.
	var columns := int(ceil(sqrt(frame_count)))
	var rows := int(ceil(float(frame_count) / columns))

	var sheet := Image.create(
		columns * capture_size.x,
		rows * capture_size.y,
		false,
		Image.FORMAT_RGBA8
	)

	for frame_i in range(frame_count):
		var t := frame_i * frame_interval
		_anim_player.seek(t, true)

		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw

		var frame_img := viewport.get_texture().get_image()

		var col := frame_i % columns
		var row := frame_i / columns
		var dst := Vector2i(col * capture_size.x, row * capture_size.y)
		sheet.blit_rect(frame_img, Rect2i(Vector2i.ZERO, capture_size), dst)

	var sheet_path := output_dir.path_join(anim_name + ".png")
	sheet.save_png(sheet_path)

	# Sidecar so you know the exact grid dimensions when setting up
	# SpriteFrames' "Add frames from Sprite Sheet" import — no need to
	# recompute or eyeball it later.
	var meta_path := output_dir.path_join(anim_name + "_info.txt")
	var meta_file := FileAccess.open(meta_path, FileAccess.WRITE)
	meta_file.store_string(
		"frame_count: %d\ncolumns: %d\nrows: %d\nframe_size: %dx%d\n" % [
			frame_count, columns, rows, capture_size.x, capture_size.y
		]
	)
	meta_file.close()

	print("Baked '", anim_name, "': ", frame_count, " frames -> ", sheet_path,
		" (", columns, "x", rows, " grid)")
