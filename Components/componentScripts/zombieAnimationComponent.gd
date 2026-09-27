extends entityComponent
class_name zombieAnimationComponent

@onready var zombie : Zombie = get_parent() as Zombie
@export var animationPlayer: AnimationPlayer 


func _ready() -> void:
	zombie.zombieMeleeC.stoppedAttacking.connect(playWalk)
	zombie.zombieMeleeC.startedAttacking.connect(playEat)


func playWalk():
	if not animationPlayer : return
	animationPlayer.play("walk")

func playEat():
	if not animationPlayer : return
	animationPlayer.play("attack")


func changeAnim(_name : StringName):
	if animationPlayer.current_animation == _name:
		return
	animationPlayer.play(_name)
