## Handles zombie-side board logic: tracking which zombies are in which
## lane, registering/unregistering them, and answering lane-based queries
## like whether a zombie is ahead of a given point.

extends Node2D
class_name zombieManager

signal zombieCreated(zombie : Zombie)

@onready var _gridManager : gridManager = preload("res://Resources/gridManager.tres")
## One [zombieLaneData] per lane, tracking which zombies currently occupy it.
var zombieInLanes : Array[zombieLaneData]




func _ready() -> void:
	initializeLanes()

func spawnZombie(zombieScene : PackedScene , lane : int):
	var spawnLane = lane
	var zombie : Zombie = SpawnHelper.spawnEntity(zombieScene , 
	get_parent() , 
	self ,
	_gridManager.get_Position(Vector2(9,spawnLane)))
	
	zombie.grid = Vector2(9 , spawnLane)
	registerZombie(zombie)
	zombieCreated.emit(zombie)


## Returns whether any zombie in [param lane] is ahead of [param xPosition]
## on the x-axis (used by attackers to check line of sight/range).
func isZombieAhead(lane: int, xPosition: float) -> bool:
	for zombie: Zombie in zombieInLanes[lane].zombies:
		if zombie.global_position.x > xPosition:
			return true
	return false


## Creates one empty [zombieLaneData] per lane, sized to [member gridManager.laneCount].
func initializeLanes():
	zombieInLanes.resize(_gridManager.laneCount)
	for lanes in _gridManager.laneCount:
		zombieInLanes[lanes] = zombieLaneData.new()


## Registers [param zombie] into its lane, based on [member boardEntity.lane].
func registerZombie(zombie: Zombie):
	zombieInLanes[zombie.lane].registerZombie(zombie)


## Removes [param zombie] from its lane.
func unregisterZombie(zombie: Zombie):
	zombieInLanes[zombie.lane].unregisterZombie(zombie)


## Returns whether [param lane] currently has any zombies in it.
func isZombieInLane(lane: int) -> bool:
	return zombieInLanes[lane].hasZombies()


## Returns a shallow copy of the zombies currently in [param lane].
func getZombiesInLane(lane: int) -> Array[Zombie]:
	return zombieInLanes[lane].zombies.duplicate(false)


## Debug helper — prints every lane's current zombie list to the console.
func printZombies():
	for i in _gridManager.laneCount:
		print("------ZOMBIES IN LANES ", i, "------")
		zombieInLanes[i].printLanes()
