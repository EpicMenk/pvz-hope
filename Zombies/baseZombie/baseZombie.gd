extends boardEntity
class_name Zombie

@export var hpC : hpComponent
@onready var _hurtboxComponent: hurtboxComponent = %hurtboxComponent
@onready var zombieMeleeC: zombieMeleeAttackComponent = %zombieMeleeAttackComponent
@onready var zombieMovementC: zombieMovementComponent = %zombieMovementComponent


func _ready() -> void:
	updateHurtboxCollisionLayer()
	zombieMeleeC.startedAttacking.connect(zombieMovementC.stop)
	zombieMeleeC.stoppedAttacking.connect(zombieMovementC.start)

func getHurtboxComponent() -> hurtboxComponent:
	return _hurtboxComponent

func die():
	_boardManager.unregisterZombie(self)
	queue_free()

func updateHurtboxCollisionLayer():
	match team:
		teamEnums.PLANT:
			_hurtboxComponent.collision_layer = 1 << 0 # Layer 1
		teamEnums.ZOMBIE:
			_hurtboxComponent.collision_layer = 1 << 1 # Layer 2
