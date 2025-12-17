extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var standing_collision_shape_3d: CollisionShape3D = $StandingCollisionShape3D
@onready var crouching_collision_shape_3d: CollisionShape3D = $CrouchingCollisionShape3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

var current_speed = 0.0
const RUNNING_SPEED = 7.0
const CROUCHING_SPEED = 4.0
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


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += gravity * delta * GRAVITY_MULTIPLIER
		coyote_time -= delta
	else:
		coyote_time = MAX_COYOTE_TIME
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and coyote_time > 0:
		velocity.y = JUMP_SPEED
		jump_count = 1
		coyote_time = 0
		print("Salto comun")
	elif Input.is_action_just_pressed("jump") and !is_on_floor() and jump_count < max_jumps:
		velocity.y = EXTRA_JUMP_SPEED
		jump_count += 1
		print("Salto extra")
	elif Input.is_action_pressed("crouch") and is_on_floor():
		current_speed = CROUCHING_SPEED
		standing_collision_shape_3d.disabled = true
		crouching_collision_shape_3d.disabled = false
		head.position.y = lerp(head.position.y, STANDING_HEAD_HEIGHT + CROUCH_DEPTH, delta * LERP_SPEED)
	elif !ray_cast_3d.is_colliding():
		current_speed = RUNNING_SPEED
		standing_collision_shape_3d.disabled = false
		crouching_collision_shape_3d.disabled = true
		head.position.y = lerp(head.position.y, STANDING_HEAD_HEIGHT, delta * LERP_SPEED)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * LERP_SPEED)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
#crear un handler de salto con coyote time y buffer

#func _on_coyote_timer_timeout() -> void:
	#coyote_time_active = false
