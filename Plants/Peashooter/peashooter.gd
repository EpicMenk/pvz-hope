extends Plant
class_name peashooter

@export var stats : plantStats
@export var _attackConfigs : attackConfigs
@export var _projectileConfigs : projectileConfigs
@export var straightShooterC: straightShooterComponent 


func evaluateStats():
	straightShooterC._projectileStats.damage = _attackConfigs.damage
	straightShooterC._projectileStats.projectileSpeed = _projectileConfigs.projectileSpeed
	straightShooterC._projectileStats.damageType = _attackConfigs.damageType
	straightShooterC.timeBetweenShots = _attackConfigs.timeBetweenAttack
	straightShooterC.projectileScene = _projectileConfigs.projectileScene
	straightShooterC.evaluateStats()
	hpC.updateMaxHP(stats.maxHP)

func activateComponent():
	straightShooterC.enable()
	hpC.enable()

func disableComponent():
	straightShooterC.disable()
	hpC.disable()
