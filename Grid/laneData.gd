## Tracks the zombies currently occupying a single lane. One instance per
## lane, owned by [ZombieManager].
extends RefCounted
class_name zombieLaneData

var zombies : Array[Zombie]

## Returns whether this lane currently has any zombies in it.
func hasZombies() -> bool:
	return not zombies.is_empty()

## Adds [param zombie] to this lane.
func registerZombie(zombie: Zombie):
	zombies.append(zombie)

## Removes [param zombie] from this lane.
func unregisterZombie(zombie: Zombie):
	zombies.erase(zombie)

## Debug helper — prints this lane's current zombie list to the console.
func printLanes():
	print(zombies)
