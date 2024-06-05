extends Node
class_name Attack

var atk_dmg : float
var knockback : float
@export var atk_pos : int
var atk_stun : float
@export var crit_chance : float

func set_attack(dmg : float, kb : float, stun : float, pos : int):
	atk_dmg = dmg
	knockback = kb
	atk_pos = pos
	atk_stun = stun

func inc_crit(val):
	crit_chance += val
