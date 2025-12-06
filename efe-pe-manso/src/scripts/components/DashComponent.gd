extends Node
class_name DashComponent

@export var dash_speed: float = 20.0
@export var dash_duration: float = 0.2

var is_dashing: bool = false
var dash_time_remaining: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO

var character: CharacterBody3D

func _ready():
	character = get_parent()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("sprint") and not is_dashing:
		start_dash()
	
	if is_dashing:
		update_dash(delta)

func start_dash() -> void:
	is_dashing = true
	dash_time_remaining = dash_duration
	# Dash en la dirección de la cámara
	dash_direction = -character.global_transform.basis.z
	dash_direction.y = 0
	dash_direction = dash_direction.normalized()

func update_dash(delta: float) -> void:
	dash_time_remaining -= delta
	if dash_time_remaining <= 0:
		is_dashing = false
	else:
		character.velocity.x = dash_direction.x * dash_speed
		character.velocity.z = dash_direction.z * dash_speed
		character.move_and_slide()

func is_active() -> bool:
	return is_dashing
