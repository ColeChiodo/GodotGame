extends State
class_name EnemyIdle

func enter():
	owner.nav.set_velocity(Vector3.ZERO)
	$"../../AnimationPlayer".play("idle")
	
func update(_delta):
	$"../../AnimationPlayer".play("idle")
	
