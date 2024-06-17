extends RayCast3D
class_name ThrowRayCast

@onready var grab_pos = $"../GrabMarker/GrabPosition"

func _init():
	enabled = false
	collision_mask = 2

func _process(_delta):
	if is_colliding():
		var object = get_collider()
		for child in object.owner.get_children():
			print(child.name)
			if child.has_method("_throw") and child.name == "Hurtbox" and not child.owner.stunned:
				child.owner.fsm.change_state("Idle")
				child.owner.global_position.x = grab_pos.global_position.x
				await get_tree().create_timer(.5).timeout
				child._throw(owner.x_dir)
			
