extends Area3D


func _on_body_exited(body: Node3D) -> void:
	if body is Boss || body is Ghost_Boss:
		body.teleport(true)
