# state_machine.gd
extends Node
class_name StateMachine

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	var player := get_parent() as Player

	if not player:
		push_error("StateMachine has no parent!")
		return
	
	# Initialize all child states
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.player = player
			print("State registered: ", child.name)
	
	print("Total states: ", states.size())
	
	# Start with initial state
	if initial_state:
		current_state = initial_state
		print("Starting with state: ", current_state.name)
		current_state.enter()
	else:
		push_error("No initial state set! Please set it in the Inspector.")

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

## Transition to a new state by name
func transition_to(state_name: String) -> void:
	var new_state = states.get(state_name.to_lower())
	
	if not new_state:
		push_error("State '%s' not found in state machine. Available states: %s" % [state_name, states.keys()])
		return
	
	if new_state == current_state:
		return
	
	print("Transitioning from %s to %s" % [current_state.name if current_state else "none", new_state.name])
	
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

func get_current_state_name() -> String:
	if current_state:
		return current_state.name
	return ""
