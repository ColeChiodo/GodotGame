extends State
class_name EnemyChase

var direction = Vector3()
@onready var target : Vector3

func enter():
	for child in owner.owner.get_children():
		if child.name == "Player":
			target = child.global_position
	
func update(delta):
	for child in owner.owner.get_children():
		if "Player" in child.name:
			target = child.global_position
	if target:
		owner.nav.target_position = target
	
	if owner.nav.is_navigation_finished():
		return
	
	direction = (owner.nav.get_next_path_position() - owner.global_position).normalized()
	
	if direction:
		$"../../AnimationPlayer".play("walk")
	
	owner.linear_velocity = owner.linear_velocity.lerp(direction * 3, 10 * delta)

