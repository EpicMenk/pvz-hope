extends Node

func spawnEntity(scene: PackedScene, bm: boardManager, container: Node, worldPosition: Vector2, grid : Vector2i = Vector2i(-1,-1)) -> boardEntity:
	var entity : boardEntity = scene.instantiate()
	entity.initializeManagers(bm)
	entity.global_position = worldPosition
	if not grid == Vector2i(-1,-1):
		entity.grid = grid
	container.add_child(entity)
	return entity

func genericInstantiating(scene : PackedScene , worldPosition : Vector2 , container : Node) -> Node:
	var sceneToInstantiate := scene.instantiate()
	container.add_child(sceneToInstantiate)
	sceneToInstantiate.global_position = worldPosition
	return sceneToInstantiate
