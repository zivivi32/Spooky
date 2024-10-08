extends LimboState
#
#var weapon: Weapon
#signal weapon_fire
#var movement_velocity: Vector3
#
#@export_subgroup("State Properties")
#@export var raycast: RayCast3D
#@export var container: Node3D
#@export var camera: Camera3D
#@export var weapon_camera: Camera3D
#@export var blaster_cooldown: Timer
#
#@export_subgroup("VFX")
#@export var impact_particles: PackedScene
#@export var vfx_marker: Marker3D
#@export var muzzle_light_flash: OmniLight3D
#
#@export_subgroup("SFX")
#@export var sfx: AudioStreamPlayer
#
#func _enter() -> void:
	#weapon = agent.weapon
	##attack()
	#
#func _update(_delta: float) -> void:
	#attack()
#
#func _input(event: InputEvent) -> void:
	#if event.is_action_released("shoot"):
		#get_root().dispatch(EVENT_FINISHED)
#
#func attack():
	#if weapon.current_magazine > 0:
		#if !blaster_cooldown.is_stopped(): return # Cooldown for shooting
		#Audio.play(weapon.sound_shoot)
		#
		#container.position.z += 0.25 # Knockback of weapon visual
		#camera.rotation.x += 0.025 # Knockback of camera
		#var knockback : Vector3 = Vector3(0, 0, weapon.knockback) 
		#agent.velocity += agent.transform.basis * knockback # Knockback
		#
		## Set muzzle flash position, play animation
		#weapon_fire.emit()
		#vfx_marker.position = container.position - weapon.muzzle_position
		#
		#var flash = weapon.muzzle_flash.instantiate()
		#flash.position = vfx_marker.position#container.position - weapon.muzzle_position
		#muzzle_light_flash.visible = true
		#weapon_camera.add_child(flash)
#
		#var bullet = weapon.bullet.instantiate()
		#bullet.position = raycast.position#vfx_marker.position
		#weapon_camera.add_child(bullet)
		#
		#blaster_cooldown.start(weapon.cooldown)
		#
		### Update Ammo count
		#weapon.current_magazine -= weapon.shot_count
		#if weapon.current_magazine < 0:
			#weapon.current_magazine = 0
		#agent.update_ammo.emit(weapon.current_magazine)
		#
		## Shoot the weapon, amount based on shot count
		#for n in weapon.shot_count:
			#
			#raycast.target_position.x = randf_range(-weapon.spread, weapon.spread)
			#raycast.target_position.y = randf_range(-weapon.spread, weapon.spread)
			#
			#raycast.force_raycast_update()
			#
			#if !raycast.is_colliding(): continue # Don't create impact when raycast didn't hit
			#
			#var collider = raycast.get_collider()
			#
			## Hitting an enemy
			#
			#if collider.has_method("damage"):
				#collider.damage(weapon.damage)
			#
			## Creating an impact animation
			#var impact_instance = impact_particles.instantiate()
			#
			#get_tree().root.add_child(impact_instance)
			#
			#impact_instance.position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
#
		#await flash.emission_dead
		#muzzle_light_flash.visible = false	
	#else: 
		#if weapon.sound_empty:
			#if !sfx.playing:
				#sfx.play()
			#
			#
