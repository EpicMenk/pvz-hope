extends entityComponent2D
class_name sunSpawnComponent

@export var _sunStats : sunStats = sunStats.new()
@export var spawnTimer: Timer
@export var timeBetweenSun : float 
@onready var spawnMarker : Marker2D = %SpawnMarker
@onready var parent : boardEntity = get_parent()
var floorMarker : Marker2D
var _sunManager : sunManager

func _ready() -> void:
	spawnTimer.timeout.connect(spawnSun)

func evaluateStats():
	spawnTimer.wait_time = timeBetweenSun
	_sunManager = parent._boardManager._sunManager
	floorMarker = parent.ground

func spawnSun():
	if not isActivated():
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
