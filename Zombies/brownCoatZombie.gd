extends Zombie
class_name brownCoatZombie

@export var stats : zombieStats
@export var attackStats : attackConfigs
@export var rangeStats : rangeConfigs

func evaluateStats():
	zombieMeleeC.attackReachInTiles = rangeStats.rangeInTiles
	zombieMeleeC.damage = attackStats.damage
	zombieMeleeC.attackCooldown = attackStats.timeBetweenAttack
	zombieMeleeC.damageType = attackStats.damageType
	zombieMovementC.speed = stats.speed
	zombieMeleeC.evaluateStats()
	hpC.updateMaxHP(stats.hp)

func disableComponent():
	zombieMeleeC.disable()
	zombieMovementC.disable()
	hpC.disable()

func activateComponent():
	zombieMeleeC.enable()
	zombieMovementC.enable()
	hpC.enable()
