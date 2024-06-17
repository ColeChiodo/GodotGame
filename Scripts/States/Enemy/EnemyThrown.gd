extends State
class_name EnemyThrown

signal throw_done

func enter():
	owner.nav.set_velocity(Vector3.ZERO)
	$"../../AnimationPlayer".stop()
	$"../../AnimationPlayer".play("hit")
	owner.apply_impulse(Vector3(owner.throw_dir * 4, 3, 0), Vector3())
	owner.throw_attack.set_attack(10, 0, 3, 2, 1 if owner.linear_velocity.x > 0 else -1)
	owner.nav.avoidance_enabled = false
	owner.throw_active.play("active")
	await get_tree().create_timer(2).timeout
	throw_done.emit()
