extends endCondition
class_name waveHPEndCondition

@export_range(0.0, 1.0) var hpThreshold : float = 0.0


func endConditionCheck(context : actionContext) -> bool:
	if wave == null:
		return false
	return wave.getWaveHPPercent() <= hpThreshold
