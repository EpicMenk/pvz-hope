extends Node2D
class_name boardManager

@onready var _gridManager : gridManager = preload("res://Resources/gridManager.tres")
@onready var plantSide := %Plants
@onready var zombieSide := %Zombies
@onready var debug_controller: debugController = %DebugController
@onready var projectileSide := $Projectiles


var gridOccupants : Dictionary [Vector2i , Variant] = {}
var zombieInLanes : Array[laneData]


func _ready() -> void:
	SignalBus.connect("placePlant" , tryPlacePlant)
	initializeLanes()


func registerGridOccupant(grid: Vector2i , object: Variant):
	gridOccupants [grid] = object
	debug_controller.refresh()


func isOccupied(grid:Vector2i) -> bool:
	return gridOccupants.has(grid)


func getObjectAtGrid(grid : Vector2i) -> Variant:
	return gridOccupants.get(grid)


func unregisterGridOccupant(grid : Vector2i):
	var toRemove : Variant = gridOccupants.get(grid)
	if toRemove:
		gridOccupants.erase(grid)
		toRemove.queue_free()

func gridToWorld(grid: Vector2i) -> Vector2:
	return _gridManager.get_Position(grid)

func worldToGrid(_position: Vector2) -> Vector2i:
	return _gridManager.get_Coordinate(_position)

## Zombies
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


## Plants

func tryPlacePlant(plant : Plant , _position : Vector2):
	var grid : Vector2i = worldToGrid(_position)
	if not canPlacePlant(grid):
		return
	plant.placePlant(grid , self)



func canPlacePlant(grid: Vector2i) -> bool:
	if not _gridManager.is_On_Lawn(grid):
		return false
	if isOccupied(grid):
		return false
	return true
