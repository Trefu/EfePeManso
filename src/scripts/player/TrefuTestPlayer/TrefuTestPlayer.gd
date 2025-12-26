extends CharacterBody3D

@onready var camera: Camera3D = $Head/HeadCamera
@onready var head: Node3D = $Head
@onready var weapon_holder: Node3D = $Head/WeaponHolder
@onready var state_machine: StateMachine = $StateMachine

# Sistema de movimiento suavizado
var target_velocity: Vector3 = Vector3.ZERO
var current_smooth_direction: Vector3 = Vector3.ZERO
var smoothed_velocity: Vector3 = Vector3.ZERO
var camera_bob_progress: float = 0.0
var tilt_angle: float = 0.0
var base_head_y: float = 0.0

# Variables exportadas para ajuste fácil
@export_category("Smoothing Settings")
@export var movement_acceleration: float = 20.0
@export var movement_deceleration: float = 45.0
@export var air_control: float = 8.0
@export var camera_smooth_speed: float = 10.0
@export var camera_bob_speed: float = 15.0
@export var camera_bob_intensity: float = 0.04
@export var tilt_amount: float = 5.0
@export var tilt_speed: float = 8.0
@export var fov_transition_speed: float = 8.0

var current_weapon = null
const MOUSE_SENSITIVITY: float = 0.002
var base_fov: float = 75.0
var target_fov: float = 75.0
var is_in_air: bool = false
var was_on_floor: bool = true
const MOVEMENT_SPEED: float = 15.0


# ===== SISTEMA DE SALTOS =====
@export_category("Jump Settings")
@export var jump_velocity: float = 14.0
@export var gravity_multiplier: float = 2.8
@export var max_air_jumps: int = 1
@export var coyote_time_max: float = 0.15

var air_jumps_used: int = 0
var coyote_time: float = 0.0
var gravity: float = 9.8

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_weapon = $Head/WeaponHolder/Weapon
	base_fov = camera.fov
	target_fov = base_fov
	base_head_y = head.position.y

func _physics_process(delta: float) -> void:
	update_air_state()
	update_coyote_time(delta)
	apply_movement_smoothing(delta)
	apply_camera_effects(delta)
	
	camera.fov = lerp(camera.fov, target_fov, delta * fov_transition_speed)

	if not is_on_floor():
		velocity.y -= gravity * gravity_multiplier * delta
	
	move_and_slide()

func _process(_delta):
	if Input.is_action_pressed("fire") and current_weapon:
		current_weapon.fire()

