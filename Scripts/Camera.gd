extends Camera3D

@onready var player = $"../Player"
@export var follow_player = true
var follow_speed = 1

var target_position

func _process(delta):
	if Input.is_action_just_pressed("debug_camera_toggle"):
		follow_player = !follow_player

	if follow_player:
		target_position = player.global_transform.origin
		target_position.y = 20
		target_position.z += 52.5
	
	global_transform.origin = global_transform.origin.lerp(target_position, delta * follow_speed)
	

func dialogue_camera(other_pos : Vector3):
	follow_player = false
	target_position = player.global_transform.origin
	target_position.x += other_pos.x
	target_position.x /= 2
	target_position.y = 18
	target_position.z += 52.5

func follow_player_camera():
	follow_player = true
