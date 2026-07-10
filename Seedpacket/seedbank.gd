extends Control
class_name seedbank

@export var selectedSeedPackets : Array[seedPacketData] #exported for now for debugging
@onready var seedSlots : Array[seedpacket]
@onready var vBoxContainer: VBoxContainer = %VBoxContainer
@export var seedSlotNum : int = 1
@onready var seedPacketScene : PackedScene = preload("res://Seedpacket/baseSeedpacket.tscn")
@onready var _boardManager: boardManager = %BoardManager


func _ready() -> void:
	createBlankSeedSlots()
	cacheSeedSlots()
	populateSeedSlots()


func populateSeedSlots():
	var count = min(seedSlotNum , selectedSeedPackets.size())
	
	for i in range(count):
		seedSlots[i].seedData = selectedSeedPackets[i] 
	

func cacheSeedSlots():
	for child in vBoxContainer.get_children() : 
		if child is seedpacket:
			seedSlots.append(child)


func createBlankSeedSlots():
	for i in range(seedSlotNum):
		var seedPacket :seedpacket= seedPacketScene.instantiate()
		vBoxContainer.add_child(seedPacket)
		seedPacket._boardManager = _boardManager
