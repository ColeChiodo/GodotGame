extends Node
class_name SpecialSlot

@export var special : Special

func activate():
	print(special.name + " activated!")
	special.activate()
