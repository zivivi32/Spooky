extends Node
class_name Special_Abilities

@export_subgroup("Ability configurations")
@export var weapon: Weapon_Resource
@export var duration_timer: Timer
@export var cool_down_timer: Timer
@export var player: Player

var can_use: bool = true

func _ready() -> void:
	duration_timer.connect("timeout", start_cooldown)
	cool_down_timer.connect("timeout", cool_down_off)

func launch_ability(): 
	if can_use:
		duration_timer.start(weapon.duration)
		player.call_abilities(weapon.bullet)
		can_use = false

func start_cooldown(): 
	cool_down_timer.start(weapon.cooldown)
	player.set_default_bullet()

func cool_down_off(): 
	can_use = true
