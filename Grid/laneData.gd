extends RefCounted
class_name laneData

var zombies : Array[Zombie]

func hasZombies() -> bool:
	return not zombies.is_empty()

func registerZombie(zombie: Zombie):
	zombies.append(zombie)

func unregisterZombie(zombie: Zombie):
	zombies.erase(zombie)

func printLanes():
	print(zombies)
