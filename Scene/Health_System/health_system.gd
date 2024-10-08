extends Area3D

class_name Health_System

@export var max_health: int = 100
@export var health_bar: HealthBar
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

signal health_changed(changed_health)
signal death

func _ready() -> void:
	if health_bar:
		health_bar.init_health(max_health)
	health = max_health

func damage(amount):
	health -= amount
