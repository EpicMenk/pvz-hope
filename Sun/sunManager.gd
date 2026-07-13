extends Node
class_name sunManager

signal sunValueChanged(currentSunCount : int)

@export var maxSun : int
@export var startingSun : int = 50
var currentSun : int :
	set(amount):
		currentSun = clamp(amount , 0 , maxSun)
		sunValueChanged.emit(currentSun)

func _ready() -> void:
	addSun(startingSun)

func canAfford(cost : int) -> bool:
	return cost <= currentSun

func addSun (value:int):
	currentSun += value

func spendSun (value:int):
	currentSun -= value

func setSun(value : int):
	currentSun = value
