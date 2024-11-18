extends MarginContainer
class_name Ability_UI

@export var ability: Special_Abilities
@export var image: Texture
@export var timer: Timer
@export var time_label: Label
@export var icon: TextureRect
@export var used: Panel
@export var ammo_label: Label

var connected_signal: bool = false
var cool_down: float

func _ready() -> void:
	time_label.hide()
	refresh()

func clear_ability() -> void:
	if ability and connected_signal:
		# Disconnect all signals if they were connected
		if ability.is_connected("on_cool_down", on_cooldown):
			ability.disconnect("on_cool_down", on_cooldown)
		if ability.is_connected("ability_used", ability_used):
			ability.disconnect("ability_used", ability_used)
		if ability.is_connected("ability_ready", ability_ready):
			ability.disconnect("ability_ready", ability_ready)
	
	ability = null
	connected_signal = false
	visible = false
	if icon:
		icon.texture = null
	if ammo_label:
		ammo_label.text = ""
	if used:
		used.visible = false
	if time_label:
		time_label.hide()

func refresh() -> void:
	if ability:
		visible = true
		icon.texture = image
		if !connected_signal:
			ability.on_cool_down.connect(on_cooldown)
			ability.ability_used.connect(ability_used)
			ability.ability_ready.connect(ability_ready)
			connected_signal = true
	else:
		clear_ability()

func _process(delta: float) -> void:
	if time_label.visible:
		time_label.text = str(snappedf(timer.time_left, 0.1))

func ability_ready() -> void:
	used.visible = false
	time_label.hide()

func ability_used() -> void:
	if ability.current_ammo <= 0:
		hide()
	used.visible = true
	ammo_label.text = str(ability.current_ammo)

func on_cooldown() -> void:
	cool_down = ability.cool_down_wait
	print_debug(cool_down)
	print_debug(ability.cool_down_wait)
	if timer.is_stopped():
		timer.start(cool_down)
	time_label.show()
