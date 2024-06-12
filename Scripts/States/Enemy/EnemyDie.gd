extends State
class_name EnemyDie

func enter():
	$"../../AnimationPlayer".stop()
	$"../../AnimationPlayer".play("RESET")
	$"../../AnimationPlayer".play("die")
	await get_tree().create_timer($"../../AnimationPlayer".current_animation_length).timeout

func exit():
	owner.queue_free()
