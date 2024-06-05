extends CharacterBody3D

@onready var animator = $AnimatedSprite3D
@onready var animation_player = $AnimationPlayer
@onready var hitbox = $Area3D
@onready var attack = $Attack

const SPEED = 5.0
const DASH = 800
const JUMP_VELOCITY = 10
var gravity = 20

var max_combo = 4
var curr_combo = 0

# States
var dead = false

var stunned = false

var attacking = false
var can_attack = true

var sprinting = false
var can_sprint = true
var sprint_mult = 1.0

var dashing = false
var can_dash = true
var dash_mult = 1.0
var dash_cd = .3

# Double tap direction to dash
var dt_left = false
var dt_right = false
var dt_up = false
var dt_down = false

func _physics_process(delta):
	if dashing: 
		animator.play("dash")
		
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if dead or stunned:
		return
		
	if Input.is_action_just_pressed("attack_basic") and is_on_floor() and not dashing:
		if sprinting:
			sprinting = false
		if can_attack:
			_basic_atk()
			
	if attacking:
		return

	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor() and not dashing:
		velocity.y = JUMP_VELOCITY
		sprinting = false
	
	if not is_on_floor() and velocity.y > 0:
		animator.play("jump")
	elif not is_on_floor() and velocity.y < 0:
		animator.play("fall")
	
	if(Input.is_action_just_released("move_right")):
		dt_right = true
		$DT_Timer.start()
	if(Input.is_action_just_released("move_left")):
		dt_left = true
		$DT_Timer.start()
	if(Input.is_action_just_released("move_forward")):
		dt_up = true
		$DT_Timer.start()
	if(Input.is_action_just_released("move_backward")):
		dt_down = true
		$DT_Timer.start()

	# Handle directional movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction.x > 0:
		$AnimatedSprite3D.flip_h = false
		hitbox.transform.origin.x = 1
	elif direction.x < 0:
		$AnimatedSprite3D.flip_h = true
		hitbox.transform.origin.x = -1

	if(Input.is_action_just_pressed("move_right")):
		if dt_right and can_sprint:
			sprinting = true
			dt_right = false
	if(Input.is_action_just_pressed("move_left")):
		if dt_left and can_sprint:
			sprinting = true
			dt_left = false
	if(Input.is_action_just_pressed("move_forward")):
		if dt_up and can_dash:
			_dash()
	if(Input.is_action_just_pressed("move_backward")):
		if dt_down and can_dash:
			_dash()
	
	if sprinting:
		sprint_mult = 1.5
	else:
		sprint_mult = 1
	
	if direction:
		velocity.x = direction.x * SPEED * sprint_mult
		velocity.z = direction.z * SPEED * sprint_mult * dash_mult # * 1.5
		if is_on_floor() and not dashing:
			if not sprinting:
				animator.play("walk")
			else:
				animator.play("run")
			
	else:
		if sprinting:
			sprinting = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if is_on_floor():
			animator.play("idle")

	move_and_slide()
	
func _dash():
	$Dash_Timer.start()
	sprinting = false
	can_sprint = false
	dashing = true
	can_dash = false
	dash_mult = 6.5
	
func _basic_atk():
	attacking = true
	can_attack = false
	
	if curr_combo == 0:
		attack.set_attack(2, 0, .45, hitbox.transform.origin)
		animation_player.play("atk1")
		animator.play("atk1")
		await get_tree().create_timer(.3).timeout
	elif curr_combo == 1:
		attack.set_attack(3, 0, .75, hitbox.transform.origin)
		animation_player.play("atk2")
		animator.play("atk2")
		await get_tree().create_timer(.4).timeout
	elif curr_combo == 2:
		attack.set_attack(5, 0, .85, hitbox.transform.origin)
		animation_player.play("atk3")
		animator.play("atk3")
		await get_tree().create_timer(.7).timeout
	elif curr_combo == 3:
		attack.set_attack(4, 0, .5, hitbox.transform.origin)
		animation_player.play("atk4")
		animator.play("atk4")
		await get_tree().create_timer(.8).timeout
	curr_combo += 1
	if curr_combo == max_combo:
		curr_combo = 0
	
	attacking = false
	can_attack = true

func _die():
	dead = true
	animator.play("death")

func _on_timer_timeout():
	dt_down = false
	dt_up = false
	dt_left = false
	dt_right = false

func _on_dash_timer_timeout():
	can_sprint = true
	dashing = false
	dash_mult = 1
	await get_tree().create_timer(dash_cd).timeout
	can_dash = true

func _on_animation_player_animation_finished(_anim_name):
	curr_combo = 0
