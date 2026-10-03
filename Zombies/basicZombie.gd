extends Zombie
class_name basicZombie


func uponFinishedInitializing():
	zombieMeleeC.startedAttacking.connect(zombieMovementC.pauseWalking)
	zombieMeleeC.windupStarted.connect(_onAttackWindupStarted)
	zombieMeleeC.stoppedAttacking.connect(zombieMovementC.resumeWalking)
	zombieMovementC.cycleStarted.connect(_onWalkCycleStarted)
	zombieMovementC.resumeWalking()
	evaluateStats()

func evaluateStats():
	zombieMovementC.speed = stats.speed
	zombieMeleeC.evaluateStats()
	hpC.updateMaxShield(stats.shield)
	hpC.updateMaxHP(stats.hp)

func _onAttackWindupStarted(windupTime: float) -> void:
	if animationC:
		animationC.playAction(&"attack", windupTime)

func _onWalkCycleStarted(interval: float) -> void:
	if animationC:
		animationC.playAction(&"walk", interval)
