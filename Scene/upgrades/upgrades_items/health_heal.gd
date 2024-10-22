extends UpgradeResource

@export var heal_percentage: float = 0.25

func apply_upgrade(player: Player):
	var heal_amount = player.health.max_health * heal_percentage
	player.heal_player(int(heal_amount))
