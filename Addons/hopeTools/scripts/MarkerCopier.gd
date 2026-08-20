#@tool
#extends Node2D
#class_name markerCopier
#
#@export var originMarker : Marker2D
#@export var markerToCopy : Marker2D
#@export var output_dir : String = "res://BakedFrames/"
#@export var animPlayer : AnimationPlayer
#@export var fps : float = 30.0
#@export var animationName : String
#
#@export_tool_button("Copy Marker")
#var copier : Callable = copyMarker
#
#
#func copyMarker():
	#copyMarkerTrack(animPlayer, animationName, fps)
#
#
#func copyMarkerTrack(
	#rigAnimPlayer : AnimationPlayer,
	#anim_name : String,
	#target_fps : float
#) -> void:
#
	#if originMarker == null or markerToCopy == null:
		#push_error("markerCopier: assign originMarker and markerToCopy first.")
		#return
#
	#if rigAnimPlayer == null:
		#push_error("markerCopier: assign an AnimationPlayer first.")
		#return
#
	#var sourceAnim : Animation = rigAnimPlayer.get_animation(anim_name)
#
	#if sourceAnim == null:
		#push_error("markerCopier: rig has no animation named '%s'." % anim_name)
		#return
#
	#var times : Array[float] = _existingTrackTimes(sourceAnim)
	#var mode : String = "existing"
#
	#if times.is_empty():
		#mode = "sampled"
		#times = _sampledTimes(sourceAnim.length, target_fps)
#
	#var outAnim : Animation = Animation.new()
	#outAnim.length = sourceAnim.length
	#outAnim.loop_mode = sourceAnim.loop_mode
	#outAnim.step = sourceAnim.step
#
	#var posIdx : int = outAnim.add_track(Animation.TYPE_VALUE)
	#outAnim.track_set_path(
		#posIdx,
		#NodePath("%s:position" % markerToCopy.name)
	#)
#
	#var rotIdx : int = outAnim.add_track(Animation.TYPE_VALUE)
	#outAnim.track_set_path(
		#rotIdx,
		#NodePath("%s:rotation" % markerToCopy.name)
	#)
#
	#var scaleIdx : int = outAnim.add_track(Animation.TYPE_VALUE)
	#outAnim.track_set_path(
		#scaleIdx,
		#NodePath("%s:scale" % markerToCopy.name)
	#)
#
	#outAnim.track_set_interpolation_type(
		#posIdx,
		#Animation.INTERPOLATION_LINEAR
	#)
#
	#outAnim.track_set_interpolation_type(
		#rotIdx,
		#Animation.INTERPOLATION_LINEAR
	#)
#
	#outAnim.track_set_interpolation_type(
		#scaleIdx,
		#Animation.INTERPOLATION_LINEAR
	#)
#
	#rigAnimPlayer.play(anim_name)
	#rigAnimPlayer.pause()
#
	#var canvasToGameplayScale : float = 0.2
#
	#for t in times:
		#rigAnimPlayer.seek(t, true)
		#rigAnimPlayer.advance(0.0)
#
		#var relative : Transform2D = (
			#originMarker.global_transform.affine_inverse()
			#* markerToCopy.global_transform
		#)
#
		#var scaledPosition : Vector2 = (
			#relative.origin * canvasToGameplayScale
		#)
#
		#outAnim.track_insert_key(
			#posIdx,
			#t,
			#scaledPosition
		#)
#
		#outAnim.track_insert_key(
			#rotIdx,
			#t,
			#relative.get_rotation()
		#)
#
		#outAnim.track_insert_key(
			#scaleIdx,
			#t,
			#relative.get_scale()
		#)
#
	#DirAccess.make_dir_recursive_absolute(
		#ProjectSettings.globalize_path(output_dir)
	#)
#
	#var savePath : String = output_dir.path_join(
		#anim_name + "_" + markerToCopy.name + ".tres"
	#)
#
	#var err : Error = ResourceSaver.save(
		#outAnim,
		#savePath
	#)
#
	#if err == OK:
		#print(
			#"markerCopier: saved %d keys ('%s' mode) -> %s"
			#% [
				#times.size(),
				#mode,
				#savePath
			#]
		#)
