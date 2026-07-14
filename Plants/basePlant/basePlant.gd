extends boardEntity
class_name Plant

signal plantPlaced()

@export var hpC : hpComponent
@export var dragC : dragComponent
@onready var hurtboxC : hurtboxComponent = %hurtboxComponent
var isPlaced : bool = false

func die():
	_boardManager.unregisterGridOccupant(grid)
	queue_free()

func evaluateStats():
	push_error("initializeStats() needs to be overriden")

func activateComponent():
	push_error("activateComponent() needs to be overriden")

func disableComponent():
	push_error("disableComponent() needs to be overriden")

func _ready() -> void:
	evaluateStats()


func getHurtboxComponent() -> hurtboxComponent:
	if not hurtboxC :
		return
	return hurtboxC


func placePlant (_grid : Vector2i , __boardManager : boardManager):
	isPlaced = false
	activateComponent()
	dragC.isDragged = false
	dragC.queue_free()
	grid = _grid
	_boardManager = __boardManager
	self.global_position = _boardManager.gridToWorld(grid)
	_boardManager.registerGridOccupant(grid , self)
	plantPlaced.emit()
