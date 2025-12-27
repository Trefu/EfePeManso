extends State

func enter() -> void:
	print("Entered JumpingState")

func physics_update(_delta: float) -> void:
	if not player:
		return
	
	# DOBLE SALTO DURANTE ASCENSO
	if Input.is_action_just_pressed("jump"):
		player.handle_jump_input()

	if player.velocity.y < 0:
		transition_to("Falling")
