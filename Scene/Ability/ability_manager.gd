extends Node
class_name Ability_Manager

var abilities: Array[Node]
@export var ability_ui: Array[Ability_UI]
@export var player: Player

#
#func _ready() -> void:
	#if abilities.size() > 0:
		#refresh_ability()

func refresh_ability():
	for ability in abilities:
		ability.player = player
	
	if abilities.size() > 0:
		var i : int = 0
		for ability in abilities:
			ability_ui[i].ability = ability
			ability_ui[i].image = ability.icon_image
			i += 1

	for ui_item in ability_ui: 
		ui_item.call_deferred("refresh")

func launch_ability(index: int):
	if index < abilities.size():
		if abilities[index]:
			abilities[index].launch_ability()

func empty_abilities(): 
	abilities.clear()

func add_ability(ability_to_add): 
	abilities.append(ability_to_add)
	refresh_ability()
	
func remove_ability(ability_to_remove):
	abilities.erase(ability_to_remove)
	refresh_ability()
