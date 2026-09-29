extends Node
class_name entityComponent

@onready var parent : boardEntity = self.get_parent()
var _behavior := entityComponentBehavior.new(self)

func enable(): _behavior.enable()
func disable(): _behavior.disable()
func isActivated() -> bool: return _behavior.isActivated()
