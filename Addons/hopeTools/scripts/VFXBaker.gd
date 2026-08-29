extends Node
class_name vfxBaker

@export var viewport : SubViewport
@export var output_dir : String = "res://BakedVfx/"
@export var target_fps : float = 30.0
@export var duration : float = PI / 3.0
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
	_previousMaxFps = Engine.max_fps
	_previousVsyncMode = DisplayServer.window_get_vsync_mode()

	Engine.max_fps = 999
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	var interval := 1.0 / target_fps
	_baseFrameCount = int(duration / interval) + 1
	_targetFrameCount = _baseFrameCount + (crossfadeFrames if loopEnabled else 0)

	_frames.clear()
	_elapsed = 0.0
	_nextCaptureTime = 0.0
	_capturedCount = 0

	while _capturedCount < _targetFrameCount:
		await get_tree().process_frame
		_elapsed += get_process_delta_time()

		while _elapsed >= _nextCaptureTime and _capturedCount < _targetFrameCount:
			await RenderingServer.frame_post_draw
			_frames.append(viewport.get_texture().get_image())
			_capturedCount += 1
			_nextCaptureTime = _capturedCount * interval

	_finishBake()


#func _process(delta : float) -> void:
	#if not _baking:
		#return
#
	#_elapsed += delta
#
	#var interval := 1.0 / target_fps
#
	#while _elapsed >= _nextCaptureTime and _capturedCount < _targetFrameCount:
		#_frames.append(viewport.get_texture().get_image())
		#_capturedCount += 1
		#_nextCaptureTime = _capturedCount * interval
#
	#if _capturedCount >= _targetFrameCount:
		#_finishBake()


func _finishBake() -> void:
	_baking = false
	set_process(false)

	Engine.max_fps = _previousMaxFps
	DisplayServer.window_set_vsync_mode(_previousVsyncMode)

	if loopEnabled:
		_crossfadeLoop()

	_frames.resize(_baseFrameCount)

	packAndSave(_frames , viewport.size , output_dir , "adrian")
	


func packAndSave(frames: Array[Image], frame_size: Vector2i, _output_dir: String, anim_name: String) -> Dictionary:
	var columns := int(ceil(sqrt(frames.size())))
	var rows := int(ceil(float(frames.size()) / columns))

	var sheet := Image.create(columns * frame_size.x, rows * frame_size.y, false, Image.FORMAT_RGBA8)

	for i in frames.size():
		var col := i % columns
		@warning_ignore("integer_division")
		var row := i / columns
		sheet.blit_rect(frames[i], Rect2i(Vector2i.ZERO, frame_size), Vector2i(col * frame_size.x, row * frame_size.y))

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_output_dir))
	sheet.save_webp(output_dir.path_join(anim_name + ".webp"), false)  # false = lossless
	print("finished baking check: " , output_dir)
	return {"columns": columns, "rows": rows, "frame_count": frames.size()}



func _crossfadeLoop() -> void:
	for i in range(1, crossfadeFrames + 1):
		var weight := float(i) / float(crossfadeFrames + 1)
		_frames[i - 1] = _blendImages(_frames[i - 1], _frames[_baseFrameCount + i - 1], weight)


func _blendImages(a : Image, b : Image, weight : float) -> Image:
	var result := Image.create(a.get_width(), a.get_height(), false, Image.FORMAT_RGBA8)

	for y in a.get_height():
		for x in a.get_width():
			var colorA := a.get_pixel(x, y)
			var colorB := b.get_pixel(x, y)
			result.set_pixel(x, y, colorA.lerp(colorB, weight))

	return result
