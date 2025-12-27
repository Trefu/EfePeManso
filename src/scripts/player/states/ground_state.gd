extends State
class_name GroundState



func enter() -> void:
	print("Entered ground_state")


func physics_update(delta: float) -> void:
	var movement_direction = player.get_direction(delta)
	player.apply_movement(movement_direction)
	player.move_and_slide()
	
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		transition_to("jump_state")
	elif not player.is_on_floor():
		transition_to("air_state")
