extends Node2D
class_name boardManager

@onready var _gridManager : gridManager = preload("res://Resources/gridManager.tres")
@onready var plantSide := %Plants
var gridOccupants : Dictionary [Vector2i , Variant] = {}



func _ready() -> void:
	SignalBus.connect("placePlant" , placePlant)


func addToGridDic(grid: Vector2i , object: Variant):
	gridOccupants [grid] = object


func isOccupied(grid:Vector2i) -> bool:
	return gridOccupants.has(grid)


func getObjectAtGrid(grid : Vector2i) -> Variant:
	return gridOccupants.get(grid)


func removeFromGrid(grid : Vector2i):
	var toRemove : Variant = gridOccupants.get(grid)
	if toRemove:
		gridOccupants.erase(grid)
		toRemove.queue_free()




func placePlant(plant : Plant , _position : Vector2):
	var grid : Vector2i = _gridManager.get_Coordinate(_position)
	var newPos : Vector2 = _gridManager.get_Position(grid)
	if _gridManager.is_On_Lawn(grid) == false:
		return
	if isOccupied(grid) == true :
		return 
	
	plant.dragC.isDragged = false
	plant.dragC.queue_free()
	plant.global_position =  newPos
	addToGridDic(grid , plant)
	print(newPos , "," , _position , " , " , _gridManager.get_Coordinate(_position))
