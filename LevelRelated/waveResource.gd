extends Resource
class_name waveResource

@export var _endCondition : endCondition
@export var actions : Array[waveAction]

var totalWaveHP : int = 0
var currentWaveHP : int = 0


func executeAction(context : actionContext):
	currentWaveHP = calculateWaveHP()
	
	_endCondition.reset()
	_endCondition.wave = self
	for action in actions:
		action.wave = self
		action.executeAction(context)



func isFinished(context : actionContext):
	if _endCondition.endConditionCheck(context) == true:
		return true


func calculateWaveHP():
	totalWaveHP = 0
	for action in actions:
		if action is spawnZombieGroupAction:
			for zombieEntries in action.zombiesList:
				var stats : zombieStats = getZombieStatsFromScene(zombieEntries.zombieScene)
				totalWaveHP += stats.hp
	return totalWaveHP



func onZombieDamaged(amount : int):
	currentWaveHP = max(currentWaveHP - amount, 0)


func getWaveHPPercent() -> float:
	if totalWaveHP <= 0:
		return 0.0
	return float(currentWaveHP) / float(totalWaveHP)


# specifically for calculating wave hp do not use otherwise.
func getZombieStatsFromScene(scene : PackedScene) -> zombieStats:
	var state := scene.get_state()
	for i in state.get_node_property_count(0):
		if state.get_node_property_name(0, i) == "stats":
			return state.get_node_property_value(0, i)
	return null
