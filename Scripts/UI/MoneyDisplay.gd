extends Label
class_name GoldDisplay

func _ready():
	self.text = str(owner.get_node("HeldItems").money)

func _process(delta):
	self.text = str(owner.get_node("HeldItems").money)
