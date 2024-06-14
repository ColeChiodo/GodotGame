extends State
class_name EnemyIdle

signal player_close

func enter():
	$"../../AnimationPlayer".play("idle")
	
func update(_delta):
	owner.nav.set_velocity(Vector3.ZERO)
	$"../../AnimationPlayer".play("idle")

func _on_agro_range_body_entered(body):
	if "Player" in body.name:
		player_close.emit()
