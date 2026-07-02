extends boardEntity
class_name projectile

@export var damage : int #will be damageInfo object 
@export var pierceCount: int = 0 #number of zombie that this can 
#hit before disappearing
const INF_PIERCE = -1
@export var destroyOnHit: bool = true
@export var damageType : damageInfo.damageTypeEnums
@onready var _hitboxComponent: hitboxComponent = %hitboxComponent
var alreadyHit: Array[hurtboxComponent] = []
var attacker : boardEntity
var _damageInfo : damageInfo

func _ready() -> void:
	buildDamageInfo()
	updateHitboxCollisionMask()
	_hitboxComponent.collidedWithHurtbox.connect(dealDamage)
	_hitboxComponent.ownerEntity = self

func dealDamage(hurtbox : hurtboxComponent):
	if hasAlreadyHit(hurtbox):
		return
	hurtbox.takeDamage(_damageInfo)
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

func buildDamageInfo():
	_damageInfo = damageInfo.new()
	_damageInfo.amount = damage
	_damageInfo.source = attacker
	_damageInfo.damageType = damageType
