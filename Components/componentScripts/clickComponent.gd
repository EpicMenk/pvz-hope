extends Area2D
class_name clickComponent

signal clicked

enum InteractionMode {
	CLICK_ONLY,
	CLICK_AND_DRAG
}

@export var interactionMode : InteractionMode = InteractionMode.CLICK_ONLY

var isActive := true

func _ready() -> void:
	input_event.connect(onInputEvent)
	mouse_entered.connect(onMouseEntered)

func onMouseEntered() -> void:
	if not isActive:
		return

	if interactionMode != InteractionMode.CLICK_AND_DRAG:
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		clicked.emit()

func onInputEvent(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not isActive:
		return
	
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		clicked.emit()

func disable():
	isActive = false
	input_pickable = false

func enable():
	isActive = true
	input_pickable = true
