extends UpgradeResource

@export var gun_damage_increase_percentage: float = 0.05

func apply_upgrade(player: Player):
	var damage_increase = player.gun.extra_damage * gun_damage_increase_percentage
	player.gun.extra_damage += damage_increase
