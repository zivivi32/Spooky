extends Area3D
@export var health: Health_System

signal destroyed

func _ready() -> void:
	health.connect("death", death)

func death() -> void:
	destroyed.emit()
	queue_free()
