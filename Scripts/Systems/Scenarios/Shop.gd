extends Node3D
class_name ShopEncounter

@onready var portal_points = $PortalPoints
@onready var player = $Player

@export var portal_pool = [
	#preload("res://Scenes/Portals/debug_portal.tscn"),
	preload("res://Scenes/Portals/enemy_portal.tscn"),
	preload("res://Scenes/Portals/enemy_portal.tscn"),
	preload("res://Scenes/Portals/enemy_portal.tscn"),
	preload("res://Scenes/Portals/enemy_portal.tscn"),
	preload("res://Scenes/Portals/enemy_portal.tscn"),
	preload("res://Scenes/Portals/elite_portal.tscn")
]

var level_parameters := {
	"player_hp": null,
	"held_object": null
}

func load_level_parameters(new_level_parameters : Dictionary):
	print("\n------- Loading Level Parameters -------\n")
	level_parameters = new_level_parameters
	self.get_node("Player/Health").hp = level_parameters.player_hp
	print("Player Health set to " + str(level_parameters.player_hp))
	if level_parameters.held_object:
		print("Was holding " + level_parameters.held_object)
		var held_object = load("res://Scenes/throwable_objects/" + level_parameters.held_object.to_lower() + ".tscn").instantiate()
		add_child(held_object)
		held_object.name = "held_object"
		held_object.pickup()
	print("\n----------------------------------------\n")

signal end_encounter

func _ready():
	if not level_parameters.player_hp:
		level_parameters.player_hp = player.get_node("Health").max_health
		
	if portal_points:
		for portal_point in portal_points.get_children():
			var i = randi_range(0, portal_pool.size() - 1)
			var portal = portal_pool[i].instantiate()
			portal.position = portal_point.global_position
			self.add_child(portal)
	

func goto_encounter(type : String):
	emit_signal("end_encounter", type)
