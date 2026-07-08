extends Node
class_name zombieAnimationComponent

@onready var zombie : Zombie = get_parent() as Zombie
@export var animationPlayer: AnimationPlayer 
@export var customBlendValue : float = 0.9

func _ready() -> void:
	zombie.zombieMeleeC.stoppedAttacking.connect(playWalk)
	zombie.zombieMeleeC.startedAttacking.connect(playEat)


func playWalk():
	animationPlayer.play("walk" , customBlendValue)


func playEat():
	animationPlayer.play("attack" , customBlendValue)


func changeAnim(_name : StringName):
	if animationPlayer.current_animation == _name:
		return
	animationPlayer.play(_name , customBlendValue)
