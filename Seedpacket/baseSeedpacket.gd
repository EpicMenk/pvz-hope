extends Button
class_name seedpacket

var seedData : seedPacketData
var _boardManager : boardManager
@onready var portrait: TextureRect = %portrait



func _ready() -> void:
	self.pressed.connect(spawnPlant)

func spawnPlant():
	if not seedData:
		return
	var plantScene : PackedScene = seedData.plantScene
	if not plantScene:
		return
	var plant : Plant = plantScene.instantiate()
	plant._boardManager = _boardManager
	plant.disableComponent()
	_boardManager.plantSide.add_child(plant)
	plant.global_position = get_global_mouse_position()
	if plant.dragC:
		plant.dragC.isDragged = true

func initialize(data : seedPacketData):
	seedData = data
	if seedData.portrait : 
		portrait.texture = seedData.portrait
	
