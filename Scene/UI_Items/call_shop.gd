extends CanvasLayer

@export var hud: CanvasLayer
@export var shop: CanvasLayer
@export var message_box: MarginContainer

func _ready() -> void:
	Events.wave_done.connect(show_shop)

func show_shop(): 
	hud.hide()
	message_box.show()
	get_tree().paused = true
	show()

func hide_shop():
	hide()
	hud.show()
	get_tree().paused = false
	Events.shop_done.emit()


func _on_yes_pressed() -> void:
	message_box.hide()
	shop.show()
	shop.choose_random_upgrades()


func _on_no_pressed() -> void:
	hide_shop()


func _on_shop_shopped() -> void:
	shop.hide()
	hide_shop()
