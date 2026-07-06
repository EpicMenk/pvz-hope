extends Node
class_name zombieAnimationComponent

@onready var zombie : Zombie = get_parent() as Zombie
@onready var animationPlayer: AnimationPlayer = %AnimationPlayer
@export var customBlendValue : float = 0.9

func _ready() -> void:
	zombie.zombieMeleeC.stoppedAttacking.connect(playWalk)

func playReset():
	animationPlayer.play("RESET" , customBlendValue)
	print("reseted")

func playWalk():
	playReset()
	animationPlayer.advance(1)
	animationPlayer.play("walk" , customBlendValue)


func playEat():
	playReset()
	animationPlayer.advance(1)
	animationPlayer.play("eat" , customBlendValue)


func changeAnim(_name : StringName):
	if animationPlayer.current_animation == _name:
		return
	animationPlayer.play("RESET" , 0.08) 
	animationPlayer.play(_name , 0.08)
