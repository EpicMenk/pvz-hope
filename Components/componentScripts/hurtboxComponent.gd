extends Area2D
class_name hurtboxComponent

@export var hpC : hpComponent

func takeDamage(damage : int): #will be damageInfo
	hpC.takeDamage(damage)
