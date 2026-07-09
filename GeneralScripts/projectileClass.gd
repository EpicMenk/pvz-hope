extends boardEntity
class_name projectile

@export var damage : int
@export var damageType : damageInfo.damageTypeEnums

@onready var _hitboxComponent: hitboxComponent = %hitboxComponent

var attacker : boardEntity
var _damageInfo : damageInfo


func _ready() -> void:
	buildDamageInfo()
	updateHitboxCollisionMask()

	_hitboxComponent.ownerEntity = self


func processHit(hurtboxes : Array[hurtboxComponent]) -> void:
	var targets := getTargets(hurtboxes)

	for hurtbox in targets:
		hurtbox.takeDamage(_damageInfo)


func getTargets(_hurtboxes : Array[hurtboxComponent]) -> Array[hurtboxComponent]:
	return []


func updateHitboxCollisionMask():
	match team:
		teamEnums.PLANT:
			_hitboxComponent.collision_mask = 1 << 1

		teamEnums.ZOMBIE:
			_hitboxComponent.collision_mask = 1 << 0


func buildDamageInfo():
	_damageInfo = damageInfo.new()
	_damageInfo.amount = damage
	_damageInfo.source = attacker
	_damageInfo.damageType = damageType
