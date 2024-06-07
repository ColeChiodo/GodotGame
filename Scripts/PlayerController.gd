extends CharacterBody3D

@onready var animator = $AnimatedSprite3D
@onready var hitbox_animation_player = $HitboxAnimations
@onready var invuln_animation_player = $InvulnAnimations
@export var hitboxes : Array[Node3D] = []
@onready var basic_attack = $BasicAttack
@onready var sp_slot_1 = $SpecialSlot1
@onready var stats = $Stats

@onready var special1_charge_ui = $UI/Label

const SPEED = 5.0
const DASH = 800
const JUMP_VELOCITY = 10
var gravity = 20

var max_combo = 4
var curr_combo = 0

@onready var special1_charges = stats.special1_max_charges

@export var x_dir = 1

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

var blocking = false

var invulnerable = false

var holding = false
var can_interact = true

# Double tap direction to dash
var dt_left = false
var dt_right = false
var dt_up = false
var dt_down = false

func _ready():
	special1_charge_ui.text = str(special1_charges)

func _physics_process(delta):
	if invulnerable:
		invuln_animation_player.play("invuln")
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if dead or stunned:
		return
		
	# Handle throw
	if Input.is_action_just_pressed("player_throw") and not dashing and not attacking:
		attacking = true
		can_attack = false
		animator.play("grab")
		hitbox_animation_player.play("throw")
		await get_tree().create_timer(.6).timeout
		attacking = false
		can_attack = true
	
	# Handle blocking
	if Input.is_action_just_pressed("player_block") and is_on_floor() and not dashing and not attacking:
		animator.play("block")
		blocking = true
	
	if Input.is_action_just_released("player_block"):
		blocking = false
		velocity.x = 0
	
	if blocking:
		return
	
	# Handle basic attack
	if Input.is_action_just_pressed("attack_basic") and is_on_floor() and not dashing:
		if can_attack:
			if sprinting:
				sprinting = false
			_basic_atk()
			
	
	if Input.is_action_just_pressed("special_attack_1") and (sp_slot_1.special.can_use_in_air || is_on_floor()) and not dashing:
		if can_attack:
			if sprinting:
				sprinting = false
			use_special(sp_slot_1.special)
	
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
		for hitbox in hitboxes:
			hitbox.global_rotation_degrees.y = 0
		x_dir = 1
	elif direction.x < 0:
		$AnimatedSprite3D.flip_h = true
		for hitbox in hitboxes:
			hitbox.global_rotation_degrees.y = 180
		x_dir = -1

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
		velocity.z = direction.z * SPEED * sprint_mult * dash_mult
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
	
	# Handle object pushing
	for count in get_slide_collision_count():
		var body = get_slide_collision(count)
		if body.get_collider() is RigidBody3D:
			body.get_collider().apply_central_impulse(-body.get_normal())
	
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
		basic_attack.set_attack(2, stats.crit_rate, 1, .6, x_dir)
		hitbox_animation_player.play("atk1")
		animator.play("atk1")
		await get_tree().create_timer(.3).timeout
	elif curr_combo == 1:
		basic_attack.set_attack(3, stats.crit_rate, 1, .9, x_dir)
		hitbox_animation_player.play("atk2")
		animator.play("atk2")
		await get_tree().create_timer(.4).timeout
	elif curr_combo == 2:
		basic_attack.set_attack(5, stats.crit_rate, 2, .85, x_dir)
		hitbox_animation_player.play("atk3")
		animator.play("atk3")
		await get_tree().create_timer(.7).timeout
	elif curr_combo == 3:
		basic_attack.set_attack(4, stats.crit_rate, 1, .4, x_dir)
		hitbox_animation_player.play("atk4")
		animator.play("atk4")
		await get_tree().create_timer(.8).timeout
	curr_combo += 1
	if curr_combo == max_combo:
		curr_combo = 0
	
	attacking = false
	can_attack = true

func use_special(special):
	if special1_charges == 0:
		return
	
	attacking = true
	can_attack = false
	
	animator.play(special.anim_name)
	special.activate()
	
	await get_tree().create_timer(special.duration).timeout
	
	if special1_charges == stats.special1_max_charges:
		$Special1_Timer.wait_time = special.cooldown
		$Special1_Timer.start()
		
	special1_charges -= 1
	special1_charge_ui.text = str(special1_charges)
	
	attacking = false
	can_attack = true

func _die():
	dead = true
	animator.play("death")

func _hit(attack : Attack):
	if dead: return
	animator.stop()
	animator.play("hit")
	stunned = true
	blocking = false
	$Stun_Timer.wait_time = attack.atk_stun
	$Stun_Timer.start()
	
func _knockback(attack : Attack):
	velocity.x = attack.atk_pos * attack.knockback
	move_and_slide()
	
func _blocking(attack : Attack):
	return blocking if attack.atk_pos != x_dir else false

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

func _on_stun_timer_timeout():
	stunned = false
	invulnerable = true
	$Invuln_Timer.wait_time = stats.invuln_time
	$Invuln_Timer.start()

func _on_invuln_timer_timeout():
	invulnerable = false

func _on_special_1_timer_timeout():
	special1_charges += 1
	special1_charge_ui.text = str(special1_charges)
	if special1_charges == stats.special1_max_charges:
		$Special1_Timer.stop()
