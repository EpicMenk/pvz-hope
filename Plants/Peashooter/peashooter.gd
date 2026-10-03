# peashooter.gd
extends Plant
class_name peashooter

@export var stats : plantStats
@export var straightShooterC: straightShooterComponent


func uponFinishedInitializing():
	straightShooterC.windupStarted.connect(_onShotWindupStarted)
	if animationC:
		animationC.actionFinished.connect(_onAnimFinished)
	evaluateStats()

func evaluateStats():
	straightShooterC.evaluateStats()
	hpC.updateMaxHP(stats.maxHP)

func _onShotWindupStarted(windupTime: float) -> void:
	if animationC:
		animationC.playAction(&"attack", windupTime)

func _onAnimFinished(animName: StringName) -> void:
	if animName == &"attack" and animationC:
		animationC.revertToFallback()
