extends Ability

class_name Dash_Ability

@export_subgroup("Dash Abilities")
@export var dash_speed: float = 30
@export var player: Player

var player_movement_speed: float

func process_ability() -> void:
	player_movement_speed = player.movement_speed
	player.health.can_hurt = false
	player.set_collision_mask_value(4,false)
	player.movement_speed = dash_speed


func process_cooldown(): 
	player.health.can_hurt = true
	player.set_collision_mask_value(4,true)
	player.movement_speed = player_movement_speed
	
