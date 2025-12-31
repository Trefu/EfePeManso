extends State

class_name InairState

var state_name : String = "in_air"

func enter() -> void:
	verifications()
	
func verifications() -> void:
	if player.floor_snap_length != 0.0:  player.floor_snap_length = 0.0
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
		if player.floor_check.is_colliding() and player.last_frame_position.y > player.position.y and player.jumps_in_air_allowed <= 0: player.jump_buff_on = true
		#check if can coyote jump
		if player.was_on_floor and player.coyote_jump_cooldown > 0.0 and player.last_frame_position.y > player.position.y and player.jump_cooldown < 0.0:
			player.coyote_jump_on = true
			transitioned.emit(self, "jump")
		if player.jump_cooldown < 0.0:
			transitioned.emit(self, "jump")
		
	if Input.is_action_just_pressed("dash"):
		if player.time_bef_can_dash_again <= 0.0 and player.dashs_allowed > 0:
			#transitioned.emit(self, "dash")
			print("dash desde in air")
		
	if Input.is_action_just_pressed("crouch"):
		if player.slide_floor_check.is_colliding() and player.last_frame_position.y > player.position.y and  player.time_bef_can_slide_again <= 0.0:
			#player.slide_buff_on = true
			print("slide desde in air")		
			
func check_if_floor() -> void:
	if player.is_on_floor():
		if player.jump_buff_on: 
			player.buffered_jump = true
			player.jump_buff_on = false
			transitioned.emit(self, "jump")
		#if player.slide_buff_on:
			#player.slide_buff_on = false
			#transitioned.emit(self, "slide") 
			print("slide desde in air check if floor")
		else:
			transitioned.emit(self, "ground")
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
			var adjusted_desired_speed : float = player.desired_move_speed_curve.sample(player.desired_move_speed)
			var adjusted_air_control_speed : float = player.in_air_move_speed_curve.sample(player.desired_move_speed) * player.in_air_input_multiplier
			
			player.velocity.x = lerp(player.velocity.x, player.move_direction.x * adjusted_desired_speed, adjusted_air_control_speed * delta)
			player.velocity.z = lerp(player.velocity.z, player.move_direction.z * adjusted_desired_speed, adjusted_air_control_speed * delta)
		
		if !player.move_direction and player.has_dashed:
			#if player dash, and drop input direction key, need to reset velocity to her pre dash self, to ensure that play char won't keep dash velocity after transitioning to inair state
			player.has_dashed = false
			var velocity_tween : Tween = create_tween()
			velocity_tween.tween_method(func(v): player.velocity = v, player.velocity, Vector3(player.velocity_pre_dash.x, 0.0, player.velocity_pre_dash.z), 0.12)
			player.velocity_pre_dash = Vector3.ZERO
			velocity_tween.finished.connect(Callable(velocity_tween, "kill"))
			
			
