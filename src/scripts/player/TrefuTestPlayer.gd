extends CharacterBody3D

#region Components
@onready var mouse_component: MouseComponent = $MouseComponent
@onready var dash_component: DashComponent = $DashComponent
#endregion

#region Configuration
const MOVEMENT_SPEED: float = 10.0
const MOVEMENT_LERP_SPEED: float = 20.0
const GRAVITY_MULTIPLIER: float = 2.8
const JUMP_VELOCITY: float = 14.0
const COYOTE_TIME_MAX: float = 0.1
const JUMP_BUFFER_MAX: float = 0.1
#endregion

#region Movement & Physics
var direction: Vector3 = Vector3.ZERO
var coyote_time: float = 0.0
var jump_buffer_time: float = 0.0
#endregion

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#region Physics Processing
func _physics_process(delta: float) -> void:

	if is_on_floor():
		coyote_time = COYOTE_TIME_MAX
	else:
		coyote_time -= delta
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_time = JUMP_BUFFER_MAX
	else:
		jump_buffer_time -= delta
	

	handle_gravity(delta)
	
	dash_component.handle_dash(delta)
	
	if not dash_component.isDashing:
		handle_movement(delta)
	
	handle_jump()
	
	move_and_slide()
#endregion

#region Movement
func handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * MOVEMENT_LERP_SPEED)
	
	if direction:
		velocity.x = direction.x * MOVEMENT_SPEED
		velocity.z = direction.z * MOVEMENT_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, MOVEMENT_SPEED)
		velocity.z = move_toward(velocity.z, 0, MOVEMENT_SPEED)
#endregion

#region Gravity
func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * GRAVITY_MULTIPLIER * delta
#endregion

#region Jump (with Coyote Time & Jump Buffer)
func handle_jump() -> void:
	if jump_buffer_time > 0.0 and coyote_time > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_time = 0.0  
		coyote_time = 0.0  
#endregion
