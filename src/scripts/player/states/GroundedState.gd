extends State

func enter() -> void:
	print("Entered GroundedState")

func physics_update(_delta: float) -> void:
	if not player:
		return
	
	if Input.is_action_just_pressed("jump"):
		print("🎯 Jump pressed from GROUND")
		if player.handle_jump_input():
			transition_to("Jumping")

	elif not player.is_on_floor():
		player.activate_coyote_time()
		transition_to("Falling")
