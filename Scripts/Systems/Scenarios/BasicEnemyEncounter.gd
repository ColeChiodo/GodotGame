extends Node3D
class_name EnemyEncounter

@onready var enemy_spawn_points = $EnemySpawnPoints

@export var enemy_pool = [
	preload("res://Scenes/Enemies/Training_Dummy/Training_Dummy.tscn")
]

var level_parameters := {
	"player_hp": 0,
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
	for spawn_point in enemy_spawn_points.get_children():
		var spawn_here = randi_range(0, 1)
		if not spawn_here:
			continue
		var enemy_index = randi_range(0, enemy_pool.size() - 1)
		var enemy = enemy_pool[enemy_index].instantiate()
		enemy.position = spawn_point.position
		self.add_child(enemy)
		enemy_count += 1
	

func _physics_process(_delta):
	if enemy_count == 0:
		end_encounter.emit()
