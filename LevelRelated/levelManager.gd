extends Node
class_name levelManager

@onready var _actionContext: actionContext = %ActionContext
@export var levelLoaded : levelResource

var currentWaveIndex : int = -1
var isLevelRunning : bool = false
var maxWaves : int

func _ready() -> void:
	maxWaves = levelLoaded.waves.size()
	startLevel()

func startLevel():
	await get_tree().create_timer(levelLoaded.initialWaitTime).timeout
	startNextWave()

func startNextWave():
	currentWaveIndex += 1
	if currentWaveIndex >= maxWaves:
		isLevelRunning = false
		print("Level complete!")
		return
	isLevelRunning = true
	levelLoaded.waves[currentWaveIndex].executeAction(_actionContext)

func _process(_delta: float) -> void:
	if not isLevelRunning:
		return
	if levelLoaded.waves[currentWaveIndex].isFinished(_actionContext):
		startNextWave()
