extends Plant
class_name sunflower

@export var sunSpawnC : sunSpawnComponent
@export var stats : plantStats
@export var _sunConfigs : sunConfigs


func evaluateStats():
	sunSpawnC.spawnTimerWaitTime = _sunConfigs.timeBetweenSun
	sunSpawnC.sunConfig = _sunConfigs._sunStats
	sunSpawnC._sunManager = _boardManager._sunManager
	sunSpawnC.floorMarker = ground
	sunSpawnC.evaluateStats()
	hpC.updateMaxHP(stats.maxHP)

func activateComponent():
	sunSpawnC.enable()
	hpC.enable()

func disableComponent():
	sunSpawnC.disable()
	hpC.disable()
