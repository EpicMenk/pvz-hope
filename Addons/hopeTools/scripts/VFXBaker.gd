extends Node
class_name vfxBaker

@export var viewport : SubViewport
@export var output_dir : String = "res://BakedFrames/"
@export var target_fps : float = 30.0
@export var duration : float = 4.0
@export var loopEnabled : bool = true
@export var crossfadeFrames : int = 8

var _frames : Array[Image] = []
var _elapsed : float = 0.0
var _nextCaptureTime : float = 0.0
var _capturedCount : int = 0
var _baseFrameCount : int = 0
var _targetFrameCount : int = 0
var _baking : bool = false

var _previousMaxFps : int
var _previousVsyncMode : DisplayServer.VSyncMode


func _ready() -> void:
	startBake()


func startBake() -> void:
	if viewport == null:
		push_error("vfxBaker: viewport is not assigned.")
		return

	if target_fps <= 0.0:
		push_error("vfxBaker: target_fps must be greater than 0.")
		return

	if duration <= 0.0:
		push_error("vfxBaker: duration must be greater than 0.")
		return

	if crossfadeFrames < 0:
		push_error("vfxBaker: crossfadeFrames cannot be negative.")
		return

	_previousMaxFps = Engine.max_fps
	_previousVsyncMode = DisplayServer.window_get_vsync_mode()

	Engine.max_fps = 999
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_DISABLED
	)

	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	var interval : float = 1.0 / target_fps

	# Number of unique frames in the original animation.
	#
	# Example:
	# 1 second × 30 FPS = 30 frames
	#
	# Frame times:
	# 0.000
	# 0.033
	# ...
	# 0.966
	#
	# There is intentionally no extra frame at exactly 1.0.
	_baseFrameCount = int(
		duration * target_fps
	)

	_targetFrameCount = _baseFrameCount

	if loopEnabled:
		_targetFrameCount += crossfadeFrames

	_frames.clear()
	_elapsed = 0.0
	_nextCaptureTime = 0.0
	_capturedCount = 0
	_baking = true

	while _capturedCount < _targetFrameCount:
		await get_tree().process_frame

		_elapsed += get_process_delta_time()

		while (
			_elapsed >= _nextCaptureTime
			and _capturedCount < _targetFrameCount
		):
			await RenderingServer.frame_post_draw
			_frames.append(
				viewport.get_texture().get_image()
			)

			_capturedCount += 1
			_nextCaptureTime = _capturedCount * interval

	_finishBake()


func _finishBake() -> void:
	_baking = false
	set_process(false)

	Engine.max_fps = _previousMaxFps
	DisplayServer.window_set_vsync_mode(
		_previousVsyncMode
	)

	if loopEnabled and crossfadeFrames > 0:
		_crossfadeLoop()

	# Only the original animation frames are exported.
	_frames.resize(_baseFrameCount)

	packAndSave(
		_frames,
		viewport.size,
		output_dir,
		"adrian"
	)


func _crossfadeLoop() -> void:
	var fadeCount : int = min(
		crossfadeFrames,
		_baseFrameCount
	)

	for i in fadeCount:
		var baseIndex : int = i
		var extraIndex : int = _baseFrameCount + i

		# The extra frame fades out while the original beginning
		# frame fades in.
		#
		# i = 0:
		#     mostly extra frame
		#
		# final fade frame:
		#     completely original frame
		var weight : float = (
			float(i + 1) / float(fadeCount)
		)

		_frames[baseIndex] = _blendImages(
			_frames[extraIndex],
			_frames[baseIndex],
			weight
		)


func _blendImages(
	a : Image,
	b : Image,
	weight : float
) -> Image:

	var result : Image = Image.create(
		a.get_width(),
		a.get_height(),
		false,
		Image.FORMAT_RGBA8
	)

	for y in a.get_height():
		for x in a.get_width():
			var colorA : Color = a.get_pixel(x, y)
			var colorB : Color = b.get_pixel(x, y)

			result.set_pixel(
				x,
				y,
				colorA.lerp(colorB, weight)
			)

	return result


func packAndSave(
	frames : Array[Image],
	frame_size : Vector2i,
	_output_dir : String,
	anim_name : String
) -> Dictionary:

	var columns : int = int(
		ceil(sqrt(frames.size()))
	)

	var rows : int = int(
		ceil(float(frames.size()) / columns)
	)

	var sheet : Image = Image.create(
		columns * frame_size.x,
		rows * frame_size.y,
		false,
		Image.FORMAT_RGBA8
	)

	for i in frames.size():
		var col : int = i % columns

		@warning_ignore("integer_division")
		var row : int = i / columns

		sheet.blit_rect(
			frames[i],
			Rect2i(
				Vector2i.ZERO,
				frame_size
			),
			Vector2i(
				col * frame_size.x,
				row * frame_size.y
			)
		)

	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(_output_dir)
	)

	sheet.save_webp(
		output_dir.path_join(anim_name + ".webp"),
		false
	)

	print(
		"Finished baking check: ",
		output_dir
	)

	return {
		"columns": columns,
		"rows": rows,
		"frame_count": frames.size()
	}
