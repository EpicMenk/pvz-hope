@abstract
extends Resource
class_name endCondition

var wave : waveResource 

func endConditionCheck(context : actionContext) -> bool:
	push_error("endConditionCheck() needs to be overriden")
	return true

func reset():
	pass # override only if the condition has per-use state to clear (like a timer) since resources are shared by default
	
