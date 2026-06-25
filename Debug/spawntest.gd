extends Button

@onready var _boardManager : boardManager = %BoardManager

func spawningPlant():
	var spawnPlant : Plant = preload("res://Plants/basePlant/basePlant.tscn").instantiate()
	_boardManager.plantSide.add_child(spawnPlant)
	spawnPlant.position = get_global_mouse_position()
	if spawnPlant.dragC :
		spawnPlant.dragC.isDragged = true



func _on_button_up() -> void:
	spawningPlant()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print(_boardManager.gridOccupants)
