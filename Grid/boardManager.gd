extends Node2D
class_name boardManager

@warning_ignore_start("unused_private_class_variable")
@onready var _sunManager: sunManager = %SunManager
@onready var _gridManager : gridManager = preload("res://Resources/gridManager.tres")
@onready var _plantManager := %PlantManager
@onready var _zombieManager := %ZombieManager
@onready var debug_controller: debugController = %DebugController
@onready var projectileManager := %ProjectileManager


var gridOccupants : Dictionary [Vector2i , Variant] = {} #including both plant and grid items

func getPlantManager() -> plantManager:
	return _plantManager

func getZombieManager() -> zombieManager:
	return _zombieManager

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
	debug_controller.refresh()

func gridToWorld(grid: Vector2i) -> Vector2:
	return _gridManager.get_Position(grid)

func worldToGrid(_position: Vector2) -> Vector2i:
	return _gridManager.get_Coordinate(_position)
