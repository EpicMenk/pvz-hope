extends Zombie
class_name basicZombie

@export var stats : zombieStats
@export var _attackConfigs : attackConfigs
@export var _rangeConfigs : rangeConfigs

func evaluateStats():
	zombieMeleeC._attackConfigs = _attackConfigs
	zombieMeleeC._rangeConfigs = _rangeConfigs
	zombieMovementC.speed = stats.speed
	zombieMeleeC.evaluateStats()
	hpC.updateShield(stats.shield)
	hpC.updateMaxHP(stats.hp)
