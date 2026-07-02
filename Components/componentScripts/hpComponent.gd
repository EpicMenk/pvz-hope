extends Node
class_name hpComponent

signal damaged(amount: int)
signal healed(amount: int)
signal died

@export var maxHP : int 
@export var shield : int
@onready var parent : boardEntity = get_parent() as boardEntity
var hasDied : bool = false
var currentHP : int : 
	set(amount):
		currentHP = clamp(amount , 0 ,maxHP)
		if currentHP <= 0 and not hasDied:
			hasDied = true
			die()

func _ready() -> void:
	currentHP = maxHP

# i wanna make a damage data object later 
func takeDamage(damage: int):
	if shield > 0:
		var absorbed := int(min(shield, damage)) 
		shield -= absorbed
		damage -= absorbed
	currentHP -= damage
	damaged.emit(damage)

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
