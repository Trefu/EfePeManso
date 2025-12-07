extends Node
class_name AnimationComponent

@export var animation_tree: AnimationTree
@export var blend_space_path: String = "parameters/Strafe/blend_position"

var character: CharacterBody3D

func _ready() -> void:
	character = get_parent() as CharacterBody3D
	if animation_tree:
		animation_tree.active = true

func update_from_movement(velocity: Vector3, _is_on_floor: bool, _is_dashing: bool) -> void:

	if not animation_tree or not character:
		return

	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	var speed := horizontal_velocity.length()

	if speed < 0.05:
		animation_tree.set(blend_space_path, Vector2.ZERO)
		print("DEBUG - Speed too low, setting to ZERO")
		return

	var character_forward := -character.global_transform.basis.z.normalized()
	var character_right := character.global_transform.basis.x.normalized()

	var move_dir := horizontal_velocity.normalized()

	var forward_amount := move_dir.dot(character_forward)
	var right_amount := move_dir.dot(character_right)

	var blend_position := Vector2(right_amount, forward_amount)

	animation_tree.set(blend_space_path, blend_position)
