extends LimboState
#
#@export_subgroup("State Properties")
#var weapon_index: int
#var weapon: Weapon
#var weapon_model
#var weapons: Array[Weapon]
#var tween: Tween
#var container_offset: Vector3
#@export var container: Node3D
#
#func _enter() -> void:
	#weapon_index = agent.weapon_index
	#weapon = agent.weapon
	#weapons = agent.weapons
	#container_offset = agent.container_offset
#
	#action_weapon_toggle()
	#get_root().dispatch(EVENT_FINISHED)
#
## Toggle between available weapons (listed in 'weapons')
#func action_weapon_toggle():
#
	#weapon_index = wrap(weapon_index + 1, 0, weapons.size())
	#initiate_change_weapon(weapon_index)
	#
	#Audio.play("sounds/weapon_change.ogg")
	#
## Initiates the weapon changing animation (tween)
#func initiate_change_weapon(index):
	#
	#weapon_index = index
	#
	#tween = get_tree().create_tween()
	#tween.set_ease(Tween.EASE_OUT_IN)
	#tween.tween_property(container, "position", container_offset - Vector3(0, 1, 0), 0.1)
	#tween.tween_callback(change_weapon) # Changes the model
#
## Switches the weapon model (off-screen)
#func change_weapon():
	#
	#weapon = weapons[weapon_index]
#
	## Step 1. Remove previous weapon model(s) from container
	#
	#for n in container.get_children():
		#container.remove_child(n)
	#
	## Step 2. Place new weapon model in container
	#
	#weapon_model = weapon.model.instantiate()
	#container.add_child(weapon_model)
	#
	#weapon_model.position = weapon.position
	#weapon_model.rotation_degrees = weapon.rotation
	#
	#
	## Step 3. Set model to only render on layer 2 (the weapon camera)
	#
	#for child in weapon_model.find_children("*", "MeshInstance3D"):
		#child.layers = 2
		#
	## Set weapon data
	#agent.weapon = weapon
	#agent.update_ammo.emit(weapon.current_magazine)
	#agent.weapon_index = weapon_index
	#agent.raycast.target_position = Vector3(0, 0, -1) * weapon.max_distance
	#agent.crosshair.texture = weapon.crosshair
