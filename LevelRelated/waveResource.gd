extends Resource
class_name waveResource

@export var waveActions : Array[actionContainer] = []

func getWaveActionAtIndex(index : int):
	return waveActions[index]

func getActionCount() -> int:
	return waveActions.size()
