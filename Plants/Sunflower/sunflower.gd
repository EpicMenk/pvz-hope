extends Plant
class_name sunflower

@export var sunSpawnC : sunSpawnComponent
@export var stats : plantStats

func evaluateStats():
	sunSpawnC.evaluateStats()
	hpC.updateMaxHP(stats.maxHP)
