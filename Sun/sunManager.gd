extends Node
class_name sunManager

signal sunValueChanged(currentSunCount : int)

@onready var sunMarker: Marker2D = %SunMarker
@onready var vfxLayer := %VFXLayer
@onready var sunSpawnTimer: Timer = %SunSpawnTimer
@onready var _boardManager: boardManager = %BoardManager
@onready var _gridManager : gridManager
@onready var sunScene : PackedScene = preload("res://Sun/Sun.tscn")
@onready var sunCountLabel: Label = %SunCount
@export var spawnHeight : float =  -200
@export var maxSun : int
@export var sunSpawnedValue : int = 50
@export var startingSun : int = 50
@export var sunSpawnWaitTime : float = 1
var currentSun : int :
	set(amount):
		currentSun = clamp(amount , 0 , maxSun)
		sunValueChanged.emit(currentSun)
		animateSunCount(currentSun)
var sunTween : Tween


func animateSunCount(newValue : int):
	if sunTween:
		sunTween.kill()
	var from := int(sunCountLabel.text)
	sunTween = create_tween()
	sunTween.tween_method(
		func(value: float):
			sunCountLabel.text = str(roundi(value)),
		from,
		newValue,
		0.2
	)


func spawnSun():
	var _sun : sun = sunScene.instantiate()
	_sun.sunValue = sunSpawnedValue
	_sun._sunManager = self
	_sun.global_position = Vector2(
		randf_range(0.0 , _gridManager.boardSize.x),
		spawnHeight
	)
	_sun.floorY = _gridManager.getLaneY(_gridManager.getRandomLane())
	_boardManager.add_child(_sun)
	_sun.drop(Vector2(0,10))
	_sun.sunClicked.connect(onSunClicked)

func onSunClicked(_sun : sun):
	addSun(_sun.sunValue)
	var screen_pos := _sun.get_global_transform_with_canvas().origin
	_sun.reparent(vfxLayer)
	_sun.position = screen_pos
	_sun.tweenToPosition(sunMarker.global_position)


func setUpSpawnTimer():
	sunSpawnTimer.wait_time = sunSpawnWaitTime
	startSpawningSun()
	sunSpawnTimer.timeout.connect(spawnSun)

func _ready() -> void:
	setUpSpawnTimer()
	_gridManager = _boardManager._gridManager
	addSun(startingSun)
	sunCountLabel.text = str(currentSun)

func stopSpawningSun():
	sunSpawnTimer.stop()

func startSpawningSun():
	sunSpawnTimer.start()


func canAfford(cost : int) -> bool:
	return cost <= currentSun

func addSun (value:int):
	currentSun += value

func spendSun (value:int):
	currentSun -= value

func setSun(value : int):
	currentSun = value
