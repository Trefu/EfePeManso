extends State

class_name IdleState

var state_name : String = "idle"

	
func physics_update(delta : float):
	check_if_floor()
	
	applies(delta)
	
	player.apply_gravity(delta)
	
	input_management()
	
	move(delta)
	
func check_if_floor():
	if !player.is_on_floor():
		print("air")
	if player.is_on_floor():
		#if player.jump_buff_on and player.jump_cooldown < 0.0: 
			#player.buffered_jump = true
			#player.jump_buff_on = false
			#print("salto")
			pass
			
func applies(delta : float):
	if player.hit_ground_cooldown > 0.0: player.hit_ground_cooldown -= delta
	
	#i don't know why, but if i put this line in verifications, it broke the jump cooldown, because he constantly stay at -1.0
	#if player.jump_cooldown > 0.0: player.jump_cooldown = -1.0
	
func input_management():
	if Input.is_action_just_pressed('jump'):
		if player.jump_cooldown < 0.0:
			print("salto")
			
	if Input.is_action_just_pressed('crouch'):
		print("crouch")
		
	if Input.is_action_just_pressed('dash'):
		print("dash")
		
func move(delta : float):
	player.input_direction = Input.get_vector('left', 'right', 'forward', 'backward')
	player.move_direction = (player.head.global_basis * Vector3(player.input_direction.x, 0.0, player.input_direction.y)).normalized()
	player.desired_move_speed = clamp(player.desired_move_speed, 0.0, player.max_desired_move_speed)
	
	if player.move_direction and player.is_on_floor():
		transitioned.emit(self, 'ground')
	else:
		#apply smooth stop 
		player.velocity.x = lerp(player.velocity.x, 0.0, player.move_deceleration * delta)
		player.velocity.z = lerp(player.velocity.z, 0.0, player.move_deceleration * delta)
		
		#cancel desired move speed accumulation if the timer has elapsed (is up)
		if player.hit_ground_cooldown <= 0: player.desired_move_speed = player.velocity.length()
