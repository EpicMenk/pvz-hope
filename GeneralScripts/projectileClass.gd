extends boardEntity
class_name projectile


@export var damage : int #will be damageInfo object 
@export var pierceCount: int = 0 #number of zombie that this can 
#hit before disappearing
const INF_PIERCE = -1
@export var destroyOnHit: bool = true
@onready var _hitboxComponent: hitboxComponent = %hitboxComponent
var alreadyHit: Array[hurtboxComponent] = []


func _ready() -> void:
	updateHitboxCollisionMask()
	_hitboxComponent.collidedWithHurtbox.connect(dealDamage)
	_hitboxComponent.ownerEntity = self


func dealDamage(hurtbox : hurtboxComponent):
	if hasAlreadyHit(hurtbox):
		return
	hurtbox.takeDamage(damage)
	updatePierce()


func hasAlreadyHit(hurtbox: hurtboxComponent) -> bool:
	if hurtbox in alreadyHit:
		return true
	alreadyHit.append(hurtbox)
	return false

func updatePierce():
	if pierceCount == INF_PIERCE:
		return
	pierceCount -= 1
	if pierceCount <= 0:
		die()


func updateHitboxCollisionMask():
	match team:
		teamEnums.PLANT:
			_hitboxComponent.collision_mask = 1 << 1 # Zombie layer (Layer 2)
		teamEnums.ZOMBIE:
			_hitboxComponent.collision_mask = 1 << 0 # Plant layer (Layer 1)
