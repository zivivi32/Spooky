extends Node

class_name UINavigationSetup

# Export variable for manually setting default focus button
@export var default_focus_button: BaseButton
@export var parent_canvas: CanvasItem
# If true, automatically sets focus to top-left button
@export var auto_focus_first: bool = true

func _ready():
	setup_navigation()
	set_default_focus()
	
	call_deferred("connect_canvas")
	
func connect_canvas():
	parent_canvas.connect("visibility_changed", on_parent_canvas_show)

func on_parent_canvas_show():
	set_default_focus()

func setup_navigation():
	# Get all children buttons recursively
	var buttons = get_all_buttons(self)
	if buttons.size() <= 1:
		return
	
	# Sort buttons by their position (left to right, top to bottom)
	buttons.sort_custom(sort_by_position)
	
	# Setup navigation
	for i in range(buttons.size()):
		var current_button = buttons[i]
		var next_button = buttons[(i + 1) % buttons.size()]  # Wrap around to first button
		var prev_button = buttons[(i - 1 + buttons.size()) % buttons.size()]
		
		# Find buttons above and below based on position
		var above_button = find_closest_button_in_direction(current_button, buttons, Vector2.UP)
		var below_button = find_closest_button_in_direction(current_button, buttons, Vector2.DOWN)
		
		# Set focus neighbors
		current_button.focus_neighbor_left = prev_button.get_path()
		current_button.focus_neighbor_right = next_button.get_path()
		if above_button:
			current_button.focus_neighbor_top = above_button.get_path()
		if below_button:
			current_button.focus_neighbor_bottom = below_button.get_path()

func set_default_focus() -> void:
	if default_focus_button:
		# Use manually specified button
		default_focus_button.grab_focus()
	elif auto_focus_first:
		# Get all buttons and focus the first one (top-left)
		var buttons = get_all_buttons(self)
		if buttons.size() > 0:
			buttons.sort_custom(sort_by_position)
			buttons[0].grab_focus()

func get_all_buttons(node: Node) -> Array:
	var buttons = []
	
	if node is BaseButton:
		buttons.append(node)
	
	for child in node.get_children():
		buttons.append_array(get_all_buttons(child))
	
	return buttons

func sort_by_position(a: Control, b: Control) -> bool:
	# First sort by Y position (rows)
	if abs(a.global_position.y - b.global_position.y) > 10:  # Small threshold for alignment
		return a.global_position.y < b.global_position.y
	# If Y positions are similar, sort by X position (columns)
	return a.global_position.x < b.global_position.x

func find_closest_button_in_direction(current: Control, buttons: Array, direction: Vector2) -> Control:
	var closest_button = null
	var closest_distance = INF
	
	for button in buttons:
		if button == current:
			continue
		
		var to_button = button.global_position - current.global_position
		# Check if button is roughly in the desired direction
		if to_button.normalized().dot(direction) > 0.7:  # Threshold for directional alignment
			var distance = to_button.length()
			if distance < closest_distance:
				closest_distance = distance
				closest_button = button
	
	return closest_button

# Public function to manually set focus to a specific button
func set_focus_to_button(button: BaseButton) -> void:
	if button and is_instance_valid(button):
		button.grab_focus()
