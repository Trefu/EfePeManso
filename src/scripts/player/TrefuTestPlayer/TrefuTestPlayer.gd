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

# Variables exportadas para ajuste fácil
@export_category("Smoothing Settings")
@export var movement_acceleration: float = 20.0
@export var movement_deceleration: float = 15.0
@export var air_control: float = 8.0
@export var camera_smooth_speed: float = 10.0
@export var camera_bob_speed: float = 15.0
@export var camera_bob_intensity: float = 0.05
@export var tilt_amount: float = 5.0
@export var tilt_speed: float = 8.0
@export var fov_transition_speed: float = 8.0

# Variables de estado
var current_weapon = null
const MOUSE_SENSITIVITY: float = 0.002
var base_fov: float = 75.0
var target_fov: float = 75.0
var is_sprinting: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_weapon = $Head/WeaponHolder/Weapon
	base_fov = camera.fov
	target_fov = base_fov

func _physics_process(delta: float) -> void:
	# Aplicar suavizado de movimiento
	apply_movement_smoothing(delta)
	
	# Aplicar efectos de cámara
	apply_camera_effects(delta)
	
	# Aplicar FOV smoothing
	camera.fov = lerp(camera.fov, target_fov, delta * fov_transition_speed)
	
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
	# Obtener input del jugador
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	
	# Calcular dirección objetivo
	var wish_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Smooth de dirección (para transiciones suaves)
	current_smooth_direction = lerp(current_smooth_direction, wish_dir, delta * movement_acceleration)
	
	# Obtener estado actual para ajustar parámetros
	var state_name = state_machine.get_current_state_name() if state_machine else ""
	var is_grounded = is_on_floor()
	
	# Determinar velocidad objetivo según estado
	var target_speed: float = 0.0
	if input_dir.length() > 0:
		target_speed = 10.0  # MOVEMENT_SPEED
		if Input.is_action_pressed("dash"):
			target_speed = 15.0
			target_fov = base_fov + 5.0
			is_sprinting = true
		else:
			target_fov = base_fov
			is_sprinting = false
	
	# Calcular velocidad objetivo
	target_velocity = current_smooth_direction * target_speed
	
	# Aplicar suavizado según estado
	if is_grounded:
		# En suelo: aceleración/desaceleración suave
		smoothed_velocity.x = lerp(smoothed_velocity.x, target_velocity.x, delta * movement_acceleration)
		smoothed_velocity.z = lerp(smoothed_velocity.z, target_velocity.z, delta * movement_acceleration)
	else:
		# En aire: menos control
		smoothed_velocity.x = lerp(smoothed_velocity.x, target_velocity.x, delta * air_control)
		smoothed_velocity.z = lerp(smoothed_velocity.z, target_velocity.z, delta * air_control)
	
	# Aplicar velocidad suavizada al jugador
	velocity.x = smoothed_velocity.x
	velocity.z = smoothed_velocity.z

func apply_camera_effects(delta: float) -> void:
	var is_moving = velocity.length() > 0.5 and is_on_floor()
	
	# Bob de cámara (balanceo al caminar)
	if is_moving:
		camera_bob_progress += delta * camera_bob_speed * (1.5 if is_sprinting else 1.0)
		var bob_offset = sin(camera_bob_progress * 2.0) * camera_bob_intensity
		var bob_tilt = sin(camera_bob_progress) * camera_bob_intensity * 0.5
		
		# Aplicar bob con lerp para suavizar
		head.position.y = lerp(head.position.y, bob_offset, delta * camera_smooth_speed)
		
		# Inclinar cámara al girar
		var move_input := Input.get_vector("left", "right", "forward", "backward")
		tilt_angle = lerp(tilt_angle, -move_input.x * tilt_amount, delta * tilt_speed)
		head.rotation.z = deg_to_rad(tilt_angle) + bob_tilt
	else:
		# Volver a posición neutral
		camera_bob_progress = 0.0
		head.position.y = lerp(head.position.y, 0.0, delta * camera_smooth_speed)
		tilt_angle = lerp(tilt_angle, 0.0, delta * tilt_speed)
		head.rotation.z = lerp(head.rotation.z, 0.0, delta * tilt_speed)

# Métodos públicos para que los estados los usen
func set_target_fov(fov: float) -> void:
	target_fov = fov

func set_camera_bob_intensity(intensity: float) -> void:
	camera_bob_intensity = intensity

func get_smoothed_velocity() -> Vector3:
	return smoothed_velocity

func reset_camera_effects() -> void:
	# Resetear efectos de cámara suavemente
	var tween = create_tween()
	tween.tween_property(head, "position:y", 0.0, 0.2)
	tween.parallel().tween_property(head, "rotation:z", 0.0, 0.2)
	tween.parallel().tween_property(camera, "fov", base_fov, 0.3)