func _input(event):
	if event.is_action_pressed("reload") and current_weapon:
		current_weapon.reload()
	
	if event.is_action_pressed("esc"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		var rotation_change = -event.relative.y * MOUSE_SENSITIVITY
		head.rotation.x = clamp(head.rotation.x + rotation_change, -PI/2, PI/2)

# ===== SISTEMA DE SMOOTHING =====

func apply_movement_smoothing(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var has_input := input_dir.length() > 0.01

	# Dirección deseada
	var wish_dir := Vector3.ZERO
	if has_input:
		wish_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Elegir control según estado
	var accel := movement_acceleration if is_on_floor() else air_control
	var decel := movement_deceleration

	# ===== ACELERACIÓN =====
	if has_input:
		current_smooth_direction = current_smooth_direction.lerp(wish_dir, accel * delta)
		target_velocity = current_smooth_direction * MOVEMENT_SPEED

		smoothed_velocity.x = lerp(smoothed_velocity.x, target_velocity.x, accel * delta)
		smoothed_velocity.z = lerp(smoothed_velocity.z, target_velocity.z, accel * delta)

	# ===== DESACELERACIÓN (FRICCIÓN) =====
	else:
		smoothed_velocity.x = move_toward(smoothed_velocity.x, 0.0, decel * delta)
		smoothed_velocity.z = move_toward(smoothed_velocity.z, 0.0, decel * delta)

	# Aplicar al cuerpo
	velocity.x = smoothed_velocity.x
	velocity.z = smoothed_velocity.z


func apply_camera_effects(delta: float) -> void:
	var is_moving = velocity.length() > 0.5 and is_on_floor()
	
	if is_moving:
		camera_bob_progress += delta * camera_bob_speed * (1.0)
		var bob_offset = sin(camera_bob_progress * 2.0) * camera_bob_intensity
		var bob_tilt = sin(camera_bob_progress) * camera_bob_intensity * 0.5
		
		head.position.y = lerp(
			head.position.y,
			base_head_y + bob_offset,
			delta * camera_smooth_speed
		)
		
		var move_input := Input.get_vector("left", "right", "forward", "backward")
		tilt_angle = lerp(tilt_angle, -move_input.x * tilt_amount, delta * tilt_speed)
		head.rotation.z = deg_to_rad(tilt_angle) + bob_tilt
	else:
		camera_bob_progress = 0.0
		head.position.y = lerp(
			head.position.y,
			base_head_y,
			delta * camera_smooth_speed
		)
		tilt_angle = lerp(tilt_angle, 0.0, delta * tilt_speed)
		head.rotation.z = lerp(head.rotation.z, 0.0, delta * tilt_speed)

# ===== MÉTODOS PARA SALTOS (usados por los estados) =====

func update_coyote_time(delta: float) -> void:
	if not is_on_floor() and coyote_time > 0:
		coyote_time -= delta

func activate_coyote_time() -> void:
	coyote_time = coyote_time_max


func reset_air_jumps() -> void:
	air_jumps_used = 0

func can_air_jump() -> bool:
	return air_jumps_used < max_air_jumps

func perform_ground_jump() -> bool:
	if is_on_floor():
		velocity.y = jump_velocity
		air_jumps_used = 0 
		is_in_air = true
		was_on_floor = false

		return true
	return false

func perform_air_jump() -> bool:
	if can_air_jump():
		velocity.y = jump_velocity
		air_jumps_used += 1
		is_in_air = true
		return true
	return false

func update_air_state() -> void:
	var currently_on_floor = is_on_floor()
	
	if not currently_on_floor:
		is_in_air = true
		if was_on_floor and velocity.y >= 0:
			air_jumps_used = 0 
			
	elif currently_on_floor and not was_on_floor:
		is_in_air = false
	
	was_on_floor = currently_on_floor

func perform_coyote_jump() -> bool:
	if coyote_time > 0:
		velocity.y = jump_velocity
		coyote_time = 0  
		return true
	return false

func handle_jump_input() -> bool:
	# 1. Si está en el suelo: salto normal
	if is_on_floor():
		return perform_ground_jump()
	
	# 2. Si puede hacer air jump: double jump
	elif can_air_jump():
		return perform_air_jump()
	
	# 3. Si tiene coyote time: coyote jump
	elif coyote_time > 0:
		return perform_coyote_jump()
	
	return false

# ===== MÉTODOS PÚBLICOS PARA ESTADOS =====

func set_target_fov(fov: float) -> void:
	target_fov = fov

func set_camera_bob_intensity(intensity: float) -> void:
	camera_bob_intensity = intensity

func get_smoothed_velocity() -> Vector3:
	return smoothed_velocity

func reset_camera_effects() -> void:
	var tween = create_tween()
	tween.tween_property(head, "position:y", base_head_y, 0.2)
	tween.parallel().tween_property(head, "rotation:z", 0.0, 0.2)
	tween.parallel().tween_property(camera, "fov", base_fov, 0.3)

func apply_landing_damping(damping: float) -> void:
	smoothed_velocity.x *= damping
	smoothed_velocity.z *= damping
	target_velocity.x *= damping
	target_velocity.z *= damping
	print("Landing damping applied: ", damping)

func is_in_air_state() -> bool:
	return is_in_air
