## Manages the sun economy: current sun count, spawning falling sun both
## from plants and periodically from the sky, and handling sun pickup
## (click-to-collect, fly-to-counter animation).
extends Node
class_name sunManager

signal sunValueChanged(currentSunCount: int)

@onready var sunMarker: Marker2D = %SunMarker
@onready var vfxLayer := %VFXLayer
@onready var sunSpawnTimer: Timer = %SunSpawnTimer
@onready var _boardManager: boardManager = %BoardManager
var _gridManager : gridManager = preload("res://Resources/gridManager.tres")
@onready var sunScene : PackedScene = preload("res://Sun/Sun.tscn")
@onready var sunCountLabel: Label = %SunCount
@export var spawnHeight : float = -200
@export var maxSun : int = 9990
@export var sunSpawnedValue : int = 50
@export var startingSun : int = 50
@export var sunSpawnWaitTime : float = 1
@export var sunSkyStats : sunStats

## Current sun total, clamped to [0, maxSun]. Setting this animates the
## displayed count and emits [signal sunValueChanged].
var currentSun : int :
	set(amount):
		currentSun = clamp(amount, 0, maxSun)
		sunValueChanged.emit(currentSun)
		animateSunCount(currentSun)
var sunTween : Tween


## Tweens the displayed sun count label from its current value to
## [param newValue] over a short duration.
func animateSunCount(newValue: int):
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


## Spawns a [sun] instance configured with [param sunConfig] at
## [param _position], falling toward [param floorY] with initial
## [param force] applied.
func spawnSun(sunConfig: sunStats, _position: Vector2, floorY: float, force: Vector2):
	var _sun : sun = sunScene.instantiate()
	_sun.evaluateStats(sunConfig)
	_sun.global_position = _position
	_sun.floorY = floorY
	_boardManager.add_child(_sun)
	_sun.drop(force)
	_sun.sunClicked.connect(onSunClicked)


## Called when [param _sun] is clicked — collects its value and flies it
## toward [member sunMarker] as a UI effect.
func onSunClicked(_sun: sun):
	addSun(_sun.sunValue)
	var screen_pos := _sun.get_global_transform_with_canvas().origin
	_sun.reparent(vfxLayer)
	_sun.position = screen_pos
	_sun.tweenToPosition(sunMarker.global_position)


## Spawns a sun at a random point along the top of the board, using
## [member sunSkyStats].
func spawnSkySun():
	spawnSun(sunSkyStats,
	Vector2(randf_range(0, _gridManager.boardSize.x), spawnHeight),
	_gridManager.getLaneY(_gridManager.getRandomLane()),
	Vector2(0, 0)
	)


## Configures and connects the periodic sky-sun spawn timer.
func setUpSpawnTimer():
	sunSpawnTimer.timeout.connect(spawnSkySun)
	sunSpawnTimer.wait_time = sunSpawnWaitTime
	startSpawningSun()



func _ready() -> void:
	setUpSpawnTimer()
	addSun(startingSun)
	sunCountLabel.text = str(currentSun)


## Stops periodic sky-sun spawning.
func stopSpawningSun():
	sunSpawnTimer.stop()


## Starts (or resumes) periodic sky-sun spawning.
func startSpawningSun():
	sunSpawnTimer.start()


## Returns whether [param cost] can be paid from the current sun total.
func canAfford(cost: int) -> bool:
	return cost <= currentSun


## Adds [param value] sun.
func addSun(value: int):
	currentSun += value


## Spends [param value] sun.
func spendSun(value: int):
	currentSun -= value


## Directly sets the current sun total to [param value].
func setSun(value: int):
	currentSun = value
