extends Control
class_name seedbank

signal finishedInitializing()

@export var selectedSeedPackets : Array[seedPacketData] #exported for now for debugging
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

func getSeedSlots () -> Array[seedpacket]:
	return seedSlots

func getSeedAtIndex(index : int)-> seedpacket:
	return seedSlots[index]

func populateSeedSlots():
	var count = min(seedSlotNum , selectedSeedPackets.size())
	
	for i in range(count):
		seedSlots[i].initialize(selectedSeedPackets[i] ) 
	

func cacheSeedSlots():
	for child in vBoxContainer.get_children() : 
		if child is seedpacket:
			seedSlots.append(child)


func createBlankSeedSlots():
	for i in range(seedSlotNum):
		var seedPacket :seedpacket= seedPacketScene.instantiate()
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
		* 2
	)
