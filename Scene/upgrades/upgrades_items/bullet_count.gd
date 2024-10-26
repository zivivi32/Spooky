extends UpgradeResource
@export var bullet_count_increase: int = 1

func apply_upgrade(player: Player):
	player.gun.increase_bullet_count(bullet_count_increase)
