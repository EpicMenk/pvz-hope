extends Plant
class_name peashooter

@export var stats : plantStats
@export var _attackConfigs : attackConfigs
@export var _projectileConfigs : projectileConfigs
@export var straightShooterC: straightShooterComponent 

func evaluateStats():
	straightShooterC._attackConfigs = _attackConfigs
	straightShooterC._projectileConfigs = _projectileConfigs
	straightShooterC.evaluateStats()
	hpC.updateMaxHP(stats.maxHP)

func activateComponent():
	straightShooterC.enable()
	hpC.enable()

func disableComponent():
	straightShooterC.disable()
	hpC.disable()
