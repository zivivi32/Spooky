# Ability_Manager.gd
extends Node
class_name Ability_Manager

var abilities: Array[Node]
var ability_scenes: Array[PackedScene]
@export var ability_ui: Array[Ability_UI]
@export var player: Player

func _ready() -> void:
	# Initialize arrays with null values to maintain slot positions
	abilities.resize(ability_ui.size())
	ability_scenes.resize(ability_ui.size())
	for i in range(abilities.size()):
		abilities[i] = null
		ability_scenes[i] = null
	
	# Initialize all UI slots to hidden
	for ui in ability_ui:
		ui.clear_ability()

func refresh_ability() -> void:
	# Update UI for each slot
	for i in range(ability_ui.size()):
		var ability = abilities[i]
		var ui = ability_ui[i]
		
		if ability != null:
			ability.player = player
			ui.ability = ability
			ui.image = ability.icon_image
			
			# Update ammo display if ability has ammo
			if ability.has_method("get_current_ammo"):
				ui.ammo_label.text = str(ability.get_current_ammo())
		else:
			ui.clear_ability()
		
		ui.refresh()

func launch_ability(index: int) -> void:
	if index >= 0 and index < abilities.size() and abilities[index] != null:
		abilities[index].launch_ability()

func empty_abilities() -> void:
	# Clear all UI first
	for ui in ability_ui:
		ui.clear_ability()
	
	# Clean up existing abilities
	for i in range(abilities.size()):
		if abilities[i] != null:
			abilities[i].queue_free()
			abilities[i] = null
			ability_scenes[i] = null

func add_ability(ability_scene: PackedScene) -> void:
	if not ability_scene:
		push_warning("Attempted to add null ability scene")
		return
	
	# Check if we already have this type of ability
	var existing_ability = find_existing_ability(ability_scene)
	
	if existing_ability:
		# Add ammo to existing ability if it supports ammo system
		if existing_ability.has_method("add_ammo"):
			var temp_instance = ability_scene.instantiate()
			var initial_ammo = temp_instance.initial_ammo if "initial_ammo" in temp_instance else 0
			existing_ability.add_ammo(initial_ammo)
			temp_instance.queue_free()
	else:
		# Find first empty slot
		var empty_slot = -1
		for i in range(abilities.size()):
			if abilities[i] == null:
				empty_slot = i
				break
		
		if empty_slot == -1:
			push_warning("No empty slots available for new ability")
			return
		
		# Create new ability instance
		var new_ability = ability_scene.instantiate()
		if not new_ability:
			push_warning("Failed to instantiate ability scene")
			return
		
		# Add as child and setup
		add_child(new_ability)
		new_ability.player = player
		
		# Connect ammo depleted signal if available
		if new_ability.has_signal("ammo_depleted"):
			new_ability.ammo_depleted.connect(func(): remove_ability.bind(new_ability).call())
		
		# Add to tracking arrays at the specific slot
		abilities[empty_slot] = new_ability
		ability_scenes[empty_slot] = ability_scene
	
	refresh_ability()

func remove_ability(ability: Node) -> void:
	if not is_instance_valid(ability):
		return
	
	# Find the slot containing this ability
	var slot = abilities.find(ability)
	if slot != -1:
		# Clear just this slot
		ability_ui[slot].clear_ability()
		abilities[slot] = null
		ability_scenes[slot] = null
		
		ability.queue_free()
		refresh_ability()

func find_existing_ability(ability_scene: PackedScene) -> Node:
	var scene_path = ability_scene.resource_path
	
	for ability in abilities:
		if is_instance_valid(ability) and ability.scene_file_path == scene_path:
			return ability
	
	return null
