extends Node
class_name plantAnimationComponent

@export var animPlayer: AnimationPlayer

func _ready():
	animPlayer.animation_finished.connect(_onAnimationFinished)

func playShoot():
	animPlayer.play("shoot")

func playIdle():
	animPlayer.play("idle")

func _onAnimationFinished(anim: StringName):
	if anim == "shoot":
		playIdle()
