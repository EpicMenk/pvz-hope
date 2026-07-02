extends boardEntity
class_name Plant

@export var dragC : dragComponent
@export var hpC : hpComponent
@onready var hurtboxC : hurtboxComponent = %hurtboxComponent


func die():
	_boardManager.unregisterGridOccupant(grid)
	queue_free()

func getHurtboxComponent() -> hurtboxComponent:
	return hurtboxC



func placePlant (_grid : Vector2i , __boardManager : boardManager):
	dragC.isDragged = false
	dragC.queue_free()
	grid = _grid
	_boardManager = __boardManager
	self.position = _boardManager.gridToWorld(grid)
	_boardManager.registerGridOccupant(grid , self)
