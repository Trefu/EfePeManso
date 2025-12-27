extends State

func enter() -> void:
	print("Entered FallingState")

func physics_update(_delta: float) -> void:
	if not player:
		return
	

	# DOBLE SALTO DURANTE DESCENSO
	if Input.is_action_just_pressed("jump"):
		if player.handle_jump_input():
			transition_to("Jumping")
	
	if player.is_on_floor():
		transition_to("Grounded")
