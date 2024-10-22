extends Special_Abilities

@export var weapon: Weapon_Resource


func process_ability(): 
	duration_timer.start(weapon.duration)
	player.change_gun_bullet(weapon.bullet)

func process_cooldown():
	cool_down_timer.start(weapon.cooldown)
	on_cool_down.emit()
	player.set_default_bullet()
