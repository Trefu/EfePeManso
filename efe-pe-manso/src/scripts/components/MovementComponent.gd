extends Node
class_name MovementComponent

@export var current_speed: float = 5.0
@export var lerp_speed: float = 10.0

var direction: Vector3 = Vector3.ZERO
var character: CharacterBody3D

func _ready():
	character = get_parent()

func handle_movement(_delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (character.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), _delta * lerp_speed)
	
	if direction:
		character.velocity.x = direction.x * current_speed
		character.velocity.z = direction.z * current_speed
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, current_speed)
		character.velocity.z = move_toward(character.velocity.z, 0, current_speed)
