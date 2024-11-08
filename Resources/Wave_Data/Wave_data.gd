extends Resource
class_name WaveData

# Wave Properties
@export var enemy_types: Array[EnemyTypeData]
@export var formation_width: float = 15.0
@export var approach_speed: float = 5.0

# Movement Pattern Selection
enum MovementPattern { STRAIGHT, CIRCLE, V_FORMATION, RANDOM_SIDE }
@export_enum("STRAIGHT", "CIRCLE", "V_FORMATION", "RANDOM_SIDE" ) var movement_pattern: int = 0

# Pattern-specific Properties
@export_group("Circle Movement Properties")
@export var circle_radius: float = 10.0

@export_group("V-Formation Properties")
@export var wing_angle: float = 45.0
@export var wing_length: float = 10.0

@export_group("Random Side Movement Properties")
@export var x_bound_min: float = -20.0
@export var x_bound_max: float = 20.0
@export var movement_cycles: int = 3
@export var pause_duration: float = 2.0

func get_movement_data() -> Dictionary:
	match movement_pattern:
		MovementPattern.CIRCLE:
			return {
				"radius": circle_radius
			}
		MovementPattern.V_FORMATION:
			return {
				"wing_angle": wing_angle,
				"wing_length": wing_length
			}
		MovementPattern.RANDOM_SIDE:
			return {
				"x_bounds": [x_bound_min, x_bound_max],
				"cycles": movement_cycles,
				"pause_duration": pause_duration
			}
	return {}

func get_pattern_name() -> int:
	return movement_pattern

func to_wave_data() -> Dictionary:
	var types: Array[Dictionary] = []
	for enemy_type in enemy_types:
		types.append(enemy_type.to_dictionary())
	
	return {
		"enemy_types": types,
		"formation_width": formation_width,
		"approach_speed": approach_speed,
		"movement_pattern": get_pattern_name(),
		"movement_data": get_movement_data()
	}
