extends Button

@onready var _gridManager : gridManager = preload("res://Resources/gridManager.tres")
@onready var board_manager: boardManager = %BoardManager

signal zombieCreated(zombie : Zombie)

func spawnZombie():
	var spawnLane = randi_range(0,4)
	var zombie : Zombie = preload("res://Zombies/coneHeadZombie/coneHeadZombie.tscn").instantiate()
	zombie.initializeManagers(board_manager)
	zombie.grid = Vector2(9 , spawnLane)
	zombie.position = _gridManager.get_Position(Vector2(9,spawnLane))
	board_manager._zombieManager.add_child(zombie)
	board_manager._zombieManager.registerZombie(zombie)
	zombieCreated.emit(zombie)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		board_manager._zombieManager.printZombies()


func _on_button_up() -> void:
	spawnZombie()
