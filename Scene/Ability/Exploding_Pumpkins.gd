extends Special_Abilities

@export var weapon: Weapon_Resource
@export var player: Player

func process_ability(): 
	duration_timer.start(weapon.duration)
	player.call_abilities(weapon.bullet)

func process_cooldown():
	cool_down_timer.start(weapon.cooldown)
	player.set_default_bullet()
