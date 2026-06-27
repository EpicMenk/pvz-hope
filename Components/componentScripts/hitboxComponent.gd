extends Area2D
class_name hitboxComponent

signal collidedWithHurtbox(hurtbox : hurtboxComponent)

var ownerEntity : boardEntity

func _ready() -> void:
	self.area_entered.connect(notifyCollision)

func notifyCollision(area: Area2D):
	if area is hurtboxComponent:
		collidedWithHurtbox.emit(area)
