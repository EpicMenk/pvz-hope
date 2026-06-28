extends Node
class_name meleeAttackComponent

signal startedAttacking
signal stoppedAttacking


@export var damage : int 
@export var attackReachInTiles : int
@export var attackCooldown : float 
@export var attackCooldownTimer: Timer 
var canAttack : bool = true
var isAttacking : bool = false

func _ready() -> void:
	attackCooldownTimer.wait_time = attackCooldown
	attackCooldownTimer.start()
	attackCooldownTimer.timeout.connect(attack)

func attack():
	if not canAttack:
		return 
	var target := getTarget()
	if target == null:
		setAttacking(false)
		return
	setAttacking(true)
	_dealDamage(target)

func getTarget() -> boardEntity:
	return null #subclass overrides this


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
	hurtbox.takeDamage(damage)
	attackCooldownTimer.start()

#helper functions
func stopAttack():
	canAttack = false
	attackCooldownTimer.stop()
	setAttacking(false)

func startAttack():
	canAttack = true
	attackCooldownTimer.start()
	setAttacking(true)
