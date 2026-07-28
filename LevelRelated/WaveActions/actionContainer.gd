extends waveAction
class_name actionContainer

@export var actions : Array[waveAction]

func executeAction():
	for action in actions:
		action.executeAction()
