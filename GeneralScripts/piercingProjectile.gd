extends projectile
class_name piercingProjectile

@export var pierceCount := 1
const INF_PIERCE := -1

var alreadyHit: Array[hurtboxComponent]


func _physics_process(_delta: float) -> void:
	var hurtboxes := getTargets(_hitboxComponent.getCollidingHurtboxes())
	
	for hurtbox in hurtboxes:
		hurtbox.takeDamage(_damageInfo)
		
		if consumePierce():
			die()
			break


func getTargets(hurtboxes: Array[hurtboxComponent]) -> Array[hurtboxComponent]:
	var targets: Array[hurtboxComponent]
	
	for hurtbox in hurtboxes:
		if hurtbox in alreadyHit:
			continue
	
		alreadyHit.append(hurtbox)
		targets.append(hurtbox)
	
	return targets


func consumePierce() -> bool:
	if pierceCount == INF_PIERCE:
		return false
	
	pierceCount -= 1
	return pierceCount <= 0
