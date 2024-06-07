extends RigidBody3D

@onready var attack = $Attack
@onready var animation_player = $AnimationPlayer
var picked = false

func _physics_process(_delta):
	if linear_velocity.y != 0 and not picked:
		attack.set_attack(6, 0, 5, .5, 1 if linear_velocity.x > 0 else -1)
		animation_player.play("active")
	else:
		animation_player.stop()
		animation_player.play("RESET")
	
	if picked:
		self.position = get_node("../Player/GrabMarker/GrabPosition").global_position
		angular_velocity.x = 0
		angular_velocity.y = 0
		angular_velocity.z = 0
		linear_velocity.x = 0
		linear_velocity.y = 0
		linear_velocity.z = 0
		self.position.y += 0.2
		self.collision_mask = 0
	
	if Input.is_action_just_pressed("player_interact") and not picked: # pickup
		var bodies = $InteractRadius.get_overlapping_bodies()
		for body in bodies:
			if body.name == "Player" and get_node("../Player").can_interact:
				picked = true
				get_node("../Player").can_interact = false
				return
	
	if Input.is_action_just_pressed("player_interact") and picked: # throw
		picked = false
		get_node("../Player").can_interact = true
		apply_impulse(Vector3(get_node("../Player").x_dir * 5, 0, 0), Vector3())
		self.collision_mask = 1
		
