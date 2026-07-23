extends Button
class_name seedpacket

signal seedpacketPressed(seed : seedpacket)

var seedData : seedPacketData
var _boardManager : boardManager
@onready var backdrop: TextureRect = %backdrop
@onready var border: TextureRect = %border
@onready var portrait: TextureRect = %portrait
@onready var sunCostLabel: Label = %sunCost
@onready var cooldownTimer: Timer = %cooldownTimer
@onready var cooldownOverlay: TextureProgressBar = %cooldownOverlay
var isSelected : bool
var _sunManager : sunManager
var firstCooldown : bool = true
var isCoolingdown : bool = false
var currentCooldownDuration : float

func _process(_delta: float) -> void:
	if isCoolingdown:
		cooldownOverlay.value = getCooldownPercent() * 100

func _ready() -> void:
	self.pressed.connect(checkRequirements)
	_sunManager.sunValueChanged.connect(onSunChanged)
	cooldownTimer.timeout.connect(onCooldownTimeout)
	


func onCooldownTimeout():
	isCoolingdown = false
	cooldownOverlay.hide()
	updateSeedOverlay()


func onSunChanged(_sunCount : int):
	updateSeedOverlay()
	updateTextOutline()

func checkRequirements():
	if isCoolingdown:
		return
	seedpacketPressed.emit(self)

func updateTextOutline():
	if not seedData:
		return
	if _sunManager.canAfford(seedData.stats.sunCost):
		sunCostLabel.add_theme_color_override("font_outline_color" , Color())
	else:
		sunCostLabel.add_theme_color_override("font_outline_color" , Color(1.0, 0.0, 0.0, 1.0))

func updateSeedOverlay():
	if not seedData:
		return
	if not _sunManager.canAfford(seedData.stats.sunCost): #or isCoolingdown:
		changeOverlaySeedPacket(Color(0.5,0.5,0.5))
	else : changeOverlaySeedPacket(Color.WHITE)

func changeOverlaySeedPacket(color : Color):
	backdrop.modulate = color
	border.modulate = color
	sunCostLabel.modulate = color
	portrait.modulate = color



func spawnPlant()-> Plant:
	if not seedData:
		return
	var plantScene : PackedScene = seedData.plantScene
	if not plantScene:
		return
	var plant : Plant = plantScene.instantiate()
	plant.initializeManagers(_boardManager)
	_boardManager._plantManager.add_child(plant)
	plant.disableComponent()
	plant.global_position = get_global_mouse_position()
	if plant.dragC:
		plant.dragC.isDragged = true
	connectToPlant(plant)
	return plant

func connectToPlant(plant : Plant):
	plant.plantPlaced.connect(startCooldown)

func getCooldownPercent() -> float:
	if !isCoolingdown:
		return 0.0
	return cooldownTimer.time_left / currentCooldownDuration 


func startCooldown():
	isCoolingdown = true
	if firstCooldown:
		
		if isCooldownZero(seedData.stats.initialCooldown):
			return
		
		currentCooldownDuration = seedData.stats.initialCooldown
		cooldownTimer.start(seedData.stats.initialCooldown)
		firstCooldown = false
	else:
		if isCooldownZero(seedData.stats.cooldown):
			return
		if seedData.stats.cooldown <= 0:
			firstCooldown = false
			isCoolingdown = false
			return
		
		currentCooldownDuration = seedData.stats.cooldown
		cooldownTimer.start(seedData.stats.cooldown)
	cooldownOverlay.show()
	updateSeedOverlay()


func isCooldownZero(duration: float) -> bool:
	if duration <= 0:
		firstCooldown = false
		isCoolingdown = false
		return true
	return false


func initialize(data : seedPacketData):
	seedData = data
	portrait.texture = seedData.portrait
	sunCostLabel.text = str(seedData.stats.sunCost)
	startCooldown()
	updateSeedOverlay()
