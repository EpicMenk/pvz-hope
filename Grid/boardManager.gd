extends Node2D
class_name boardManager

@onready var _gridManager : gridManager = preload("res://Resources/gridManager.tres")
@onready var plantSide := %Plants

func _ready() -> void:
	SignalBus.connect("placePlant" , placePlant)

func placePlant(plant : basePlant , _position : Vector2):
	var newPos : Vector2 = _gridManager.get_Position(_gridManager.get_Coordinate(_position))
	plant.global_position =  newPos
	print(newPos , "," , _position , " , " , _gridManager.get_Coordinate(_position))
