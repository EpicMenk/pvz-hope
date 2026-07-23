extends Node2D
class_name debugHPOverlay

var enabled := false

@onready var _boardManager : boardManager = %BoardManager

func _ready():
	z_index = 4096   # Godot's max is 4096, effectively "always on top"

func toggle(on: bool):
	enabled = on
	queue_redraw()

func _process(_delta):
	if enabled:
		queue_redraw()   # only redraw when the overlay is actually on

func _draw():
	if not enabled:
		return

	# plants live in gridOccupants
	for occupant in _boardManager.gridOccupants.values():
		if occupant is Plant:
			_drawHP(occupant)
			_drawShield(occupant)

	# zombies live per-lane in zombieManager
	for lane in _boardManager._zombieManager.zombieInLanes:
		for zombie in lane.zombies:
			_drawHP(zombie)
			_drawShield(zombie)

func _drawHP(entity):
	var text := str(entity.hpC.currentHP) + "/" + str(entity.hpC.maxHP)
	var pos : Vector2 = entity.global_position + Vector2(0, -100) 
	draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
	

func _drawShield(entity):
	var text := str(entity.hpC.shield)
	var pos : Vector2 = entity.global_position + Vector2(0, -75)  
	draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
