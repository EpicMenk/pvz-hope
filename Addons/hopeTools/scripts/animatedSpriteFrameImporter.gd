@tool
extends Node
class_name animatedSpriteFrameImporter

@export var targetAnimationPlayer : AnimationPlayer
@export var sprite : AnimatedSprite2D

# Key = AnimatedSprite2D animation name
# Value = AnimationPlayer animation name
@export var animationNameMap : Dictionary[StringName, StringName] = {
}

@export var fps : float = 30.0

@export_tool_button("Import All Frame Tracks")
var importButton : Callable = importFrameTracks


func importFrameTracks() -> void:
	if targetAnimationPlayer == null or sprite == null:
		push_error("frameTrackImporter: assign targetAnimationPlayer and sprite first.")
		return

	if sprite.sprite_frames == null:
		push_error("frameTrackImporter: sprite has no SpriteFrames resource.")
		return

	if fps <= 0.0:
		push_error("frameTrackImporter: fps must be greater than zero.")
		return

	if animationNameMap.is_empty():
		push_warning("frameTrackImporter: animationNameMap is empty.")
		return

	var imported_count : int = 0

	for spriteAnimationName in animationNameMap:
		var targetAnimationName : StringName = animationNameMap[spriteAnimationName]

		if not sprite.sprite_frames.has_animation(spriteAnimationName):
			push_error(
				"frameTrackImporter: sprite has no SpriteFrames animation named '%s'."
				% spriteAnimationName
			)
			continue

		if targetAnimationName == &"":
			push_error(
				"frameTrackImporter: target animation name is empty for sprite animation '%s'."
				% spriteAnimationName
			)
			continue

		if _importFrameTrack(spriteAnimationName, targetAnimationName):
			imported_count += 1

	print(
		"frameTrackImporter: imported %d/%d animation(s)."
		% [imported_count, animationNameMap.size()]
	)


func _importFrameTrack(
	spriteAnimationName : StringName,
	targetAnimationName : StringName
) -> bool:

	var frame_count : int = sprite.sprite_frames.get_frame_count(spriteAnimationName)

	if frame_count <= 0:
		push_error(
			"frameTrackImporter: '%s' has no frames."
			% spriteAnimationName
		)
		return false

	var interval : float = 1.0 / fps
	var length : float = (frame_count - 1) * interval

	var anim : Animation = _getOrCreateAnimation(
		targetAnimationName,
		length
	)

	var relativePath : NodePath = targetAnimationPlayer.get_parent().get_path_to(sprite)

	# ---------------------------------------------------------
	# Animation track
	# ---------------------------------------------------------
	# This tells AnimatedSprite2D which SpriteFrames animation
	# it should use.
	var animationPath : NodePath = NodePath(
		"%s:animation" % relativePath
	)

	var animationTrack : int = _findOrCreateTrack(
		anim,
		animationPath
	)

	anim.value_track_set_update_mode(
		animationTrack,
		Animation.UPDATE_DISCRETE
	)

	_clearTrackKeys(anim, animationTrack)

	# Set the AnimatedSprite2D animation at the beginning.
	anim.track_insert_key(
		animationTrack,
		0.0,
		spriteAnimationName
	)


	# ---------------------------------------------------------
	# Frame track
	# ---------------------------------------------------------
	# This controls which frame of that SpriteFrames animation
	# is displayed.
	var framePath : NodePath = NodePath(
		"%s:frame" % relativePath
	)

	var frameTrack : int = _findOrCreateTrack(
		anim,
		framePath
	)

	anim.value_track_set_update_mode(
		frameTrack,
		Animation.UPDATE_DISCRETE
	)

	_clearTrackKeys(anim, frameTrack)

	for i in frame_count:
		var t : float = i * interval
		anim.track_insert_key(
			frameTrack,
			t,
			i
		)

	print(
		"frameTrackImporter: wrote %d frame keys from '%s' into '%s'."
		% [
			frame_count,
			spriteAnimationName,
			targetAnimationName
		]
	)

	return true


func _findOrCreateTrack(
	anim : Animation,
	path : NodePath
) -> int:

	for i in anim.get_track_count():
		if anim.track_get_path(i) == path:
			return i

	var idx : int = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(idx, path)

	return idx


func _clearTrackKeys(
	anim : Animation,
	track : int
) -> void:

	# Iterate backwards since removing a key shifts
	# later indices down.
	for k in range(
		anim.track_get_key_count(track) - 1,
		-1,
		-1
	):
		anim.track_remove_key(track, k)


func _getOrCreateAnimation(
	anim_name : StringName,
	length : float
) -> Animation:

	var library : AnimationLibrary = (
		targetAnimationPlayer.get_animation_library("")
	)

	if library == null:
		library = AnimationLibrary.new()
		targetAnimationPlayer.add_animation_library(
			"",
			library
		)

	var anim : Animation = library.get_animation(anim_name)

	if anim == null:
		anim = Animation.new()
		anim.length = length
		library.add_animation(anim_name, anim)

	else:
		# Make sure an existing animation gets the correct length.
		anim.length = length

	return anim
