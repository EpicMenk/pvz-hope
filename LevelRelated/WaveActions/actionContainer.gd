extends waveAction
class_name actionContainer

@export var actions : Array[waveAction]

func executeAction(context : actionContext):
	for action in actions:
		action.executeAction(context)
