extends Resource
class_name EnemyTypeData
@export var enemy_scene: PackedScene
@export var count: int = 1

func to_dictionary() -> Dictionary:
	return {
		"scene": enemy_scene,
		"count": count
	}
