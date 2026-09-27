extends entityComponent2D
class_name straightShooterComponent

@export var _projectileStats : projectileStats = projectileStats.new()
@export var burst : burstSequencer 
@export var animPlayer : AnimationPlayer 
@export var timeBetweenShots : float 
@export var repeatCount := 1
@export var repeatDelay := 0.0
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
		if not parent._zombieManager.isZombieAhead(parent.lane , parent.global_position.x):
			return
	readyToShoot = false
	if animPlayer:
		animPlayer.play("attack")
	timeBetweenShotsTimer.start()
	burst.fire(fireSpawnPoints)


func fireSpawnPoints() -> void:
	for point in spawnPoints:
		spawnProjectile(point)


func spawnProjectile(point : Marker2D):
	var _boardManager : boardManager = parent._boardManager
	var projectileInstance : projectile = SpawnHelper.spawnEntity(projectileScene , _boardManager , _boardManager._projectileManager , point.global_position , parent.grid)
	projectileInstance.attacker = parent
	projectileInstance.evaluateStats(_projectileStats)

func disable():
	super()
	timeBetweenShotsTimer.stop()

func enable():
	super()
	timeBetweenShotsTimer.start()
