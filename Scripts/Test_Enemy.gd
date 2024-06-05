extends CharacterBody3D

@onready var animation_player = $AnimationPlayer
@onready var animator = $AnimatedSprite3D

var x_dir = -1

# States
var stunned = false
var blocking = false

@export var always_block = false

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
	
func _knockback(attack : Attack):
	velocity.x = attack.atk_pos * attack.knockback
	move_and_slide()
	
func _blocking(attack : Attack):
	return blocking if attack.atk_pos != x_dir else false

func _on_animation_player_animation_finished(_anim_name):
	queue_free()

func _on_stun_timer_timeout():
	stunned = false
