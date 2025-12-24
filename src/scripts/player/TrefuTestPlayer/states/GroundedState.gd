extends State

const MOVEMENT_SPEED: float = 10.0
const SPRINT_SPEED: float = 15.0
const LANDING_DAMPING: float = 0.7
const MIN_VELOCITY_FOR_LANDING_EFFECT: float = 5.0

var is_landing: bool = false
var landing_timer: float = 0.0
var landing_effect_duration: float = 0.3
var current_move_speed: float = MOVEMENT_SPEED

func enter() -> void:
	print("Entered GroundedState")
	
	is_landing = false
	
	var prev_state = state_machine.get_current_state_name() if state_machine else ""
	var was_in_air = prev_state in ["Jumping", "Falling"]
	
	if was_in_air and player:
		var vertical_velocity = abs(player.velocity.y)
		
		if vertical_velocity > MIN_VELOCITY_FOR_LANDING_EFFECT:
			print("Hard landing detected! Velocity: ", vertical_velocity)
			
			# Aplicar damping al smoothed_velocity del player
			if player.has_method("get_smoothed_velocity"):
				var smoothed_vel = player.get_smoothed_velocity()
				player.smoothed_velocity.x *= LANDING_DAMPING
				player.smoothed_velocity.z *= LANDING_DAMPING
			
			landing_timer = landing_effect_duration
			is_landing = true
		else:
			landing_timer = 0.0
			is_landing = false
	else:
		landing_timer = 0.0
		is_landing = false
	
	# Configurar player para estado grounded
	if player:
		player.target_fov = player.base_fov
		player.camera_bob_intensity = 0.05  # Intensidad normal

func physics_update(delta: float) -> void:
	if not player:
		return
	
	# Actualizar temporizador de aterrizaje
	if landing_timer > 0:
		landing_timer -= delta
		if landing_timer <= 0:
			is_landing = false
			landing_timer = 0.0
	
	# Determinar velocidad según sprint
	if Input.is_action_pressed("dash") and not is_landing:
		current_move_speed = SPRINT_SPEED
		player.target_fov = player.base_fov + 5.0
		player.camera_bob_intensity = 0.08  # Más intenso al sprint
	else:
		current_move_speed = MOVEMENT_SPEED
		player.target_fov = player.base_fov
		player.camera_bob_intensity = 0.05
	
	# **CRÍTICO: No tocar velocity.x/z directamente!**
	# El Player maneja el smoothing en apply_movement_smoothing()
	# Solo actualizamos target_velocity si estamos en landing damping
	if is_landing:
		# Reducir target_velocity durante landing
		player.target_velocity = player.target_velocity * LANDING_DAMPING
	
	# Check for state transitions
	if Input.is_action_just_pressed("jump") and not is_landing:
		print("Jump pressed in GroundedState")
		
		# Asegurar que velocity.y esté limpia antes del salto
		player.velocity.y = 0
		
		transition_to("Jumping")
	elif not player.is_on_floor() and not is_landing:
		print("Left ground, transitioning to FallingState")
		transition_to("Falling")

func exit() -> void:
	print("Exited GroundedState")
	# Resetear configuraciones específicas del estado grounded
	if player:
		player.camera_bob_intensity = 0.05
