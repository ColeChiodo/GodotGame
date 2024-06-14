extends Area3D
class_name Hitbox

@export var attack = Attack

func _init():
	collision_layer = 0
	collision_mask = 2
	monitoring = false
	

func _on_area_entered(area : Area3D):
	for child in area.get_children():
		if not area:
			return
		if area.has_method("_dmg"):
			area._dmg(attack)
