extends CharacterBody3D

#region Components
@onready var mouse_component: MouseComponent = $MouseComponent
@onready var dash_component: DashComponent = $DashComponent
@onready var camera: Camera3D = $head/Camera3D
#endregion

#region Configuration
# Movement Settings
const MOVEMENT_SPEED: float = 10.0          # Horizontal movement speed in units/second
const MOVEMENT_LERP_SPEED: float = 20.0     # Smoothing factor for direction changes (higher = more responsive)

# Physics Settings
const GRAVITY_MULTIPLIER: float = 2.8       # Gravity strength multiplier (default Godot gravity = 9.8)
const JUMP_VELOCITY: float = 14.0           # Initial upward velocity when jumping

# Jump Mechanics Settings
const COYOTE_TIME_MAX: float = 0.1          # Time window after leaving ground where jump is still allowed (seconds)
const JUMP_BUFFER_MAX: float = 0.1          # Time window before landing where jump input is stored (seconds)

# Headbob Configuration
const HEADBOB_SPEED: float = 13.0           # Speed of head bobbing animation
const HEADBOB_AMOUNT: float = 0.05          # Maximum intensity of head bobbing movement
const HEADBOB_SPRINT_MULTIPLIER: float = 1.5 # Future: multiplier for sprint headbob intensity
#endregion

#region Movement & Physics Variables
var direction: Vector3 = Vector3.ZERO        # Current movement direction (normalized)

# Coyote Time Variables
var coyote_time: float = 0.0                 # Time remaining to jump after leaving ground

# Jump Buffer Variables
var jump_buffer_time: float = 0.0            # Time remaining to execute buffered jump

# Double Jump Variables
var air_jumps: int = 0                       # Number of air jumps performed
const MAX_AIR_JUMPS: int = 1                 # Maximum allowed air jumps
var last_jump_time: float = 0.0              # Time since last jump (for cooldown)
const JUMP_COOLDOWN: float = 0.1             # Minimum time between jumps (seconds)

# Headbob Variables
var headbob_time: float = 0.0                # Accumulated time for headbob animation
var headbob_intensity: float = 0.0           # Current intensity of headbob effect
#endregion

func _ready():
	# Capture mouse for FPS controls
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#region Physics Processing
# Main physics loop - called every physics frame (60 times per second by default)
func _physics_process(delta: float) -> void:
	# Update coyote time: allows jumping briefly after leaving ground
	if is_on_floor():
		coyote_time = COYOTE_TIME_MAX
		# Reset air jumps when landing
		air_jumps = 0
	else:
		coyote_time -= delta
	
	# Update jump buffer: stores jump input briefly before landing
	if Input.is_action_just_pressed("jump"):
		jump_buffer_time = JUMP_BUFFER_MAX
	else:
		jump_buffer_time -= delta
	
	# Process jump logic FIRST (before dash and gravity for proper priority)
	handle_jump()
	
	# Process dash mechanics
	dash_component.handle_dash(delta)
	
	# Process movement only if not dashing
	if not dash_component.isDashing:
		handle_movement(delta)
		# Apply gravity only if not dashing
		handle_gravity(delta)
		# Apply headbob effect for realistic camera movement
		handle_headbob(delta)
	
	# Execute the actual movement and collision detection
	move_and_slide()
#endregion

#region Movement Handler
# Handles player horizontal movement based on input
func handle_movement(delta: float) -> void:
	# Get input from keyboard (WASD or arrow keys)
	# Input.get_vector returns a 2D vector with values between -1 and 1
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	
	# Convert 2D input to 3D world space and smooth the direction change
	# transform.basis converts local coordinates to world coordinates
	# lerp provides smooth direction transitions
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * MOVEMENT_LERP_SPEED)
	
	# Apply movement speed to velocity if there's input
	if direction:
		velocity.x = direction.x * MOVEMENT_SPEED
		velocity.z = direction.z * MOVEMENT_SPEED
	else:
		# Gradually stop movement when no input (friction simulation)
		velocity.x = move_toward(velocity.x, 0, MOVEMENT_SPEED)
		velocity.z = move_toward(velocity.z, 0, MOVEMENT_SPEED)
#endregion

#region Gravity Handler
# Applies gravity to the player when not on ground and not dashing
func handle_gravity(delta: float) -> void:
	# Only apply gravity when in air and not dashing
	# get_gravity() returns the project's gravity vector (usually (0, -9.8, 0))
	if not is_on_floor() and not dash_component.isDashing:
		velocity += get_gravity() * GRAVITY_MULTIPLIER * delta
#endregion

#region Jump Handler (with Coyote Time & Jump Buffer & Double Jump)
# Handles all jump mechanics including coyote time, jump buffering, and double jumps
func handle_jump() -> void:
	# Check if we have a buffered jump input
	if jump_buffer_time > 0.0:
		if coyote_time > 0.0:
			# Normal jump from ground (coyote time allows jumping slightly after leaving ground)
			velocity.y = JUMP_VELOCITY
			coyote_time = 0.0        # Reset coyote time after jumping
			jump_buffer_time = 0.0   # Clear the buffered jump
			last_jump_time = 0.0     # Reset jump cooldown timer
		elif air_jumps < MAX_AIR_JUMPS and last_jump_time >= JUMP_COOLDOWN:
			# Double jump in air (only if we haven't used all air jumps and cooldown has passed)
			velocity.y = JUMP_VELOCITY
			air_jumps += 1           # Increment air jump counter
			jump_buffer_time = 0.0   # Clear the buffered jump
			last_jump_time = 0.0     # Reset jump cooldown timer
	
	# Always increment the jump cooldown timer
	last_jump_time += get_physics_process_delta_time()
#endregion

#region Headbob System
# Creates realistic camera movement when walking to simulate head bobbing
func handle_headbob(delta: float) -> void:
	# Only apply headbob when on ground and moving
	if is_on_floor() and direction.length() > 0.1:
		# Increment headbob animation time
		headbob_time += delta * HEADBOB_SPEED
		# Smoothly transition to full intensity when moving
		headbob_intensity = lerp(headbob_intensity, HEADBOB_AMOUNT, delta * 10.0)
	else:
		# Smoothly reduce intensity when stopping or in air
		headbob_intensity = lerp(headbob_intensity, 0.0, delta * 10.0)
	
	# Calculate headbob offset using sine/cosine waves
	var headbob_offset = Vector3.ZERO
	# Vertical movement (up/down) - uses sine for smooth up-down motion
	headbob_offset.y = sin(headbob_time * 2.0) * headbob_intensity
	# Horizontal movement (side-to-side) - uses cosine with reduced intensity
	headbob_offset.x = cos(headbob_time) * headbob_intensity * 0.5
	
	# Apply the calculated offset to the camera's local position
	camera.transform.origin = headbob_offset
#endregion
