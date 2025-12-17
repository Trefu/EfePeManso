extends CharacterBody3D

@onready var camera: Camera3D = $Head/HeadCamera
@onready var head: Node3D = $Head
@onready var weapon_holder: Node3D = $Head/WeaponHolder
@onready var current_weapon = $Head/WeaponHolder/Weapon

const MOUSE_SENSITIVITY: float = 0.002

const MOVEMENT_SPEED: float = 10.0
const MOVEMENT_LERP_SPEED: float = 20.0

const GRAVITY_MULTIPLIER: float = 2.8
const JUMP_VELOCITY: float = 14.0

const COYOTE_TIME_MAX: float = 0.1
const JUMP_BUFFER_MAX: float = 0.1

const HEADBOB_SPEED: float = 13.0
const HEADBOB_AMOUNT: float = 0.07

var direction: Vector3 = Vector3.ZERO
var coyote_time: float = 0.0
var jump_buffer_time: float = 0.0
var air_jumps: int = 0
const MAX_AIR_JUMPS: int = 1
var last_jump_time: float = 0.0
const JUMP_COOLDOWN: float = 0.1
var headbob_time: float = 0.0
var headbob_intensity: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	var weapon = $Head/WeaponHolder/PistolBlaster

	if is_on_floor():
		coyote_time = COYOTE_TIME_MAX
		air_jumps = 0
	else:
		coyote_time -= delta
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_time = JUMP_BUFFER_MAX
	else:
		jump_buffer_time -= delta
	
	handle_jump()
	handle_movement(delta)
	handle_gravity(delta)
	handle_headbob(delta)
	
	move_and_slide()

func handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * MOVEMENT_LERP_SPEED)
	
	if direction:
		velocity.x = direction.x * MOVEMENT_SPEED
		velocity.z = direction.z * MOVEMENT_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, MOVEMENT_SPEED)
		velocity.z = move_toward(velocity.z, 0, MOVEMENT_SPEED)

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * GRAVITY_MULTIPLIER * delta

func handle_jump() -> void:
	if jump_buffer_time > 0.0:
		if coyote_time > 0.0:
			velocity.y = JUMP_VELOCITY
			coyote_time = 0.0
			jump_buffer_time = 0.0
			last_jump_time = 0.0
		elif air_jumps < MAX_AIR_JUMPS and last_jump_time >= JUMP_COOLDOWN:
			velocity.y = JUMP_VELOCITY
			air_jumps += 1
			jump_buffer_time = 0.0
			last_jump_time = 0.0
	
	last_jump_time += get_physics_process_delta_time()

func handle_headbob(delta: float) -> void:
	if is_on_floor() and direction.length() > 0.1:
		headbob_time += delta * HEADBOB_SPEED
		headbob_intensity = lerp(headbob_intensity, HEADBOB_AMOUNT, delta * 10.0)
	else:
		headbob_intensity = lerp(headbob_intensity, 0.0, delta * 10.0)
	
	var headbob_offset = Vector3.ZERO
	headbob_offset.y = sin(headbob_time * 2.0) * headbob_intensity
	headbob_offset.x = cos(headbob_time) * headbob_intensity * 0.5
	
	camera.transform.origin = headbob_offset

func _process(_delta):
	if Input.is_action_pressed("fire") and current_weapon:
		current_weapon.fire()

func _input(event):
	if event.is_action_pressed("reload") and current_weapon:
		current_weapon.reload()
	
	if event.is_action_pressed("toggle_mouse_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		var rotation_change = -event.relative.y * MOUSE_SENSITIVITY
		head.rotation.x = clamp(head.rotation.x + rotation_change, -PI/2, PI/2)
