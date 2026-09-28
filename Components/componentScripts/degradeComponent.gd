extends entityComponent2D

signal degradeStateChanged(event : StringName)

@export var hpC : hpComponent
@export var targetSprite : Sprite2D
@export var degradeSprites : Dictionary[StringName, Texture2D]

func _ready() -> void:
	if hpComponent == null:
		push_error("degradeComponent: hpComponent not assigned.")
		return

	hpC.eventTriggered.connect(onHpEventTriggered)


func onHpEventTriggered(event : StringName) -> void:
	if targetSprite != null and degradeSprites.has(event):
		targetSprite.texture = degradeSprites[event]

	degradeStateChanged.emit(event)
