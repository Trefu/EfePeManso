extends State

class_name JumpState

var state_name : String = "jump"

func enter() -> void:
	verifications()
	jump()
	
func verifications() -> void:
	if player.floor_snap_length != 0.0:  player.floor_snap_length = 0.0
	if player.jump_cooldown < player.jump_cooldown_ref: player.jump_cooldown = player.jump_cooldown_ref
	if player.hit_ground_cooldown != player.hit_ground_cooldown_ref: player.hit_ground_cooldown = player.hit_ground_cooldown_ref
	
func physics_update(delta : float) -> void:
	applies(delta)
	player.apply_gravity(delta)
	input_management()
	check_if_floor()
	move(delta)
	
func applies(delta : float) -> void:
	if !player.is_on_floor(): 
		if player.jump_cooldown > 0.0: player.jump_cooldown -= delta
		if player.coyote_jump_cooldown > 0.0: player.coyote_jump_cooldown -= delta
		
func input_management() -> void:
	if Input.is_action_just_pressed("jump"):
		if player.jump_cooldown < 0.0:
			jump()
		
	if Input.is_action_just_pressed("dash"):
		if player.time_bef_can_dash_again <= 0.0 and player.dashs_allowed > 0:
			print("dash")
		
func check_if_floor():
	if !player.is_on_floor() and player.velocity.y < 0.0:
		transitioned.emit(self, "in_air")
		
	if player.is_on_floor():
		if player.move_direction: transitioned.emit(self, "ground")
		else: transitioned.emit(self, "IdleState")
		
	#lose all velocity and accumulated speed if play char hit a wall
	if player.is_on_wall():
		if player.lose_dms_if_hit_wall_in_air:
			player.desired_move_speed = 0.0
		if player.lose_vel_if_hit_wall_in_air:
			player.velocity.x = 0.0
			player.velocity.z = 0.0
		
func move(delta : float) -> void:
	player.input_direction = Input.get_vector("left", "right", "forward", "backward")
	player.move_direction = (player.head.global_basis * Vector3(player.input_direction.x, 0.0, player.input_direction.y)).normalized()
	player.desired_move_speed = clamp(player.desired_move_speed, 0.0, player.max_desired_move_speed)
	
	if !player.is_on_floor():
		if player.move_direction:
			if player.desired_move_speed < player.max_desired_move_speed: player.desired_move_speed += player.bunny_hop_dms_incre * delta
			#use of curves here to have a better in air movement
			var contrd_des_move_speed : float = player.desired_move_speed_curve.sample(player.desired_move_speed)
			var contrd_inair_move_speed : float = player.in_air_move_speed_curve.sample(player.desired_move_speed) * player.in_air_input_multiplier
			player.velocity.x = lerp(player.velocity.x, player.move_direction.x * contrd_des_move_speed, contrd_inair_move_speed * delta)
			player.velocity.z = lerp(player.velocity.z, player.move_direction.z * contrd_des_move_speed, contrd_inair_move_speed * delta)
			if player.velocity.length() > player.max_desired_move_speed:
				player.velocity = player.velocity.normalized() * player.max_desired_move_speed
		else:
			#accumulate desired speed for bunny hopping
			player.desired_move_speed = player.velocity.length()
			
func jump() -> void: 	
	var can_jump : bool = false
	
	#in air jump
	if !player.is_on_floor():
		if !player.coyote_jump_on and player.jumps_in_air_allowed > 0:
			player.jumps_in_air_allowed -= 1
			player.jump_cooldown = player.jump_cooldown_ref
			can_jump = true 
		if player.coyote_jump_on:
			player.jump_cooldown = player.jump_cooldown_ref
			player.coyote_jump_cooldown = -1.0 #so that the character cannot immediately make another coyote jump
			player.coyote_jump_on = false
			can_jump = true 
			
	#on floor jump
	if player.is_on_floor():
		player.jump_cooldown = player.jump_cooldown_ref
		can_jump = true 
		
	#jump buffering
	if player.buffered_jump:
		player.buffered_jump = false
		player.jumps_in_air_allowed = player.jumps_in_air_allowed_ref
		
	#apply jump
	if can_jump:
		player.velocity.y = player.jump_velocity
		can_jump = false
