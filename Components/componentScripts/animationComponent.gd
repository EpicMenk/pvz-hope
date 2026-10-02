# TODO FIX THIS
extends entityComponent
class_name animationComponent

@export var animationPlayer : AnimationPlayer
@export var fallbackAnimName : StringName = &""
@export var actionConfigs : Dictionary[StringName, animationActionConfig] = {}
@export var uninterruptibleAnimNames : Array[StringName] = []

var _protectedActive : bool = false
var _primedAnims : Dictionary = {}   # animName -> true once it's been played at least once; this IS the cold-start detector

func _ready() -> void:
	if animationPlayer:
		animationPlayer.animation_finished.connect(_onAnimFinished)

func playAction(animName: StringName, desiredActionTime: float) -> void:
	if not animationPlayer or not isActivated():
		return
	if _protectedActive:
		return
	var anim : Animation = animationPlayer.get_animation(animName)
	if anim == null:
		push_warning("animationComponent.playAction: no animation named %s" % animName)
		return

	var config : animationActionConfig = actionConfigs.get(animName)
	var actionPointRatio : float = config.actionPointRatio if config else 1.0
	var maxSpeed : float = config.maxPlaybackSpeed if config else INF

	var requiredSpeed : float = 1.0
	if desiredActionTime > 0.0:
		requiredSpeed = anim.length / desiredActionTime
	requiredSpeed = clamp(requiredSpeed, 0.01, maxSpeed)

	animationPlayer.speed_scale = requiredSpeed
	animationPlayer.stop()
	animationPlayer.play(animName)

	var isColdStart :StringName = not _primedAnims.get(animName, false)
	_primedAnims[animName] = true
	if isColdStart and actionPointRatio < 1.0:
		# No previous cycle pre-scheduled this clip. Jump straight to the
		# action point instead of playing a windup that would land after
		# the hit already happened — only the recovery tail shows this once.
		animationPlayer.seek(anim.length * actionPointRatio, true)

	if animName in uninterruptibleAnimNames:
		_protectedActive = true

func getActionLeadDelay(animName: StringName, desiredActionTime: float) -> float:
	if not _primedAnims.get(animName, false):
		return 0.0   # cold start — no previous clip's tail to protect, call playAction() right away
	var config : animationActionConfig = actionConfigs.get(animName)
	var ratio : float = config.actionPointRatio if config else 1.0
	return desiredActionTime * (1.0 - ratio)

func revertToFallback() -> void:
	if not animationPlayer or _protectedActive:
		return
	animationPlayer.speed_scale = 1.0
	if fallbackAnimName == &"":
		animationPlayer.stop()
	else:
		animationPlayer.play(fallbackAnimName)

func _onAnimFinished(animName: StringName) -> void:
	if animName in uninterruptibleAnimNames:
		_protectedActive = false
