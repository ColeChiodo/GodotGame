extends Node
class_name HeldItems

var money : int = 0

var items : Dictionary = {
	"special1_charge_up" : 0,
	
}

func pickup(item_name : String):
	items[item_name] += 1
	print("%s gained %s, now %d" % [owner.name, item_name, items[item_name]])
	owner.owner.level_parameters.held_items = items

func give_money(val : int):
	money += val
	if "Player" in owner.name:
		owner.owner.level_parameters.player_money = money

func take_money(val : int):
	money -= val
	if "Player" in owner.name:
		owner.owner.level_parameters.player_money = money
