## Handles the seed bank UI-to-gameplay bridge: tracking which seed packet
## is currently selected, spawning/dragging the held plant preview, and
## finalizing placement (spending sun) once it's placed on the board.
extends Node
class_name seedBankManager

@onready var _sunManager: sunManager = %SunManager
@onready var seedBank: seedbank = %Seedbank

## The seed packets currently available in the bank, populated once
## [member seedBank] finishes initializing.
var seedSlots : Array[seedpacket]

## The plant instance currently being dragged/previewed, or null if nothing
## is selected.
var holdingPlant : Plant

## The seed packet currently selected in the bank, or null if none is.
var selectedSeedpacket : seedpacket = null


func _ready() -> void:
	seedBank.finishedInitializing.connect(initializeSeedpackets)


## Caches the bank's seed slots and wires up their press signals.
func initializeSeedpackets():
	seedSlots = seedBank.getSeedSlots()
	connectToSeedpackets()


## Called when [param seedPacket] is pressed. Toggles selection if it's
## already selected, otherwise swaps the current selection for it and
## spawns a draggable preview plant (if affordable).
func onSeedpacketPressed(seedPacket: seedpacket):
	if not seedPacket.seedData:
		return
	var cost : int = seedPacket.seedData.stats.sunCost
	if selectedSeedpacket == seedPacket:
		unselectCurrent()
		return
	if not _sunManager.canAfford(cost):
		return
	unselectCurrent()
	selectedSeedpacket = seedPacket
	selectedSeedpacket.isSelected = true
	holdingPlant = selectedSeedpacket.spawnPlant()
	holdingPlant.plantPlaced.connect(onPlantPlaced)


## Called once [member holdingPlant] is actually placed on the board.
## Spends the sun cost and clears selection state.
func onPlantPlaced():
	if holdingPlant.plantPlaced.is_connected(onPlantPlaced):
		holdingPlant.plantPlaced.disconnect(onPlantPlaced)
	_sunManager.spendSun(selectedSeedpacket.seedData.stats.sunCost)
	selectedSeedpacket.isSelected = false
	holdingPlant = null
	selectedSeedpacket = null


## Cancels the current selection: kills the held preview plant (if any)
## and deselects the seed packet.
func unselectCurrent():
	if holdingPlant:
		holdingPlant.dragC.isDragged = false
		holdingPlant.die()
		holdingPlant = null

	if selectedSeedpacket:
		selectedSeedpacket.isSelected = false
	selectedSeedpacket = null


## Wires every slot's pressed signal to [method onSeedpacketPressed].
func connectToSeedpackets():
	for seedPacket in seedSlots:
		seedPacket.seedpacketPressed.connect(onSeedpacketPressed)
