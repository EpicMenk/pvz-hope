extends Node

func spawnEntity(scene: PackedScene, bm: boardManager, container: Node, worldPosition: Vector2) -> boardEntity:
	var entity : boardEntity = scene.instantiate()
	entity.initializeManagers(bm)
	container.add_child(entity)
	entity.global_position = worldPosition
	return entity

func genericInstantiating(scene : PackedScene , worldPosition : Vector2 , container : Node) -> Node:
	var sceneToInstantiate := scene.instantiate()
	container.add_child(sceneToInstantiate)
	sceneToInstantiate.global_position = worldPosition
	return sceneToInstantiate
