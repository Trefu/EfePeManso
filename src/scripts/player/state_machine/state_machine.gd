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
			child.connect("transitioned", Callable(self, "_on_state_transitioned"))
			print("State registered: ", child.name)
	
	if initial_state:
		current_state = initial_state
		current_state.enter()
	else:
		push_error("No initial state, set it in the Inspector.")

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func get_current_state_name() -> String:
	if current_state:
		return current_state.name
	return ""

func _on_state_transitioned(state: State, new_state_name: String) -> void:
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		push_error("State '%s' not found in state machine." % new_state_name)
		return
	
	print("Transitioning from %s to %s" % [current_state.name, new_state.name])
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()
