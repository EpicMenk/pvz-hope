extends Node
class_name sunManager

signal sunValueChanged(currentSunCount : int)

@onready var sunCountLabel: Label = %SunCount
@export var maxSun : int
@export var startingSun : int = 50
var currentSun : int :
	set(amount):
		currentSun = clamp(amount , 0 , maxSun)
		sunValueChanged.emit(currentSun)
		animateSunCount(currentSun)
var sunTween : Tween


func animateSunCount(newValue : int):
	if sunTween:
		sunTween.kill()
	var from := int(sunCountLabel.text)
	sunTween = create_tween()
	sunTween.tween_method(
		func(value: float):
			sunCountLabel.text = str(roundi(value)),
		from,
		newValue,
		0.2
	)


func _ready() -> void:
	addSun(startingSun)
	sunCountLabel.text = str(currentSun)

func canAfford(cost : int) -> bool:
	return cost <= currentSun

func addSun (value:int):
	currentSun += value

func spendSun (value:int):
	currentSun -= value

func setSun(value : int):
	currentSun = value
