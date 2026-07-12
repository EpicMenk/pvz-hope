extends Node
class_name seedBankManager


@onready var seedBank: seedbank = %Seedbank
var seedSlots : Array[seedpacket]
var holdingPlant : Plant 
var selectedSeedpacket : seedpacket = null

func _ready() -> void:
	seedBank.finishedInitializing.connect(initializeSeedpackets)

func initializeSeedpackets():
	seedSlots = seedBank.getSeedSlots()
	connectToSeedpackets()

func onSeedpacketPressed(seedPacket : seedpacket):
	if selectedSeedpacket == seedPacket :
		unselectCurrent()
		return
	if selectedSeedpacket != seedPacket:
		if seedPacket.seedData :
			unselectCurrent()
			selectedSeedpacket = seedPacket
			selectedSeedpacket.isSelected = true
			holdingPlant = selectedSeedpacket.spawnPlant()
			holdingPlant.plantPlaced.connect(onPlantPlaced)
		

func onPlantPlaced():
	if holdingPlant.plantPlaced.is_connected(onPlantPlaced):
		holdingPlant.plantPlaced.disconnect(onPlantPlaced)
	
	holdingPlant = null
	selectedSeedpacket = null


func unselectCurrent():
	if holdingPlant:
		holdingPlant.dragC.isDragged = false
		holdingPlant.die()
		holdingPlant = null
	
	if selectedSeedpacket:
		selectedSeedpacket.isSelected = false
	selectedSeedpacket = null


func connectToSeedpackets():
	for seedPacket in seedSlots:
		seedPacket.seedpacketPressed.connect(onSeedpacketPressed)
