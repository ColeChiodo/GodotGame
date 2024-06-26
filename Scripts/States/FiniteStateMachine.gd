extends Node
class_name FiniteStateMachine

var states : Dictionary = {}
var curr_state : State
@export var init_state : State
@onready var debug_state = $"../DebugState"


func _ready():
	for child in get_children():
		if child  is State:
			states[child.name.to_lower()] = child
			child.state_finished.connect(change_state)
	
	if init_state:
		init_state.enter()
		curr_state = init_state

func _process(delta):
	if curr_state:
		debug_state.text = curr_state.name
		curr_state.update(delta)

func change_state(new_name : String):
	var new_state = states.get(new_name.to_lower())
	if !new_state:
		push_error("change_state: new_state " + new_state + " doesn't exist.")
		return
	
	curr_state.exit()
	new_state.enter()
	
	curr_state = new_state
