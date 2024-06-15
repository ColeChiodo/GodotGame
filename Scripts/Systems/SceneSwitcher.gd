extends Node

var next_level = null

@onready var curr_level = self.get_child(self.get_child_count() - 1)
@onready var animator = $AnimationPlayer
var type : String

func _ready():
	curr_level.end_encounter.connect(handle_level_change)

func handle_level_change(new_type : String):
	type = new_type
	animator.play("fade_out")
	
func transfer_level_parameters(old, new):
	new.load_level_parameters(old.level_parameters)

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"fade_out":
			next_level = load("res://Scenes/Tests/Test_"+ type + ".tscn").instantiate()
			add_child(next_level)
			next_level.end_encounter.connect(handle_level_change)
			transfer_level_parameters(curr_level, next_level)
			curr_level.queue_free()
			curr_level = next_level
			next_level = null
			animator.play("fade_in")
