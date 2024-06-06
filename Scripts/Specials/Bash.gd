extends Special

@export var attack : Attack
@export var anim_name : String
@export var duration : float
@export var animation_player : AnimationPlayer
@export var can_use_in_air = true

var active = false

func _init():
	cooldown = 3

func activate():
	active = true
	attack.set_attack(7, owner.stats.crit_rate, 30, 1.25, owner.x_dir)
	animation_player.play("RESET")
	animation_player.play(anim_name)
	await get_tree().create_timer(duration).timeout
	active = false

func _physics_process(_delta):
	if active:
		owner.velocity.x = owner.x_dir * 18
		owner.move_and_slide()
