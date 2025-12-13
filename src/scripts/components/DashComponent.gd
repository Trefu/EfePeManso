extends Node
class_name DashComponent

const DASH_DURATION: float = 0.3
const DASH_SPEED: float = 40.0

var isDashing: bool = false
var dashTimeRemaining: float = 0.0
var dashDirection: Vector3 = Vector3.ZERO
var player: CharacterBody3D
var head: Node3D

func _ready() -> void:
	player = get_parent()
	head = player.get_node("%head")
func handle_dash(delta: float) -> void:
	var dash_input = Input.is_action_just_pressed("dash")

	if dash_input and not isDashing:
		start_dash()
	
	if isDashing:
		update_dash(delta)

func start_dash() -> void:
	isDashing = true
	dashTimeRemaining = DASH_DURATION
	#directional dash, to the head look direction
	dashDirection = -head.global_transform.basis.z
	dashDirection = dashDirection.normalized()

	player.last_jump_time = player.JUMP_COOLDOWN

func update_dash(delta: float) -> void:
	dashTimeRemaining -= delta
	if dashTimeRemaining <= 0:
		isDashing = false
	else:
		if player.velocity.y >= player.JUMP_VELOCITY * 0.9:
			player.velocity.x = dashDirection.x * DASH_SPEED
			player.velocity.z = dashDirection.z * DASH_SPEED
		else:
			player.velocity = dashDirection * DASH_SPEED
