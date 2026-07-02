extends Node2D
class_name straightShooterComponent

@export var animPlayer : AnimationPlayer 
@export var timeBetweenShots : float 
@export var burstCount := 1
@export var burstDelay := 0.0
@export var projectileScene : PackedScene #will be a projectile class later when i make it and will preload the projectile
@onready var spawnPoints: Array[Marker2D] = []
@onready var parent : boardEntity = get_parent() as boardEntity
@onready var timeBetweenShotsTimer: Timer = %timeBetweenShots
var readyToShoot : bool = false

func setUpMarks():
	for child in %spawnPoints.get_children():
		spawnPoints.append(child as Marker2D)

func _ready() -> void:
	setUpMarks()
	timeBetweenShotsTimer.wait_time = timeBetweenShots
	timeBetweenShotsTimer.start()
	timeBetweenShotsTimer.timeout.connect(updateShoot)

func _process(_delta):
	tryShoot()

func updateShoot():
	readyToShoot = true
	timeBetweenShotsTimer.stop()

func tryShoot():
	if not readyToShoot:
		return
	if parent is Plant:
		if not parent._boardManager.isZombieAhead(parent.lane , parent.global_position.x):
			return
	animPlayer.play("shoot")

func shoot() -> void:
	for i in burstCount:
		for point in spawnPoints:
			spawnProjectile(point)
		if i != burstCount - 1:
			readyToShoot = false
			await get_tree().create_timer(burstDelay).timeout
			readyToShoot = true
	readyToShoot = false
	timeBetweenShotsTimer.start()

func spawnProjectile(point : Marker2D):
	var _projectile : projectile = projectileScene.instantiate()
	_projectile.attacker = parent
	_projectile.global_position = point.global_position
	parent._boardManager.projectileSide.add_child(_projectile)
