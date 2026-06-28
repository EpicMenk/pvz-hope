extends Node2D
class_name debugController

@onready var _gridManager : gridManager = preload("res://Resources/gridManager.tres")
@onready var debugFont : Font = preload("res://Debug/Roboto_Condensed-Black.ttf")
@onready var _boardManager: boardManager = %BoardManager


@export var drawGrid := false
@export var drawCoordinates := false
@export var drawOccupiedGrids := false
@export var drawLaneNumbers := false
@export var drawLaneLines := false


func _draw() -> void:
	if drawGrid:
		_drawGrid()
	if drawCoordinates:
		_drawGridCoordinates()
	if drawOccupiedGrids:
		_drawOccupiedGrids()
	if drawLaneNumbers:
		_drawLaneNumbers()
	if drawLaneLines:
		_drawLaneLines()

func refresh():
	queue_redraw()

func _drawGrid():
	var cell_size = _gridManager.grid_size

	for y in _gridManager.grid_Row_Column_size.y:
		for x in _gridManager.grid_Row_Column_size.x:
			draw_rect(
				Rect2(
					Vector2(x, y) * cell_size,
					cell_size
				),
				Color(0, 1, 0, 0.2),
				false
			)

func _drawGridCoordinates():
	for y in _gridManager.grid_Row_Column_size.y:
		for x in _gridManager.grid_Row_Column_size.x:

			var cell := Vector2i(x, y)

			_drawCenteredText(
				_gridManager.get_Position(cell),
				str(cell)
			)

func _drawCenteredText(_position: Vector2, text: String):
	var size := debugFont.get_string_size(text)

	draw_string(
		debugFont,
		_position - Vector2(size.x / 2.0, -size.y / 2.0),
		text
	)

func _drawOccupiedGrids():
	for cell: Vector2i in _boardManager.gridOccupants.keys():

		var center := _gridManager.get_Position(cell)

		draw_rect(
			Rect2(
				Vector2(cell) * _gridManager.grid_size,
				_gridManager.grid_size
			),
			Color(0.2, 0.8, 0.2, 0.4),
			true
		)

		_drawCenteredText(center, "X")

func _drawLaneNumbers():
	for lane in _gridManager.grid_Row_Column_size.y:

		var cell := Vector2i(0, lane)

		# Top-left corner of the first cell in this lane
		var cell_origin := Vector2(cell) * _gridManager.grid_size

		# Offset a little inward from the top-right corner
		var text := "Lane %d" % lane
		var text_size := debugFont.get_string_size(text)

		var draw_pos := Vector2(
			cell_origin.x + _gridManager.grid_size.x - text_size.x - 4,
			cell_origin.y + text_size.y + 4
		)

		draw_string(debugFont, draw_pos, text)

func _drawLaneLines():
	var board_width := _gridManager.boardSize.x

	for lane in _gridManager.grid_Row_Column_size.y:

		var y := (lane * _gridManager.grid_size.y) + (_gridManager.grid_size.y / 2.0)

		draw_line(
			Vector2(0, y),
			Vector2(board_width, y),
			Color.CYAN,
			2.0
		)
