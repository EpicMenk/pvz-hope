extends Node
class_name levelManager

@onready var _actionContext: actionContext = %ActionContext
@export var levelLoaded : levelResource
var totalWaves : int
var currentWave : int
var isLevelRunning : bool = true

#func _process(delta: float) -> void:
	#if isLevelRunning == false:
		#return
	#for wave in levelLoaded.waves:
		#for actions in wave.waveActions:
			#actions.executeAction(_actionContext)

func _ready() -> void:
	startLevel()

func startLevel():
	await get_tree().create_timer(levelLoaded.initialWaitTime).timeout
	startFirstWave()

func startFirstWave():
	currentWave = 0
	getCurrentWave().getWaveActionAtIndex(0).executeAction(_actionContext)
	

func getCurrentWave():
	return levelLoaded.waves[currentWave]
