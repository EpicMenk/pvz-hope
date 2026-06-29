extends meleeAttackComponent
class_name zombieMeleeAttackComponent

@onready var zombie : Zombie = get_parent() as Zombie

func getTarget() -> boardEntity:
	return zombie._boardManager.getClosestPlantAhead(zombie , attackReachInTiles)

#func _process(_delta: float) -> void:
	#print(attackCooldownTimer.time_left)
