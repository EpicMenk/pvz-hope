extends boardEntity
class_name Zombie

@export var hpC : hpComponent
@export var hurtboxC: hurtboxComponent
@export var zombieMeleeC: zombieMeleeAttackComponent 
@export var zombieMovementC: zombieMovementComponent 
@export var zombieAnimationC: zombieAnimationComponent 
@onready var groundMarker: Marker2D = $GroundMarker

@onready var lowerHandRight: Sprite2D = $visuals/Torso/UpperHandRight/LowerHandRight
var test 
var test2 = false

func _ready() -> void:
	updateHurtboxCollisionLayer()
	hpC.eventTriggered.connect(evaluateEvent)
	zombieMeleeC.startedAttacking.connect(zombieMovementC.stop)
	zombieMeleeC.stoppedAttacking.connect(zombieMovementC.start)

func evaluateEvent(event : StringName):
	match event:
		&"dropRightArm":
			dropLimb(lowerHandRight)

func dropLimb(limb : Sprite2D):
	var _floor : float = groundMarker.global_position.y
	limb.visible = false
	var physicObject : physicsSprite2D = load("uid://cduer3twlusei").instantiate()
	get_parent().add_child(physicObject)
	physicObject.copyHierarchy(limb , _floor)
	physicObject.drop(
	Vector2(120, -350))


func getHurtboxComponent() -> hurtboxComponent:
	return hurtboxC

func die():
	_boardManager.unregisterZombie(self)
	queue_free()

func updateHurtboxCollisionLayer():
	match team:
		teamEnums.PLANT:
			hurtboxC.collision_layer = 1 << 0 # Layer 1
		teamEnums.ZOMBIE:
			hurtboxC.collision_layer = 1 << 1 # Layer 2
