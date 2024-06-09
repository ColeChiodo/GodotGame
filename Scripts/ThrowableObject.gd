extends RigidBody3D

@onready var attack = $Attack
@onready var animation_player = $AnimationPlayer
@onready var stats = $ItemStats
@onready var cd_timer = $Cooldown_Timer

var picked = false
var can_pick = true

func _physics_process(_delta):
	if linear_velocity.y != 0 and not picked:
		attack.set_attack(stats.throw_atk, 0, 5, .5, 1 if linear_velocity.x > 0 else -1)
		animation_player.play("active")
	else:
		animation_player.stop()
		animation_player.play("RESET")
	
	if picked:
		position = get_node("../Player/GrabMarker/GrabPosition").global_position
		rotation = get_node("../Player/GrabMarker/GrabPosition").rotation
		rotation.y += get_node("../Player/GrabMarker").rotation.y
		
		angular_velocity.x = 0
		angular_velocity.y = 0
		angular_velocity.z = 0
		linear_velocity.x = 0
		linear_velocity.y = 0
		linear_velocity.z = 0
		
		axis_lock_angular_x = false
		axis_lock_angular_y = false
		
		collision_mask = 0
		
		animation_player.stop()
		animation_player.play("RESET")
	else:
		axis_lock_angular_x = true
		axis_lock_angular_y = true
		
		rotation_degrees.x = 0
		rotation_degrees.y = 0
		rotation_degrees.z = 0
		
		collision_mask = 1
	
	if can_pick and Input.is_action_just_pressed("player_interact") and not picked and not get_node("../Player").blocking: # pickup
		var bodies = $InteractRadius.get_overlapping_bodies()
		for body in bodies:
			if body.name == "Player" and get_node("../Player").can_interact:
				picked = true
				can_pick = false
				get_node("../Player").can_interact = false
				get_node("../Player").holding = true
				get_node("../Player").stats.item_atk = stats.swing_atk
				return
	
	if (Input.is_action_just_pressed("player_interact") or Input.is_action_just_pressed("player_block") ) and picked:
		drop()
		
	if Input.is_action_just_pressed("player_throw") and picked:
		throw()

func drop():
	cd_timer.wait_time = 1
	cd_timer.start()
	
	picked = false
	get_node("../Player").can_interact = true
	get_node("../Player").holding = false
	
func throw():
	cd_timer.wait_time = 1
	cd_timer.start()
	
	picked = false
	get_node("../Player").can_interact = true
	get_node("../Player").holding = false
	apply_impulse(Vector3(get_node("../Player").x_dir * 3, 1, 0), Vector3())

func _on_cooldown_timer_timeout():
	can_pick = true
