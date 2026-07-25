extends Node2D
class_name boardEntity

var _plantManager : plantManager
var _zombieManager : zombieManager
var _boardManager : boardManager

func initializeManagers(bm: boardManager):
	_boardManager = bm
	_plantManager = bm.getPlantManager()
	_zombieManager = bm.getZombieManager()


# pair components with their configs resource that can be changed during runtime
var runtimeComponents : Array[Dictionary] = [] 

func registerRuntimeComponent(component : Node , configs : Dictionary):
	runtimeComponents.append({"component": component, "configs": configs})

func evaluateComponentStats():
	for component in runtimeComponents:
		component.component.evaluateStats()

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
