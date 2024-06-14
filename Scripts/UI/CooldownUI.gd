extends ProgressBar

@export var timer : Timer

func _process(_delta):
	max_value = timer.wait_time
	value = max_value - timer.time_left * 1.0
