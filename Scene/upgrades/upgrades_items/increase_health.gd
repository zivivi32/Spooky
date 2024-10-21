extends UpgradeResource

@export var increase_health_amount: int = 25

func apply_upgrade(player: Player):
	player.increase_health(increase_health_amount)
