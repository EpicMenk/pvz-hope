extends waveAction
class_name spawnZombieGroupAction

#zombies it the key and the lane where it spawns is the value.
@export var zombiesList : Dictionary[PackedScene , int]

func executeAction(context : actionContext):
	for zombie in zombiesList:
		context._zombieManager.spawnZombie(zombie , zombiesList.get(zombie))
