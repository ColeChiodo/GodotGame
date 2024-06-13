extends State
class_name EnemyChase

var direction = Vector3()
@onready var target : Vector3
@export var attack_range : Area3D

signal can_attack

func enter():
	$"../../AnimationPlayer".stop()
	$"../../AnimationPlayer".play("RESET")
	$"../../AnimationPlayer".play("walk")
	for child in owner.owner.get_children():
		if child.name == "Player":
			target = child.global_position
	
func update(delta):
	if owner.dead or owner.stunned: return
	direction = (owner.nav.get_next_path_position() - owner.global_position).normalized()
	
	if direction.x > 0: owner.x_dir = 1
	if direction.x < 0: owner.x_dir = -1
	
	if attack_range.has_overlapping_areas():
		for body in attack_range.get_overlapping_areas():
			if body.name == "Hurtbox":
				can_attack.emit()
	
	for child in owner.owner.get_children():
		if "Player" in child.name:
			target = child.global_position
	if target:
		owner.nav.target_position = target
	
	if owner.nav.is_navigation_finished():
		return
	
	owner.nav.set_velocity(owner.linear_velocity.lerp(direction * owner.max_speed, owner.acceleration * delta))
	
