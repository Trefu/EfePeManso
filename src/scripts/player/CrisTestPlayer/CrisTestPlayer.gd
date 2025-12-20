extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var standing_collision_shape_3d: CollisionShape3D = $StandingCollisionShape3D
@onready var crouching_collision_shape_3d: CollisionShape3D = $CrouchingCollisionShape3D
@onready var height_ray_cast_3d: RayCast3D = $HeightRayCast3D

var current_speed = 0.0
const RUNNING_SPEED = 7.0
const CROUCHING_SPEED = RUNNING_SPEED * 0.65
const DASHING_SPEED = RUNNING_SPEED * 10
const JUMP_SPEED = 10.0
const EXTRA_JUMP_SPEED = 7.5
const LERP_SPEED = 8.0

var direction := Vector3.ZERO
var last_movement_direction := Vector3.ZERO

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
const GRAVITY_MULTIPLIER: float = 20.0

var is_crouching = false
const CROUCH_DEPTH = -0.5
const STANDING_HEAD_HEIGHT = 1.5

var jump_count = 0
var max_jumps = 2

var coyote_time = 0.0
const MAX_COYOTE_TIME = 1.0

var dash_cooldown = 0.0
var dash_duration = 0.0
const MAX_DASH_COOLDOWN = 2.0
const MAX_DASH_DURATION = 0.5
var is_dashing = false
var dash_direction = Vector3.ZERO

var is_sliding = false

func _physics_process(delta: float) -> void:
	
	if coyote_time > 0.0 and !is_on_floor():
		coyote_time -= delta
	elif is_on_floor():
		jump_count = 0
		coyote_time = MAX_COYOTE_TIME
	
	# Add the gravity.
	if !is_on_floor() and !is_dashing:
		velocity += gravity * delta * GRAVITY_MULTIPLIER
	
	if dash_cooldown > 0.0:
		dash_cooldown -= delta
	else:
		dash_cooldown = 0.0
		dash_duration = MAX_DASH_DURATION
	
	if is_dashing:
		dash_duration -= delta
		if dash_duration <= 0.0:
			dash_duration = 0.0
			current_speed = RUNNING_SPEED
			is_dashing = false
			velocity.y = 0.0
		elif _can_crouch() and is_on_floor():
			is_sliding = true
			is_dashing = false
		else:
			move(dash_direction)
			return
	
	if is_sliding:
		crouch(delta)
		current_speed -= delta * 15
		if current_speed <= CROUCHING_SPEED and is_crouching:
			is_sliding = false
		elif !is_crouching:
			is_sliding = false
			stand(delta)
	
	if _can_jump():
		# Handle jump.
		velocity.y = JUMP_SPEED
		jump_count += 1
		coyote_time = 0
	
	elif _can_extra_jump():
		# Handle extra jumps.
		velocity.y = EXTRA_JUMP_SPEED
		jump_count += 1
	
	elif _can_crouch():
		# Handle crouch.
		crouch(delta)
	
	elif _can_dash():
		# Handle dash.
		calculate_dash_direction()
		dash()
	
	elif _can_stand():
		# Handle head collition.
		stand(delta)
		
	# Get the input direction and handle the movement/deceleration.
	direction = get_direction(delta)
	
	# Store movement direction for dash calculations
	if direction.length() > 0.1:
		last_movement_direction = Vector3(direction.x, 0, direction.z).normalized()
	
	move(direction)

func stand(delta: float) -> void:
	is_crouching = false
	current_speed = RUNNING_SPEED
	standing_collision_shape_3d.disabled = false
	crouching_collision_shape_3d.disabled = true
	head.position.y = lerp(head.position.y, STANDING_HEAD_HEIGHT, delta * LERP_SPEED)

func crouch(delta: float) -> void:
	is_crouching = true
	standing_collision_shape_3d.disabled = true
	crouching_collision_shape_3d.disabled = false
	head.position.y = lerp(head.position.y, STANDING_HEAD_HEIGHT + CROUCH_DEPTH, delta * LERP_SPEED)
	if !is_sliding and is_on_floor():
		current_speed = CROUCHING_SPEED

func calculate_dash_direction() -> void:
	var camera_forward = -camera_3d.global_transform.basis.z.normalized()
	var camera_flat_forward = Vector3(camera_forward.x, 0, camera_forward.z).normalized()
	
	# Verificar si se está moviendo en XZ
	var is_moving_xz = last_movement_direction.length() > 0.1 and _is_running()
	
	if is_on_floor():
		if is_moving_xz:
			# Caso 1: Piso + movimiento
			dash_direction = last_movement_direction
		else:
			# Caso 2: Piso + no movimiento
			dash_direction = camera_flat_forward
	else:
		if is_moving_xz:
			# Caso 4: No piso + movimiento
			# Mantener dirección horizontal del movimiento
			var horizontal_dir = last_movement_direction
			
			# Usar componente vertical de la cámara
			var vertical_component = camera_forward.y
			
			if Input.is_action_pressed("backward"):
				# Invertir componente vertical cuando se presiona backward
				vertical_component = -vertical_component
			
			# Combinar dirección horizontal del movimiento con componente vertical de la cámara
			dash_direction = Vector3(horizontal_dir.x, vertical_component, horizontal_dir.z).normalized()
		else:
			# Caso 3: No piso + no movimiento
			dash_direction = camera_forward.normalized()
	
	# Asegurar que el dash tenga velocidad constante
	dash_direction = dash_direction.normalized()

func dash() -> void:
	is_dashing = true
	dash_cooldown = MAX_DASH_COOLDOWN
	dash_duration = MAX_DASH_DURATION
	current_speed = DASHING_SPEED

func get_direction(delta: float) -> Vector3:
	if !is_dashing:
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * LERP_SPEED)
	return direction
	
func move(movement_direction: Vector3) -> void:
	if is_dashing:
		# Durante el dash, usar velocidad completa en la dirección calculada
		velocity = dash_direction * DASHING_SPEED
	elif movement_direction:
		velocity.x = movement_direction.x * current_speed
		velocity.z = movement_direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()

func _can_dash() -> bool:
	return Input.is_action_just_pressed("dash") and dash_cooldown == 0.0
	
func _can_crouch() -> bool:
	return Input.is_action_pressed("crouch") and !is_sliding
	
func _can_jump() -> bool:
	return Input.is_action_just_pressed("jump") and coyote_time > 0
	
func _can_extra_jump() -> bool:
	return Input.is_action_just_pressed("jump") and !is_on_floor() and jump_count < max_jumps

func _can_stand() -> bool:
	return !height_ray_cast_3d.is_colliding() and !is_sliding

func _is_running() -> bool:
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	return !is_crouching and horizontal_speed >= RUNNING_SPEED * 0.8
