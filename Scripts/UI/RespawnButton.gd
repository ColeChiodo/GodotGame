extends Button

@onready var animator = $AnimationPlayer

func _process(_delta):
	if self.visible:
		if Input.is_action_just_pressed("attack_basic"):
			self.visible = false
			animator.play("fade_out")

func _on_pressed():
	self.visible = false
	animator.play("fade_out")
	
func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"fade_out":
			get_tree().reload_current_scene()
