extends Node
class_name entityComponent

var isActive : bool = true

func isActivated() -> bool:
	return isActive


func disable():
	isActive = false
	set_process(false)
	set_physics_process(false)

func enable():
	isActive = true
	set_process(true)
	set_physics_process(true)
