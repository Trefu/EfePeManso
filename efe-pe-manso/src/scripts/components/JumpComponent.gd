extends Node
class_name JumpComponent

const jump_velocity: float = 4.5
var character: CharacterBody3D

func _ready():
	character = get_parent()

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and character.is_on_floor():
		character.velocity.y = jump_velocity
