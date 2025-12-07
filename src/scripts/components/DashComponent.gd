extends Node
class_name DashComponent

const DASH_DURATION: float = 0.3
const DASH_SPEED: float = 15.0

var isDashing: bool = false
var dashTimeRemaining: float = 0.0
var dashDirection: Vector3 = Vector3.ZERO
var player: CharacterBody3D

func _ready() -> void:
	player = get_parent()

func handle_dash(delta: float) -> void:
	var dash_input = Input.is_action_just_pressed("dash")

	if dash_input and not isDashing:
		start_dash()
	
	if isDashing:
		update_dash(delta)

func start_dash() -> void:
	isDashing = true
	dashTimeRemaining = DASH_DURATION
	# Dash en la dirección de la cámara
	dashDirection = -player.global_transform.basis.z
	dashDirection.y = 0
	dashDirection = dashDirection.normalized()

func update_dash(delta: float) -> void:
	dashTimeRemaining -= delta
	if dashTimeRemaining <= 0:
		isDashing = false
	else:
		player.velocity.x = dashDirection.x * DASH_SPEED
		player.velocity.z = dashDirection.z * DASH_SPEED
