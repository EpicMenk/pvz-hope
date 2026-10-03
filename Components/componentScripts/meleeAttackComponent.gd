extends entityComponent
class_name meleeAttackComponent

signal startedAttacking
signal stoppedAttacking
signal windupStarted(windupTime: float)
signal didAttack

@export var burst : burstSequencer
@export var damage : int 
@export var attackReachInTiles : int
@export var attackCooldown : float 
@export var windupTime : float = 0.0
@export var attackCooldownTimer: Timer 
@export var damageType : damageInfo.damageTypeEnums
@onready var attacker : boardEntity = get_parent() as boardEntity
var canAttack : bool = true
var isAttacking : bool = false        # true while engaged with a target — may span many bite cycles
var cycleInProgress : bool = false   # true only during one windup+burst — pure re-entrancy guard, resets every cycle
var currentTarget : boardEntity = null   # locked for the whole cycle — never re-queried mid-attack
var _damageInfo : damageInfo


func _ready() -> void:
	attackCooldownTimer.timeout.connect(_onCooldownTimeout)

func evaluateStats():
	buildDamageInfo()
	attackCooldownTimer.wait_time = attackCooldown
	attackCooldownTimer.start()

func _onCooldownTimeout() -> void:
	attackCooldownTimer.start()
	attack()

func attack():
	if not isActivated():
		return
	if not canAttack:
		return
	if cycleInProgress:
		return
	var target := getCurrentTarget()
	if target == null:
		return
	currentTarget = target
	cycleInProgress = true
	setAttacking(true)   # no-ops after the first cycle — startedAttacking only fires once per engagement
	if windupTime > 0.0:
		windupStarted.emit(windupTime)
		await get_tree().create_timer(windupTime).timeout
		if not is_instance_valid(self) or not canAttack:
			cycleInProgress = false
			return
		if not is_instance_valid(currentTarget):
			cycleInProgress = false
			setAttacking(false)
			return
	await burst.fire(hitOnce)
	cycleInProgress = false

func hitOnce():
	if not is_instance_valid(currentTarget):
		return
	dealDamage(currentTarget)

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
		currentTarget = null
		stoppedAttacking.emit()

func dealDamage(target : boardEntity):
	var hurtbox : hurtboxComponent = target.getHurtboxComponent()
	if hurtbox == null:
		return
	hurtbox.takeDamage(_damageInfo)
	didAttack.emit()

func buildDamageInfo():
	_damageInfo = damageInfo.new()
	_damageInfo.amount = damage
	_damageInfo.source = attacker
	_damageInfo.damageType = damageType

func stopAttack():
	canAttack = false
	attackCooldownTimer.stop()
	setAttacking(false)

func startAttack():
	canAttack = true
	attackCooldownTimer.start()
	setAttacking(true)

func disable():
	super()
	attackCooldownTimer.stop()

func enable():
	super()
	attackCooldownTimer.start()
