extends entityComponent2D
class_name straightShooterComponent

signal windupStarted(windupTime: float)
signal shotFired

@export var _projectileStats : projectileStats = projectileStats.new()
@export var burst : burstSequencer
@export var timeBetweenShots : float
@export var windupTime : float = 0.0   # portion of timeBetweenShots spent winding up before the shot fires; 0 = instant, old behavior , 0.1 if it's calculated by the entity
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
	timeBetweenShotsTimer.start()
	if windupTime > 0.0:
		windupStarted.emit(windupTime)
		await get_tree().create_timer(windupTime).timeout
		if not is_instance_valid(self):
			return
	burst.fire(fireSpawnPoints)

func fireSpawnPoints() -> void:
	for point in spawnPoints:
		spawnProjectile(point)
	shotFired.emit()

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
