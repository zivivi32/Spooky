extends Area3D

class_name CoinMagnet

@export var magnet_enabled: bool = true
@export var collision_shape: CollisionShape3D
@export var player: Player

# Called when the magnet area detects a coin entering
func _on_magnet_area_body_entered(body):
	if body is Coin and magnet_enabled:
		body.start_moving_towards_player(player)

# Called when a coin exits the magnet area
func _on_magnet_area_body_exited(body):
	if body is Coin:
		body.stop_moving()

func increase_radius(amount: float): 
	collision_shape.shape.radius += amount
