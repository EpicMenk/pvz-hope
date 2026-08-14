extends Zombie
class_name basicZombie



func evaluateStats():
	zombieMovementC.speed = stats.speed
	zombieMeleeC.evaluateStats()
	hpC.updateShield(stats.shield)
	hpC.updateMaxHP(stats.hp)
