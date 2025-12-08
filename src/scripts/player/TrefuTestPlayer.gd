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
var air_jumps: int = 0
const MAX_AIR_JUMPS: int = 1
var last_jump_time: float = 0.0
const JUMP_COOLDOWN: float = 0.1  # 100ms entre saltos
#endregion

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#region Physics Processing
func _physics_process(delta: float) -> void:

	if is_on_floor():
		coyote_time = COYOTE_TIME_MAX
		air_jumps = 0
	else:
		coyote_time -= delta
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_time = JUMP_BUFFER_MAX
	else:
		jump_buffer_time -= delta
	

	# Procesar salto PRIMERO (antes de dash y gravedad)
	handle_jump()
	
	# Procesar dash
	dash_component.handle_dash(delta)
	
	# Procesar movimiento (solo si no está dasheando)
	if not dash_component.isDashing:
		handle_movement(delta)
		# Aplicar gravedad solo si no está dasheando
		handle_gravity(delta)
	
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
	if not is_on_floor() and not dash_component.isDashing:
		velocity += get_gravity() * GRAVITY_MULTIPLIER * delta
#endregion

#region Jump (with Coyote Time & Jump Buffer & Double Jump)
func handle_jump() -> void:
	if jump_buffer_time > 0.0:
		if coyote_time > 0.0:
			# Salto normal desde el suelo
			velocity.y = JUMP_VELOCITY
			coyote_time = 0.0
			jump_buffer_time = 0.0
			last_jump_time = 0.0
		elif air_jumps < MAX_AIR_JUMPS and last_jump_time >= JUMP_COOLDOWN:
			# Doble salto en el aire (con cooldown)
			velocity.y = JUMP_VELOCITY
			air_jumps += 1
			jump_buffer_time = 0.0
			last_jump_time = 0.0
	
	# Incrementar cooldown siempre
	last_jump_time += get_physics_process_delta_time()
#endregion
