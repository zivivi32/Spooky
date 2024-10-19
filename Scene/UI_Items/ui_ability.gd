extends MarginContainer
class_name Ability_UI
@export var ability: Special_Abilities
@export var image: Texture
@export var icon: TextureRect
@export var used: Panel

var connected_signal: bool = false

func _ready() -> void:
	pass
	
func refresh(): 
	if ability: 
		visible = true
		icon.texture = image
		if !connected_signal:
			ability.connect("ability_used",ability_used)
			ability.connect("ability_ready", ability_ready)		
			connected_signal = true
	else: 
		visible = false
		connected_signal = false

func ability_ready(): 
	used.visible = false
	
func ability_used(): 
	used.visible = true
	
