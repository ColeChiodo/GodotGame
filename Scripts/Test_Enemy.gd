extends RigidBody3D
class_name Enemy

@export var max_speed : float = 4.0
@export var acceleration : float = 10.0

var gravity = 20
var x_dir = -1

@onready var fsm : FiniteStateMachine = $FSM
@onready var idle = $FSM/Idle as EnemyIdle
@onready var wander = $FSM/Wander as EnemyWander
@onready var chase = $FSM/Chase as EnemyChase
@onready var attack = $FSM/Attack as EnemyAttack
@onready var block = $FSM/Block as EnemyBlock
@onready var die = $FSM/Die as EnemyDie
@onready var hit = $FSM/Hit as EnemyHit


@onready var animation_player = $AnimationPlayer
@onready var animator = $AnimatedSprite3D
@onready var throw_active = $ThrownHitboxAnimation
@onready var throw_attack = $ThrowAttack

@onready var nav : NavigationAgent3D = $NavigationAgent3D

# States
var stunned = false
var dead = false
var blocking = false
var thrown = false

@export var always_block = false
@export var hitboxes : Array[Node3D] = []

func _ready():
	chase.can_attack.connect(fsm.change_state.bind("Attack"))
	attack.attack_done.connect(fsm.change_state.bind("Chase"))
	hit.stun_done.connect(fsm.change_state.bind("Block"))
	block.is_safe.connect(fsm.change_state.bind("Chase"))

func _physics_process(_delta):
	if x_dir == 1: 
		$AnimatedSprite3D.flip_h = true
		for hitbox in hitboxes:
			hitbox.global_rotation_degrees.y = 0
	elif x_dir == -1:
		$AnimatedSprite3D.flip_h = false
		for hitbox in hitboxes:
			hitbox.rotation_degrees.y = 180
	
	if blocking:
		fsm.change_state("Block")
	
	if not is_on_floor() and thrown:
		throw_attack.set_attack(10, 0, 3, .5, 1 if linear_velocity.x > 0 else -1)
		throw_active.play("active")
	else:
		thrown = false
		throw_active.stop()
		throw_active.play("RESET")

func _process(_delta):
	if stunned:
		animator.modulate = Color(.5, .5, .5)
	elif blocking:
		animator.modulate = Color(.1, .1, 1)
	else:
		if always_block:
			blocking = true
		animator.modulate = Color(1, 1, 1)

func _die():
	dead = true
	fsm.change_state("die")
	
func _hit(incoming_attack : Attack):
	fsm.change_state("Hit")
	stunned = true
	blocking = false
	$Stun_Timer.wait_time = incoming_attack.atk_stun
	$Stun_Timer.start()

func _throw(dir):
	if thrown:
		return
	thrown = true
	apply_impulse(Vector3(dir * 4, 3, 0), Vector3())

func _knockback(incoming_attack : Attack):
	apply_impulse(Vector3(incoming_attack.atk_pos * incoming_attack.knockback, 0, 0), Vector3())
	
func _blocking(dir : int):
	return blocking if dir != x_dir else false

func _on_animation_player_animation_finished(_anim_name):
	queue_free()

func _on_stun_timer_timeout():
	stunned = false

var old_velocity = 0
func is_on_floor():
	var new_velocity = linear_velocity.y
	if new_velocity == old_velocity:
		return true
	old_velocity = linear_velocity.y

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	if not thrown and not blocking:
		linear_velocity = linear_velocity.lerp(safe_velocity, 1)
