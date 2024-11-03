extends CanvasLayer

@export var item_icon_rect: TextureRect
@export var description_label: RichTextLabel
@export var cost_label: Label #Cost of the upgrade
@export var coins_label: Label ## Money the player has
@export var upgrade_pool: Array[UpgradeResource]
@export var purchase_button: Button
@export var default_icon: Texture  # Optional default icon

var current_upgrade_index: int = 0
var player: Player  # Reference to the player

func _ready():
	# Get player reference using group method
	player = get_tree().get_first_node_in_group("player")
	
	call_deferred("init_shop_ui")


func init_shop_ui():
	# Initial setup when the shop opens
	if upgrade_pool.size() > 0:
		update_upgrade_display(current_upgrade_index)
	else:
		print("No upgrades available in the pool!")
	coins_label.text = "Coins: " + str(player.coins)
	# Update player's current coins
	update_coins_display()

func update_upgrade_display(index: int):
	# Ensure index is within bounds and loops
	current_upgrade_index = index % upgrade_pool.size()
	if current_upgrade_index < 0:
		current_upgrade_index += upgrade_pool.size()
	
	var current_upgrade = upgrade_pool[current_upgrade_index]
	
	# Update description
	description_label.text = current_upgrade.description
	
	# Update cost and check affordability
	cost_label.text = "Cost: " + str(current_upgrade.cost)
	check_upgrade_affordability(current_upgrade)
	
	# Update icon
	# Check if the upgrade has an export var for icon, otherwise use default
	if current_upgrade.get("icon") != null:
		item_icon_rect.texture = current_upgrade.icon
	elif default_icon != null:
		item_icon_rect.texture = default_icon
	else:
		# Clear the icon if no default is provided
		item_icon_rect.texture = null

func check_upgrade_affordability(current_upgrade):
	# Check if player can afford the upgrade
	if player.coins >= current_upgrade.cost:
		# Enough coins
		cost_label.add_theme_color_override("font_color", Color.WHITE)
		purchase_button.disabled = false
	else:
		# Not enough coins
		cost_label.add_theme_color_override("font_color", Color.RED)
		purchase_button.disabled = true

func update_coins_display():
	# Explicitly update coins label with player's current coins
	coins_label.text = "Coins: " + str(player.coins)
	
	# Recheck affordability after coins change
	if upgrade_pool.size() > 0:
		check_upgrade_affordability(upgrade_pool[current_upgrade_index])

func on_left_pressed() -> void:
	# Navigate to previous upgrade (with looping)
	current_upgrade_index -= 1
	update_upgrade_display(current_upgrade_index)

func on_right_pressed() -> void:
	# Navigate to next upgrade (with looping)
	current_upgrade_index += 1
	update_upgrade_display(current_upgrade_index)

func on_button_pressed() -> void:
	# BUY FUNCTION
	if current_upgrade_index < 0 or current_upgrade_index >= upgrade_pool.size():
		print("Invalid upgrade selection!")
		return
	
	var current_upgrade = upgrade_pool[current_upgrade_index]
	
	# Check if player has enough coins
	if player.coins >= current_upgrade.cost:
		# Apply the upgrade
		current_upgrade.apply_upgrade(player)
		
		# Deduct coins
		player.coins -= current_upgrade.cost
		
		# Update coins display AFTER deducting coins
		update_coins_display()
		
		# Optional: Provide feedback
		print("Upgrade purchased: " + current_upgrade.upgrade_name)
	else:
		# Optional: Show error message or play sound
		print("Not enough coins to purchase this upgrade!")


func _on_exit_pressed() -> void:
	hide()
	Events.shop_done.emit()
	
