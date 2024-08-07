extends CharacterBody3D
class_name Player

@onready var animator = $AnimationPlayer
@onready var invuln_animation_player = $InvulnAnimations
@export var hitboxes : Array[Node3D] = []
@onready var basic_attack = $BasicAttack
@onready var air_attack = $AirAttack
@onready var sp_slot_1 = $SpecialSlot1
@onready var stats = $Stats
@onready var held_items = $HeldItems


@onready var special1_charge_ui = $UI/Label

const SPEED = 3.0
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
var sprint_atk = false
var sprint_mult = 1.0

var dashing = false
var can_dash = true
var dash_mult = 1.0
var dash_cd = .3

var blocking = false

var invulnerable = false

var holding = false
var can_interact = true

var on_ladder = false
var climbing = false

var chatting = false

# Double tap direction to dash
var dt_left = false
var dt_right = false
var dt_up = false
var dt_down = false

func _ready():
	special1_charge_ui.text = str(special1_charges)

func _physics_process(delta):
	if not is_on_floor() and not climbing:
		velocity.y -= gravity * delta
		
	if sprint_atk:
		velocity.x = x_dir * 6.0
		move_and_slide()
	
	if not $Timers/Action_Timer.is_stopped() and is_on_floor():
		$Timers/Action_Timer.stop()
		animator.stop()
		animator.play("RESET")
		
		attacking = false
		can_attack = true
	
	if invulnerable:
		invuln_animation_player.play("invuln")
	
	# Handle Ladders
	if on_ladder and Input.is_action_pressed("move_forward"):
		climbing = true
		
	if on_ladder and is_on_floor() and Input.is_action_pressed("move_backward"):
		climbing = false
	
	if dead or stunned:
		move_and_slide()
		return
	
	if chatting:
		animator.play("idle")
		return
	
	# Handle blocking
	if Input.is_action_just_pressed("player_block") and is_on_floor() and not dashing and not attacking and not climbing:
		animator.play("block")
		blocking = true
	
	if Input.is_action_just_released("player_block"):
		blocking = false
		velocity.x = 0
	
	if blocking:
		return
		
	# Handle throw
	if Input.is_action_just_pressed("player_throw") and not dashing and not attacking and not climbing and not holding:
		attacking = true
		can_attack = false
		animator.play("grab")
		await get_tree().create_timer(.6).timeout
		attacking = false
		can_attack = true
	
	# Handle basic attack
	if Input.is_action_just_pressed("attack_basic") and not dashing and not climbing:
		if can_attack:
			if holding and is_on_floor():
				if sprinting:
					sprinting = false
				_item_atk()
			elif sprinting:
				_sprint_atk()
			elif is_on_floor():
				_basic_atk()
			else:
				_air_atk()
			
	
	if Input.is_action_just_pressed("special_attack_1") and (sp_slot_1.special.can_use_in_air || is_on_floor()) and not dashing and not climbing:
		#if can_attack:
		if sprinting:
			sprinting = false
		use_special(sp_slot_1.special)
	
	if not is_on_floor() and velocity.y > 0 and not climbing and not attacking:
		animator.play("jump")
	elif not is_on_floor() and velocity.y < 0 and not climbing and not attacking:
		animator.play("fall")

	# Handle jump.
	if (Input.is_action_just_pressed("player_jump") and is_on_floor() and not attacking) or (Input.is_action_pressed("player_jump") and Input.is_action_pressed("move_backward") and climbing):
		velocity.y = JUMP_VELOCITY
		sprinting = false
		climbing = false
	
	if(Input.is_action_just_released("move_right")):
		dt_right = true
		$Timers/DT_Timer.start()
	if(Input.is_action_just_released("move_left")):
		dt_left = true
		$Timers/DT_Timer.start()
	if(Input.is_action_just_released("move_forward")):
		dt_up = true
		$Timers/DT_Timer.start()
	if(Input.is_action_just_released("move_backward")):
		dt_down = true
		$Timers/DT_Timer.start()

	# Handle directional movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if not attacking:
		if direction.x > 0:
			$AnimatedSprite3D.flip_h = false
			for hitbox in hitboxes:
				hitbox.global_rotation_degrees.y = 0
			x_dir = 1
		elif direction.x < 0:
			$AnimatedSprite3D.flip_h = true
			for hitbox in hitboxes:
				hitbox.rotation_degrees.y = 180
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
	
	if direction and (not attacking or not is_on_floor()):
		velocity.x = direction.x * SPEED * sprint_mult
		if climbing:
			velocity.y = -direction.z * SPEED * sprint_mult * dash_mult
		else:
			velocity.z = direction.z * SPEED * sprint_mult * dash_mult
		if is_on_floor() and not dashing:
			if not sprinting:
				animator.play("walk")
			else:
				animator.play("run")
		if climbing:
				animator.play("climb")
	else:
		if sprinting:
			sprinting = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if climbing:
			velocity.y = move_toward(velocity.y, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if not attacking:
			if is_on_floor():
				animator.play("idle")
			elif climbing:
				animator.play("climb_idle")

	move_and_slide()
	
	# Handle object pushing
	for count in get_slide_collision_count():
		var body = get_slide_collision(count)
		if body.get_collider() is RigidBody3D:
			body.get_collider().apply_central_impulse(-body.get_normal())

func _process(_delta):
	if special1_charge_ui.text != str(special1_charges):
		special1_charge_ui.text = str(special1_charges)
	
	var old_special1_max = stats.special1_max_charges
	stats.special1_max_charges = 1 + held_items.items["special1_charge_up"]
	if old_special1_max < stats.special1_max_charges:
		special1_charges += 1
		special1_charge_ui.text = str(special1_charges)

func _dash():
	animator.play("dash")
	$Timers/Dash_Timer.start()
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
		animator.play("atk1")
	elif curr_combo == 1:
		basic_attack.set_attack(3, stats.crit_rate, 1, .9, x_dir)
		animator.play("atk2")
	elif curr_combo == 2:
		basic_attack.set_attack(5, stats.crit_rate, 2, .85, x_dir)
		animator.play("atk3")
	elif curr_combo == 3:
		basic_attack.set_attack(4, stats.crit_rate, 1, .4, x_dir)
		animator.play("atk4")
	
	$Timers/Chain_Atk_Timer.wait_time = animator.current_animation_length + .1
	$Timers/Chain_Atk_Timer.start()
	await get_tree().create_timer(animator.current_animation_length - .1).timeout
	
	curr_combo += 1
	if curr_combo >= max_combo:
		curr_combo = 0
	
	attacking = false
	can_attack = true

func _item_atk():
	attacking = true
	can_attack = false
	
	basic_attack.set_attack(stats.item_atk, stats.crit_rate, 1, .6, x_dir)
	animator.play("item_atk")
	await get_tree().create_timer(animator.current_animation_length).timeout
	
	attacking = false
	can_attack = true

func _sprint_atk():
	attacking = true
	can_attack = false
	sprint_atk = true
	
	basic_attack.set_attack(7, stats.crit_rate, 1, .6, x_dir)
	animator.play("sprint_atk")
	
	await get_tree().create_timer(animator.current_animation_length).timeout
	
	attacking = false
	can_attack = true
	sprint_atk = false

func _air_atk():
	attacking = true
	can_attack = false
	
	air_attack.set_attack(5, stats.crit_rate, 1, .6, x_dir)
	animator.play("air_atk")
	$Timers/Action_Timer.wait_time = animator.current_animation_length
	$Timers/Action_Timer.start()

func use_special(special):
	if special1_charges <= 0:
		special1_charges = 0
		return
	
	attacking = true
	can_attack = false
	
	animator.stop()
	animator.play("RESET")
	animator.play(special.anim_name)
	special.activate()
	
	await get_tree().create_timer(special.duration).timeout
	
	if special1_charges == stats.special1_max_charges:
		$Timers/Special1_Timer.wait_time = special.cooldown
		$Timers/Special1_Timer.start()
		
	special1_charges -= 1
	if special1_charges <= 0:
		special1_charges = 0
	special1_charge_ui.text = str(special1_charges)
	
	attacking = false
	can_attack = true

func _die():
	if not dead:
		animator.play("death")
		dead = true
		
		velocity = Vector3.ZERO
		
		$UI/RespawnButton.visible = true
	

func _hit(attack : Attack):
	if dead: return
	if is_on_floor():
		velocity = Vector3.ZERO
	animator.stop()
	animator.play("hit")
	stunned = true
	blocking = false
	$Timers/Stun_Timer.wait_time = attack.atk_stun
	$Timers/Stun_Timer.start()
	
func _knockback(attack : Attack):
	velocity.x = attack.atk_pos * attack.knockback
	move_and_slide()
	
func _blocking(dir : int):
	return blocking if dir != x_dir else false

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

func _on_chain_atk_timer_timeout():
	curr_combo = 0

func _on_stun_timer_timeout():
	stunned = false
	invulnerable = true
	$Timers/Invuln_Timer.wait_time = stats.invuln_time
	$Timers/Invuln_Timer.start()

func _on_invuln_timer_timeout():
	invulnerable = false

func _on_special_1_timer_timeout():
	special1_charges += 1
	special1_charge_ui.text = str(special1_charges)
	if special1_charges == stats.special1_max_charges:
		$Timers/Special1_Timer.stop()

func _on_action_timer_timeout():
	attacking = false
	can_attack = true
