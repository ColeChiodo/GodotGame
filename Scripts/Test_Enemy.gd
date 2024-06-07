extends RigidBody3D

@onready var animation_player = $AnimationPlayer
@onready var animator = $AnimatedSprite3D
@onready var throw_active = $ThrownHitboxAnimation
@onready var throw_attack = $ThrowAttack

var gravity = 20

var x_dir = -1

# States
var stunned = false
var blocking = false
var thrown = false

@export var always_block = false

func _physics_process(_delta):
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
		animator.play("idle")
		animator.modulate = Color(1, 1, 1)

func _die():
	animation_player.play("die")
	
func _hit(attack : Attack):
	animator.stop()
	animator.play("hit")
	stunned = true
	blocking = false
	$Stun_Timer.wait_time = attack.atk_stun
	$Stun_Timer.start()

func _throw(dir):
	if thrown:
		return
	thrown = true
	apply_impulse(Vector3(dir * 2, 2, 0), Vector3())

func _knockback(attack : Attack):
	apply_impulse(Vector3(attack.atk_pos * attack.knockback, 0, 0), Vector3())
	
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
