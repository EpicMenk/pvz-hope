extends plantStats
class_name plantAttackerStats

@export var damage : int
@export var timeBetweenAttack : float
@export var attackRange : int # calculated by tiles used by melee attacks
@export var projectileScene : PackedScene
@export var projectileSpeed : float # in pixels per frame
@export var damageType : damageInfo.damageTypeEnums
