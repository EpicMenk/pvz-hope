extends Area2D
class_name hitboxComponent

signal collidedWithHurtbox(hurtbox : hurtboxComponent)

var ownerEntity : boardEntity

func _ready() -> void:
	self.area_entered.connect(notifyCollision)

func notifyCollision(_area: Area2D):
	collidedWithHurtbox.emit(getCollidingHurtboxes())


func getCollidingHurtboxes() -> Array[hurtboxComponent]:
	var result : Array[hurtboxComponent]
	
	for area in get_overlapping_areas():
		if area is hurtboxComponent:
			result.append(area)
	
	return result
