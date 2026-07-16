extends Plant
class_name sunflower

@export var sunSpawnC : sunSpawnComponent
@export var plantSunProcStats : plantSunProducerStats

func evaluateStats():
	sunSpawnC.spawnTimer.wait_time = plantSunProcStats.timeBetweenSun
	sunSpawnC.sunConfig = plantSunProcStats.sunConfig
	sunSpawnC._sunManager = _boardManager._sunManager
	sunSpawnC.floorMarker = ground
	hpC.updateMaxHP(plantSunProcStats.maxHP)

func activateComponent():
	sunSpawnC.enable()
	hpC.enable()

func disableComponent():
	sunSpawnC.enable()
	hpC.disable()
