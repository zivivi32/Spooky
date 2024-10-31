extends Area3D

class_name Health_System

@export var max_health: int = 100
@export var health_bar: HealthBar
@export var sfx_hurt: Array[AudioStream]
@export var is_player: bool = false
@export var damange_number_origin: Marker3D

var health: int : 
	set(new_health):
		health = new_health
		if health <= 0: 
			health = 0
			is_alive = false
		if health > max_health:
			health = max_health
		if health_bar:
			health_bar._set_health(health)
			
		health_changed.emit(health)
	get: 
		return health
		
var is_alive: bool :
	set(value): 
		is_alive = value
		if !value: 
			death.emit()
	get:
		return is_alive

var can_hurt: bool = true

signal health_changed(changed_health)
signal death

func _ready() -> void:
	if health_bar:
		health_bar.init_health(max_health)
	health = max_health

func immune(time): 
	can_hurt = false
	await get_tree().create_timer(time).timeout
	can_hurt = true

func damage(amount):
	if can_hurt:
		if is_player:
			Events.emit_signal("fx_screen_shake", 0.1, 0.5)
			Events.emit_signal("fx_chromatic_aberration", 0.05, 10)
			if sfx_hurt:
				for sfx in sfx_hurt:
					AudioManager.play_sound(sfx)
		if damange_number_origin:
			DamageNumbers.display_number(amount, damange_number_origin.global_position)
		health -= amount
