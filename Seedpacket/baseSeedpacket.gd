extends Button
class_name seedpacket

signal seedpacketPressed(seed : seedpacket)

var seedData : seedPacketData
var _boardManager : boardManager
@onready var portrait: TextureRect = %portrait
@onready var sunCostLabel: Label = %sunCost
var isSelected : bool



func _ready() -> void:
	self.pressed.connect(checkRequirements)

func checkRequirements():
	seedpacketPressed.emit(self)




func spawnPlant()-> Plant:
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
	return plant


func initialize(data : seedPacketData):
	seedData = data
	portrait.texture = seedData.portrait
	sunCostLabel.text = str(seedData.stats.sunCost)
