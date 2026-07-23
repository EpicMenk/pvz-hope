extends Node2D
class_name mainGame

@onready var assigningIDs : int = 0
@onready var button_2: Button =%debug2
@onready var zombies: Node2D = %Zombies
@onready var projectiles: Node2D = %Projectiles


func _process(delta: float) -> void:
	print(projectiles.get_child_count())

func _ready() -> void:
	button_2.zombieCreated.connect(assignIDs)

func assignIDs(zombie : Zombie):
	zombie.ID = assigningIDs
	assigningIDs += 1
