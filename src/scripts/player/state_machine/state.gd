#state.gd
extends Node
class_name State

## Reference to the state machine
var state_machine: StateMachine
## Reference to the player (or any entity using this state)
var player: Player

## Called when entering this state
func enter() -> void:
	pass

## Called when exiting this state
func exit() -> void:
	pass

## Called every physics frame while in this state
func physics_update(delta: float) -> void:
	pass

## Called every frame while in this state
func update(delta: float) -> void:
	pass

## Called when input events occur while in this state
func handle_input(event: InputEvent) -> void:
	pass

## Helper function to transition to another state
func transition_to(state_name: String) -> void:
	state_machine.transition_to(state_name)
