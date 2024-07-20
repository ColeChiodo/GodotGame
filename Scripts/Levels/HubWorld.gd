extends Node3D
class_name HubWorld

@onready var player = $Player

var level_parameters := {
	"player_hp": null,
	"held_object": null,
	"held_items": null,
	"player_money": null,
	
}

func load_level_parameters(new_level_parameters : Dictionary):
	print("\n------- Loading Level Parameters -------\n")
	level_parameters = new_level_parameters
	
	self.get_node("Player/Health").hp = level_parameters.player_hp
	print("Player Health set to " + str(level_parameters.player_hp))
	
	self.get_node("Player/HeldItems").money = level_parameters.player_money
	print("Player gold: " + str(level_parameters.player_money))
	
	if level_parameters.held_object:
		print("Was holding " + level_parameters.held_object)
		var held_object = load("res://Scenes/throwable_objects/" + level_parameters.held_object.to_lower() + ".tscn").instantiate()
		add_child(held_object)
		held_object.name = "held_object"
		held_object.pickup()
	
	if level_parameters.held_items:
		self.get_node("Player/HeldItems").items = level_parameters.held_items
		self.get_node("Player/Stats").special1_max_charges = 1 + level_parameters.held_items["special1_charge_up"]
		self.get_node("Player").special1_charges = self.get_node("Player/Stats").special1_max_charges
		print(self.get_node("Player").special1_charges)
		self.get_node("Player").special1_charge_ui.text = str(self.get_node("Player").special1_charges)
		print(level_parameters.held_items)
	
	print("\n----------------------------------------\n")

signal end_encounter

func _ready():
	if not level_parameters.player_hp:
		level_parameters.player_hp = player.get_node("Health").max_health
	
	if not level_parameters.player_money:
		level_parameters.player_money = player.get_node("HeldItems").money
	
func goto_encounter(type : String):
	emit_signal("end_encounter", type)
