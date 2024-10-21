extends UpgradeResource

@export var healing_amount: int = 25

func apply_upgrade(player: Player):
	player.heal_player(healing_amount)
