extends Node
class_name State

signal state_finished

func enter():
	pass
	
func update(_delta):
	pass
	
func exit():
	print("Exiting " + self.name)
	
