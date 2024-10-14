extends Node
class_name Ability
@export_subgroup("Abilities Configurations")
@export var duration_timer: Timer
@export var duration: float = 0.2
@export var ability_cooldown_timer: Timer
@export var ability_cooldown: float = 15

var can_use_ability: bool = true

func _ready() -> void:
	
	duration_timer.one_shot = true
	ability_cooldown_timer.one_shot = true
	
	duration_timer.connect("timeout", cool_down_start)
	ability_cooldown_timer.connect("timeout", cooldown_finished)

func launch_ability(): 
	if can_use_ability:
		process_ability()
		duration_timer.start(duration)
		can_use_ability = false

func process_ability() -> void:
	pass

func process_cooldown() -> void:
	pass

func cool_down_start(): 
	ability_cooldown_timer.start(ability_cooldown)
	process_cooldown()

func cooldown_finished(): 
	can_use_ability = true
