extends physicsSprite2D
class_name sun

signal sunClicked(_sun : sun)

var sunLifeTime : float 
var sunValue : int = 50
@export var _clickComponent: clickComponent
@export var sunLifeTimeTimer: Timer 



func _ready() -> void:
	_clickComponent.clicked.connect(onClicked)
	sunLifeTimeTimer.timeout.connect(func() : playDisappearingTween())
	landed.connect(func(): sunLifeTimeTimer.start())

func onClicked():
	modulate.a = 1
	sunLifeTimeTimer.stop()
	_clickComponent.disable()
	simulatePhysics = false
	sunClicked.emit(self)

func tweenToPosition(_position : Vector2):
	var tween = get_tree().create_tween()
	var tweenDuration : float = 0.3
	tween.tween_property(self , "position" , _position , tweenDuration)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.connect("finished" , func(): playDisappearingTween())

func evaluateStats(stats : sunStats):
	sunValue = stats.sunValue
	sunLifeTime = stats.sunLifeTime
	sunLifeTimeTimer.wait_time = sunLifeTime
