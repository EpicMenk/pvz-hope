extends Resource
class_name waveResource

@export var waveActions : Array[waveAction] = []

func getWaveActionAtIndex(index : int):
	return waveActions[index]
