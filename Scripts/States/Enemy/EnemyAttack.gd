extends State
class_name EnemyAttack

signal attack_done

func enter():
	$"../../Attack".set_attack(5, 0, 10, .6, owner.x_dir)
	$"../../AnimationPlayer".stop()
	$"../../AnimationPlayer".play("RESET")
	$"../../AnimationPlayer".play("atk1")
	await get_tree().create_timer($"../../AnimationPlayer".current_animation_length).timeout
	attack_done.emit()

func update(_delta):
	if owner.dead or owner.stunned:
		$"../../AnimationPlayer".stop()
		$"../../AnimationPlayer".play("RESET")
		$"../../AnimationPlayer".play("idle")
		attack_done.emit()
