extends MarginContainer
class_name item_button
@export var button_item: Button

@export var upgrade_name: Label
@export var upgrade_cost: Label

signal button_pressed(button)

func set_text(upgrade_name_text: String, upgrade_cost_text: String):
	upgrade_name.text = upgrade_name_text
	upgrade_cost.text = upgrade_cost_text

func set_button_meta(meta_name, meta_value):
	button_item.set_meta(meta_name, meta_value)
	
func pressed():
	button_pressed.emit(button_item)
