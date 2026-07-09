extends Node
class_name movementComponent

enum directionEnums {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

const DIRECTION_VECTORS := [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
]

@export var velocityModifier : float = 1.0
@export var direction : directionEnums = directionEnums.LEFT
@export var speed : float = 60.0
@export var acceleration : float = 0.0
@onready var parent = get_parent() as Node2D
var isMoving : bool = true

func _process(delta: float) -> void:
	if not isMoving:
		return
	move(delta)

func move(delta):
	parent.position += getVelocity() * delta

func getVelocity() -> Vector2:
	return getDirectionVector() * speed * velocityModifier

func getDirectionVector() -> Vector2:
	return DIRECTION_VECTORS[direction]

func stop():
	isMoving = false
	set_process(false)

func start():
	isMoving = true 
	set_process(true)

func reverseDirection() -> void:
	match direction:
		directionEnums.LEFT:
			direction = directionEnums.RIGHT
		directionEnums.RIGHT:
			direction = directionEnums.LEFT
		directionEnums.UP:
			direction = directionEnums.DOWN
		directionEnums.DOWN:
			direction = directionEnums.UP
