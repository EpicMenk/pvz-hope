extends meleeAttackComponent
class_name zombieMeleeAttackComponent

@onready var zombie : Zombie = get_parent() as Zombie


func getTarget() -> boardEntity:
	return zombie._boardManager.getClosestPlantAhead(zombie , attackReachInTiles)

func _process(_delta):
	var target = getCurrentTarget()
	if target != null and !isAttacking :
		attack()
	if isAttacking and getCurrentTarget() == null: # if no more target stop attacking immediately
		setAttacking(false)
