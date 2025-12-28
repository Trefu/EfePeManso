#ground.gd
extends State
class_name GroundState

func physics_update(delta: float) -> void:
	player.direction = player.get_input_direction()
	player.apply_movement(delta)
	player.move_and_slide()

	if Input.is_action_pressed("crouch"):
		player.posture_controller.request_crouch()
	else:
		player.posture_controller.request_stand()

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		transition_to("jump")
	elif not player.is_on_floor():
		print('transition air')
		#transition_to("air")
