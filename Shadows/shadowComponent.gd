extends Sprite2D
class_name shadowComponent

enum shadowSizesEnums {small , medium}

@export var shadowSize : shadowSizesEnums
@export var shadowOffset : float = 60

@export_group("Setup")
@export var smallShadow : Texture2D
@export var mediumShadow : Texture2D

var parent : boardEntity 
var _boardManager : boardManager
var lane : int = -1

func _ready() -> void:
	top_level = true
	parent = get_parent()
	z_index = parent.z_index - 1
	updateTexture()

func setLane(_lane : int):
	lane = _lane
	updatePosition()

func _process(delta: float) -> void:
	if parent == null or lane == -1 or _boardManager == null:
		return
	updatePosition()


func updatePosition():
	global_position = Vector2(
		parent.global_position.x , 
		_boardManager._gridManager.getLaneY(lane) + shadowOffset
	)

func updateTexture():
	match shadowSize:
		shadowSizesEnums.small:
			texture = smallShadow
		shadowSizesEnums.medium:
			texture = mediumShadow
