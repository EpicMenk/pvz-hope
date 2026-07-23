extends Node2D
class_name plantManager

@onready var _boardManager: boardManager = %BoardManager


func _ready() -> void:
	SignalBus.connect("placePlant" , tryPlacePlant)


func getClosestPlantAhead(attacker: boardEntity ,attackReach: int) -> Plant:
	for i in attackReach + 1:
		var grid := Vector2i(attacker.column - i, attacker.lane)
		if not _boardManager.isOccupied(grid):
			continue
		var occupant = _boardManager.getObjectAtGrid(grid)
		if occupant is Plant:
			return occupant
	return null


func tryPlacePlant(plant : Plant , _position : Vector2):
	var grid : Vector2i = _boardManager.worldToGrid(_position)
	if not canPlacePlant(grid):
		return
	plant.placePlant(grid , _boardManager)


func canPlacePlant(grid: Vector2i) -> bool:
	if not _boardManager._gridManager.is_On_Lawn(grid):
		return false
	if _boardManager.isOccupied(grid):
		return false
	return true
