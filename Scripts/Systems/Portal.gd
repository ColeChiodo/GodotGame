extends Node3D
class_name Portal

@export var type : String
@onready var trigger_area = $Area3D as Area3D

func _process(_delta):
	for body in trigger_area.get_overlapping_bodies():
		if "Player" in body.name:
			if Input.is_action_just_pressed("world_interact"):
				get_node("..").goto_encounter(type)
	
