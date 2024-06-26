extends Node

func display_number(flag : String, value : int, position : Vector3, crit : bool = false):
	var number = Label3D.new()
	number.transform.origin = position
	number.text = str(value)
	number.billboard = 1
	
	var color = "#FFF"
	if crit:
		color = "#822"
	if flag == "+":
		color = "#282"
		
	number.modulate = color
	number.font_size = 75
	number.outline_modulate = "#000"
	number.outline_size = 25
	
	call_deferred("add_child", number)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y + .25, .25
	).set_ease(Tween.EASE_OUT)
	var random = (randi() % 2) - .5
	tween.tween_property(
		number, "position:x", number.position.x + random, 1
	).set_ease(Tween.EASE_IN)
	tween.tween_property(
		number, "position:y", number.position.y, .5
	).set_ease(Tween.EASE_IN).set_delay(.25)
	tween.tween_property(
		number, "scale", Vector3.ZERO, .25
	).set_ease(Tween.EASE_IN).set_delay(.5)
	
	await tween.finished
	number.queue_free()
