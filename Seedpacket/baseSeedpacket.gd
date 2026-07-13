extends Button
class_name seedpacket

signal seedpacketPressed(seed : seedpacket)

var seedData : seedPacketData
var _boardManager : boardManager
@onready var portrait: TextureRect = %portrait
@onready var sunCostLabel: Label = %sunCost
var isSelected : bool
var _sunManager : sunManager

func _ready() -> void:
	self.pressed.connect(checkRequirements)
	_sunManager.sunValueChanged.connect(onSunChanged)

func onSunChanged(_sunCount : int):
	updateSeedOverlay()

func checkRequirements():
	seedpacketPressed.emit(self)

func updateSeedOverlay():
	if not seedData:
		return
	if _sunManager.canAfford(seedData.stats.sunCost):
		modulate = Color.WHITE
	else : modulate = Color(0.5,0.5,0.5)


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
	updateSeedOverlay()
