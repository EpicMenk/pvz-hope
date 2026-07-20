extends entityComponent2D
class_name sunSpawnComponent

@export var _sunStats : sunStats = sunStats.new()
@export var _sunConfigs : sunConfigs = sunConfigs.new()
@export var spawnTimer: Timer
@export var spawnTimerWaitTime : float 
@onready var spawnMarker : Marker2D = %SpawnMarker
var floorMarker : Marker2D
var _sunManager : sunManager

func _ready() -> void:
	spawnTimer.timeout.connect(spawnSun)

func evaluateStats():
	spawnTimerWaitTime = _sunConfigs.timeBetweenSun
	_sunStats = _sunConfigs._sunStats
	spawnTimer.wait_time = spawnTimerWaitTime

func spawnSun():
	if not _behavior.isActive:
		return
	_sunManager.spawnSun(_sunStats ,
	spawnMarker.global_position ,
	floorMarker.global_position.y , 
	Vector2(randf_range(-750,750) , -750))

func disable():
	super()
	spawnTimer.stop()

func enable():
	super()
	spawnTimer.start()
