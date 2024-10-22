extends UpgradeResource
@export var new_ability: PackedScene

func apply_upgrade(player: Player):
	player.add_ability(new_ability)
