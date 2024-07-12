extends Node3D
class_name EnemyEncounter

@onready var portal_points = $PortalPoints
@onready var enemy_spawn_points = $EnemySpawnPoints
@onready var player = $Player

@export var enemy_pool = [
	preload("res://Scenes/Enemies/Training_Dummy/Training_Dummy.tscn"),
	
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
	preload("res://Scenes/Portals/shop_portal.tscn"),
	
]

@export var item_pool = [
	preload("res://Scenes/Items/special1_charge_up.tscn"),
	
]

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

var enemy_count : int = 0
var total_enemy_count : int = 0

signal end_encounter

func _ready():
	if not level_parameters.player_hp:
		level_parameters.player_hp = player.get_node("Health").max_health
	
	if not level_parameters.player_money:
		level_parameters.player_money = player.get_node("HeldItems").money
	
func goto_encounter(type : String):
	emit_signal("end_encounter", type)

var initialized = false
var can_spawn_portals = true
func _process(_delta):
	if not initialized:
		if enemy_spawn_points:
			for spawn_point in enemy_spawn_points.get_children():
				var spawn_here = randi_range(0, 100)
				if spawn_here <= 20:
					continue
				var enemy_index = randi_range(0, enemy_pool.size() - 1)
				var enemy = enemy_pool[enemy_index].instantiate()
				enemy.position = spawn_point.global_position
				self.add_child(enemy)
				enemy.name = "Enemy"
				enemy_count += 1
			total_enemy_count = enemy_count
		initialized = true
	
	if can_spawn_portals:
		if enemy_count == 0:
			if portal_points:
				for portal_point in portal_points.get_children():
					var portal_index = randi_range(0, portal_pool.size() - 1)
					var portal = portal_pool[portal_index].instantiate()
					portal.position = portal_point.global_position
					self.add_child(portal)
				
				var item_index = randi_range(0, item_pool.size() - 1)
				var item = item_pool[item_index].instantiate()
				item.position = portal_points.global_position
				self.add_child(item)
				
				can_spawn_portals = false
			if total_enemy_count:
				self.get_node("Player/HeldItems").give_money(total_enemy_count)
				Engine.time_scale = .1
				await get_tree().create_timer(.2).timeout
				Engine.time_scale = 1
