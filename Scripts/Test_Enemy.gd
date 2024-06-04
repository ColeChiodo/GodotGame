extends Node3D

@onready var animation_player = $AnimationPlayer

func _die():
	animation_player.play("die")

func _on_animation_player_animation_finished(anim_name):
	queue_free()
