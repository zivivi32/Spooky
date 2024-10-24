extends CanvasLayer

class_name ShopUI

var player: Player
@export var upgrade_pool: Array[UpgradeResource]
var chosen_upgrades: Array[UpgradeResource]

@export var items_buttons: Array[item_button]

@export var num_coin: Label
#var test_coins: int = 100
signal shopped

func _ready() -> void:
	connecting_buttons()
	player = get_tree().get_first_node_in_group("player")

func show_upgrades(): 
	choose_random_upgrades()
	

func connecting_buttons():
	for button in items_buttons:
		button.connect("button_pressed", _on_Button_pressed)
		#button.reset_button()
# Function to pick 3 random upgrades
func choose_random_upgrades():
	chosen_upgrades.clear()
	upgrade_pool.shuffle()
	num_coin.text = "Candies: " + str(player.coins)
	var i: int = 0
	for button in items_buttons:
		var upgrade_instance :UpgradeResource = upgrade_pool[i]
		chosen_upgrades.append(upgrade_instance)
		button.set_text(upgrade_instance.upgrade_name, str(upgrade_instance.cost))
		button.set_button_meta("upgrade", upgrade_instance)
		#button.refresh_button()
		i+=1

# Function called when a button is clicked to purchase an upgrade
func _on_Button_pressed(button):
	var upgrade_instance = button.get_meta("upgrade") as UpgradeResource
	if player.coins >= upgrade_instance.cost:
		player.coins -= upgrade_instance.cost
		upgrade_instance.apply_upgrade(player)
		#button.disabled = true  # Disable the button after purchase
	shopped.emit()


func _on_button_pressed() -> void:
	shopped.emit()
