# ground.gd
extends State
class_name GroundState

var state_name: String = "ground"

func physics_update(delta: float) -> void:
	check_if_floor()
	player.apply_gravity(delta)
	move(delta)
	input_management(delta)
	
func check_if_floor() -> void:
	if !player.is_on_floor():
		if player.velocity.y < 0.0:
			print('air')

func move(delta : float) -> void:
	player.input_direction = Input.get_vector("left", "right", "forward", "backward")
	player.move_direction = (player.head.global_basis * Vector3(player.input_direction.x, 0.0, player.input_direction.y)).normalized()
	
	player.desired_move_speed = clamp(player.desired_move_speed, 0.0, player.max_desired_move_speed)
	
	if player.move_direction and player.is_on_floor():
		player.velocity.x = lerp(player.velocity.x, player.move_direction.x * player.move_speed, player.move_acceleration * delta)
		player.velocity.z = lerp(player.velocity.z, player.move_direction.z * player.move_speed, player.move_acceleration * delta)
		
		if player.hit_ground_cooldown <= 0: player.desired_move_speed = player.velocity.length()
	else:
		transitioned.emit(self, "idle")


func input_management(delta: float) -> void:
	if Input.is_action_pressed("crouch"):
		player.posture_controller.request_crouch()
	else:
		player.posture_controller.request_stand()

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		print('salto')
		#transition_to("jump")
	elif not player.is_on_floor():
		print('air')
		#transition_to("air")
