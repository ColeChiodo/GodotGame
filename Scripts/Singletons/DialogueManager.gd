extends Node

@onready var text_box_scene = preload("res://Scenes/Components/dialoguebox.tscn")

var lines : Array[String] = []
var curr_line_index = 0

var text_box

var is_active = false
var can_advance = false

signal dialogue_finished()

func start_dialogue(new_pos : Vector3, new_lines : Array[String]):
	if is_active:
		return
	
	get_tree().root.get_node("SceneManager/Level/Camera3D").dialogue_camera(new_pos)
	get_tree().root.get_node("SceneManager/Level/Player").chatting = true
	
	lines = new_lines
	show_text_box()
	
	is_active = true

func show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	text_box.display_text(lines[curr_line_index])
	can_advance = false

func text_box_finished_displaying():
	can_advance = true

func _process(_delta):
	if (
		(Input.is_action_just_pressed("advance_dialogue")
		or Input.is_action_just_pressed("world_interact"))
		and is_active
		and can_advance
	):
		if is_instance_valid(text_box):
			text_box.queue_free()
		
		curr_line_index += 1
		if curr_line_index >= lines.size():
			curr_line_index = 0
			get_tree().root.get_node("SceneManager/Level/Camera3D").follow_player_camera()
			is_active = false
			get_tree().root.get_node("SceneManager/Level/Player").chatting = false
			if is_instance_valid(text_box):
				text_box.queue_free()
			dialogue_finished.emit()
			return
		
		show_text_box()
		
