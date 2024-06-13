extends State
class_name EnemyHit

signal stun_done

func enter():
	owner.nav.set_velocity(Vector3.ZERO)
	$"../../AnimationPlayer".stop()
	$"../../AnimationPlayer".play("hit")
	await get_tree().create_timer($"../../AnimationPlayer".current_animation_length).timeout

func update(_delta):
	if $"../../Stun_Timer".is_stopped():
		stun_done.emit()
