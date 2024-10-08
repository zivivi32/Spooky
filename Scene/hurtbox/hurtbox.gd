extends Area3D
@export var damage: int = 50
@export var die_after_hurting: bool = true

func _on_body_entered(body):
	if body is Health_System:
		body.damage(damage)
		if die_after_hurting:
			queue_free()
