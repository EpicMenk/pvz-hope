extends Plant
class_name peashooter

@export var stats : plantStats

@export var straightShooterC: straightShooterComponent 

func evaluateStats():
	straightShooterC.evaluateStats()
	hpC.updateMaxHP(stats.maxHP)
