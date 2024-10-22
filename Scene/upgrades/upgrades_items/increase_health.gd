extends UpgradeResource

@export var max_health_increase_percentage: float = 0.1

func apply_upgrade(player: Player):
	var health_increase = player.health.max_health * max_health_increase_percentage
	player.increase_health(int(health_increase))
