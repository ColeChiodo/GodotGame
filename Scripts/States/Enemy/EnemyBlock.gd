extends State
class_name EnemyBlock

@export var attack_range : Area3D
@onready var block_timer = $Block_Timer

signal not_safe
signal is_safe

func enter():
	owner.nav.set_velocity(Vector3.ZERO)
	$"../../AnimationPlayer".stop()
	$"../../AnimationPlayer".play("RESET")
	$"../../AnimationPlayer".play("idle")
	owner.blocking = true

func update(_delta):
	owner.nav.set_velocity(Vector3.ZERO)
	if attack_range.has_overlapping_areas():
		for body in attack_range.get_overlapping_areas():
			if body.owner.name == "Player":
				return
	owner.blocking = false
	is_safe.emit()
