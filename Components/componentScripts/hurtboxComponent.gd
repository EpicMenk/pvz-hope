extends Area2D
class_name hurtboxComponent

@export var hpC : hpComponent
@onready var collisionShape2d: CollisionShape2D = %CollisionShape2D


func takeDamage(damage : damageInfo): #will be damageInfo
	hpC.takeDamage(damage.amount)
