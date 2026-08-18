@tool
extends Node2D
class_name markerCopier

@export var originMarker : Marker2D
@export var markerToCopy : Marker2D
@export var output_dir : String = "res://BakedFrames/"
@export var animPlayer : AnimationPlayer
@export var fps : float = 24.0
@export var animationName : String
@export_tool_button("Copy Marker")
var copier : Callable = copyMarker

func copyMarker():
	copyMarkerTrack(animPlayer, animationName, fps)

func copyMarkerTrack(rigAnimPlayer: AnimationPlayer, anim_name: String, target_fps: float) -> void:
	if originMarker == null or markerToCopy == null:
		push_error("markerCopier: assign originMarker and markerToCopy first.")
		return

	var sourceAnim : Animation = rigAnimPlayer.get_animation(anim_name)
	if sourceAnim == null:
		push_error("markerCopier: rig has no animation named '%s'." % anim_name)
		return

	var times := _existingTrackTimes(sourceAnim)
	var mode := "existing" if not times.is_empty() else "sampled"

	if times.is_empty():
		times = _sampledTimes(sourceAnim.length, target_fps)

	var outAnim := Animation.new()
	outAnim.length = sourceAnim.length

	var path := NodePath("%s:position" % markerToCopy.name)
	var posIdx := outAnim.add_track(Animation.TYPE_VALUE)
	outAnim.track_set_path(posIdx, path)
	var rotIdx := outAnim.add_track(Animation.TYPE_VALUE)
	outAnim.track_set_path(rotIdx, NodePath("%s:rotation" % markerToCopy.name))
	var scaleIdx := outAnim.add_track(Animation.TYPE_VALUE)
	outAnim.track_set_path(scaleIdx, NodePath("%s:scale" % markerToCopy.name))

	for idx in [posIdx, rotIdx, scaleIdx]:
		outAnim.track_set_interpolation_type(idx, Animation.INTERPOLATION_CUBIC)

	rigAnimPlayer.play(anim_name)
	rigAnimPlayer.pause()
	for t in times:
		rigAnimPlayer.seek(t, true)
		rigAnimPlayer.advance(0.0)
		await RenderingServer.frame_post_draw

		var relative := originMarker.global_transform.affine_inverse() * markerToCopy.global_transform

		outAnim.track_insert_key(posIdx, t, relative.origin)
		outAnim.track_insert_key(rotIdx, t, relative.get_rotation())
		outAnim.track_insert_key(scaleIdx, t, relative.get_scale())

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var save_path := output_dir.path_join(anim_name + "_" + markerToCopy.name + ".tres")
	var err := ResourceSaver.save(outAnim, save_path)

	if err == OK:
		print("markerCopier: saved %d keys ('%s' mode) -> %s" % [times.size(), mode, save_path])
	else:
		push_error("markerCopier: failed to save resource, error %d" % err)


func _existingTrackTimes(anim: Animation) -> Array[float]:
	var result : Array[float] = []
	for i in anim.get_track_count():
		var path := str(anim.track_get_path(i))
		if markerToCopy.name in path and path.ends_with(":position"):
			for k in anim.track_get_key_count(i):
				result.append(anim.track_get_key_time(i, k))
			break
	return result

func _sampledTimes(length: float, _fps: float) -> Array[float]:
	var result : Array[float] = []
	var interval := 1.0 / fps
	var count := int(length / interval) + 1
	for i in count:
		result.append(min(i * interval, length))
	return result
