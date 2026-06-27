extends boardEntity
class_name Zombie

@export var hpC : hpComponent
@onready var _hurtboxComponent: hurtboxComponent = %hurtboxComponent

func _ready() -> void:
	updateHurtboxCollisionLayer()

func die():
	_boardManager.unregisterZombie(self)
	queue_free()

func updateHurtboxCollisionLayer():
	match team:
		teamEnums.PLANT:
			_hurtboxComponent.collision_layer = 1 << 0 # Layer 1
		teamEnums.ZOMBIE:
			_hurtboxComponent.collision_layer = 1 << 1 # Layer 2
