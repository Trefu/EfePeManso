extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var standing_collision_shape_3d: CollisionShape3D = $StandingCollisionShape3D
@onready var crouching_collision_shape_3d: CollisionShape3D = $CrouchingCollisionShape3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

var current_speed = 0.0
const RUNNING_SPEED = 7.0
const CROUCHING_SPEED = RUNNING_SPEED * 0.65
const DASHING_SPEED = RUNNING_SPEED * 10
const JUMP_SPEED = 10.0
const EXTRA_JUMP_SPEED = 7.5
const LERP_SPEED = 8.0

var direction := Vector3.ZERO

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
const GRAVITY_MULTIPLIER: float = 20.0

const CROUCH_DEPTH = -0.5
const STANDING_HEAD_HEIGHT = 1.5

var jump_count = 0
var max_jumps = 2

var coyote_time = 0.0
const MAX_COYOTE_TIME = 1.0

var dash_cooldown = 0.0
var dash_duration = 0.0
const MAX_DASH_COOLDOWN = 2.0
const MAX_DASH_DURATION = 0.25
var is_dashing = false
var dash_direction = Vector3.ZERO  # Nueva variable para guardar dirección del dash

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
			velocity.y = get_direction(delta).y * current_speed
		else:
			velocity.x = dash_direction.x * DASHING_SPEED
			velocity.z = dash_direction.z * DASHING_SPEED
			if velocity.y != 0.0:
				velocity.y = dash_direction.y * DASHING_SPEED
			move_and_slide()
			return
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and coyote_time > 0:
		velocity.y = JUMP_SPEED
		jump_count += 1
		coyote_time = 0
	elif Input.is_action_just_pressed("jump") and !is_on_floor() and jump_count < max_jumps:
		velocity.y = EXTRA_JUMP_SPEED
		jump_count += 1
	elif Input.is_action_pressed("crouch") and is_on_floor():
		current_speed = CROUCHING_SPEED
		standing_collision_shape_3d.disabled = true
		crouching_collision_shape_3d.disabled = false
		head.position.y = lerp(head.position.y, STANDING_HEAD_HEIGHT + CROUCH_DEPTH, delta * LERP_SPEED)
	elif _can_dash():
		direction = get_direction(delta)
		if direction:
			is_dashing = true
			dash_cooldown = MAX_DASH_COOLDOWN
			dash_duration = MAX_DASH_DURATION
			current_speed = DASHING_SPEED
			dash_direction = Vector3(direction.x, -camera_3d.global_transform.basis.z.y, direction.z).normalized()
			return
	elif !ray_cast_3d.is_colliding():
		current_speed = RUNNING_SPEED
		standing_collision_shape_3d.disabled = false
		crouching_collision_shape_3d.disabled = true
		head.position.y = lerp(head.position.y, STANDING_HEAD_HEIGHT, delta * LERP_SPEED)
		
	# Get the input direction and handle the movement/deceleration.
	direction = get_direction(delta)
	move(direction)

func get_direction(delta: float) -> Vector3:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * LERP_SPEED)
	return direction
	
func move(movement_direction: Vector3) -> void:
	if movement_direction:
		velocity.x = movement_direction.x * current_speed
		velocity.z = movement_direction.z * current_speed
	elif !movement_direction:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	move_and_slide()

func _can_dash() -> bool:
	return Input.is_action_just_pressed("dash") and dash_cooldown == 0.0
