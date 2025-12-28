extends CharacterBody3D
class_name Player

@onready var state_machine: StateMachine = $StateMachine
@onready var head: Node3D = $Head
@onready var posture_controller: PostureController = $PostureController
@export var lerp_speed: float = 12.0
const CHARACTER_DEFAULT_SPEED: float = 7.0
var current_speed := 0.0
var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	current_speed = CHARACTER_DEFAULT_SPEED
	posture_controller.setup(self)
	pass

func _physics_process(delta: float) -> void:
	posture_controller.physics_update(delta)
	pass

func get_input_direction() -> Vector3:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	if input_dir == Vector2.ZERO:
		return Vector3.ZERO

	return (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func apply_movement(_delta: float) -> void:
	var target_velocity := direction * current_speed

	var accel := 20.0
	var decel := 20.0

	if direction != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, target_velocity.x, accel * _delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, accel * _delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, decel * _delta)
		velocity.z = move_toward(velocity.z, 0.0, decel * _delta)
