extends Node
class_name plantAnimationComponent

@export var animPlayer : AnimationPlayer

func _ready() -> void:
	animPlayer.animation_finished.connect(setIdle)


func setIdle(anim : StringName):
	if anim == "shoot":
		animPlayer.current_animation = "idle"
