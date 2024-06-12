extends State
class_name EnemyAttack

signal attack_done

func enter():
	$"../../Attack".set_attack(5, 0, 10, .6, owner.x_dir)
	$"../../AnimationPlayer".play("atk1")
	await get_tree().create_timer($"../../AnimationPlayer".current_animation_length).timeout
	attack_done.emit()
