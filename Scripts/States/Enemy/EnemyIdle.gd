extends State
class_name EnemyIdle

func enter():
	$"../../AnimationPlayer".play("idle")
	
func update(_delta):
	$"../../AnimationPlayer".play("idle")
	
