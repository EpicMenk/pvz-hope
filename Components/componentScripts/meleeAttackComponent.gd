extends entityComponent
class_name meleeAttackComponent

signal startedAttacking
signal stoppedAttacking


@export var damage : int 
@export var attackReachInTiles : int
@export var attackCooldown : float 
@export var attackCooldownTimer: Timer 
@export var damageType : damageInfo.damageTypeEnums
@onready var attacker : boardEntity = get_parent() as boardEntity
var canAttack : bool = true
var isAttacking : bool = false
var _damageInfo : damageInfo


func _ready() -> void:
	attackCooldownTimer.timeout.connect(attack)

func evaluateStats():
	buildDamageInfo()
	attackCooldownTimer.wait_time = attackCooldown
	attackCooldownTimer.start()

func attack():
	if not isActivated():
		return
	if not canAttack:
		return 
	var target := getCurrentTarget()
	if target == null:
		setAttacking(false)
		return
	setAttacking(true)
	_dealDamage(target)

func getTarget() -> boardEntity:
	return null #subclass overrides this

func getCurrentTarget() -> boardEntity:
	return getTarget()


func setAttacking(attacking: bool):
	if isAttacking == attacking:
		return
	isAttacking = attacking
	if attacking:
		startedAttacking.emit()
	else:
		stoppedAttacking.emit()


func _dealDamage(target : boardEntity):
	var hurtbox : hurtboxComponent = target.getHurtboxComponent()
	if hurtbox == null:
		return
	hurtbox.takeDamage(_damageInfo)
	attackCooldownTimer.start()

func buildDamageInfo():
	_damageInfo = damageInfo.new()
	_damageInfo.amount = damage
	_damageInfo.source = attacker
	_damageInfo.damageType = damageType

#helper functions
func stopAttack():
	canAttack = false
	attackCooldownTimer.stop()
	setAttacking(false)

func startAttack():
	canAttack = true
	attackCooldownTimer.start()
	setAttacking(true)
