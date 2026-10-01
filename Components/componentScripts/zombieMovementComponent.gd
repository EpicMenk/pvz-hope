extends movementComponent
class_name zombieMovementComponent

@export var burst : burstSequencer = burstSequencer.new()   # repeatCount should stay 2 — one per leg, not a tunable balance value
@export var stepTime : float

signal cycleStarted(interval: float)   # pure domain signal — knows nothing about animation

var _walking : bool = false
var _loopActive : bool = false

@onready var zombie := parent as Zombie


func evaluateStats() -> void:
	resumeWalking()

func resumeWalking() -> void:
	_walking = true
	if _loopActive:
		return   # a suspended loop iteration picks this back up on its own
	walkLoop()

func pauseWalking() -> void:
	_walking = false
	stop(true)

func walkLoop() -> void:
	_loopActive = true
	while _walking:
		var cycleInterval := stepTime * burst.repeatCount + burst.repeatDelay * (burst.repeatCount - 1)
		cycleStarted.emit(cycleInterval)
		await burst.fire(doStep)
		if not _walking:
			break
		await get_tree().create_timer(burst.repeatDelay).timeout
	_loopActive = false

func doStep() -> void:
	if not _walking and _loopActive:
		return
	start(true)
	await get_tree().create_timer(stepTime).timeout
	if not is_instance_valid(self) or not _walking:
		return
	stop(true)

func move(delta):
	zombie.position += getVelocity() * delta   # no melee check needed — pauseWalking() already halts this via stop()
	updateGridPosition()
