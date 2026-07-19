extends Node2D
class_name sunSpawnComponent

@export var sunConfig : sunStats
@onready var spawnMarker : Marker2D = %SpawnMarker
@export var spawnTimer: Timer
@export var spawnTimerWaitTime : float 
var floorMarker : Marker2D
var _sunManager : sunManager
var isActive : bool 

func _ready() -> void:
	spawnTimer.timeout.connect(spawnSun)

func evaluateStats():
	spawnTimer.wait_time = spawnTimerWaitTime

func spawnSun():
	if not isActive:
		return
	_sunManager.spawnSun(sunConfig ,
	spawnMarker.global_position ,
	floorMarker.global_position.y , 
	Vector2(randf_range(-750,750) , -750))

func disable():
	isActive = false
	spawnTimer.stop()

func enable():
	isActive = true
	spawnTimer.start()