#
		#print(
			#"length=",
			#sourceAnim.length,
			#" fps=",
			#target_fps,
			#" frameInterval=",
			#1.0 / target_fps
		#)
	#else:
		#push_error(
			#"markerCopier: failed to save resource, error %d"
			#% err
		#)
#
#
#func _existingTrackTimes(anim : Animation) -> Array[float]:
#
	#var result : Array[float] = []
#
	#var positionPath : String = "%s:position" % markerToCopy.name
#
	#for i in anim.get_track_count():
#
		#var path : String = str(
			#anim.track_get_path(i)
		#)
#
		#if path.ends_with(positionPath):
			#for k in anim.track_get_key_count(i):
				#result.append(
					#anim.track_get_key_time(i, k)
				#)
			#break
#
	#result.sort()
	#return result
#
#
#func _sampledTimes(
	#length : float,
	#_fps : float
#) -> Array[float]:
#
	#var result : Array[float] = []
#
	#if _fps <= 0.0:
		#push_error("markerCopier: FPS must be greater than zero.")
		#return result
#
	#var interval : float = 1.0 / _fps
	#var count : int = int(length / interval) + 1
#
	#for i in count:
		#result.append(
			#min(i * interval, length)
		#)
#
	#return result
@tool
extends Node2D
class_name markerCopier

@export var originMarker : Marker2D
@export var markerToCopy : Marker2D
@export var output_dir : String = "res://BakedFrames/"
@export var canvasToGameplayScale : float = 0.2

var _outAnim : Animation
var _animName : String
var _posIdx : int
var _rotIdx : int
var _scaleIdx : int
var _sampleCount : int


# Called once by bakeRig right before it starts stepping through
# an animation's frames.
func beginBake(anim_name : String, length : float) -> void:
	if originMarker == null or markerToCopy == null:
		push_error("markerCopier: assign originMarker and markerToCopy first.")
		return

	_animName = anim_name
	_sampleCount = 0

	_outAnim = Animation.new()
	_outAnim.length = length

	_posIdx = _outAnim.add_track(Animation.TYPE_VALUE)
	_outAnim.track_set_path(_posIdx, NodePath("%s:position" % markerToCopy.name))

	_rotIdx = _outAnim.add_track(Animation.TYPE_VALUE)
	_outAnim.track_set_path(_rotIdx, NodePath("%s:rotation" % markerToCopy.name))

	_scaleIdx = _outAnim.add_track(Animation.TYPE_VALUE)
	_outAnim.track_set_path(_scaleIdx, NodePath("%s:scale" % markerToCopy.name))

	for idx in [_posIdx, _rotIdx, _scaleIdx]:
		_outAnim.track_set_interpolation_type(idx, Animation.INTERPOLATION_LINEAR)


# Called once per baked frame, with the exact same t bakeRig just
# used to capture that frame's image.
func recordSample(t : float) -> void:
	if _outAnim == null:
		push_error("markerCopier: recordSample() called before beginBake().")
		return

	var relative : Transform2D = (
		originMarker.global_transform.affine_inverse()
		* markerToCopy.global_transform
	)

	var scaledPosition : Vector2 = relative.origin * canvasToGameplayScale

	_outAnim.track_insert_key(_posIdx, t, scaledPosition)
	_outAnim.track_insert_key(_rotIdx, t, relative.get_rotation())
	_outAnim.track_insert_key(_scaleIdx, t, relative.get_scale())

	_sampleCount += 1


# Called once by bakeRig after the last frame of the animation
# has been captured.
func finalizeBake() -> void:
	if _outAnim == null:
		push_error("markerCopier: finalizeBake() called before beginBake().")
		return

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))

	var savePath : String = output_dir.path_join(_animName + "_" + markerToCopy.name + ".tres")
	var err : Error = ResourceSaver.save(_outAnim, savePath)

	if err == OK:
		print("markerCopier: saved %d keys -> %s" % [_sampleCount, savePath])
	else:
		push_error("markerCopier: failed to save resource, error %d" % err)

	_outAnim = null
