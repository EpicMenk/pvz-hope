extends physicsSprite2D
class_name sun

signal sunClicked(_sun : sun)

@export var sunValue : int = 50
@onready var _clickComponent: clickComponent = %ClickComponent
var _sunManager : sunManager


func _ready() -> void:
	_clickComponent.clicked.connect(onClicked)

func onClicked():
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
