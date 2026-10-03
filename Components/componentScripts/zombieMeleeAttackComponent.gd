extends meleeAttackComponent
class_name zombieMeleeAttackComponent

@onready var zombie : Zombie = get_parent() as Zombie

func getTarget() -> boardEntity:
	return zombie._plantManager.getClosestPlantAhead(zombie, attackReachInTiles)

func _process(_delta):
	if not isActivated():
		return
	if isAttacking:
		if not is_instance_valid(currentTarget):
			setAttacking(false)
		return
	var target := getCurrentTarget()
	if target != null:
		attack()
