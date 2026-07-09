extends Node2D
class_name dragComponent


var isDragged : bool = false
@onready var dragTarget = get_parent()



@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if isDragged == true:
		dragTarget.global_position = get_global_mouse_position() 





func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton :
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if isDragged == true:
				SignalBus.emit_signal("placePlant" , dragTarget , dragTarget.global_position)
