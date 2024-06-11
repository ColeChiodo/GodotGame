extends State
class_name EnemyWander

var direction = Vector3()
@onready var target : Vector3

func enter():
	target = owner.owner.get_child(owner.owner.get_child_count()-1).global_position
	
func update(delta):
	if target:
		owner.nav.target_position = target
	if owner.nav.is_navigation_finished():
		return
	
	direction = (owner.nav.get_next_path_position() - owner.global_position).normalized()
	
	owner.linear_velocity = owner.linear_velocity.lerp(direction * 4, 10 * delta)
