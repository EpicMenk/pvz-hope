extends boardEntity
class_name Zombie

@export var hpC : hpComponent
@export var hurtboxC: hurtboxComponent
@export var zombieMeleeC: zombieMeleeAttackComponent 
@export var zombieMovementC: zombieMovementComponent 
@export var zombieAnimationC: zombieAnimationComponent 


func _ready() -> void:
	updateHurtboxCollisionLayer()
	zombieMeleeC.startedAttacking.connect(zombieMovementC.stop)
	zombieMeleeC.stoppedAttacking.connect(zombieMovementC.start)

func getHurtboxComponent() -> hurtboxComponent:
	return hurtboxC

func die():
	_boardManager.unregisterZombie(self)
	queue_free()

func updateHurtboxCollisionLayer():
	match team:
		teamEnums.PLANT:
			hurtboxC.collision_layer = 1 << 0 # Layer 1
		teamEnums.ZOMBIE:
			hurtboxC.collision_layer = 1 << 1 # Layer 2
