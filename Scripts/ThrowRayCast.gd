extends RayCast3D
class_name ThrowRayCast

@onready var grab_pos = $"../GrabMarker/GrabPosition"

func _init():
	enabled = false
	collision_mask = 2

func _process(_delta):
	if is_colliding():
		var object = get_collider()
		print(object.name)
		for child in object.owner.get_children():
			if child.has_method("_throw") and child.name == "Hurtbox":
				child.owner.global_position.x = grab_pos.global_position.x
				await get_tree().create_timer(.5).timeout
				child._throw(owner.x_dir)
			
