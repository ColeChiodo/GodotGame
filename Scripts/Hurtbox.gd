extends Area3D
class_name Hurtbox

@export var health : Health

func _init():
	collision_layer = 2
	collision_mask = 0

func _dmg(attack : Attack):
	if health:
		health._dmg(attack)
		Engine.time_scale = .1
		await get_tree().create_timer(.015).timeout
		Engine.time_scale = 1

func _throw(dir):
	if owner.has_method("_blocking"):
		if owner._blocking(dir):
			return
			
	owner._throw(dir)
