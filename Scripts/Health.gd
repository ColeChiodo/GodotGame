extends Node
class_name Health

@export var max_health = 20.0
var hp : float

@onready var parent = get_parent()

func _process(_delta):
	if owner.name == "Player":
		if Input.is_action_just_pressed("debug_take_dmg"):
			var attack = Attack.new()
			attack.atk_dmg = max_health
			attack.knockback = 5
			attack.atk_pos = get_parent().global_transform.origin
			_dmg(attack)

func _ready():
	hp = max_health
	
func _dmg(attack : Attack):
	hp -= attack.atk_dmg
	print(str(owner.name) + " has been hit.\nHP: " + str(hp))
	if parent.has_method("_hit"):
		parent._hit(attack)
	if hp <= 0:
		parent._die()
		
