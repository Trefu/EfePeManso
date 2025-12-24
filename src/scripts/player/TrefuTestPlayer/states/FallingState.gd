extends State

const JUMP_VELOCITY: float = 14.0
const GRAVITY_MULTIPLIER: float = 2.8

var air_jumps_used: int = 0
const MAX_AIR_JUMPS: int = 1

func enter() -> void:
	print("Entered JumpingState (air jumps used: ", air_jumps_used, ")")
	
	# Solo aplicar velocidad de salto si NO es un air jump
	if player and air_jumps_used == 0:
		player.velocity.y = JUMP_VELOCITY
		print("Applied jump velocity: ", JUMP_VELOCITY)

func physics_update(delta: float) -> void:
	if not player:
		push_error("JumpingState: player reference is null!")
		return
	
	# Apply gravity
	player.velocity += player.get_gravity() * GRAVITY_MULTIPLIER * delta
	
	# El movimiento suavizado lo maneja el Player
	
	# Check for air jump
	if Input.is_action_just_pressed("jump") and air_jumps_used < MAX_AIR_JUMPS:
		print("Air jump from JumpingState! (", air_jumps_used + 1, "/", MAX_AIR_JUMPS, ")")
		player.velocity.y = JUMP_VELOCITY
		air_jumps_used += 1
	
	# Transición a Grounded
	if player.is_on_floor():
		print("Landed, transitioning to Grounded")
		air_jumps_used = 0
		transition_to("Grounded")

func exit() -> void:
	print("Exited JumpingState")
