extends RigidBody3D

@export var sprite_name : String
@export var interactable : bool = false
@export_enum("OVERHEAD", "POPUP") var textbox_type = "OVERHEAD"
@export var dialogue : Array[String] = []

@onready var interact_area = $InteractArea
@onready var dialogue_box = $DialogueBox
@onready var timer = $Timer

var dialogue_cycle : int = 0

func _ready():
	dialogue_box.text = ""

func _process(_delta):
	for body in interact_area.get_overlapping_bodies():
		if "Player" in body.name:
			if Input.is_action_just_pressed("world_interact") and timer.time_left == 0:
				print("NPC says: \"", dialogue[dialogue_cycle], "\"")
				dialogue_box.text = dialogue[dialogue_cycle]
				timer.start()
				dialogue_cycle += 1
				if dialogue_cycle == dialogue.size():
					dialogue_cycle = 0


func _on_timer_timeout():
	dialogue_box.text = ""
