extends waveAction
class_name sunSkySpawnAction

@export var amount : int
@export_range(0.0, 0.5) var randomJitter : float = 0.0
var finished : bool = false

func executeAction(context : actionContext):
	for i in amount:
		await context.get_tree().create_timer(randf_range(0,randomJitter)).timeout
		context._sunManager.spawnSkySun()
	finished = true

func isFinished(context : actionContext):
	if finished == true:
		return true
