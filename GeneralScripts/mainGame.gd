extends Node2D
class_name mainGame

@onready var assigningIDs : int = 0
@onready var button_2: Button =%debug2

func _ready() -> void:
	button_2.zombieCreated.connect(assignIDs)

func assignIDs(zombie : Zombie):
	zombie.ID = assigningIDs
	assigningIDs += 1
