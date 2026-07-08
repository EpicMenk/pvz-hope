extends movementComponent
class_name zombieMovementComponent

@onready var zombie := parent as Zombie

func move(delta):
	if zombie.zombieMeleeC.getCurrentTarget() :
		return
	zombie.position += getVelocity() * delta
	updateZombieGrid()


func updateZombieGrid():
	var newGrid = zombie._boardManager.worldToGrid(parent.global_position)
	if newGrid == zombie.grid:
		return
	zombie.grid = newGrid
