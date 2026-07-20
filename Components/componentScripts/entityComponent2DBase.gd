extends Node2D
class_name entityComponent2D

var _behavior := entityComponentBehavior.new(self)

func enable(): _behavior.enable()
func disable(): _behavior.disable()
func isActivated() -> bool: return _behavior.isActivated()
