extends CharacterBody3D
class_name Player

@onready var state_machine: StateMachine = $StateMachine
@export var lerp_speed: float = 8.0

const CHARACTER_DEFAULT_SPEED: float = 7.0
var character_speed := 0.0
var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass

func get_direction(delta: float) -> Vector3:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = direction.lerp(
		(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),
		delta * lerp_speed
	)
	return direction

func apply_movement(movement_direction: Vector3) -> void:
	if movement_direction.length() > 0.1:
		velocity.x = movement_direction.x * character_speed
		velocity.z = movement_direction.z * character_speed
	else:
		velocity.x = move_toward(velocity.x, 0, character_speed)
		velocity.z = move_toward(velocity.z, 0, character_speed)
