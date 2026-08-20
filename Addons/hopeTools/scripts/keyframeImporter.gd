@tool
extends Node
class_name markerImporter

@export var targetAnimationPlayer : AnimationPlayer
@export var markerNode : Node2D          # the marker as it exists in THIS entity scene
@export var sourceTrackResource : Animation   # the .tres saved by markerCopier
@export var anim_name : StringName = "attack"

@export_tool_button("Import Marker Track") var importButton := importTrack


func importTrack():
	if targetAnimationPlayer == null or sourceTrackResource == null or markerNode == null:
		push_error("markerImporter: assign targetAnimationPlayer, markerNode, and sourceTrackResource first.")
		return

	var targetAnim := _getOrCreateAnimation(anim_name, sourceTrackResource)
	var relativePath := targetAnimationPlayer.get_parent().get_path_to(markerNode)

	var mergedCount := 0
	for property in ["position", "rotation", "scale"]:
		if _mergeProperty(sourceTrackResource, targetAnim, property, relativePath):
			mergedCount += 1

	print("markerImporter: merged %d track(s) for '%s' into '%s'." % [mergedCount, markerNode.name, anim_name])


func _mergeProperty(source: Animation, target: Animation, property: String, relativePath: NodePath) -> bool:
	var srcTrack := _findTrackByProperty(source, property)
	if srcTrack == -1:
		return false

	var path := NodePath("%s:%s" % [relativePath, property])
	var idx := _findOrCreateTrack(target, path)

	for k in source.track_get_key_count(srcTrack):
		var t := source.track_get_key_time(srcTrack, k)
		var v = source.track_get_key_value(srcTrack, k)
		target.track_insert_key(idx, t, v)

	return true


func _findTrackByProperty(anim: Animation, property: String) -> int:
	for i in anim.get_track_count():
		if str(anim.track_get_path(i)).ends_with(":" + property):
			return i
	return -1


func _findOrCreateTrack(anim: Animation, path: NodePath) -> int:
	for i in anim.get_track_count():
		if anim.track_get_path(i) == path:
			return i
	var idx := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(idx, path)
	anim.track_set_interpolation_type(idx, Animation.INTERPOLATION_CUBIC)
	return idx


func _getOrCreateAnimation(
	_name : StringName,
	sourceAnimation : Animation
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

	var anim : Animation = library.get_animation(_name)

	if anim == null:
		anim = Animation.new()
		anim.length = sourceAnimation.length
		anim.loop_mode = sourceAnimation.loop_mode
		anim.step = sourceAnimation.step

		library.add_animation(
			_name,
			anim
		)

	return anim
