@tool
extends Node2D

@export var output_dir : String = "res://BakedFrames/"
@export var target_fps : float = 30
@export var animations_to_bake : Array[String] = []
@export var capture_size : Vector2i = Vector2i(128, 128)

@onready var viewport : SubViewport = %SubViewport
@onready var rig_container : Node2D = %Node2D

@export_tool_button("Scan Folder") var scanFolder := scanFiles

var _anim_player : AnimationPlayer

func scanFiles():
	if Engine.is_editor_hint():
		var fileSystem := EditorInterface.get_resource_filesystem()
		if not fileSystem.is_scanning():
			fileSystem.scan()

func _ready():
	if Engine.is_editor_hint():
		return
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

	var crop_rect := await _compute_global_crop_rect(anim_list)

	for anim_name in anim_list:
		await _bake_animation(anim_name, crop_rect)

	print("Baking complete! Check: ", output_dir)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found:
			return found
	return null

func _bake_animation(anim_name: String, crop_rect: Rect2i):

	_anim_player.play(anim_name)
	_anim_player.pause()
	_anim_player.seek(0.0, true)
	_anim_player.advance(0.0)

	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw

	var animation := _anim_player.get_animation(anim_name)

	var frame_interval := 1.0 / target_fps
	var frame_count := int(animation.length / frame_interval) + 1

	var columns := int(ceil(sqrt(frame_count)))
	var rows := int(ceil(float(frame_count) / columns))

	var frames : Array[Image] = []

	for frame_i in range(frame_count):

		var t := frame_i * frame_interval

		_anim_player.seek(t, true)
		_anim_player.advance(0.0)

		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw

		frames.append(viewport.get_texture().get_image())

	var sheet := Image.create(
		columns * crop_rect.size.x,
		rows * crop_rect.size.y,
		false,
		Image.FORMAT_RGBA8
	)
	for i in range(frame_count):

		var cropped := Image.create(
			crop_rect.size.x,
			crop_rect.size.y,
			false,
			Image.FORMAT_RGBA8
		)

		cropped.blit_rect(
			frames[i],
			crop_rect,
			Vector2i.ZERO
		)

		var col := i % columns
		@warning_ignore("integer_division")
		var row := i / columns

		var dst := Vector2i(
			col * crop_rect.size.x,
			row * crop_rect.size.y
		)

		sheet.blit_rect(
			cropped,
			Rect2i(Vector2i.ZERO, crop_rect.size),
			dst
		)

	var sheet_path := output_dir.path_join(anim_name + ".png")
	sheet.save_png(sheet_path)

	var meta_path := output_dir.path_join(anim_name + "_info.txt")
	var meta_file := FileAccess.open(meta_path, FileAccess.WRITE)

	meta_file.store_string(
		"frame_count: %d\ncolumns: %d\nrows: %d\nframe_size: %dx%d\n"
		% [
			frame_count,
			columns,
			rows,
			crop_rect.size.x,
			crop_rect.size.y
		]
	)

	meta_file.close()
	print(
		"Baked '",
		anim_name,
		"': ",
		frame_count,
		" frames -> ",
		sheet_path,
		" (",
		columns,
		"x",
		rows,
		" grid)"
	)


func _get_trim_rect(img: Image) -> Rect2i:
	var min_x := img.get_width()
	var min_y := img.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a > 0.001:
				min_x = min(min_x, x)
				min_y = min(min_y, y)
				max_x = max(max_x, x)
				max_y = max(max_y, y)
	if max_x == -1:
		return Rect2i(Vector2i.ZERO, Vector2i.ONE)
	return Rect2i(
		min_x,
		min_y,
		max_x - min_x + 1,
		max_y - min_y + 1
	)


func _compute_global_crop_rect(anim_list: Array[String]) -> Rect2i:

	var global_min_x := capture_size.x
	var global_min_y := capture_size.y
	var global_max_x := 0
	var global_max_y := 0

	const PADDING := 2

	for anim_name in anim_list:

		_anim_player.play(anim_name)
		_anim_player.pause()
		_anim_player.seek(0.0, true)
		_anim_player.advance(0.0)

		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw

		var animation := _anim_player.get_animation(anim_name)

		var frame_interval := 1.0 / target_fps
		var frame_count := int(animation.length / frame_interval) + 1

		for frame_i in range(frame_count):

			var t := frame_i * frame_interval

			_anim_player.seek(t, true)
			_anim_player.advance(0.0)

			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw

			var frame_img := viewport.get_texture().get_image()
			var trim := _get_trim_rect(frame_img)

			global_min_x = min(global_min_x, trim.position.x)
			global_min_y = min(global_min_y, trim.position.y)

			global_max_x = max(global_max_x, trim.position.x + trim.size.x)
			global_max_y = max(global_max_y, trim.position.y + trim.size.y)

	global_min_x = max(global_min_x - PADDING, 0)
	global_min_y = max(global_min_y - PADDING, 0)

	global_max_x = min(global_max_x + PADDING, capture_size.x)
	global_max_y = min(global_max_y + PADDING, capture_size.y)

	var crop_rect := Rect2i(
		global_min_x,
		global_min_y,
		global_max_x - global_min_x,
		global_max_y - global_min_y
	)

	print("Global crop rect: ", crop_rect)

	return crop_rect
