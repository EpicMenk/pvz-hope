extends endCondition
class_name timerEndCondition

@export var duration : float = 5.0
var timedOut : bool = false
var hasStarted : bool = false

func endConditionCheck(context : actionContext) -> bool:
	if not hasStarted:
		hasStarted = true
		context.get_tree().create_timer(duration).timeout.connect(func(): timedOut = true)
	return timedOut

func reset():
	timedOut = false
	hasStarted = false
