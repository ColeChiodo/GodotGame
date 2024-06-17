extends Node3D
class_name EnemyEncounter

@onready var portal_points = $PortalPoints
@onready var enemy_spawn_points = $EnemySpawnPoints
@onready var player = $Player

@export var enemy_pool = [
	preload("res://Scenes/Enemies/Training_Dummy/Training_Dummy.tscn")
]

@export var portal_pool = [
	#preload("res://Scenes/Portals/debug_portal.tscn"),
	preload("res://Scenes/Portals/enemy_portal.tscn"),
	preload("res://Scenes/Portals/enemy_portal.tscn"),
	preload("res://Scenes/Portals/enemy_portal.tscn"),
	preload("res://Scenes/Portals/enemy_portal.tscn"),
	preload("res://Scenes/Portals/enemy_portal.tscn"),
	preload("res://Scenes/Portals/elite_portal.tscn"),
	preload("res://Scenes/Portals/shop_portal.tscn"),
	preload("res://Scenes/Portals/shop_portal.tscn")
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

var enemy_count : int = 0
@export var max_instanced_enemy_count : int = 5

signal end_encounter

func _ready():
	if not level_parameters.player_hp:
		level_parameters.player_hp = player.get_node("Health").max_health
		
	

func goto_encounter(type : String):
	emit_signal("end_encounter", type)

var initialized = false
var can_spawn_portals = true
func _process(_delta):
	if not initialized:
		if enemy_spawn_points:
			for spawn_point in enemy_spawn_points.get_children():
				var spawn_here = randi_range(0, 100)
				if spawn_here <= (80 - (get_parent().get_node("RunStats").curr_level * 2)): # Rate to spawn enemy. Base 20 + 2 * LevelCount
					continue
				var enemy_index = randi_range(0, enemy_pool.size() - 1)
				var enemy = enemy_pool[enemy_index].instantiate()
				enemy.position = spawn_point.global_position
				self.add_child(enemy)
				enemy.name = "Enemy"
				enemy_count += 1
		initialized = true
	
	if max_instanced_enemy_count and can_spawn_portals:
		if enemy_count == 0:
			if portal_points:
				for portal_point in portal_points.get_children():
					var i = randi_range(0, portal_pool.size() - 1)
					var portal = portal_pool[i].instantiate()
					portal.position = portal_point.global_position
					self.add_child(portal)
				can_spawn_portals = false
