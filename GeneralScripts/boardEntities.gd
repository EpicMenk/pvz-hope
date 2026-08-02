extends Node2D
class_name boardEntity

var _plantManager : plantManager
var _zombieManager : zombieManager
var _boardManager : boardManager
@export var ground: Marker2D 

func initializeManagers(bm: boardManager):
	_boardManager = bm
	_plantManager = bm.getPlantManager()
	_zombieManager = bm.getZombieManager()

#registers components here if we were to inject new components at runtime
var components : Array[Variant] = [] 

func registerRuntimeComponent(component : Node):
	components.append(component)

func activateComponent():
	for child in get_children():
		if child is entityComponent or child is entityComponent2D:
			child.enable()

func disableComponent():
	for child in get_children():
		if child is entityComponent or child is entityComponent2D:
			child.disable()

enum teamEnums {
	PLANT,
	ZOMBIE
}

@export var team: teamEnums
@warning_ignore("unused_private_class_variable")

var grid: Vector2i = Vector2i(-1, -1)
var lane:
	get:
		return grid.y
var column:
	get:
		return grid.x
var ID : int

func getHurtboxComponent() -> hurtboxComponent:
	return null # let other classes override

func die():
	queue_free()
