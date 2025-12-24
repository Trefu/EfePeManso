extends State

const GRAVITY_MULTIPLIER: float = 2.8
const JUMP_VELOCITY: float = 14.0
const COYOTE_TIME_MAX: float = 0.1

var coyote_time: float = 0.0
var air_jumps_used: int = 0
const MAX_AIR_JUMPS: int = 1

func enter() -> void:
	print("Entered FallingState (air jumps used: ", air_jumps_used, ")")
	# Start coyote time when entering from grounded
	var prev_state = state_machine.get_current_state_name() if state_machine else ""
	if prev_state == "Grounded":
		coyote_time = COYOTE_TIME_MAX
		print("Coyote time activated: ", COYOTE_TIME_MAX)
	else:
		coyote_time = 0.0

func physics_update(delta: float) -> void:
	if not player:
		push_error("FallingState: player reference is null!")
		return
	
	# Update coyote time
	coyote_time -= delta
	
	# Apply gravity (sin lerp aquí)
	player.velocity += player.get_gravity() * GRAVITY_MULTIPLIER * delta
	
	# El movimiento ahora lo maneja el Player con smoothing
	
	# Check for jump input
	if Input.is_action_just_pressed("jump"):
		if coyote_time > 0:
			print("Coyote time jump!")
			transition_to("Jumping")
		elif air_jumps_used < MAX_AIR_JUMPS:
			print("Air jump from FallingState! (", air_jumps_used + 1, "/", MAX_AIR_JUMPS, ")")
			player.velocity.y = JUMP_VELOCITY
			air_jumps_used += 1
	
	if player.is_on_floor():
		print("Landed, transitioning to Grounded")
		air_jumps_used = 0
		transition_to("Grounded")

func exit() -> void:
	print("Exited FallingState")
