extends Plant
class_name peashooter

@export var stats : plantAttackerStats
@export var straightShooterC: straightShooterComponent 


func evaluateStats():
	straightShooterC._projectileStats.damage = stats.damage
	straightShooterC._projectileStats.projectileSpeed = stats.projectileSpeed
	straightShooterC._projectileStats.damageType = stats.damageType
	straightShooterC.timeBetweenShots = stats.timeBetweenAttack
	straightShooterC.projectileScene = stats.projectileScene
	hpC.updateMaxHP(stats.maxHP)

func activateComponent():
	straightShooterC.enable()
	hpC.enable()

func disableComponent():
	straightShooterC.disable()
	hpC.disable()
