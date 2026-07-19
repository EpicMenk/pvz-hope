extends Resource
class_name zombieStats

@export var displayName : String
@export var hp : int
@export var shield : int
@export var speed : float
@export var weight : float # future proof used for things like knockback resistance
@export var point : float # future proof used for level editor to calculate difficulty of a wave
