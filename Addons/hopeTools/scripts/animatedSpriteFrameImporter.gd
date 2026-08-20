@tool
extends Node
class_name animatedSpriteFrameImporter

@export var targetAnimationPlayer : AnimationPlayer
@export var sprite : AnimatedSprite2D
@export var spriteAnimationName : StringName = "default"
@export var targetAnimationName : StringName = "walk"
@export var fps : float = 30.0

@export_tool_button("Import Frame Track")
var importButton : Callable = importFrameTrack


func importFrameTrack() -> void:
	if targetAnimationPlayer == null or sprite == null:
		push_error("frameTrackImporter: assign targetAnimationPlayer and sprite first.")
		return

	if sprite.sprite_frames == null or not sprite.sprite_frames.has_animation(spriteAnimationName):
		push_error("frameTrackImporter: sprite has no SpriteFrames animation named '%s'." % spriteAnimationName)
		return

	if fps <= 0.0:
		push_error("frameTrackImporter: fps must be greater than zero.")
		return

	var frame_count : int = sprite.sprite_frames.get_frame_count(spriteAnimationName)

	if frame_count <= 0:
		push_error("frameTrackImporter: '%s' has no frames." % spriteAnimationName)
		return

	var interval : float = 1.0 / fps
	var length : float = (frame_count - 1) * interval

	var anim : Animation = _getOrCreateAnimation(targetAnimationName, length)

	var relativePath : NodePath = targetAnimationPlayer.get_parent().get_path_to(sprite)
	var path : NodePath = NodePath("%s:frame" % relativePath)
	var idx : int = _findOrCreateTrack(anim, path)

	anim.value_track_set_update_mode(idx, Animation.UPDATE_DISCRETE)

	_clearTrackKeys(anim, idx)

	for i in frame_count:
		var t : float = i * interval
		anim.track_insert_key(idx, t, i)

	print(
		"frameTrackImporter: wrote %d frame keys for '%s' into '%s'."
		% [frame_count, sprite.name, targetAnimationName]
	)


func _findOrCreateTrack(anim : Animation, path : NodePath) -> int:
	for i in anim.get_track_count():
		if anim.track_get_path(i) == path:
			return i

	var idx : int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(idx, path)
	return idx


func _clearTrackKeys(anim : Animation, track : int) -> void:
	# Iterate backwards since removing a key shifts later indices down.
	for k in range(anim.track_get_key_count(track) - 1, -1, -1):
		anim.track_remove_key(track, k)


func _getOrCreateAnimation(anim_name : StringName, length : float) -> Animation:
	var library : AnimationLibrary = targetAnimationPlayer.get_animation_library("")

	if library == null:
		library = AnimationLibrary.new()
		targetAnimationPlayer.add_animation_library("", library)

	var anim : Animation = library.get_animation(anim_name)

	if anim == null:
		anim = Animation.new()
		anim.length = length
		library.add_animation(anim_name, anim)

	return anim
