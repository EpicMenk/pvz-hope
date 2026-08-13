extends Resource
class_name waveResource

@export var _endCondition : endCondition
@export var actions : Array[waveAction]


func executeAction(context : actionContext):
	_endCondition.reset()
	for action in actions:
		action.executeAction(context)

func isFinished(context : actionContext):
	if _endCondition.endConditionCheck(context) == true:
		return true
