extends UpgradeResource

@export var radius: int = 2

func apply_upgrade(player: Player):
	player.increase_magnet_radius(radius)
