extends Area2D
class_name hitboxComponent

var ownerEntity : boardEntity

func getCollidingHurtboxes() -> Array[hurtboxComponent]:
	var result : Array[hurtboxComponent]

	for area in get_overlapping_areas():
		if area is hurtboxComponent:
			result.append(area)

	return result
