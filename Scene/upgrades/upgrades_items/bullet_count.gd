extends UpgradeResource
@export var bullet_count_increase: int = 2

func apply_upgrade(player: Player):
	player.gun.bullet_count += bullet_count_increase
