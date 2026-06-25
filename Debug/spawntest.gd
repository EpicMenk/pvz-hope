extends Button

@onready var _boardManager : boardManager = %BoardManager

func spawningPlant():
	var spawnPlant : basePlant = preload("res://Plants/basePlant/basePlant.tscn").instantiate()
	_boardManager.plantSide.add_child(spawnPlant)
	spawnPlant.position = get_global_mouse_position()
	if spawnPlant.dragC :
		spawnPlant.dragC.isDragged = true



func _on_button_up() -> void:
	spawningPlant()
