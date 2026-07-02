extends Area2D
class_name hurtboxComponent

@export var hpC : hpComponent

func takeDamage(damage : damageInfo): #will be damageInfo
	hpC.takeDamage(damage.amount)
