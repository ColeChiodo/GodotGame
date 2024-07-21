extends Control
@onready var label = $MarginContainer/Label
@onready var timer = $DisplayTimer

var text = ""
var index = 0

var letter_time = 0.03
var space_time = 0.06
var punctuation_time = 0.09

signal finished_displaying()

func display_text(text_to_display : String):
	text = text_to_display

	label.text = ""
	display_letter()

func display_letter():
	label.text += text[index]
	index += 1
	if index >= text.length():
		finished_displaying.emit()
		return
	
	match text[index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)

func _on_display_timer_timeout():
	display_letter()
