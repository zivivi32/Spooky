extends Node
class_name Special_Abilities

@export_subgroup("Ability configurations")
@export var player: Player
@export var duration_timer: Timer
@export var cool_down_timer: Timer
@export var icon_image: Texture
@export var is_available: bool = true
@export var ammo: int = 2

var can_use: bool = true


signal ability_used
signal ability_ready
signal on_cool_down

func _ready() -> void:
	can_use = is_available
	
	duration_timer.connect("timeout", start_cooldown)
	cool_down_timer.connect("timeout", cool_down_off)
	

func process_ability(): 
	pass

func launch_ability(): 
	if can_use:
		can_use = false
		ability_used.emit()
		process_ability()
		
func process_cooldown():
	pass
	
func start_cooldown(): 
	process_cooldown()

func cool_down_off(): 
	can_use = true
	ability_ready.emit()
