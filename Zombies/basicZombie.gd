extends Zombie
class_name basicZombie



func evaluateStats():
	zombieMovementC.speed = stats.speed
	zombieMeleeC.evaluateStats()
	hpC.updateMaxShield(stats.shield)
	hpC.updateMaxHP(stats.hp)
