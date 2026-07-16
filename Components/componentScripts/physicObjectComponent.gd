extends Sprite2D
class_name physicsSprite2D

signal landed

# Friction while sliding on the ground.
@export var groundFriction := 700.0
# How quickly spinning slows down.
@export var angularDamping := 10.0
# Internal state so landing only happens once.
var hasLanded := false
# Enables/disables the physics simulation.
@export var simulatePhysics := false
# Current movement velocity in pixels/sec.
@export var velocity := Vector2.ZERO
# Rotation speed in radians/sec.
@export var angularVelocity := 0.0
# Gravity applied every physics frame.
@export var gravity := 1200.0
# Multiplies velocity every second.
# Higher values lose speed faster.
@export var airDrag := 0.0
# Floor position in global coordinates.
# Leave at INF to disable floor collision.
@export var floorY := INF
# Amount of velocity kept after bouncing.
# 0 = no bounce
# 1 = perfect bounce
@export_range(0.0, 1.0)
var bounce := 0.2
@export var disappearsOnLanding : bool = false
@export var disappearTweenDuration : float = 1
const PHYSICS_OBJECT := preload("uid://cduer3twlusei")

func _physics_process(delta):
	if !simulatePhysics:
		return
	
	# Gravity
	velocity.y += gravity * delta
	
	# Air resistance
	velocity *= max(0.0, 1.0 - airDrag * delta)
	
	# Move
	global_position += velocity * delta
	
	# Rotate
	rotation += angularVelocity * delta
	
	# Floor collision
	if global_position.y >= floorY:
		global_position.y = floorY
		# First time hitting the floor
		if !hasLanded:
			hasLanded = true
			landed.emit()
			if disappearsOnLanding:
				playDisappearingTween()
		# Bounce
		if abs(velocity.y) > 5.0:
			velocity.y *= -bounce
		else:
			velocity.y = 0.0
		# Ground friction
		velocity.x = move_toward(
			velocity.x,
			0.0,
			groundFriction * delta
		)
		# Slow down spinning
		angularVelocity = move_toward(
			angularVelocity,
			0.0,
			angularDamping * delta
		)
		# Stop simulating when almost completely still
		if velocity.length() < 2.0 and abs(angularVelocity) < 0.05:
			stop()

func playDisappearingTween():
	var disappearTween := get_tree().create_tween()
	disappearTween.tween_property(self, "modulate:a", 0.0, disappearTweenDuration)
	disappearTween.set_ease(Tween.EASE_IN_OUT)
	disappearTween.set_trans(Tween.TRANS_SINE)
	disappearTween.finished.connect(queue_free)


func copyHierarchy(from: Sprite2D , yfloor : float):
	texture = from.texture
	flip_h = from.flip_h
	flip_v = from.flip_v
	offset = from.offset
	global_position = from.global_position
	global_rotation = from.global_rotation
	global_scale = from.global_scale
	modulate = from.modulate
	show_behind_parent = from.show_behind_parent
	floorY = yfloor
	for child in from.get_children():
		if child is Sprite2D:
			var newChild : physicsSprite2D= preload("uid://cduer3twlusei").instantiate()
			add_child(newChild)
			newChild.copyChildHierarchy(child , yfloor)


func copyChildHierarchy(from: Sprite2D, yFloor: float):
	texture = from.texture
	flip_h = from.flip_h
	flip_v = from.flip_v
	offset = from.offset
	position = from.position
	rotation = from.rotation
	scale = from.scale
	modulate = from.modulate
	show_behind_parent = from.show_behind_parent
	floorY = yFloor
	for child in from.get_children():
		if child is Sprite2D:
			var newChild: physicsSprite2D = PHYSICS_OBJECT.instantiate()
			add_child(newChild)
			newChild.copyChildHierarchy(child, yFloor)


# Starts the simulation with an initial velocity.
func drop(initialVelocity: Vector2, initialAngularVelocity := 0.0):
	simulatePhysics = true
	velocity = initialVelocity
	angularVelocity = initialAngularVelocity


# Stops all movement.
func stop():
	simulatePhysics = false
	velocity = Vector2.ZERO
	angularVelocity = 0.0
