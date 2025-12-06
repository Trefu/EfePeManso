extends Node
class_name GravityComponent

var character: CharacterBody3D

func _ready():
	character = get_parent()

func handle_gravity(delta: float) -> void:
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
