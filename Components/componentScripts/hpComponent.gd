extends entityComponent
class_name hpComponent

signal damaged(amount: int)
signal healed(amount: int)
signal died
signal eventTriggered(event : StringName)

@export var hpEvents : Dictionary [int , StringName]
@export var shieldEvents : Dictionary [int , StringName]
@export var maxHP : int = 1
@export var maxShield : int = 0
@onready var parent : boardEntity = get_parent() as boardEntity
var hasDied : bool = false
var triggeredEvents : Array
var currentHP : int : 
	set(amount):
		currentHP = clamp(amount , 0 ,maxHP)
		checkHpEvents()
		if currentHP <= 0 and not hasDied:
			hasDied = true
			die()

var shield : int : 
	set(amount):
		shield = clamp(amount , 0 , maxShield)
		checkShieldEvents()


func updateMaxHP(HP : int):
	maxHP = HP
	currentHP = maxHP

func updateMaxShield(amount : int):
	maxShield = amount
	shield = maxShield

func checkShieldEvents():
	var thresholds := shieldEvents.keys()
	thresholds.sort()
	
	for threshold in thresholds:
		if threshold in triggeredEvents:
			continue
		
		if shield <= threshold:
			triggeredEvents.append(threshold)
			eventTriggered.emit(shieldEvents[threshold])


func checkHpEvents():
	var thresholds := hpEvents.keys()
	thresholds.sort()
	
	for threshold in thresholds:
		if threshold in triggeredEvents:
			continue
		
		if currentHP <= threshold:
			triggeredEvents.append(threshold)
			eventTriggered.emit(hpEvents[threshold])


func takeDamage(damage: int):
	if shield > 0:
		var absorbed : int = int(min(shield, damage))
		shield -= absorbed
		damage -= absorbed
	var hpLost : int = min(currentHP, damage)
	currentHP -= hpLost
	damaged.emit(hpLost)


func heal(amount : int):
	currentHP += amount
	healed.emit(amount)

func overheal(amount : int):
	maxHP += amount
	currentHP += amount
	healed.emit(amount)

func die():
	died.emit()
	parent.die()

func isDead() -> bool:
	return hasDied

func isAlive() -> bool:
	return not hasDied

func getHealthPercent() -> float:
	if hasDied == true :
		return 0.0
	return float(currentHP) / maxHP
