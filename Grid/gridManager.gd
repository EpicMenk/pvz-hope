extends Resource
class_name gridManager

#-------Variables--------#
#first number is row second is column
@export var boardSize : Vector2 # x value represents width and y for height
@export var grid_Row_Column_size : Vector2i = Vector2(20,20)



var grid_size: Vector2:
	get:
		return Vector2(boardSize.x / grid_Row_Column_size.x,boardSize.y / grid_Row_Column_size.y)


var center_Of_Grid : Vector2 :
	get:
		return grid_size/ 2

var laneCount: int:
	get:
		return grid_Row_Column_size.y

var columnCount: int:
	get:
		return grid_Row_Column_size.x

var gridOccupant : Dictionary [Vector2i , Variant] = {}

#-------Functions--------#
##get the position normally of a grid
func get_Position(grid_Coord : Vector2i) -> Vector2 :
	return Vector2(grid_Coord) * grid_size + center_Of_Grid

##get the coordinate of grid in atlast coord ex: (1,1)
func get_Coordinate(grid_Position : Vector2) -> Vector2i:
	return (grid_Position / grid_size).floor()

#------------------------------------------------------------------------------#
func is_On_Lawn(grid_coordinate : Vector2i) -> bool:
	var outX = grid_coordinate.x >= 0 and grid_coordinate.x < grid_Row_Column_size.x
	var outY = grid_coordinate.y >= 0 and grid_coordinate.y < grid_Row_Column_size.y
	return outX and outY

#------------------------------------------------------------------------------#
func clamp_Grid(grid_position: Vector2i) -> Vector2i:
	var out := grid_position
	out.x = clamp(out.x, 0, grid_Row_Column_size.x - 1.0)
	out.y = clamp(out.y, 0, grid_Row_Column_size.y - 1.0)
	return out

#------------------------------------------------------------------------------#
#save a grid as a numerical value 
func as_index(grid: Vector2i) -> int:
	return int(grid.x + grid_Row_Column_size.x * grid.y)

#------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#
