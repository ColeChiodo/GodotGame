extends Node
class_name Attack

var atk_dmg : float
var knockback : float
var atk_pos : Vector3
var atk_stun : float
@export var crit_chance : float

func set_attack(dmg : float, kb : float, stun : float, pos : Vector3):
	atk_dmg = dmg
	knockback = kb
	atk_pos = pos
	atk_stun = stun
	
