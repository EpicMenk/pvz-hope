extends Resource
class_name burstSequencer

@export_range(1, 20) var repeatCount := 1
@export var repeatDelay := 0.0

func fire(onShot: Callable) -> void:
	for i in repeatCount:
		if not is_instance_valid(onShot.get_object()):
			return
		await onShot.call()
		
		
		if i != repeatCount - 1:
			await (Engine.get_main_loop() as SceneTree).create_timer(repeatDelay).timeout
