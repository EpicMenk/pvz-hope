extends Zombie
class_name basicZombie


func uponFinishedInitializing():
	zombieMeleeC.startedAttacking.connect(zombieMovementC.pauseWalking)
	zombieMeleeC.cycleFired.connect(_onAttackCycleFired)
	zombieMeleeC.stoppedAttacking.connect(zombieMovementC.resumeWalking)
	zombieMovementC.cycleStarted.connect(_onWalkCycleStarted)
	zombieMovementC.resumeWalking()
	evaluateStats()

func evaluateStats():
	zombieMovementC.speed = stats.speed
	zombieMeleeC.evaluateStats()
	hpC.updateMaxShield(stats.shield)
	hpC.updateMaxHP(stats.hp)

func _onAttackCycleFired(interval: float) -> void:
	if not animationC:
		return
	var delay := animationC.getActionLeadDelay(&"attack", interval)
	await get_tree().create_timer(delay).timeout
	if not is_instance_valid(self) or not zombieMeleeC.isAttacking:
		return   
	animationC.playAction("attack" , interval)

func _onWalkCycleStarted(interval : float) -> void:
	if not animationC:
		return
	animationC.playAction("walk", interval)
