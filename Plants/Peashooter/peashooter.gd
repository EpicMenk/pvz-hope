extends Plant
class_name peashooter

@export var stats : plantAttackerStats
@onready var straightShooterC: straightShooterComponent = %straightShooterComponent

func initializeStats():
	straightShooterC._projectileStats.damage = stats.damage
	straightShooterC._projectileStats.projectileSpeed = stats.projectileSpeed
	straightShooterC._projectileStats.damageType = stats.damageType
	straightShooterC.timeBetweenShots = stats.timeBetweenAttack
	straightShooterC.projectileScene = stats.projectileScene
