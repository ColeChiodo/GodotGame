extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var animator = $AnimatedSprite3D



# States
var stunned = false

func _process(_delta):
	if not stunned:
		animator.play("idle")
		animator.modulate = Color(1, 1, 1)
	elif stunned:
		animator.modulate = Color(1, 0, 0)

func _die():
	animation_player.play("die")
	
func _hit(attack : Attack):
	animator.play("hit")
	stunned = true
	$Stun_Timer.wait_time = attack.atk_stun
	$Stun_Timer.start()

func _on_animation_player_animation_finished(anim_name):
	queue_free()

func _on_stun_timer_timeout():
	stunned = false
