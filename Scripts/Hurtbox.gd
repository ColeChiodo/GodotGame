extends Area3D
class_name Hurtbox

@export var health : Health

func _init():
	collision_layer = 2
	collision_mask = 0

func _dmg(attack : Attack):
	if health:
		Engine.time_scale = .1
		health._dmg(attack)
		await get_tree().create_timer(.015).timeout
		Engine.time_scale = 1
