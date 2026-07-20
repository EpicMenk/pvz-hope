extends RefCounted
class_name entityComponentBehavior

var isActive : bool = true
var _owner : Node

func _init(owner: Node):
	_owner = owner

func isActivated() -> bool:
	return isActive

func enable():
	isActive = true
	_owner.set_process(true)
	_owner.set_physics_process(true)

func disable():
	isActive = false
	_owner.set_process(false)
	_owner.set_physics_process(false)
