extends Node3D
var font = preload("res://Assets/Fonts/Silvertones.ttf")
func display_number(value: int, position: Vector3, is_critical: bool = false):
	var number = Label3D.new()
	number.text = str(value)
	number.billboard = true
	number.no_depth_test = true
	number.pixel_size = 0.003
	number.font = font
	
	var color = Color.WHITE
	if is_critical:
		color = Color("b22222")
	
	if value == 0:
		color = Color(1, 1, 1, 0.53)
		
	number.modulate = color
	number.font_size = 450
	number.outline_size = 1
	number.outline_modulate = Color.BLACK
	number.double_sided = true
	
	# Set the local position first
	number.position = position - global_position
	
	add_child(number)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	var start_y = number.position.y
	
	tween.tween_property(
		number, "position:y", 
		start_y + 1.0,
		0.25
	).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(
		number, "position:y",
		start_y,
		0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	
	tween.tween_property(
		number, "scale",
		Vector3.ZERO,
		0.5
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	tween.tween_property(
		number, "modulate:a",
		0.0,
		0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	
	number.queue_free()
