extends movementComponent
class_name zombieMovementComponent

@export var burst : burstSequencer = burstSequencer.new()   # repeatCount should stay 2 — one per leg, not a tunable balance value
@export var stepTime : float

@onready var zombie := parent as Zombie


func _ready() -> void:
	walkLoop()

func walkLoop() -> void:
	while true:
		var cycleInterval := stepTime * burst.repeatCount + burst.repeatDelay * (burst.repeatCount - 1)
		scheduleWalkVisual(cycleInterval)
		await burst.fire(doStep)
		await get_tree().create_timer(burst.repeatDelay).timeout

func doStep() -> void:
	start(true)
	await get_tree().create_timer(stepTime).timeout
	if not is_instance_valid(self):
		return
	stop(true)

func move(delta):
	if zombie.zombieMeleeC.getCurrentTarget():
		return
	zombie.position += getVelocity() * delta
	updateGridPosition()

func scheduleWalkVisual(interval: float) -> void:
	if zombie.animationC:
		zombie.animationC.playAction(&"walk", interval)
