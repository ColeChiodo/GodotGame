extends Node
class_name Attack

@export var atk_dmg : float
@export var knockback : float
@export var atk_pos : Vector3
@export var atk_stun : float

func set_attack(dmg : float, kb : float, stun : float, pos : Vector3):
	atk_dmg = dmg
	knockback = kb
	atk_pos = pos
	atk_stun = stun
	
