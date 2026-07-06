extends meleeAttackComponent
class_name zombieMeleeAttackComponent

@onready var zombie : Zombie = get_parent() as Zombie

func _ready() -> void:
	super()
	self.startedAttacking.connect(func(): zombie.zombieAnimationC.playEat())


func getTarget() -> boardEntity:
	return zombie._boardManager.getClosestPlantAhead(zombie , attackReachInTiles)

func _process(_delta):
	if getCurrentTarget() != null:
		attackCooldownTimer.timeout.emit()
		zombie.zombieAnimationC.changeAnim("eat")
	if isAttacking and getCurrentTarget() == null:
		setAttacking(false)
