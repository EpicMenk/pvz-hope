extends projectile
class_name singleTargetProjectile

func _physics_process(_delta):
	var hurtboxes := _hitboxComponent.getCollidingHurtboxes()
	if hurtboxes.is_empty():
		return
	processHit(hurtboxes)

func getTargets(hurtboxes : Array[hurtboxComponent]) -> Array[hurtboxComponent]:
	var target := chooseTarget(hurtboxes)
	if target == null:
		return []
	die()
	return [target]


func chooseTarget(hurtboxes : Array[hurtboxComponent]) -> hurtboxComponent:
	if hurtboxes.is_empty():
		return null
	var target := hurtboxes[0]
	for hurtbox in hurtboxes:
		if hurtbox.global_position.x < target.global_position.x:
			target = hurtbox
		elif is_equal_approx(hurtbox.global_position.x, target.global_position.x):
			if hurtbox.owner.ID < target.owner.ID:
				target = hurtbox

	return target
