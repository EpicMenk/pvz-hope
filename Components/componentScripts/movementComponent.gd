extends entityComponent
class_name movementComponent

signal moved

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
## Units of speed gained/lost per second. 0 (default) = instant start/stop,
## matching the old behavior exactly. >0 = ramps up to full speed on
## start(), and coasts to a stop on stop() instead of halting instantly.
@export var acceleration : float = 0.0

@onready var parent = get_parent() as Node2D

var isMoving : bool = true
var _currentSpeed : float = 0.0
var _isStopping : bool = false


func _process(delta: float) -> void:
	if not isActivated():
		return
	if not isMoving:
		return

	_updateSpeed(delta)
	move(delta)
	moved.emit()

	# Fully decelerated — actually stop processing now.
	if _isStopping and _currentSpeed <= 0.0:
		isMoving = false
		_isStopping = false
		set_process(false)


func _updateSpeed(delta: float) -> void:
	if acceleration <= 0.0:
		_currentSpeed = 0.0 if _isStopping else speed
		return

	var target := 0.0 if _isStopping else speed
	_currentSpeed = move_toward(_currentSpeed, target, acceleration * delta)


func move(delta):
	parent.position += getVelocity() * delta


func getVelocity() -> Vector2:
	return getDirectionVector() * _currentSpeed * velocityModifier


func getDirectionVector() -> Vector2:
	return DIRECTION_VECTORS[direction]


func stop():
	if acceleration <= 0.0 or not isMoving:
		isMoving = false
		_isStopping = false
		set_process(false)
		return
	_isStopping = true   # keep _physics_process running to decelerate


func start():
	_isStopping = false
	isMoving = true
	if acceleration <= 0.0:
		_currentSpeed = speed
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
