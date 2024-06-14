extends Node
class_name Attack

var atk_dmg : float
var knockback : float
var atk_pos : int
var atk_stun : float
var crit_chance : float

func set_attack(dmg : float, crit : float, kb : float, stun : float, pos : int):
	atk_dmg = dmg
	crit_chance = crit
	knockback = kb
	atk_pos = pos
	atk_stun = stun
