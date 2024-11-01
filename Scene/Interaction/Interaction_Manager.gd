extends Node3D

@onready var player = get_tree().get_first_node_in_group("Player")
#@export var label : Label3D

#@export var controller_texture : Texture
#@export var keyboard_texture : Texture

#@export var texture_bg : TextureRect
#@export var key_label : Label
@export var action_label : Label
@export var sprite_interaction : Sprite3D
var base_text = "[F] to "

var active_areas = []

var can_interact: bool = true
var is_dialogue: bool = false


var is_controller : bool = false
var device_use : String = "keyboard"

func _ready():
	#get_proper_input_key()
	#InputHelper.device_changed.connect(_on_input_device_changed)
	pass

func register_area(area: InteractionArea):
	active_areas.push_back(area)
	
func unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1 : 
		active_areas.remove_at(index)

func _process(delta):
	#get_proper_input_key()
	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(sort_by_distance_to_player)
		#label.text = base_text + active_areas[0].action_name
		#key_label.text = base_text
		action_label.text = base_text + active_areas[0].action_name
		#label.global_position = active_areas[0].global_position
		sprite_interaction.global_position = active_areas[0].global_position
		sprite_interaction.global_position.y += 6
		sprite_interaction.show()
		#label.show()
	else:
		sprite_interaction.hide()
		#label.hide()
		
func sort_by_distance_to_player(area1, area2):
	if player != null:
		var area1_to_player = player.global_position.distance_to(area1.global_position)
		var area2_to_player = player.global_position.distance_to(area2.global_position)
	
		return area1_to_player < area2_to_player

func _input(event):
	if event.is_action_pressed("interact") && can_interact:
		if active_areas.size() > 0:
			can_interact = false
			#label.hide()
			sprite_interaction.hide()
			
			await active_areas[0].interact.call()
			
			can_interact = true

#func get_proper_input_key():
	#if !is_controller:
		#texture_bg.texture = keyboard_texture
		#base_text = "[" + InputHelper.get_keyboard_input_for_action("interact").as_text().trim_suffix(" (Physical)") + "]"
	#else:
		#texture_bg.texture = controller_texture
		#base_text = "[" + get_button_label(InputHelper.get_joypad_input_for_action("interact").as_text(), device_use) + "]"
	#
#func _on_input_device_changed(device: String, device_index: int):
	#is_controller = !(device == InputHelper.DEVICE_KEYBOARD)	
	#device_use = device
#func get_button_label(input_string: String, controller: String):
	#var parts = input_string.split(", ")
#
	#for part in parts:
		#if controller == "Sony" and "Sony" in part:
			#return part.split(" ")[1]
		#elif controller == "xbox" and "Xbox" in part:
			#return part.split(" ")[1]
#
	#return ""
