extends Zombie
class_name basicZombie


func _ready() -> void:
	finishedInitializing.connect(onFinishedInitialization)
	zombieMeleeC.startedAttacking.connect(_onAttackStarted)
	zombieMeleeC.stoppedAttacking.connect(zombieMovementC.resumeWalking)
	zombieMovementC.cycleStarted.connect(_onWalkCycleStarted)
	super()

func onFinishedInitialization():
	zombieMovementC.resumeWalking()
	evaluateStats()

func evaluateStats():
	zombieMovementC.resumeWalking()
	zombieMovementC.speed = stats.speed
	zombieMeleeC.evaluateStats()
	zombieMovementC.evaluateStats()
	hpC.updateMaxShield(stats.shield)
	hpC.updateMaxHP(stats.hp)

func _onAttackStarted() -> void:
	zombieMovementC.pauseWalking()
	if animationC:
		animationC.playAction(&"attack", zombieMeleeC.attackCooldown)

func _onWalkCycleStarted(interval: float) -> void:
	if animationC:
		animationC.playAction(&"walk", interval)
