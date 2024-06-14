extends Camera3D

@onready var player = $"../Player"
@export var follow_player = true
var follow_speed = 1

func _process(delta):
	if Input.is_action_just_pressed("debug_camera_toggle"):
		follow_player = !follow_player

	if follow_player:
		var target_position = player.global_transform.origin 
		target_position.y = 20
		target_position.z += 50
		global_transform.origin = global_transform.origin.lerp(target_position, delta * follow_speed)
