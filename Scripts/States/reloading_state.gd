extends LimboState
#var weapon: Weapon
#@export var container: Node3D
#func _enter() -> void:
	#weapon = agent.weapon
	#agent.is_reloading = true
	##await get_tree().create_timer(weapon.reload_time).timeout
	#rotate_reload()
	#agent.is_reloading = false
	#get_root().dispatch(EVENT_FINISHED)
	#
#func reload() -> void:
	## Calculate how much ammo is needed to fill the magazine
	#var needed_ammo = weapon.magazine_size - weapon.current_magazine
#
	## Check if there's enough total ammo left to fill the magazine
	#if weapon.current_ammo >= needed_ammo:
		## Fill the magazine with required ammo
		#weapon.current_magazine += needed_ammo
		#weapon.current_ammo -= needed_ammo
	#else:
		## If we don't have enough ammo to fill the magazine, fill it with what we have left
		#weapon.current_magazine = weapon.current_ammo
		#weapon.current_ammo = 0
	#agent.update_ammo.emit(weapon.current_magazine)
	#agent.is_reloading = false
#
#func rotate_reload(): 
	#var tween = create_tween()
	#tween.tween_property(container, "rotation_degrees:x", container.rotation_degrees.x + 360, weapon.reload_time)
	#tween.tween_callback(reload)
