## UI panel for the seed bank: creates and populates seed packet slots,
## and sizes the backpack lid/straps to fit them. Emits
## [signal finishedInitializing] once slots are ready, which
## [SeedBankManager] waits on before wiring up press handlers.
extends Control
class_name seedbank

signal finishedInitializing()

## The plant loadout to populate the bank with. Exported directly for
## debugging — eventually this should come from the level/player's actual
## loadout rather than being set per-scene.
@export var selectedSeedPackets : Array[seedPacketData]

@onready var seedSlots : Array[seedpacket]
@onready var vBoxContainer: VBoxContainer = %VBoxContainer
@onready var lid: Panel = %Lid
@onready var straps: TextureRect = %Straps
@export var seedSlotNum : int = 0
@onready var seedPacketScene : PackedScene = preload("res://Seedpacket/baseSeedpacket.tscn")
@onready var _boardManager: boardManager = %BoardManager
@onready var _sunManager: sunManager = %SunManager


func _ready() -> void:
	createBlankSeedSlots()
	cacheSeedSlots()
	populateSeedSlots()
	lid.custom_minimum_size.y = getRequiredLidHeight()
	call_deferred("updateStrappers")
	finishedInitializing.emit()


## Returns every seed slot in the bank.
func getSeedSlots() -> Array[seedpacket]:
	return seedSlots


## Returns the seed slot at [param index].
func getSeedAtIndex(index: int) -> seedpacket:
	return seedSlots[index]


## Initializes each seed slot with its corresponding entry from
## [member selectedSeedPackets], up to whichever is smaller between that
## and [member seedSlotNum].
func populateSeedSlots():
	var count = min(seedSlotNum, selectedSeedPackets.size())

	for i in range(count):
		seedSlots[i].initialize(selectedSeedPackets[i])


## Collects every [seedpacket] child of [member vBoxContainer] into
## [member seedSlots].
func cacheSeedSlots():
	for child in vBoxContainer.get_children():
		if child is seedpacket:
			seedSlots.append(child)


## Instantiates [member seedSlotNum] empty seed packet slots and adds them
## to the bank.
func createBlankSeedSlots():
	for i in range(seedSlotNum):
		var seedPacket : seedpacket = seedPacketScene.instantiate()
		seedPacket._sunManager = _sunManager
		vBoxContainer.add_child(seedPacket)
		seedPacket._boardManager = _boardManager

func updateStrappers():
	straps.global_position.y += lid.size.y


func getRequiredLidHeight() -> float:
	lid.grow_vertical = Control.GROW_DIRECTION_END
	var padding := 4
	var separation : int = vBoxContainer.get_theme_constant("separation")
	if seedSlots.is_empty():
		return 0
	
	var packetHeight = seedSlots[0].size.y
	
	return (
		packetHeight * seedSlots.size()
		+ separation * max(seedSlots.size() - 1, 0) + padding
		* 2 + 50
		
	)
