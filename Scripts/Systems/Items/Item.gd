extends Node3D
class_name Item

@export var item_name : String

func _on_area_3d_body_entered(body):
	if "Player" in body.name:
		body.get_node("HeldItems").pickup(item_name)
		self.queue_free()
