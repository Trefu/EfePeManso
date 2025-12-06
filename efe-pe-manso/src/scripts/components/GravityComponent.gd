extends Node
class_name GravityComponent

var player: CharacterBody3D

func _ready() -> void:
	player = get_parent()

func handle_gravity(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
