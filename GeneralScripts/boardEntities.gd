extends Node2D
class_name boardEntity

enum teamEnums {
	PLANT,
	ZOMBIE
}

@export var team: teamEnums
@warning_ignore("unused_private_class_variable")
var _boardManager : boardManager
var grid: Vector2i = Vector2i(-1, -1)
var lane:
	get:
		return grid.y
var column:
	get:
		return grid.x

func die():
	queue_free()
