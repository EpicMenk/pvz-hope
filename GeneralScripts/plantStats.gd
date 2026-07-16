extends Resource
class_name plantStats

@export var plantType : PLANT_TYPE
@export var plantFamily : PLANT_FAMILY
@export var displayName : String
@export var maxHP : int
@export var internalID : int
@export var cooldown : float
@export var initialCooldown : float
@export var sunCost : int



enum PLANT_TYPE {
	Attacker,
	Defender,
	SunProducer
}

enum PLANT_FAMILY {
	AppeaseMint,
	EnlightMint
}
