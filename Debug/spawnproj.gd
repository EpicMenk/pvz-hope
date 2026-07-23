extends Button

@export var projectileScene : PackedScene 
@onready var _boardManager: boardManager = %BoardManager
@export var _projectileStats : projectileStats = projectileStats.new()

func _ready() -> void:
	pressed.connect(spawnProjectile)


func spawnProjectile():
	var projectileInstance : projectile = projectileScene.instantiate()
	projectileInstance.global_position = Vector2(50,50)
	_boardManager.projectileManager.add_child(projectileInstance)
	projectileInstance.evaluateStats(_projectileStats)
