extends Node3D
class_name EnemyEncounter

@onready var enemy_spawn_points = $EnemySpawnPoints

@export var enemy_pool = [
	preload("res://Scenes/Enemies/Training_Dummy/Training_Dummy.tscn")
]

var enemy_count : int = 0
@export var max_instanced_enemy_count : int = 5
@export var enemy_respawns : int = 4

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
	

func _physics_process(delta):
	if enemy_count == 0:
		print("Encounter Won")
