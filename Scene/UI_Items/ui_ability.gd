extends MarginContainer
class_name Ability_UI
@export var ability: Special_Abilities
@export var image: Texture
@export var timer: Timer
@export var time_label: Label
@export var icon: TextureRect
@export var used: Panel

var connected_signal: bool = false
var cool_down: float

func _ready() -> void:
	time_label.hide()
	refresh()
	
func refresh(): 
	if ability: 
		visible = true
		icon.texture = image
		if !connected_signal:
			ability.connect("on_cool_down",on_cooldown)
			ability.connect("ability_used", ability_used)
			ability.connect("ability_ready", ability_ready)		
			connected_signal = true
	else: 
		visible = false
		connected_signal = false

func _process(delta: float) -> void:
	if time_label.visible:
		time_label.text = str(snappedf(timer.time_left, 0.1))

func ability_ready(): 
	used.visible = false
	time_label.hide()

func ability_used():
	used.visible = true
	
func on_cooldown(): 
	cool_down = ability.cool_down_timer.wait_time
	if timer.is_stopped():
		timer.start(cool_down)
	time_label.show()
	
	
