extends Node
class_name Health

@onready var origin = $Origin

@export var max_health = 20.0
var hp : float

@onready var parent = get_parent()

func _process(_delta):
	if owner.name == "Player":
		if Input.is_action_just_pressed("debug_take_dmg"):
			var attack = Attack.new()
			attack.atk_dmg = 1
			attack.knockback = 20
			attack.atk_pos = -1
			attack.crit_chance = 50
			attack.atk_stun = .75
			_dmg(attack)
		if Input.is_action_just_pressed("debug_heal"):
			_heal(1)

func _ready():
	hp = max_health
	
func _dmg(attack : Attack):
	if "invulnerable" in owner:
		if owner.invulnerable:
			return
		
	if owner.has_method("_blocking"):
		if owner._blocking(attack):
			if owner.has_method("_knockback"):
				owner._knockback(attack)
			return
	
	var crit = false
	var random : float = (randi() % 1000) / 10.0
	if random <= attack.crit_chance:
		crit = true
	var dmg_taken = attack.atk_dmg * (2 if crit else 1)
	hp -= dmg_taken
	DamageNumbers.display_number("-", dmg_taken, origin.global_position, crit)
	print(str(owner.name) + " has been hit for " + str(dmg_taken) + ".\nHP: " + str(hp))
	if parent.has_method("_hit"):
		parent._hit(attack)
	if hp <= 0:
		parent._die()

func _heal(value):
	var heal_amount
	if(hp + value >= max_health):
		heal_amount = max_health - hp
	else:
		heal_amount = value
	hp += heal_amount
	DamageNumbers.display_number("+", heal_amount, origin.global_position, false)
	print(str(owner.name) + " has been healed for " + str(heal_amount) + ".\nHP: " + str(hp))
	if parent.has_method("_heal"):
		parent._heal(value)
