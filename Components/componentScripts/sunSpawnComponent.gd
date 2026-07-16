extends entityComponent
class_name sunSpawnComponent

@onready var spawnTimer: Timer = %Timer

func _ready() -> void:
	spawnTimer.timeout.connect(spawnSun)

func spawnSun():
	pass
