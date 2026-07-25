## Central authority for the game board: tracks what occupies each grid tile,
## converts between grid coordinates and world positions, and exposes access
## to the plant/zombie managers.
##
## Other systems (components, seed packets, debug tools) should go through
## this manager rather than reaching into gridOccupants or the child
## managers directly.
extends Node2D
class_name boardManager

@warning_ignore_start("unused_private_class_variable")
@onready var _sunManager: sunManager = %SunManager
@onready var _gridManager : gridManager = preload("res://Resources/gridManager.tres")
@onready var _plantManager : plantManager = %PlantManager
@onready var _zombieManager : zombieManager = %ZombieManager
@onready var _debugController: debugController = %DebugController
@onready var _projectileManager: Node2D = %ProjectileManager



## Maps a grid coordinate to whatever occupies it — a [Plant] or a grid item.
## Does not include zombies, which are tracked separately per-lane by
## [zombieManager].
var gridOccupants : Dictionary[Vector2i, Variant] = {}


## Returns the [plantManager] responsible for plant-side board logic.
func getPlantManager() -> plantManager:
	return _plantManager


## Returns the [zombieManager] responsible for zombie-side board logic.
func getZombieManager() -> zombieManager:
	return _zombieManager


## Marks [param grid] as occupied by [param object] and refreshes the debug
## overlay.
func registerGridOccupant(grid: Vector2i, object: Variant):
	gridOccupants[grid] = object
	_debugController.refresh()


## Returns whether [param grid] currently has an occupant.
func isOccupied(grid: Vector2i) -> bool:
	return gridOccupants.has(grid)


## Returns whatever occupies [param grid], or null if it's empty.
func getObjectAtGrid(grid: Vector2i) -> Variant:
	return gridOccupants.get(grid)


## Frees and removes whatever occupies [param grid], if anything, and
## refreshes the debug overlay.
func unregisterGridOccupant(grid: Vector2i):
	var toRemove : Variant = gridOccupants.get(grid)
	if toRemove:
		gridOccupants.erase(grid)
		toRemove.queue_free()
	_debugController.refresh()


## Converts a grid coordinate to its corresponding world-space position.
func gridToWorld(grid: Vector2i) -> Vector2:
	return _gridManager.get_Position(grid)


## Converts a world-space position to its corresponding grid coordinate.
func worldToGrid(_position: Vector2) -> Vector2i:
	return _gridManager.get_Coordinate(_position)
