extends waveAction
class_name spawnZombieGroupAction

#zombies it the key and the lane where it spawns is the value.
@export var zombiesList : Array[zombieSpawnEntries]
var spawnedAllZombiesInList : bool = false

func executeAction(context : actionContext):
	for zombieEntries in zombiesList:
		context._zombieManager.spawnZombie(
			zombieEntries.zombieScene,
			zombieEntries.lane
		)
	spawnedAllZombiesInList = true



func isFinished(context : actionContext):
	if spawnedAllZombiesInList == true:
		return true
