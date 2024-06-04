extends Area3D
class_name Hurtbox

@export var health : Health

func _init():
	collision_layer = 2
	collision_mask = 0

func _dmg(attack : Attack):
	if health:
		health._dmg(attack)
