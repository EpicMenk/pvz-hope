extends Node2D
class_name zombieManager

@onready var _boardManager: boardManager = %BoardManager
@onready var _gridManager : gridManager 
var zombieInLanes : Array[laneData]


func _ready() -> void:
	_gridManager = _boardManager._gridManager
	initializeLanes()


func isZombieAhead(lane: int, xPosition: float) -> bool:
	for zombie: Zombie in zombieInLanes[lane].zombies:
		if zombie.global_position.x > xPosition:
			return true
	return false

func initializeLanes():
	zombieInLanes.resize(_gridManager.laneCount)
	for lanes in _gridManager.laneCount :
		zombieInLanes[lanes] = laneData.new()

func registerZombie(zombie : Zombie):
	zombieInLanes[zombie.lane].registerZombie(zombie)

func unregisterZombie(zombie : Zombie):
	zombieInLanes[zombie.lane].unregisterZombie(zombie)

func isZombieInLane (lane : int) -> bool:
	return zombieInLanes[lane].hasZombies()

func getZombiesInLane(lane : int) -> Array[Zombie]:
	return zombieInLanes[lane].zombies.duplicate(false)

func printZombies():
	for i in _gridManager.laneCount:
		print(zombieInLanes[i].printLanes())
