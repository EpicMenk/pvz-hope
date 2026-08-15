extends Label

@export var baker : bakeRig 

func _ready() -> void:
	baker.bakingCompleted.connect(func(): text = "Baking completed")
	
