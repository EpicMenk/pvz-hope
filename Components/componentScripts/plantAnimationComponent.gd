extends Node
class_name plantAnimationComponent

@export var animPlayer: AnimationPlayer

func _ready():
	animPlayer.animation_finished.connect(_onAnimationFinished)

func playAttack():
	animPlayer.play("attack")
	print("attack")

func playIdle():
	animPlayer.play("idle")
	print("idle")

func _onAnimationFinished(anim: StringName):
	if anim == "attack":
		playIdle()
