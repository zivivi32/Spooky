# Special_Abilities Class
extends Node
class_name Special_Abilities
@export_subgroup("Ability configurations")
@export var player: Player
@export var duration_timer: Timer
@export var cool_down_timer: Timer
@export var icon_image: Texture
@export var is_available: bool = true
@export var max_ammo: int = 20  # Max ammo for the ability
@export var initial_ammo: int = 2  # Initial ammo when ability is added

var current_ammo: int = 2
var can_use: bool = true

signal ability_used
signal ability_ready
signal on_cool_down
signal ammo_depleted

func _ready() -> void:
	can_use = is_available
	current_ammo = initial_ammo
	
	duration_timer.connect("timeout", start_cooldown)
	cool_down_timer.connect("timeout", cool_down_off)
	
func process_ability(): 
	pass

func launch_ability(): 
	if can_use and current_ammo > 0:
		can_use = false
		current_ammo -= 1
		ability_used.emit()
		
		process_ability()
		# Check if ammo is depleted
		if current_ammo <= 0:
			ammo_depleted.emit()

			
func process_cooldown():
	pass
	
func start_cooldown(): 
	process_cooldown()

func cool_down_off(): 
	can_use = true
	ability_ready.emit()

func add_ammo(amount: int = 1):
	# Add ammo, but don't exceed max ammo
	current_ammo = min(current_ammo + amount, max_ammo)

func get_current_ammo(): 
	return current_ammo
