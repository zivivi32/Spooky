extends Node
class_name Special_Abilities

@export_subgroup("Ability configurations")
@export var duration_timer: Timer
@export var cool_down_timer: Timer

var can_use: bool = true

func _ready() -> void:
	duration_timer.connect("timeout", start_cooldown)
	cool_down_timer.connect("timeout", cool_down_off)

func process_ability(): 
	pass

func launch_ability(): 
	if can_use:
		can_use = false
		process_ability()
		
func process_cooldown():
	pass
	
func start_cooldown(): 
	process_cooldown()

func cool_down_off(): 
	can_use = true
