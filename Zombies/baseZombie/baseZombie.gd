extends boardEntity
class_name Zombie

@export var hpC : hpComponent
#var grid : Vector2i
#var lane : int

func die():
	_boardManager.unregisterZombie(self)
	queue_free()
