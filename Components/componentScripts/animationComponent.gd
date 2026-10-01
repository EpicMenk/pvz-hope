# animationComponent.gd — back to the simple version, no priority/expiry needed
extends entityComponent
class_name animationComponent

@export var animationPlayer : AnimationPlayer
@export var fallbackAnimName : StringName = &""
@export var actionPointRatios : Dictionary
@export var maxPlaybackSpeeds : Dictionary
@export var uninterruptibleAnimNames : Array[StringName] = []

var _protectedActive : bool = false

func _ready() -> void:
	if animationPlayer:
		animationPlayer.animation_finished.connect(_onAnimFinished)

func playAction(animName: StringName, _actionInterval: float) -> void:
	if not animationPlayer or not isActivated():
		return
	if _protectedActive:
		return
	animationPlayer.speed_scale = 1.0
	animationPlayer.play(animName)
	if animName in uninterruptibleAnimNames:
		_protectedActive = true

func revertToFallback() -> void:
	if not animationPlayer or _protectedActive:
		return
	if fallbackAnimName == &"":
		animationPlayer.stop()
	else:
		animationPlayer.play(fallbackAnimName)

func _onAnimFinished(animName: StringName) -> void:
	if animName in uninterruptibleAnimNames:
		_protectedActive = false
