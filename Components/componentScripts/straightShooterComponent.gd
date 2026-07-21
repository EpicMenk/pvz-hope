extends entityComponent2D
class_name straightShooterComponent

@export var _attackConfigs : attackConfigs = attackConfigs.new()
@export var _projectileConfigs : projectileConfigs = projectileConfigs.new()
@export var _projectileStats : projectileStats = projectileStats.new()
@export var animPlayer : AnimationPlayer 
@export var timeBetweenShots : float 
@export var burstCount := 1
@export var burstDelay := 0.0
@export var projectileScene : PackedScene 
@onready var spawnPoints: Array[Marker2D] = []
@onready var parent : boardEntity = get_parent() as boardEntity
@onready var timeBetweenShotsTimer: Timer = %timeBetweenShots
var readyToShoot : bool = false

func setUpMarks():
	for child in %spawnPoints.get_children():
		spawnPoints.append(child as Marker2D)

func _ready() -> void:
	setUpMarks()
	timeBetweenShotsTimer.timeout.connect(updateShoot)

func evaluateStats():
	_projectileStats.damage = _attackConfigs.damage
	_projectileStats.damageType = _attackConfigs.damageType
	_projectileStats.projectileSpeed = _projectileConfigs.projectileSpeed
	timeBetweenShots = _attackConfigs.timeBetweenAttack
	projectileScene = _projectileConfigs.projectileScene
	timeBetweenShotsTimer.wait_time = timeBetweenShots
	timeBetweenShotsTimer.start()


func _process(_delta):
	if not isActivated():
		return
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
	var projectileInstance : projectile = projectileScene.instantiate()
	projectileInstance.attacker = parent
	projectileInstance.global_position = point.global_position
	parent._boardManager.projectileSide.add_child(projectileInstance)
	projectileInstance.evaluateStats(_projectileStats)

func disable():
	super()
	timeBetweenShotsTimer.stop()

func enable():
	super()
	timeBetweenShotsTimer.start()
