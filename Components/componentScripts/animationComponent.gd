extends entityComponent
class_name animationComponent

signal actionFinished(animName: StringName)

@export var animationPlayer : AnimationPlayer
@export var fallbackAnimName : StringName = &""
@export var actionConfigs : Dictionary[StringName, animationActionConfig] = {}
@export var uninterruptibleAnimNames : Array[StringName] = []

var _protectedActive : bool = false

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
		requiredSpeed = (anim.length * actionPointRatio) / desiredActionTime
	requiredSpeed = clamp(requiredSpeed, 0.01, maxSpeed)

	animationPlayer.speed_scale = requiredSpeed
	animationPlayer.stop()
	animationPlayer.play(animName)
	if animName in uninterruptibleAnimNames:
		_protectedActive = true

func revertToFallback() -> void:
	if not animationPlayer or _protectedActive:
		return
	animationPlayer.speed_scale = 1.0
	if fallbackAnimName == &"":
		animationPlayer.stop()
	else:
		animationPlayer.play(fallbackAnimName)

func changeAnim(_name : StringName):
	if animationPlayer.current_animation == _name:
		return
	animationPlayer.speed_scale = 1
	animationPlayer.play(_name)

func _onAnimFinished(animName: StringName) -> void:
	if animName in uninterruptibleAnimNames:
		_protectedActive = false
	actionFinished.emit(animName)
