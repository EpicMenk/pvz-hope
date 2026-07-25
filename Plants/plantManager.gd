## Handles plant-side board logic: placement validation, placing a plant
## in response to the "placePlant" signal, and finding the nearest plant
## in front of a given attacker.
extends Node2D
class_name plantManager

@onready var _boardManager: boardManager = %BoardManager





func _ready() -> void:
	SignalBus.connect("placePlant", tryPlacePlant)


## Returns the closest [Plant] within [param attackReach] tiles ahead of
## [param attacker] (inclusive of the attacker's own tile), or null if
## there isn't one.
func getClosestPlantAhead(attacker: boardEntity, attackReach: int) -> Plant:
	for i in attackReach + 1:
		var grid := Vector2i(attacker.column - i, attacker.lane)
		if not _boardManager.isOccupied(grid):
			continue
		var occupant = _boardManager.getObjectAtGrid(grid)
		if occupant is Plant:
			return occupant
	return null


## Attempts to place [param plant] at the grid tile corresponding to
## [param _position]. Does nothing if the tile isn't a valid placement spot.
func tryPlacePlant(plant: Plant, _position: Vector2):
	var grid : Vector2i = _boardManager.worldToGrid(_position)
	if not canPlacePlant(grid):
		return
	plant.placePlant(grid, _boardManager)


## Returns whether [param grid] is a valid spot to place a plant — on the
## lawn and not already occupied.
func canPlacePlant(grid: Vector2i) -> bool:
	if not _boardManager._gridManager.is_On_Lawn(grid):
		return false
	if _boardManager.isOccupied(grid):
		return false
	return true
