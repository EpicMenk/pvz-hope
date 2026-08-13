extends Node
class_name levelManager

@onready var _actionContext: actionContext = %ActionContext
@export var levelLoaded : levelResource

var totalWaves : int 
var currentWaveIndex : int = -1
var currentActionIndex : int = 0
var isLevelRunning : bool = false


func _ready() -> void:
	totalWaves = levelLoaded.waves.size()
	startLevel()

func startLevel():
	await get_tree().create_timer(levelLoaded.initialWaitTime).timeout
	startNextWave()

func startNextWave():
	currentWaveIndex += 1
	if currentWaveIndex >= totalWaves:
		isLevelRunning = false
		print("Level complete!")
		return
	currentActionIndex = 0
	isLevelRunning = true
	startCurrentAction()

func startCurrentAction():
	getCurrentWave().getWaveActionAtIndex(currentActionIndex).executeAction(_actionContext)
	print("executed")

func getCurrentWave():
	return levelLoaded.waves[currentWaveIndex]

func _process(_delta: float) -> void:
	if not isLevelRunning:
		return
	var currentContainer : actionContainer = getCurrentWave().getWaveActionAtIndex(currentActionIndex)
	if currentContainer.isFinished(_actionContext):
		currentActionIndex += 1
		if currentActionIndex >= getCurrentWave().getActionCount():
			startNextWave()
		else:
			startCurrentAction()
