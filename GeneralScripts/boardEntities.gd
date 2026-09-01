extends Node2D
class_name boardEntity

signal existedInLawn

enum teamEnums {
	PLANT,
	ZOMBIE
}

var grid: Vector2i = Vector2i(-1, -1)
var lane:
	get:
		return grid.y
var column:
	get:
		return grid.x
var ID : int
var existInLawn : bool = false
var _plantManager : plantManager
var _zombieManager : zombieManager
var _boardManager : boardManager
@export var ground: Marker2D 
@export var team: teamEnums
@export var shadowSize : shadowComponent.shadowSizesEnums

func _ready() -> void:
	self.existedInLawn.connect(uponExistingInLawn)

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

func uponExistingInLawn():
	print("yep")
	spawnShadow()

func spawnShadow():
	var shadowScene : PackedScene = preload("uid://c5pkycrbfusgd") #shadow component uid
	var shadow : shadowComponent = shadowScene.instantiate()
	shadow.lane = lane
	shadow.parent = self
	shadow._boardManager = _boardManager
	shadow.shadowSize = shadowSize
	add_child(shadow)


func getHurtboxComponent() -> hurtboxComponent:
	return null # let other classes override

func die():
	queue_free()
