@abstract
extends Resource
class_name waveAction


func executeAction(context : actionContext):
	push_error("executeAction() needs to be overriden")

func isFinished(context : actionContext):
	push_error("isFinished() needs to be overriden")
	return true
